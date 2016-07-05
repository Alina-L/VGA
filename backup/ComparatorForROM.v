`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:21:47 07/05/2016 
// Design Name: 
// Module Name:    ComparatorForROM 
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
module ComparatorForROM
            #(parameter H_RES = 1024,
					parameter V_RES = 768)
					
				(input [10:0] HORIZONTAL,
				 input [10:0] VERTICAL,
				 input PIX_CLK,
				 output reg DISP_EN,
				 output reg[10:0] POS_X,
				 output reg [10:0] POS_Y
    );
	 
	
	 
	always@(posedge PIX_CLK) begin
		if((HORIZONTAL < H_RES) && (VERTICAL < V_RES)) DISP_EN <= 1;
		else DISP_EN <= 0;
		POS_X <= HORIZONTAL;
		POS_Y <= VERTICAL;

	end

endmodule
