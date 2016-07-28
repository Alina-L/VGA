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
	input 							 RST_IN,
	input 								tSDA,
	input 								tSCL,
	output	 [7:0]			 tSCANCODE,
	output 							tDVALID,
	output 	[7:0]					 OUTPUT,
	output 	[3:0] 					ANODE,
	output [7:0] 						SEG1
);
wire [4:0] GRID_Y;
wire [4:0] GRID_X;
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

TOP_KEYBOARD keyboard_int( .tSDA(tSDA),
			     .tSCL(tSCL),
			     .tCLK(FCLK),
			     .RST(RST_IN),
				  .tSCANCODE(tSCANCODE),
				  .tDVALID(tDVALID),
				  .OUTPUT(OUTPUT),
				  .ANODE(ANODE),
				  .SEG1(SEG1)
);


wire fake_clock;
reg [24:0] counter = 0;
always @ (posedge FCLK) begin
	counter <= counter + 1;
end
assign fake_clock = counter[24];
assign DISPLAY_EN = en_hoz&&en_ver;
					/*(POS_X > SYNC_PULSE_HORIZONTAL + FRONT_PORCH_HORIZONTAL) &
						  (POS_X < WHOLE_LINE_HORIZONTAL - BACK_PORCH_HORIZONTAL)&
						  (POS_Y > SYNC_PULSE_HORIZONTAL + FRONT_PORCH_HORIZONTAL) &
						  (POS_Y < WHOLE_FRAME_VERTICAL - BACK_PORCH_HORIZONTAL);
							*/
wire non_play_area;

reg [4:0] PARAM_X = 7;
reg [4:0] PARAM_Y = 0;

/*always @ (posedge fake_clock) begin
	PARAM_Y <= PARAM_Y + 1;
	if(tSCANCODE == 8'h23) PARAM_X <= PARAM_X + 1;
	if (PARAM_X == 16) PARAM_X <= 0; //TO ADD RIGHT BORDER
	
	register  <= register + 1;
end*/

reg [3:0] line=0;//dunno if cur line or next line. Maybe cur.
reg [3:0] col=0;
reg [2:0] piece=0;
reg need = 1;
reg [159:0] grid=160'd0;
wire left;
wire right;
wire rotate;
assign left = PIXEL_DATA[7] && (col-1) != 0;
assign right = PIXEL_DATA[6] && (col+1) != 10;
assign rotate = PIXEL_DATA[5];
wire [7:0]lineMinusOne;
wire [7:0]lineMinusTwo;
wire [7:0]lineSoft;
wire [7:0]linePlusOne;
wire [7:0]linePlusTwo;
wire [3:0]ten;
wire[3:0] linieMinusOne;
wire[3:0] linieMinusTwo;
wire[3:0] linieMoale;
wire[3:0] liniePlusOne;
wire[3:0] liniePlusTwo;
assign linieMinusOne = line - 1;
assign liniePlusOne = line +1 ;
assign linieMinusTwo = line - 2;
assign liniePlusTwo = line + 2;
assign linieMoale = line;
assign ten = 4'b1010;
DSP lineMinusOneDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(line-1), // input [3 : 0] b
  .p(lineMinusOne) // output [7 : 0] p
);
DSP lineMinusTwoDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(line-2), // input [3 : 0] b
  .p(lineMinusTwo) // output [7 : 0] p
);
DSP lineSoftDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(line), // input [3 : 0] b
  .p(lineSoft) // output [7 : 0] p
);
DSP linePlusOneDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(line+1), // input [3 : 0] b
  .p(linePlusOne) // output [7 : 0] p
);
DSP linePlusTwoDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(line+2), // input [3 : 0] b
  .p(linePlusTwo) // output [7 : 0] p
);

always @ (posedge fake_clock) begin //to be changed with a slower clock
if (need == 1) begin
	line <= 1;
	col <= 5;
	grid[lineMinusOne+col] <= 1;
	grid[lineSoft+col] <= 1;
	grid[lineSoft+col+1] <= 1;
	grid[lineSoft+col-1] <= 1;
	piece<=0;
	need<=0;
end
else begin
	if (piece == 0 /* TBlock 0 grade*/) begin
		if (left) begin
			if (grid[linePlusOne+ col - 2] == 0 && grid[linePlusOne + col-1] == 0 && grid[linePlusOne + col] == 0) begin 
				grid[linePlusOne + col - 2] <= 1;
				grid[linePlusOne + col - 1] <= 1;
				grid[linePlusOne + col] <= 1;
				grid[lineSoft + col - 1]<= 1;
				grid[lineSoft + col]<= 0;
				grid[lineSoft + col+1] <=0;
				grid[lineMinusOne + col]<= 0;
				line <=line + 1;
				col <=col - 1;
				need<= 0;
			end
			else if (grid[linePlusOne + col - 1] == 0 && grid[linePlusOne + col] == 0 && grid[linePlusOne + col + 1] == 0)begin
				grid[linePlusOne + col - 1]<= 1;
				grid[linePlusOne + col] <=1;
				grid[linePlusOne + col + 1] <=1;
				grid[lineSoft + col]<= 1;
				grid[lineSoft + col + 1] <=0;
				grid[lineSoft + col - 1] <=0;
				grid[lineMinusOne + col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
		else if (right) begin
			if (grid[linePlusOne + col + 2] == 0 && grid[linePlusOne + col+1] == 0 && grid[linePlusOne + col] == 0) begin 
				grid[linePlusOne + col + 2] <=1;
				grid[linePlusOne + col + 1] <=1;
				grid[linePlusOne + col]<= 1;
				grid[lineSoft+ col +1] <=1;
				grid[lineSoft + col]<= 0;
				grid[lineSoft+ col-1]<= 0;
				grid[lineMinusOne + col] <=0;
				line<= line + 1;
				col <=col +1;
				need<= 0;
			end
			else if (grid[linePlusOne + col - 1] == 0 && grid[linePlusOne + col] == 0 && grid[linePlusOne + col + 1] == 0)begin
				grid[linePlusOne + col - 1]<= 1;
				grid[linePlusOne + col] <=1;
				grid[linePlusOne + col + 1] <=1;
				grid[lineSoft + col]<= 1;
				grid[lineSoft + col + 1] <=0;
				grid[lineSoft + col - 1] <=0;
				grid[lineMinusOne + col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
		
		else if (rotate) begin
			if (grid[linePlusOne + col] == 0 && grid[linePlusTwo + col] == 0 && grid[linePlusOne+col+1] == 0) begin
				grid[linePlusOne + col] <=1;
				grid[linePlusTwo + col] <=1;
				grid[linePlusOne+col+1] <=1;
				grid[linePlusOne + col] <=1;
				grid[lineSoft+ col - 1]<= 0;
				grid[lineSoft+ col + 1] <=0;
				grid[lineMinusOne+ col] <=1;
				line <=line + 1;
				col<= col;
				need<= 0;
				piece <= 1;
			end
			else if (grid[linePlusOne + col - 1] == 0 && grid[linePlusOne + col] == 0 && grid[linePlusOne + col + 1] == 0)begin
				grid[linePlusOne + col - 1]<= 1;
				grid[linePlusOne + col] <=1;
				grid[linePlusOne + col + 1] <=1;
				grid[lineSoft + col]<= 1;
				grid[lineSoft + col + 1] <=0;
				grid[lineSoft + col - 1] <=0;
				grid[lineMinusOne + col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
		
		else begin
			if (grid[linePlusOne + col - 1] == 0 && grid[linePlusOne + col] == 0 && grid[linePlusOne + col + 1] == 0)begin
				grid[linePlusOne + col - 1]<= 1;
				grid[linePlusOne + col] <=1;
				grid[linePlusOne + col + 1] <=1;
				grid[lineSoft + col]<= 1;
				grid[lineSoft + col + 1] <=0;
				grid[lineSoft + col - 1] <=0;
				grid[lineMinusOne + col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
	end
	else if (piece == 1/*Tblock 90 grade*/) begin
	if (left) begin
			if (grid[lineSoft+ col - 1] == 0 && grid[linePlusOne + col-1] == 0 && grid[linePlusTwo+ col-1] == 0) begin 
				grid[lineSoft+ col - 1] <=1;
				grid[linePlusOne+ col-1]<=1 ;
				grid[linePlusTwo+ col-1]<= 1;
				grid[linePlusOne+ col]<= 1;
				grid[lineSoft+ col] <=0;
				grid[lineSoft+ col +1]<= 0;
				grid[lineMinusOne+ col]<= 0;
				line<= line + 1;
				col <=col - 1;
				need<= 0;
			end
			else if (grid[linePlusOne+ col + 1] == 0 && grid[linePlusTwo+ col] == 0)begin
				grid[linePlusOne+ col + 1] <=1;
				grid[linePlusTwo+ col]<= 1;
				grid[lineSoft+ col + 1]<= 0;
				grid[lineMinusOne+ col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
		else if (right) begin
			if (grid[linePlusOne+ col + 1] == 0 && grid[linePlusOne+ col+2] == 0 && grid[linePlusTwo+ col + 1] == 0) begin 
				grid[linePlusOne+ col + 1] <=1;
				grid[linePlusOne+ col+2]<=1;
				grid[linePlusTwo+ col + 1]<=1;
				grid[linePlusOne+ col]<= 0;
				grid[lineSoft+ col] <=0;
				grid[lineMinusOne+ col]<= 0;
				line<= line + 1;
				col<= col +1;
				need<= 0;
			end
			else if (grid[linePlusOne+ col + 1] == 0 && grid[linePlusTwo+ col] == 0)begin
				grid[linePlusOne+ col + 1] <=1;
				grid[linePlusTwo+ col]<= 1;
				grid[lineSoft+ col + 1]<= 0;
				grid[lineMinusOne+ col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
		
		else if (rotate) begin
			if (grid[linePlusOne+ col+1] == 0 && grid[linePlusOne+ col-1] == 0 ) begin
				grid[linePlusOne+ col+1]<= 1;
				grid[linePlusOne+ col-1]<= 1;
				grid[lineSoft + col+1] <=0;
				grid[lineMinusOne+ col] <=0;
				line <=line + 1;
				col <=col;
				need <=0;
				piece <= 0;
			end
			else if (grid[linePlusOne+ col + 1] == 0 && grid[linePlusTwo+ col] == 0)begin
				grid[linePlusOne+ col + 1] <=1;
				grid[linePlusTwo+ col]<= 1;
				grid[lineSoft+ col + 1]<= 0;
				grid[lineMinusOne+ col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
		
		else begin
			if (grid[linePlusOne+ col + 1] == 0 && grid[linePlusTwo+ col] == 0)begin
				grid[linePlusOne+ col + 1] <=1;
				grid[linePlusTwo+ col]<= 1;
				grid[lineSoft+ col + 1]<= 0;
				grid[lineMinusOne+ col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
		end
	
	
	
	
	
	
	
	end
end
end







assign non_play_area = GRID_X < 5 || GRID_X > 14 || GRID_Y > 15;
always @ (posedge VGACLK) begin
	if(DISPLAY_EN) begin
		if (non_play_area)begin
			R <= 0;
			B <= 0;
			G <= 0;
		end
		else begin
			if(GRID_X == 5  && GRID_Y == 0) begin
				if (grid[0]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 0) begin
				if (grid[1]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 0) begin
				if (grid[2]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 0) begin
				if (grid[3]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 0) begin
				if (grid[4]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 0) begin
				if (grid[5]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 0) begin
				if (grid[6]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 0) begin
				if (grid[7]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 0) begin
				if (grid[8]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 0) begin
				if (grid[9]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 1) begin
				if (grid[10]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 1) begin
				if (grid[11]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 1) begin
				if (grid[12]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 1) begin
				if (grid[13]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 1) begin
				if (grid[14]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 1) begin
				if (grid[15]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 1) begin
				if (grid[16]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 1) begin
				if (grid[17]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 1) begin
				if (grid[18]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 1) begin
				if (grid[19]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 2) begin
				if (grid[20]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 2) begin
				if (grid[21]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 2) begin
				if (grid[22]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 2) begin
				if (grid[23]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 2) begin
				if (grid[24]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 2) begin
				if (grid[25]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 2) begin
				if (grid[26]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 2) begin
				if (grid[27]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 2) begin
				if (grid[28]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 2) begin
				if (grid[29]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 3) begin
				if (grid[30]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 3) begin
				if (grid[31]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 3) begin
				if (grid[32]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 3) begin
				if (grid[33]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 3) begin
				if (grid[34]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 3) begin
				if (grid[35]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 3) begin
				if (grid[36]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 3) begin
				if (grid[37]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 3) begin
				if (grid[38]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 3) begin
				if (grid[39]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 4) begin
				if (grid[40]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 4) begin
				if (grid[41]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 4) begin
				if (grid[42]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 4) begin
				if (grid[43]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 4) begin
				if (grid[44]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 4) begin
				if (grid[45]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 4) begin
				if (grid[46]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 4) begin
				if (grid[47]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 4) begin
				if (grid[48]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 4) begin
				if (grid[49]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 5) begin
				if (grid[50]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 5) begin
				if (grid[51]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 5) begin
				if (grid[52]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 5) begin
				if (grid[53]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 5) begin
				if (grid[54]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 5) begin
				if (grid[55]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 5) begin
				if (grid[56]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 5) begin
				if (grid[57]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 5) begin
				if (grid[58]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 5) begin
				if (grid[59]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 6) begin
				if (grid[60]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 6) begin
				if (grid[61]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 6) begin
				if (grid[62]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 6) begin
				if (grid[63]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 6) begin
				if (grid[64]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 6) begin
				if (grid[65]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 6) begin
				if (grid[66]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 6) begin
				if (grid[67]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 6) begin
				if (grid[68]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 6) begin
				if (grid[69]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 7) begin
				if (grid[70]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 7) begin
				if (grid[71]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 7) begin
				if (grid[72]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 7) begin
				if (grid[73]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 7) begin
				if (grid[74]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 7) begin
				if (grid[75]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 7) begin
				if (grid[76]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 7) begin
				if (grid[77]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 7) begin
				if (grid[78]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 7) begin
				if (grid[79]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 8) begin
				if (grid[80]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 8) begin
				if (grid[81]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 8) begin
				if (grid[82]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 8) begin
				if (grid[83]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 8) begin
				if (grid[84]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 8) begin
				if (grid[85]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 8) begin
				if (grid[86]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 8) begin
				if (grid[87]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 8) begin
				if (grid[88]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 8) begin
				if (grid[89]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 9) begin
				if (grid[90]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 9) begin
				if (grid[91]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 9) begin
				if (grid[92]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 9) begin
				if (grid[93]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 9) begin
				if (grid[94]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 9) begin
				if (grid[95]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 9) begin
				if (grid[96]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 9) begin
				if (grid[97]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 9) begin
				if (grid[98]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 9) begin
				if (grid[99]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 100) begin
				if (grid[100]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 10) begin
				if (grid[101]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 10) begin
				if (grid[102]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 10) begin
				if (grid[103]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 10) begin
				if (grid[104]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 10) begin
				if (grid[105]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 10) begin
				if (grid[106]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 10) begin
				if (grid[107]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 10) begin
				if (grid[108]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 10) begin
				if (grid[109]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 11) begin
				if (grid[110]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 6  && GRID_Y == 11) begin
				if (grid[111]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 7  && GRID_Y == 11) begin
				if (grid[112]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 8  && GRID_Y == 11) begin
				if (grid[113]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 9  && GRID_Y == 11) begin
				if (grid[114]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 10  && GRID_Y == 11) begin
				if (grid[115]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 11  && GRID_Y == 11) begin
				if (grid[116]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 12  && GRID_Y == 11) begin
				if (grid[117]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 13  && GRID_Y == 11) begin
				if (grid[118]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 14  && GRID_Y == 11) begin
				if (grid[119]) begin
				R <= PIXEL_DATA[7:5];
				G <= PIXEL_DATA[4:2];
				B <= PIXEL_DATA[1:0];
				end
				else begin
					R <= ~PIXEL_DATA[7:5];
					G <= ~PIXEL_DATA[4:2];
					B <= ~PIXEL_DATA[1:0];
				end
			end
			else if(GRID_X == 5  && GRID_Y == 12) begin
                if (grid[120]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 6  && GRID_Y == 12) begin
                if (grid[121]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 7  && GRID_Y == 12) begin
                if (grid[122]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 8  && GRID_Y == 12) begin
                if (grid[123]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 9  && GRID_Y == 12) begin
                if (grid[124]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 10  && GRID_Y == 12) begin
                if (grid[125]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 11  && GRID_Y == 12) begin
                if (grid[126]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 12  && GRID_Y == 12) begin
                if (grid[127]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 13  && GRID_Y == 12) begin
                if (grid[128]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 14  && GRID_Y == 12) begin
                if (grid[129]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
 

				else if(GRID_X == 5  && GRID_Y == 13) begin
                if (grid[130]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 6  && GRID_Y == 13) begin
                if (grid[131]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 7  && GRID_Y == 13) begin
                if (grid[132]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 8  && GRID_Y == 13) begin
                if (grid[133]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 9  && GRID_Y == 13) begin
                if (grid[134]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 10  && GRID_Y == 13) begin
                if (grid[135]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 11  && GRID_Y == 13) begin
                if (grid[136]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 12  && GRID_Y == 13) begin
                if (grid[137]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 13  && GRID_Y == 13) begin
                if (grid[138]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 14  && GRID_Y == 13) begin
                if (grid[139]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
else if(GRID_X == 5  && GRID_Y == 14) begin
                if (grid[140]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 6  && GRID_Y == 14) begin
                if (grid[141]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 7  && GRID_Y == 14) begin
                if (grid[142]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 8  && GRID_Y == 14) begin
                if (grid[143]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 9  && GRID_Y == 14) begin
                if (grid[144]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 10  && GRID_Y == 14) begin
                if (grid[145]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 11  && GRID_Y == 14) begin
                if (grid[146]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 12  && GRID_Y == 14) begin
                if (grid[147]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 13  && GRID_Y == 14) begin
                if (grid[148]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 14  && GRID_Y == 14) begin
                if (grid[149]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end     
      

else if(GRID_X == 5  && GRID_Y == 15) begin
                if (grid[150]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 6  && GRID_Y == 15) begin
                if (grid[152]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 7  && GRID_Y == 15) begin
                if (grid[152]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 8  && GRID_Y == 15) begin
                if (grid[153]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 9  && GRID_Y == 15) begin
                if (grid[154]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 10  && GRID_Y == 15) begin
                if (grid[155]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 11  && GRID_Y == 15) begin
                if (grid[156]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 12  && GRID_Y == 15) begin
                if (grid[157]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 13  && GRID_Y == 15) begin
                if (grid[158]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
            else if(GRID_X == 14  && GRID_Y == 15) begin
                if (grid[159]) begin
                R <= PIXEL_DATA[7:5];
                G <= PIXEL_DATA[4:2];
                B <= PIXEL_DATA[1:0];
                end
                else begin
                    R <= ~PIXEL_DATA[7:5];
                    G <= ~PIXEL_DATA[4:2];
                    B <= ~PIXEL_DATA[1:0];
                end
            end
			else begin
				R <= ~PIXEL_DATA[7:5];
				G <= ~PIXEL_DATA[4:2];
				B <= ~PIXEL_DATA[1:0];
			end
		end
	end
	else begin
		R <= 0;
		B <= 0;
		G <= 0;
	end
end

endmodule