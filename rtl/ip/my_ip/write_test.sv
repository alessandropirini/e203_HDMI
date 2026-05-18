`timescale 1ns/10ps
`include "icb_bus_HDMI.v"
`include "sirv_uart_top.v"
`include "sirv_uart.v"
`include "sirv_uartrx.v"
`include "sirv_uarttx.v"
`include "sirv_queue_1.v"

module tb_write(
); 
    reg                   clk=1; 
    reg                   rst_n=1; 

    
    reg  [32-1:0]         cpu_icb_cmd_addr;   
    reg                   cpu_icb_cmd_read;   
    reg  [32-1:0]         cpu_icb_cmd_wdata; 
                                 
    reg                   HDMI_icb_cmd_valid; 
    reg                   uart_icb_cmd_valid; 
                                         
    wire                  HDMI_icb_cmd_ready;  
    wire                  uart_icb_cmd_ready;

    wire                  HDMI_icb_rsp_valid;  
    wire                  uart_icb_rsp_valid; 

    reg [31:0]            reg_value; 
                                              
    reg                   icb_rsp_ready;  //common for both 

    wire [32-1:0]         HDMI_icb_rsp_rdata;       
    wire                  HDMI_io_interrupts_0_0;                 
    wire [32-1:0]         HDMI_io_pad_out; 

    wire [32-1:0]         uart_icb_rsp_rdata;       
    wire                  uart_io_interrupts_0_0;                 
    wire                  uart_io_port_txd;
    reg                   rx_pin;
    localparam            uart_tx_period = 1000000000/115200;

icb_bus_HDMI dut1(
        .clk(clk),     //system wide inputs 
        .rst_n(rst_n),              
        .HDMI_icb_cmd_valid(HDMI_icb_cmd_valid),
        .HDMI_icb_cmd_ready(HDMI_icb_cmd_ready), 
        .HDMI_icb_cmd_addr (cpu_icb_cmd_addr),
        .HDMI_icb_cmd_read (cpu_icb_cmd_read),   //this is to assert if the session is READ or WRITE session
        .HDMI_icb_cmd_wdata(cpu_icb_cmd_wdata),  //this is the data to write in case it is a WRITE session
        .HDMI_icb_rsp_valid(HDMI_icb_rsp_valid),  //this means the value in icb_rsp_rdata is ready to be read by 
        .HDMI_icb_rsp_ready(icb_rsp_ready), 
        .HDMI_icb_rsp_rdata(HDMI_icb_rsp_rdata),  //Data the master reads from the slave      
        .HDMI_io_interrupts_0_0(HDMI_io_interrupts_0_0),                
        .HDMI_io_pad_out(HDMI_io_pad_out) 
);

sirv_uart_top dut2(
        .clk(clk),
        .rst_n(rst_n),
        .i_icb_cmd_valid(uart_icb_cmd_valid),
        .i_icb_cmd_ready(uart_icb_cmd_ready),
        .i_icb_cmd_addr(cpu_icb_cmd_addr), 
        .i_icb_cmd_read(cpu_icb_cmd_read), 
        .i_icb_cmd_wdata(cpu_icb_cmd_wdata),
        .i_icb_rsp_valid(uart_icb_rsp_valid),
        .i_icb_rsp_ready(icb_rsp_ready),
        .i_icb_rsp_rdata(uart_icb_rsp_rdata),
        .io_interrupts_0_0(uart_io_interrupts_0_0),                
        .io_port_txd(uart_io_port_txd),
        .io_port_rxd(rx_pin)
); 

always @ (posedge clk or negedge rst_n)begin
    if (rst_n==0)reg_value <=32'b0; 
    else  if (cpu_icb_cmd_addr == 32'h10013004 && cpu_icb_cmd_read == 1'b1 && uart_icb_cmd_valid == 1'b1)reg_value <= uart_icb_rsp_rdata; 
end

always @ (*)begin
    if (cpu_icb_cmd_addr == 32'h10014004 && cpu_icb_cmd_read ==1'b0 && HDMI_icb_cmd_valid == 1'b1) begin
        cpu_icb_cmd_wdata = reg_value; 
    end
    end

    initial begin
        #1 rst_n = 0; 
        #1 rst_n = 1;
    end

    always begin 
        #0.5 clk = ~clk;
    end

    initial begin
        $dumpfile("waveout.vcd");
        $dumpvars(0, tb_write);
    end


    initial begin
        
        
         // Send a character 'A' (0x41) over UART
        send_uart_byte(8'h41);
        #50000; // Wait some time

        read_uart_op();

        write_HDMI_op(); 

        // Send another character 'B' (0x42) over UART
        send_uart_byte(8'h42);
        #50000; // Wait some time

        read_uart_op();

        write_HDMI_op(); 

        // Send another character 'C' (0x43) over UART
        send_uart_byte(8'h43);
        #50000; // Wait some time

        read_uart_op();

        write_HDMI_op(); 

        #500000 $finish;
    end




    task write_HDMI_op(
        ); 
    begin 
            cpu_icb_cmd_addr = 32'h10014004; //address of HDMI_control_reg
            cpu_icb_cmd_read = 1'b0; 
            HDMI_icb_cmd_valid = 1'b0;  
            icb_rsp_ready = 1'b0; 
        #10 HDMI_icb_cmd_valid = 1'b1; 
            icb_rsp_ready = 1'b1; 
        #1  HDMI_icb_cmd_valid = 1'b0; 
        #1  icb_rsp_ready = 1'b0; 
        #10; 
    end 
    endtask 

    task read_uart_op(
    );
    begin
            cpu_icb_cmd_addr = 32'h10013004;  //uart rx register 
            uart_icb_cmd_valid = 1'b0; 
            cpu_icb_cmd_read = 1'b0;  
            icb_rsp_ready = 1'b0; 
        #10 uart_icb_cmd_valid = 1'b1; 
            cpu_icb_cmd_read = 1'b1;  
            icb_rsp_ready = 1'b1; 
        #1  uart_icb_cmd_valid = 1'b0; 
            cpu_icb_cmd_read = 1'b0; 
        #1  icb_rsp_ready = 1'b0; 
        #10;
    end    
    endtask
    
    // Task to send a byte over UART
    task send_uart_byte(
        input [7:0] data
        );
        integer i;
        begin
            // Send start bit (low)
            rx_pin = 1'b0;
            #uart_tx_period; // Baud rate = 115200, one bit period = 1/115200 = 8.68us

            // Send data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_pin = data[i];
                #uart_tx_period; // One bit period
            end

            // Send stop bit (high)
            rx_pin = 1'b1;
            #uart_tx_period; // One bit period
        end
    endtask




endmodule 