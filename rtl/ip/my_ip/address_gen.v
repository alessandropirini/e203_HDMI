module address_gen( 
    input             clk,
    input             reset,
    input      [31:0] cpu_data, //data coming from the cpu HDMI_io_pad_out icb
    output reg [14:0] addr_in,  //address for writing into the dpram
    output reg [15:0] wdata     //data to write in the dpram (cpu_data[15:0])
);

localparam [31:0] INIT_VALUE           = 32'h02345678;
localparam        FLAG_STARTUP_DELETE = 31;
localparam        FLAG_BACKSPACE      = 30;
localparam        FLAG_ENTER          = 29;
localparam        FLAG_CHAR_POS       = 28;
localparam        FLAG_TERMINAL       = 27;
localparam [14:0] CHAR_ROW_STRIDE     = 15'd16;
localparam [14:0] DISPLAY_COLS        = 15'd40;

reg [14:0] cnt;
reg        hold_next_zero_row;
reg [14:0] initial_pos;
reg [15:0] previous_value;
reg [15:0] stable_value;

always @ (posedge clk or posedge reset) begin
    if (reset) begin
        cnt <= 15'b0;
        hold_next_zero_row <= 1'b0;
        initial_pos <= 15'b0;
        previous_value <= 15'b0;
        stable_value <= 15'b0;
    end

    else if (previous_value != cpu_data[31:16]) begin
        previous_value <= cpu_data[31:16];

        if (cpu_data[31:16] == 16'h0000 && hold_next_zero_row == 1'b0) begin
            cnt <= cnt + 1'b1;
        end
        else if (cpu_data[31:16] == 16'h0000 && hold_next_zero_row == 1'b1) begin
            cnt <= cnt;
            hold_next_zero_row <= 1'b0;
        end

        else if (cpu_data[FLAG_CHAR_POS]) begin
            cnt <= cpu_data[14:0] - 1'b1;
            initial_pos <= cpu_data[14:0] - 1'b1;
            hold_next_zero_row <= 1'b0; //minus one because the next row-zero write increments cnt
        end
      
        else if (cpu_data[FLAG_TERMINAL]) begin
            cnt <= 15'b0; //if flag_terminal is asserted we go back to the first matrix
        end

        else if (cpu_data[FLAG_STARTUP_DELETE]) begin
            cnt <= initial_pos + 1'b1; //add 1 because in the initial pos there is nothing
        end
  
        else if (cpu_data[FLAG_BACKSPACE]) begin
            cnt <= cnt;
            hold_next_zero_row <= 1'b1;
        end //if delete flag is asserted the address block remains the same, it doesn't increment

        else if (cpu_data[FLAG_ENTER]) begin
            cnt <= cnt + (DISPLAY_COLS - (cnt % DISPLAY_COLS) - 1'b1); //move to the end of the current character row
        end
    end

    else if (stable_value != previous_value) begin   //stable state needed for right address generation
        stable_value <= previous_value; 
      
        if (cpu_data != INIT_VALUE) begin   //different from the initialization value of our internal register of icb_bus_HDMI.v
      
            addr_in <= ((cnt * CHAR_ROW_STRIDE) + cpu_data[19:16]);
            if (cpu_data[FLAG_CHAR_POS] == 0) begin
                wdata <= cpu_data[15:0];
            end
        end
    end
end 

endmodule
