`timescale 1ns / 1ps

module CHECK #(parameter H_RES = 1024,
					parameter V_RES = 768,
					parameter H_DIM = 11,
					parameter V_DIM = 10)
					
				(input [H_DIM:0] HORIZONTAL,
				 input [V_DIM:0] VERTICAL,
				 input PIX_CLK,
				 output reg DISP_EN,
				 output [H_DIM:0] POS_X,
				 output [V_DIM:0] POS_Y
    );
	 
	always@(posedge PIX_CLK) begin
		if((HORIZONTAL <= H_RES) && (VERTICAL <= V_RES)) DISP_EN <= 1;
		else DISP_EN <= 0;
	end
	
	assign POS_X = HORIZONTAL;
	assign POS_Y = VERTICAL;

endmodule
