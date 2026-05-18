/**
*/

//=====================================================================
//
// Designer   : Alessandro Pirini and Tommaso calzolari
//
// Description:
//  Example for an e203 icb peripheral
//
// ====================================================================

module icb_bus_HDMI (
    input                   clk,     //system wide inputs 
    input                   rst_n,
                                  //command (master)
    input                   HDMI_icb_cmd_valid,  //means a new read/write session is starting when valid=1
                                              // each for every peripheral module 
    output                  HDMI_icb_cmd_ready,  // means the master is ready to start the session
    input  [32-1:0]         HDMI_icb_cmd_addr,   //address: this bus signal is common to all peripherals; 
                                              //we usually need to check just the lower bits for right address
    input                   HDMI_icb_cmd_read,   //this is to assert if the session is READ or WRITE session
    input  [32-1:0]         HDMI_icb_cmd_wdata,  //this is the data to write in case it is a WRITE session
                                              //response (slave)
    output                  HDMI_icb_rsp_valid,  //this means the value in icb_rsp_rdata is ready to be read by 
                                              //the master. When WRITE operation it means it has been successful
    input                   HDMI_icb_rsp_ready,  //slave is ready for data transfer
    output [32-1:0]         HDMI_icb_rsp_rdata,  //Data the master reads from the slave      
    output                  HDMI_io_interrupts_0_0,                
    output [32-1:0]         HDMI_io_pad_out

);

    //define a 32-bit register for operating your module
    reg [32-1:0] HDMI_control_reg; //this will be the register which is operated by the HDMI module (slave)
                                   // in the operation of the module (ASCII characters info) 
                                   //the 2MSB for mode operation (color strip/ASCII/terminal), 24 LSB for 
                                   //ASCII character
    
    reg [32-1:0] icb_data_out; 
    reg          icb_rsp_valid;    // this will be asserted in the operations and will determine 
                                   //i_icb_valid together with ready signal

    wire reset;   
    wire clock;
    //read enable signal for register reading, this signal is asserted when proper address issued.
    wire HDMI_control_reg_rd_en;

    //write enable signal for register writing, this signal is asserted when proper address issued.
    wire HDMI_control_reg_wr_en;


    assign reset = ~rst_n;
    assign clock = clk;
    
    //READ OPERATION:judge if the register is selected for read. 3'h4 is the address of the register in this example. 
    assign HDMI_control_reg_rd_en = HDMI_icb_cmd_valid && HDMI_icb_cmd_read && (HDMI_icb_cmd_addr[31:0] == 32'h10014004);
    //read operation can start if: master is Valid & read operation is asserted & the address is right. 
    // we can check the last 3 bits for the address. 

    //wRITE operation: 
    assign HDMI_control_reg_wr_en = HDMI_icb_cmd_valid && (~HDMI_icb_cmd_read) && (HDMI_icb_cmd_addr[31:0] == 32'h10014004);
    //can start only if: master is valid & Write operation is asserted &  address is right. 


    //no wait state, so direct connect valid to ready signal. Master is ready when valid is asserted
    assign HDMI_icb_cmd_ready = HDMI_icb_cmd_valid;

    //the response is valid if the slave is ready and the operation was succesful. 
    assign HDMI_icb_rsp_valid = HDMI_icb_rsp_ready && icb_rsp_valid;



    assign HDMI_icb_rsp_rdata = icb_data_out;

    //connect io pad to register
    assign HDMI_io_pad_out = HDMI_control_reg;

    //assign HDMI_control_out = HDMI_control_reg; 

    // Read and write operations in the always block 

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            HDMI_control_reg <= 32'h02345678;       //value of the register to operate the module
            icb_rsp_valid <= 1'b0;              //Slave is not valid
        end 
        else begin
            if (HDMI_control_reg_rd_en) begin        //if all conditions for read operation are respected
                icb_data_out <= HDMI_control_reg;   //the reg valued is passed to the data output (also rdata of slave)
                icb_rsp_valid <= 1'b1;          //op is succesful and data can be read by the master
            end
            else begin
                icb_rsp_valid <= 1'b0;          //
            end

            if(HDMI_control_reg_wr_en) begin        //if all conditions are met for write operation, then wdata 
                                                    //is written on the register and slave becomes valid
                HDMI_control_reg <= HDMI_icb_cmd_wdata;
                icb_rsp_valid <= 1'b1;
            end
        end
    end

endmodule

//so if all conditions for read operation are met, master can read data from the specified register.
//If all conditions for write operation are met, master can write data on the specified register. 

//response valid signals are acknowledgements that the operation was succesful. 

//When these conditions are not met, then all the always block is not triggered by any if statement and the 
//system maintains its state. That is io_value, rdata remain the same


