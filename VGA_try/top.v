`timescale 1ns / 1ps
module top(
	input 								FCLK,
	input 		[ 7: 0] 		PIXEL_DATA,
	output 						DISPLAY_EN,
	output 		[10: 0]			  POS_X,
	output 		[10: 0]			  POS_Y,
	output reg 	[ 2: 0] 					R,
	output reg  [ 2: 0] 					G,
	output reg 	[ 1: 0] 					B,
	output 							  HSYNC,
	output 							  VSYNC,
	input 							 RST_IN
);
wire [3:0] GRID_Y;
wire [3:0] GRID_X;
	parameter SYNC_PULSE_VERTICAL   			= 11'd2;
	parameter WHOLE_FRAME_VERTICAL  			= 11'd449;
	parameter FRONT_PORCH_VERTICAL  			= 11'd37;
	parameter BACK_PORCH_VERTICAL   			= 11'd60;
	parameter VISIBLE_AREA_VERTICAL 			= 11'd350;
	
	parameter SYNC_PULSE_HORIZONTAL 			= 11'd96;
	parameter WHOLE_LINE_HORIZONTAL 			= 11'd800;
	parameter FRONT_PORCH_HORIZONTAL 		= 11'd16;
	parameter BACK_PORCH_HORIZONTAL 			= 11'd48;
	parameter VISIBLE_AREA_HORIZONTAL 		= 11'd640;
	

	wire 								 en_hoz;
	wire 								 en_ver;
	wire 								 VGACLK;
	wire 							  CLK0_OUT;
	wire 						   LOCKED_OUT;

DCM_DIVIDER instance_name (
   .CLKIN_IN						 (FCLK), 
   .RST_IN						  (RST_IN), 
   .CLKFX_OUT					  (VGACLK), 
   .CLK0_OUT					(CLK0_OUT), 
   .LOCKED_OUT(LOCKED_OUT)
    );
gridEnforcer myGrid(
.POS_X(POS_X), .POS_Y(POS_Y), .GRID_X(GRID_X), .GRID_Y(GRID_Y)
);	 
	 
horizontal_count #(
	SYNC_PULSE_HORIZONTAL,
	WHOLE_LINE_HORIZONTAL,
	FRONT_PORCH_HORIZONTAL,
	BACK_PORCH_HORIZONTAL,
	VISIBLE_AREA_HORIZONTAL
	) horizontal(
	.slow_clock(VGACLK), .out_horizontal_counter(POS_X), .hsync(HSYNC), .enable_display_horizontally(en_hoz) 
);
vertical_count #(
	SYNC_PULSE_VERTICAL,
	WHOLE_FRAME_VERTICAL,
	FRONT_PORCH_VERTICAL,
	BACK_PORCH_VERTICAL,
	VISIBLE_AREA_VERTICAL
	) vertical(
	.slow_clock(VGACLK), .enable(HSYNC), .out_vertical_counter(POS_Y), .vsync(VSYNC), .enable_display_vertically(en_ver)
);

assign DISPLAY_EN = en_hoz&&en_ver;
							/*(POS_X > SYNC_PULSE_HORIZONTAL + FRONT_PORCH_HORIZONTAL) &
						  (POS_X < WHOLE_LINE_HORIZONTAL - BACK_PORCH_HORIZONTAL)&
						  (POS_Y > SYNC_PULSE_HORIZONTAL + FRONT_PORCH_HORIZONTAL) &
						  (POS_Y < WHOLE_FRAME_VERTICAL - BACK_PORCH_HORIZONTAL);
							*/
always @ (*) begin
	if (DISPLAY_EN) begin
		if(GRID_X == 0 || GRID_X == 2 || GRID_X == 4 ||GRID_X == 6 ||  GRID_X == 8 || GRID_X == 10 || GRID_X == 12 || GRID_X == 14 ||GRID_X == 16 ||  GRID_X == 18) begin
		 R = PIXEL_DATA[7:5];
		 G = PIXEL_DATA[4:2];
		 B = PIXEL_DATA[1:0];
		 end
		else begin
		 R = ~PIXEL_DATA[7:5];
		 G = ~PIXEL_DATA[4:2];
		 B = ~PIXEL_DATA[1:0];
		 end
	end
	else begin
		 R = 0;
		 G = 0;
		 B = 0;
	end
end


endmodule

module tb(); 
	reg fclk, rst;
	reg [7:0] pix_data;
	wire disp_en, hs, vs;
	wire [10:0] x, y;
	wire [2:0] R,G;
	wire [1:0] B;

	top top (
		.FCLK(fclk),
		.PIXEL_DATA(pix_data),
		.DISPLAY_EN(disp_en),
		.POS_X(x),
		.POS_Y(y),
		.R(R),
		.G(G),
		.B(B),
		.HSYNC(hs),
		.VSYNC(vs),
		.RST_IN(rst));

	initial begin 
		fclk = 0;
		forever #10 fclk = ~fclk;
	end
	
	initial begin
		pix_data = 0;
		rst = 0;
	end

endmodule 