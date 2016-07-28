`timescale 1ns / 1ps
module FFSYNC(
	input SDA,
	input SCL,
	input CLK,
	output reg sSDA,
	output reg sSCL
    );
	 
always@(negedge CLK) begin
	sSDA<=SDA;
	sSCL<=SCL;
end

endmodule
