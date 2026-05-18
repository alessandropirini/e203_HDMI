`timescale 1ns/10ps

module top_testbench (

);
    reg clk = 1;
    reg reset = 0;
    reg [15:0] data_in;
    wire [14:0] address; 
    wire Hsync;
    wire Vsync;
    wire [7:0]Red;
    wire [7:0]Green; 
    wire [7:0]Blue ;
    wire [11:0]H_cnt; 
    wire [11:0]V_cnt; 
    wire [7:0]color_cnt_1; 
    wire [3:0] color_cnt_2; 

    HDMI_module dut (
        .reset(reset), 
        .clk(clk), 
        .data_in(data_in), 
        .Hsync(Hsync), 
        .address(address),
        .Vsync(Vsync), 
        .Red(Red), 
        .Green(Green), 
        .Blue(Blue))
        ;
    
    
    assign H_cnt = dut.H_cnt; 
    assign V_cnt = dut.V_cnt; 
    assign color_cnt_1=dut.color_cnt_1; 
    assign color_cnt_2=dut.color_cnt_2; 
    //assign V_flag = dut.V_flag; 

    initial begin
        $dumpfile("waveout.vcd");
        $dumpvars(0, top_testbench);
    end
    
    always begin 
        #0.5 clk = ~clk;
    end

    initial begin
        #1 reset = 1; data_in = 16'h0000;
        #1 reset = 0;
        #500000 $finish;
    end

endmodule