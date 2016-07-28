`timescale 1ns / 1ps

module CTRL_CIRC (
    input  sSCL,
    input  sSDA,
	 input CLK,
    output reg START
);
 
reg [2:0] state = 1;
reg [3:0] cnt = 0;
 
always @(negedge sSCL) begin
 
        case (state)
            3'b001: if (sSDA == 0 && cnt == 0) state <= 3'b010;			//START STATE
				3'b010: if (cnt == 8) state <= 3'b011;        					//SHIFTING DATA
				3'b011: if (cnt == 9) state <= 3'b100;								//PARITY STATE
            3'b100: if (sSDA == 1 && cnt == 10) state <= 3'b001;			//STOP STATE
            default: state <= 3'b001;
        endcase
 
end

always @(negedge sSCL) begin
   if ((sSDA == 1) && (cnt == 0)) cnt <= 0;
	if (cnt == 10) cnt <= 0;
	else cnt <= cnt + 1;
end

always @(state) begin
if (state == 3'b010 || state == 3'b100 || state == 3'b011) START = 1;
else START = 0;
end


endmodule
