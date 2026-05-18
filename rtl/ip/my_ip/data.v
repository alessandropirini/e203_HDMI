module data (
    input clk, 
    input reset, 
    output reg [31:0] data
); 

reg [4:0] counter; 
reg [9:0] counter_2;
reg [10:0]counter_3;

always @ (posedge clk, posedge reset)begin
    if (reset) begin 
        counter <= 11'b0; 
        counter_2 <= 11'b0;
        counter_3 <= 11'b0;  
    end
    else if (counter < 9 && counter_3 < 789)begin 
        counter <= counter +1'b1; 
        counter_3 <= counter_3 +1'b1; 
    end
    else if (counter == 9 && counter_3 < 789)begin
        counter_2 <= counter_2 +1'b1; 
        counter <= 11'b0; 
    end
end
always @ (posedge clk, posedge reset)begin 
    if (reset) data <= 32'b0; 
    else case (counter_2)
    11'd0: data <=  32'h00000000;
    11'd1: data <=  32'h00010000;
    11'd2: data <=  32'h00020000;
    11'd3: data <=  32'h00030000;
    11'd4: data <=  32'h00040CC0;
    11'd5: data <=  32'h00050CC0;
    11'd6: data <=  32'h00067FF0;
    11'd7: data <=  32'h00071980;
    11'd8: data <=  32'h00081980;
    11'd9: data <=  32'h00097FF0;
    11'd10: data <= 32'h000A3300;
    11'd11: data <= 32'h000B3300;
    11'd12: data <= 32'h000C0000;
    11'd13: data <= 32'h000D0000;
    11'd14: data <= 32'h000E0000;
    11'd15: data <= 32'h000F0000;

    11'd16: data <= 32'h00000000;
    11'd17: data <= 32'h00010000;
    11'd18: data <= 32'h00020000;
    11'd19: data <= 32'h00033000;
    11'd20: data <= 32'h000468C0;
    11'd21: data <= 32'h00056980;
    11'd22: data <= 32'h00066E00;
    11'd23: data <= 32'h00070600;
    11'd24: data <= 32'h00080C00;
    11'd25: data <= 32'h00091800;
    11'd26: data <= 32'h000A3000;
    11'd27: data <= 32'h000B6700;
    11'd28: data <= 32'h000CC680;
    11'd29: data <= 32'h000D0180;
    11'd30: data <= 32'h000E0000;
    11'd31: data <= 32'h000F0000;
    11'd32: data <= 32'h00000000;
    11'd33: data <= 32'h00010000;
    11'd34: data <= 32'h00020000;
    11'd35: data <= 32'h00033000;
    11'd36: data <= 32'h000468C0;
    11'd37: data <= 32'h00056980;
    11'd38: data <= 32'h00066E00;
    11'd39: data <= 32'h00070600;
    11'd40: data <= 32'h00080C00;
    11'd41: data <= 32'h00091800;
    11'd42: data <= 32'h000A3000;
    11'd43: data <= 32'h000B6700;
    11'd44: data <= 32'h000CC680;
    11'd45: data <= 32'h000D0180;
    11'd46: data <= 32'h000E0000;
    11'd47: data <= 32'h000F0000;
    11'd48: data <= 32'h00000000;
    11'd49: data <= 32'h00010000;
    11'd50: data <= 32'h00020000;
    11'd51: data <= 32'h00033000;
    11'd52: data <= 32'h000468C0;
    11'd53: data <= 32'h00056980;
    11'd54: data <= 32'h00066E00;
    11'd55: data <= 32'h00070600;
    11'd56: data <= 32'h00080C00;
    11'd57: data <= 32'h00091800;
    11'd58: data <= 32'h000A3000;
    11'd59: data <= 32'h000B6700;
    11'd60: data <= 32'h000CC680;
    11'd61: data <= 32'h000D0180;
    11'd62: data <= 32'h000E0000;
    11'd63: data <= 32'h000F0000;
    11'd64: data <= 32'h00000000;
    11'd65: data <= 32'h00010000;
    11'd66: data <= 32'h00020000;
    11'd67: data <= 32'h00033000;
    11'd68: data <= 32'h000468C0;
    11'd69: data <= 32'h00056980;
    11'd70: data <= 32'h00066E00;
    11'd71: data <= 32'h00070600;
    11'd72: data <= 32'h00080C00;
    11'd73: data <= 32'h00091800;
    11'd74: data <= 32'h000A3000;
    11'd75: data <= 32'h000B6700;
    11'd76: data <= 32'h000CC680;
    11'd77: data <= 32'h000D0180;
    11'd78: data <= 32'h000E0000;
    11'd79: data <= 32'h000F0000;
    default: data <=32'b0; 
    endcase
end
endmodule