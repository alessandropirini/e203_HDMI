
module main(
    input          clk, 
    input          rst_n, 
    input  [31:0]  pad_out,
    output         O_tmds_clk_p_o,
    output         O_tmds_clk_n_o, 
    output [2:0]   O_tmds_data_p_o,
    output [2:0]   O_tmds_data_n_o, 
    output         mode_flag 
);

//A side is the address generator side and B side is the HDMI module side

wire [15:0] dpout_b; 
wire [15:0] dpin_a; 
wire [14:0] addr_in_a; 
wire [14:0] addr_in_b;   
wire        Hsync;
wire        Vsync;
wire [7:0]  Red;
wire [7:0]  Green;
wire [7:0]  Blue;
wire        de;

wire serial_clk;
wire pll_lock;

wire hdmi4_rst_n;

wire pix_clk;


wire        reset; 

assign reset = ~rst_n; 


address_gen addr_instance(
        .clk(clk),
        .reset(reset), 
        .cpu_data(pad_out), 
        .addr_in(addr_in_a), 
        .wdata(dpin_a)
); 


TMDS_rPLL u_tmds_rpll
(.clkin     (clk     ),   //input clk 
 .clkout    (serial_clk),     //output clk 
 .lock      (pll_lock  )     //output lock
);

Gowin_CLKDIV u_clkdiv(
        .clkout(pix_clk), //output clkout
        .hclkin(serial_clk), //input hclkin
        .resetn(hdmi4_rst_n), //input resetn
        .calib(1'b1) //input calib
    );

assign hdmi4_rst_n = rst_n & pll_lock;

HDMI_module hdmi_instance(
        .clk(pix_clk), 
        .reset(reset), 
        .data_in(dpout_b), 
        .address(addr_in_b), 
        .Hsync(Hsync), 
        .Vsync(Vsync), 
        .Red(Red), 
        .Green(Green), 
        .Blue(Blue), 
        .de(de), 
        .mode_flag(mode_flag)
);

DVI_TX u_dvi_tx(
	.I_rst_n(hdmi4_rst_n),
     .I_serial_clk(serial_clk),
	.I_rgb_clk(pix_clk), //input I_rgb_clk
	.I_rgb_vs(Vsync), //input I_rgb_vs
	.I_rgb_hs(Hsync), //input I_rgb_hs
	.I_rgb_de(de), //input I_rgb_de
	.I_rgb_r(Red), //input [7:0] I_rgb_r
	.I_rgb_g(Green), //input [7:0] I_rgb_g
	.I_rgb_b(Blue), //input [7:0] I_rgb_b
	.O_tmds_clk_p(O_tmds_clk_p_o), //output O_tmds_clk_p
	.O_tmds_clk_n(O_tmds_clk_n_o), //output O_tmds_clk_n
	.O_tmds_data_p(O_tmds_data_p_o), //output [2:0] O_tmds_data_p
	.O_tmds_data_n(O_tmds_data_n_o) //output [2:0] O_tmds_data_n
	);


Gowin_DPB dpram_instance(
        .douta(), 
        .doutb(dpout_b), //output [15:0] doutb
        .clka(clk), //input clka
        .ocea(), 
        .cea(1'b1), 
        .reseta(reset), //input reseta
        .wrea(1'b1), 
        .clkb(clk), //input clkb
        .oceb(), 
        .ceb(1'b1), 
        .resetb(reset), //input resetb
        .wreb(1'b0), 
        .ada(addr_in_a), //input [14:0] ada
        .dina(dpin_a), //input [15:0] dina
        .adb(addr_in_b), //input [14:0] adb
        .dinb() 
);



endmodule
