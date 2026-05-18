`include "HDMI.v"
`include "address_gen.v"
`include "gowin_dpb.v"
`include "prim_sim1.v"

`timescale 1ns/10ps

module testbench_comm (

);
    reg clk = 1;
    reg reset = 0;
    reg [31:0] pad_out;
    wire Hsync;
    wire Vsync;
    wire [11:0] H_cnt; 
    wire [11:0] V_cnt; 
    wire [7:0] Red;
    wire [7:0] Green; 
    wire [7:0] Blue ;
    wire [14:0] addr_in_b; 
    wire [14:0] addr_in_a; 
    wire [15:0] dpout_b; 
    wire [15:0] dpin_a; 


    wire  [5:0]      cnt_bits; 
    wire  [5:0]      cnt_regs; 
    wire  [5:0]      cnt_COLS_DISP; 
    wire  [5:0]      cnt_ROWS_DISP; 



    HDMI_module dut1(
        .reset(reset), 
        .clk(clk), 
        .data_in(dpout_b), 
        .address(addr_in_b),
        .Hsync(Hsync), 
        .Vsync(Vsync), 
        .Red(Red), 
        .Green(Green), 
        .Blue(Blue)
        );

    
    Gowin_DPB  dut2(
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

    
    address_gen dut3(
        .clk(clk),
        .reset(reset), 
        .cpu_data(pad_out), 
        .addr_in(addr_in_a), 
        .wdata(dpin_a)
); 
   
    assign cnt_bits=dut1.cnt_bits;
    assign cnt_regs=dut1.cnt_regs;
    assign cnt_COLS_DISP=dut1.cnt_COLS_DISP;
    assign cnt_ROWS_DISP=dut1.cnt_ROWS_DISP;


    initial begin
        $dumpfile("waveout.vcd");
        $dumpvars(0, testbench_comm);
    end
    
    always begin 
        #0.5 clk = ~clk;
    end

      initial begin 
              pad_out = 32'h00000000; 
         #3.3 pad_out = 32'h00010001;
         #3   pad_out = 32'h00020002;
         #3   pad_out = 32'h00030003;
         #3   pad_out = 32'h00040004;
         #3   pad_out = 32'h00050005;
         #3   pad_out = 32'h00060006;
         #3   pad_out = 32'h00070007;
         #3   pad_out = 32'h00080008;
         #3   pad_out = 32'h00090009;
         #3   pad_out = 32'h000A800A;
         #3   pad_out = 32'h000B000B;
         #3   pad_out = 32'h000C000C;
         #3   pad_out = 32'h000D000D;
         #3   pad_out = 32'h000E000E;
         #3   pad_out = 32'h000F000F;
         #3   pad_out = 32'h00000000;
         #3   pad_out = 32'h00010001;
         #3   pad_out = 32'h00020002;
         #3   pad_out = 32'h00030003;
         #3   pad_out = 32'h00040004;
    end

    initial begin
        #1 reset = 1; 
        #1 reset = 0;
        #500000 $finish;
    end

endmodule
