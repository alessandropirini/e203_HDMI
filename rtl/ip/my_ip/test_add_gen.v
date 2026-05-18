`timescale 1ns/10ps

module top_testbench_comm (

);
    reg clk = 1;
    reg reset = 0;
    wire [14:0] address; 
    reg [31:0] pad_out; 
    wire [14:0] addr_in; 
    wire [15:0] wdata; 
    wire [14:0]cnt; 
    wire [14:0]cnt_backup; 

   /* wire Hsync;
    wire Vsync;
    wire [7:0]Red;
    wire [7:0]Green; 
    wire [7:0]Blue ;
    wire [11:0]H_cnt; 
    wire [11:0]V_cnt; 
    wire [7:0]color_cnt_1; 
    wire [3:0] color_cnt_2; 
    */

    address_gen dut (
        .clk(clk),
        .reset(reset),  
        .cpu_data(pad_out),
        .addr_in(addr_in), 
        .wdata(wdata)
    );
    
    /*assign H_cnt = dut.H_cnt; 
    assign V_cnt = dut.V_cnt; 
    assign color_cnt_1=dut.color_cnt_1; 
    assign color_cnt_2=dut.color_cnt_2; 
    //assign V_flag = dut.V_flag; 
    */

    assign cnt = dut.cnt; 

    initial begin
        $dumpfile("waveout.vcd");
        $dumpvars(0, top_testbench_comm);
    end
    
    always begin 
        #0.5 clk = ~clk;
    end

    initial begin 
            pad_out = 32'h02345678;

         #10 pad_out = 32'h100000AF;
         #10 pad_out = 32'h00000000; //first letter
         #10 pad_out = 32'h00010001;
         #10 pad_out = 32'h00020002;
         #10 pad_out = 32'h00030003;
         #10 pad_out = 32'h00040004;
         #10 pad_out = 32'h00050005;
         #10 pad_out = 32'h00060006;
         #10 pad_out = 32'h00070007;
         #10 pad_out = 32'h00080008;
         #10 pad_out = 32'h00090009;
         #10 pad_out = 32'h000A000A;
         #10 pad_out = 32'h000B000B;
         #10 pad_out = 32'h000C000C;
         #10 pad_out = 32'h000D000D;
         #10 pad_out = 32'h000E000E;
         #10 pad_out = 32'h000F000F;
         #10 pad_out = 32'h80000000; //delete startup text
         #10 pad_out = 32'h00010000;
         #10 pad_out = 32'h00020000;
         #10 pad_out = 32'h00030000;
         #10 pad_out = 32'h00040000;
         #10 pad_out = 32'h00050000;
         #10 pad_out = 32'h00060000;
         #10 pad_out = 32'h00070000;
         #10 pad_out = 32'h00080000;
         #10 pad_out = 32'h00090000;
         #10 pad_out = 32'h000A0000;
         #10 pad_out = 32'h000B0000;
         #10 pad_out = 32'h000C0000;
         #10 pad_out = 32'h000D0000;
         #10 pad_out = 32'h000E0000;
         #10 pad_out = 32'h000F0000;
         #10 pad_out = 32'h08000000; //second letter
         #10 pad_out = 32'h00010001;
         #10 pad_out = 32'h00020002;
         #10 pad_out = 32'h00030003;
         #10 pad_out = 32'h00040004;
         #10 pad_out = 32'h00050005;
         #10 pad_out = 32'h00060006;
         #10 pad_out = 32'h00070007;
         #10 pad_out = 32'h00080008;
         #10 pad_out = 32'h00090009;
         #10 pad_out = 32'h000A000A;
         #10 pad_out = 32'h000B000B;
         #10 pad_out = 32'h000C000C;
         #10 pad_out = 32'h000D000D;
         #10 pad_out = 32'h000E000E;
         #10 pad_out = 32'h000F000F;
         #10 pad_out = 32'h40000000; //delete key
         #10 pad_out = 32'h00010000;
         #10 pad_out = 32'h00020000;
         #10 pad_out = 32'h00030000;
         #10 pad_out = 32'h00040000;
         #10 pad_out = 32'h00050000;
         #10 pad_out = 32'h00060000;
         #10 pad_out = 32'h00070000;
         #10 pad_out = 32'h00080000;
         #10 pad_out = 32'h00090000;
         #10 pad_out = 32'h000A0000;
         #10 pad_out = 32'h000B0000;
         #10 pad_out = 32'h000C0000;
         #10 pad_out = 32'h000D0000;
         #10 pad_out = 32'h000E0000;
         #10 pad_out = 32'h000F0000;
         #10 pad_out = 32'h00000000; //new letter
         #10 pad_out = 32'h00010001;
         #10 pad_out = 32'h00020002;
         #10 pad_out = 32'h00030003;
         #10 pad_out = 32'h00040004;
         #10 pad_out = 32'h00050005;
         #10 pad_out = 32'h00060006;
         #10 pad_out = 32'h00070007;
         #10 pad_out = 32'h00080008;
         #10 pad_out = 32'h00090009;
         #10 pad_out = 32'h000A000A;
         #10 pad_out = 32'h000B000B;
         #10 pad_out = 32'h000C000C;
         #10 pad_out = 32'h000D000D;
         #10 pad_out = 32'h000E000E;
         #10 pad_out = 32'h000F000F;
         #10 pad_out = 32'h20000000; //enter key
         #10 pad_out = 32'h00000000; //new letter
         #10 pad_out = 32'h00010001;
         #10 pad_out = 32'h00020002;
         #10 pad_out = 32'h00030003;
         #10 pad_out = 32'h00040004;
         #10 pad_out = 32'h00050005;
         #10 pad_out = 32'h00060006;
         #10 pad_out = 32'h00070007;
         #10 pad_out = 32'h00080008;
         #10 pad_out = 32'h00090009;
         #10 pad_out = 32'h000A000A;
         #10 pad_out = 32'h000B000B;
         #10 pad_out = 32'h000C000C;
         #10 pad_out = 32'h000D000D;
         #10 pad_out = 32'h000E000E;
         #10 pad_out = 32'h000F000F;

    end

    initial begin
        #1 reset = 1; 
        #1 reset = 0;
        #10000 $finish;
    end

endmodule