module HDMI_module (
    //input rst_n, 
    input          reset, 
    input          clk,     //pixel_clk is 25,125MHz while CPU is 27MHz so we added more porch space to achieve right clk on display 
    input  [15:0]  data_in, //input che arriva dalla DPRAM. 
    output [14:0]  address,
    output         Hsync, 
    output         Vsync,
    output [7:0]   Red,
    output [7:0]   Green, 
    output [7:0]   Blue,
    output         de,
    output         mode_flag
);      
            //timing parameters
localparam  HSYNC = 12'd40;
localparam  VSYNC = 12'd5;
//localparam  H_front_porch = 12'd16 + 12'd9; 
//localparam  V_front_porch = 12'd10;
localparam  H_back_porch = 12'd220;
localparam  V_back_porch = 12'd20;
localparam  H_total_time = 12'd1650;
localparam  V_total_time = 12'd750;
localparam  H_res = 12'd1280; 
localparam  V_res = 12'd720; 

            //color parameters 
localparam	WHITE	= {8'd255 , 8'd255 , 8'd255 };//{B,G,R}
localparam	YELLOW	= {8'd0   , 8'd255 , 8'd255 };
localparam	CYAN	= {8'd255 , 8'd255 , 8'd0   };
localparam	GREEN	= {8'd0   , 8'd255 , 8'd0   };
localparam	MAGENTA	= {8'd255 , 8'd0   , 8'd255 };
localparam	RED		= {8'd0   , 8'd0   , 8'd255 };
localparam	BLUE	= {8'd255 , 8'd0   , 8'd0   };
localparam	BLACK	= {8'd0   , 8'd0   , 8'd0   };
  
//....................................
reg  [11:0]     H_cnt; 
reg  [11:0]     V_cnt; 
reg  [23:0]     Data_int;  //[23:16] blue, [15:8] green, [7:0]red. 
reg  [23:0]     color_bar; //[23:16] blue, [15:8] green, [7:0]red.
reg  [7:0]      color_cnt_1; 
reg  [3:0]      color_cnt_2; 
reg  [32:0]     cnt_mode; 
reg             mode_flag; 
reg  [5:0]      cnt_bits; 
reg  [5:0]      cnt_regs; 
reg  [5:0]      cnt_COLS_DISP; 
reg  [5:0]      cnt_ROWS_DISP; 
reg  [5:0]      cnt_bits_de; 
reg             clk_int; 
reg             flag_h_res; 
reg             five_sec; 

always @(posedge clk, posedge reset)begin   //to double the clock period 
    if (reset) begin
        clk_int<=1'b0; 
    end
    else  clk_int <= ~clk_int; 

end

wire            pixel; 
reg [23:0]     monochr; 

// PIXEL POSITIONING-------------------------------------------------------------------------------------
always @ (posedge clk or posedge reset) begin
    if (reset) begin
        H_cnt <= 12'b0; 
        V_cnt <= 12'b0;
    end
    else begin
        if (H_cnt < H_total_time - 1) begin   //increasing horizontal and vertical counters 
            H_cnt <= H_cnt + 1'b1;
        end
        else begin
            H_cnt <= 12'b0;
            if (V_cnt < V_total_time - 1) begin
                V_cnt <= V_cnt + 1'b1;
            end
            else begin
                V_cnt <= 12'b0;
            end
        end
    end
end

//COLOR STRIP GENERATION------------------------------------------------------------------------------
always @ (posedge clk or posedge reset) begin
    if (reset) begin 
        color_cnt_1 <= 0;
        color_cnt_2 <= 0;
    end

    else if ((H_cnt == (HSYNC + H_back_porch - 1'b1)) && (V_cnt >= (VSYNC + V_back_porch))&&(V_cnt < (VSYNC+V_back_porch+V_res-1'b1))) color_cnt_2 <= 1'b1;

    else if ((H_cnt > HSYNC + H_back_porch - 1'b1) && (H_cnt < H_res + H_back_porch + HSYNC ) && 
                (V_cnt > VSYNC + V_back_porch - 1'b1) && (V_cnt < V_res + V_back_porch +VSYNC)) begin
        
        color_cnt_1 <= color_cnt_1 + 1'b1; 
        if (color_cnt_1 == ((H_res/8) - 1'b1)) begin
            color_cnt_2 <= color_cnt_2 + 1'b1;
            color_cnt_1 <= 8'b0;
        end
        if (color_cnt_2 == 4'd9) color_cnt_2 <= 4'b0; 
    end
end

always @ (posedge clk or posedge reset) begin
    if (reset) color_bar <= 24'b0;

    else case (color_cnt_2)
            4'd1	:	color_bar	<=	WHITE  ;
            4'd2	:	color_bar	<=	YELLOW ;
            4'd3	:	color_bar	<=	CYAN   ;
            4'd4	:	color_bar	<=	GREEN  ;
            4'd5	:	color_bar	<=	MAGENTA;
            4'd6	:	color_bar	<=	RED    ;
            4'd7	:	color_bar	<=	BLUE   ;
            4'd8	:	color_bar	<=	BLACK  ;
            default	:	color_bar	<=	BLACK  ;  
        endcase
end

//CHARATOR DISPLAY---------------------------------------------------------------------------------------


// make a delayed version of these counters in order to have address change one bit before, 
// but use cnt_bits to access the DPRAM data.
// done to make up for the one clock delay of the RAM
// clk_int is used because of higher resolution implementation
always @ (posedge clk_int, posedge reset) begin 
    if (reset) begin
        cnt_bits <= 6'b0; 
        cnt_regs <= 6'b0; 
        cnt_COLS_DISP <= 6'b0; 
        cnt_ROWS_DISP <= 6'b0; 
        flag_h_res <= 1'b0; 
    end
    else if ((H_cnt > HSYNC + H_back_porch -1'b1) && (H_cnt <= H_res + H_back_porch + HSYNC-1'b1)&& 
                (V_cnt > VSYNC + V_back_porch-1'b1) && (V_cnt <= V_res + V_back_porch +VSYNC - 6'd17)) begin
        if (cnt_bits < 15 )begin
        cnt_bits <= cnt_bits + 1'b1;
        end

        else if(cnt_bits == 15)begin
            cnt_bits <= 6'b0; 
            if (cnt_COLS_DISP < 39)cnt_COLS_DISP <= cnt_COLS_DISP +1'b1; 
            else if(cnt_COLS_DISP == 39)begin
                cnt_COLS_DISP <= 6'b0;
                flag_h_res <= 1'b1; 
                if(cnt_regs <15 && flag_h_res == 1'b1)begin 
                    cnt_regs <= cnt_regs +1'b1;
                    flag_h_res <= 1'b0;  
                end
                    else if (cnt_regs == 15 && flag_h_res == 1'b1)begin
                        cnt_regs <= 6'b0; 
                        flag_h_res <= 1'b0; 
                        if(cnt_ROWS_DISP < 21)cnt_ROWS_DISP <= cnt_ROWS_DISP +1'b1; 
                            else if(cnt_ROWS_DISP == 21) cnt_ROWS_DISP <= 6'b0; 
                    end
            end
        end
    end 
end 
//anticipated version to make address change before than cnt_bits and solve the delay between address generation and DPRAM
always @ (posedge clk_int, posedge reset) begin 
    if (reset) begin
        cnt_bits_de <= 6'b0; 
    end
        else cnt_bits_de <= cnt_bits; 
 end
        

assign address = (cnt_ROWS_DISP*40 + cnt_COLS_DISP)*16 + cnt_regs;  //address generation for the DPRAM
assign pixel = data_in[15-cnt_bits_de]; 

always @ (*) begin
    case (pixel) 
    1'b0: monochr = BLACK; 
    1'b1: monochr = WHITE; 
    endcase 
end 

//MODE FLAG ---------------------------------------------------------------------------------------------
//done to switch between the color strip and character display
always @ (posedge clk or posedge reset) begin
    if(reset) begin
        cnt_mode <= 28'b0; 
        mode_flag <= 1'b0; 
    end

    else if (cnt_mode < 449999990) begin         
        cnt_mode <= cnt_mode + 1'b1; 
        end
        else begin 
            mode_flag <= 1'b1; 
            cnt_mode <=1'b0;
        end
end
 

//OUTPUTS RGB
assign Hsync = (H_cnt < HSYNC) ? 1'b1: 1'b0; 
assign Vsync = (V_cnt < VSYNC) ? 1'b1: 1'b0; 

always @ (*) begin
    case (mode_flag)  
    1'b1: begin
            if (de) Data_int = monochr; 
            else Data_int = 24'b0; 
    end
    default: Data_int = color_bar ; 
    endcase 
end


//final outputs 

assign de = (H_cnt > HSYNC + H_back_porch -1'b1) && (H_cnt <= H_res + H_back_porch + HSYNC-1'b1) && 
            (V_cnt > VSYNC + V_back_porch -1'b1) && (V_cnt <= V_res + V_back_porch +VSYNC -1'b1 ) ? 1'b1 : 1'b0; 
assign Red = Data_int[7:0];
assign Green = Data_int [15:8];
assign Blue = Data_int [23:16]; 








endmodule
