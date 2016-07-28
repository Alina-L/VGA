`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:44:28 06/29/2016 
// Design Name: 
// Module Name:    LATCH 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module LATCH(
	input reset,
	input set,
	output reg q
    );

	always@(set, reset)begin
	if (set) q = 1;
	else if (reset) q = 0;
	end

endmodule