module bitmap(
    input clk, 
    input reset,
    input [14:0] address, 
    output reg [15:0] data
); 

always @ (posedge clk, posedge reset)begin 
    if (reset) data <= 16'B0; 
    else case (address)
    14'd0: data <=  16'h0000;
    14'd1: data <=  16'h0000;
    14'd2: data <=  16'h0000;
    14'd3: data <=  16'h0000;
    14'd4: data <=  16'h0CC0;
    14'd5: data <=  16'h0CC0;
    14'd6: data <=  16'h7FF0;
    14'd7: data <=  16'h1980;
    14'd8: data <=  16'h1980;
    14'd9: data <=  16'h7FF0;
    14'd10: data <=  16'h3300;
    14'd11: data <=  16'h3300;
    14'd12: data <=  16'h0000;
    14'd13: data <=  16'h0000;
    14'd14: data <=  16'h0000;
    14'd15: data <=  16'h0000;
    14'd16: data <= 16'h0000;
    14'd17: data <= 16'h0000;
    14'd18: data <= 16'h0000;
    14'd19: data <= 16'h3000;
    14'd20: data <= 16'h68C0;
    14'd21: data <= 16'h6980;
    14'd22: data <= 16'h6E00;
    14'd23: data <= 16'h0600;
    14'd24: data <= 16'h0C00;
    14'd25: data <= 16'h1800;
    14'd26: data <=16'h3000;
    14'd27: data <=16'h6700;
    14'd28: data <=16'hC680;
    14'd29: data <=16'h0180;
    14'd30: data <=16'h0000;
    14'd31: data <=16'h0000;
    default data <= 16'b0; 

    endcase
end
endmodule