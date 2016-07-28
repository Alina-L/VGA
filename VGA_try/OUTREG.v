`timescale 1ns / 1ps

module OUTREG( 
	input  [7:0] PROR,
	input  CLK,
	input OE,
	output reg [7:0] SCANCODE
    );
	 
reg [7:0] PRORlink;
	 
always@(negedge CLK) begin
	if (OE) begin
		SCANCODE<=PROR;
	end
	end

always@(negedge CLK)
	PRORlink<=PROR;
	
endmodule










