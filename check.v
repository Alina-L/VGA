`timescale 1ns / 1ps

module CHECK #(parameter H_RES = 1024,
					parameter V_RES = 768)
					
				(input [11:0] HORIZONTAL,
				 input [11:0] VERTICAL,
				 input PIX_CLK,
				 output reg DISP_EN,
				 output reg[11:0] POS_X,
				 output reg [11:0] POS_Y
    );
	 
	
	 
	always@(posedge PIX_CLK) begin
		if((HORIZONTAL < H_RES) && (VERTICAL < V_RES)) DISP_EN <= 1;
		else DISP_EN <= 0;
		POS_X <= HORIZONTAL;
		POS_Y <= VERTICAL;

	end
	


endmodule


module tb();

	reg [11:0] h, v;
	reg clk;
	wire en;
	wire [11:0] x, y;
	
	CHECK ck  (.HORIZONTAL(h),
								.VERTICAL(v),
								.PIX_CLK(clk),
								.DISP_EN(en),
								.POS_X(x),
								.POS_Y(y));
	initial begin
		clk = 0;
		forever #1 clk = ~clk;
	end
	
	initial begin
		h = 0;
		v = 0;
		
		#20 h = 500;
			 v = 500;
		
		#20 h = 1000;
			 v = 1000;
		
		#20 h = 1030;
			 v = 1000;
		
		#20 $stop;
	end
endmodule
