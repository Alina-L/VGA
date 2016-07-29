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
assign left = PIXEL_DATA[7] && ((col-1) != 0);
assign right = PIXEL_DATA[6] && ((col+1) != 10);
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
  .b(linieMinusOne), // input [3 : 0] b
  .p(lineMinusOne) // output [7 : 0] p
);
DSP lineMinusTwoDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(linieMinusTwo), // input [3 : 0] b
  .p(lineMinusTwo) // output [7 : 0] p
);
DSP lineSoftDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(linieMoale), // input [3 : 0] b
  .p(lineSoft) // output [7 : 0] p
);
DSP linePlusOneDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(liniePlusOne), // input [3 : 0] b
  .p(linePlusOne) // output [7 : 0] p
);
DSP linePlusTwoDSP (
  .clk(FCLK), // input clk
  .a(ten), // input [3 : 0] a
  .b(liniePlusTwo), // input [3 : 0] b
  .p(linePlusTwo) // output [7 : 0] p
);

/*always @ (posedge fake_clock) begin //to be changed with a slower clock
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
	if (piece == 0  ) begin
		if (left && grid[linePlusOne+ col - 2] == 0 && grid[linePlusOne + col-1] == 0 && grid[linePlusOne + col] == 0) begin
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
		else if (right && grid[linePlusOne + col + 2] == 0 && grid[linePlusOne + col+1] == 0 && grid[linePlusOne + col] == 0) begin
			
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
		else if (rotate && grid[linePlusOne + col] == 0 && grid[linePlusTwo + col] == 0 && grid[linePlusOne+col+1] == 0) begin
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
	else if (piece == 1) begin
	if (left && grid[lineSoft+ col - 1] == 0 && grid[linePlusOne + col-1] == 0 && grid[linePlusTwo+ col-1] == 0) begin
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
	else if (right && grid[linePlusOne+ col + 1] == 0 && grid[linePlusOne+ col+2] == 0 && grid[linePlusTwo+ col + 1] == 0) begin
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
	else if (rotate && grid[linePlusOne+ col+1] == 0 && grid[linePlusOne+ col-1] == 0) begin
				grid[linePlusOne+ col+1]<= 1;
				grid[linePlusOne+ col-1]<= 1;
				grid[lineSoft + col+1] <=0;
				grid[lineMinusOne+ col] <=0;
				line <=line + 1;
				col <=col;
				need <=0;
				piece <= 0;
	end
	else if (grid[linePlusOne+ col + 1] == 0 && grid[linePlusTwo+ col] == 0) begin
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
*/

always @ (posedge fake_clock) begin //to be changed with a slower clock
if (need == 1) begin
	line <= 1;
	col <= 5;
	grid[(line-1)*10+col] <= 1;
	grid[(line)*10+col] <= 1;
	grid[(line)*10+col+1] <= 1;
	grid[(line)*10+col-1] <= 1;
	need <= 0;
	piece <= 0;
end
else begin
	if (piece == 0) begin
		if (left && grid[(line+1)*10 + col - 2] == 0 && grid[(line+1)*10 + col-1] == 0 && grid[(line+1)*10 + col] == 0) begin 
				grid[(line+1)*10 + col - 2] <= 1;
				grid[(line+1)*10 + col - 1] <= 1;
				grid[(line+1)*10 + col] <= 1;
				grid[(line)*10 + col - 1]<= 1;
				grid[(line)*10 + col]<= 0;
				grid[(line)*10 + col+1] <=0;
				grid[(line-1)*10 + col]<= 0;
				line <=line + 1;
				col <=col - 1;
				need<= 0;
		end
		
		else if (right && grid[(line+1)*10 + col + 2] == 0 && grid[(line+1)*10 + col+1] == 0 && grid[(line+1)*10 + col] == 0) begin
				grid[(line+1)*10 + col + 2] <=1;
				grid[(line+1)*10 + col + 1] <=1;
				grid[(line+1)*10 + col]<= 1;
				grid[(line)*10 + col +1] <=1;
				grid[(line)*10 + col]<= 0;
				grid[(line)*10 + col-1]<= 0;
				grid[(line-1)*10 + col] <=0;
				line<= line + 1;
				col <=col +1;
				need<= 0;
		end
		
		else if (rotate && grid[(line + 1) * 10 + col] == 0 && grid[(line+2)*10 + col] == 0 && grid[(line + 1)*10+col+1] == 0) begin
				grid[(line + 1) * 10 + col] <=1;
				grid[(line+2)*10 + col] <=1;
				grid[(line + 1)*10+col+1] <=1;
				grid[(line) * 10 + col] <=1;
				grid[(line) * 10 + col - 1]<= 0;
				grid[(line) * 10 + col + 1] <=0;
				grid[(line-1) * 10 + col] <=1;
				line <=line + 1;
				col<= col;
				need<= 0;
				piece <= 1;
		end
		
		else if (grid[(line+1)*10 + col - 1] == 0 && grid[(line+1)*10 + col] == 0 && grid[(line+1)*10 + col + 1] == 0)begin
				grid[(line+1)*10 + col - 1]<= 1;
				grid[(line+1)*10 + col] <=1;
				grid[(line+1)*10 + col + 1] <=1;
				grid[(line)*10 + col] <=1;
				grid[(line)*10 + col + 1] <=0;
				grid[(line)*10 + col - 1] <=0;
				grid[(line-1)*10 + col] <=0;
				line<= line + 1;
				col <=col;
				need<= 0;
			end
			else begin
				need <=1;
			end
	end
	else if (piece == 1) begin
	if (left && grid[(line)*10 + col - 1] == 0 && grid[(line+1)*10 + col-1] == 0 && grid[(line+2)*10 + col-1] == 0) begin
				grid[(line)*10 + col - 1] <=1;
				grid[(line+1)*10 + col-1]<=1 ;
				grid[(line+2)*10 + col-1]<= 1;
				grid[(line+1)*10 + col]<= 1;
				grid[(line)*10 + col] <=0;
				grid[(line)*10 + col +1]<= 0;
				grid[(line - 1)*10 + col]<= 0;
				line<= line + 1;
				col <=col - 1;
				need<= 0;
		end
		
		else if (right && grid[(line+1)*10 + col + 1] == 0 && grid[(line+1)*10 + col+2] == 0 && grid[(line+2)*10 + col + 1] == 0) begin 
				grid[(line+1)*10 + col + 1] <=1;
				grid[(line+1)*10 + col+2]<=1;
				grid[(line+2)*10 + col + 1]<=1;
				grid[(line+1)*10 + col]<= 0;
				grid[(line)*10 + col] <=0;
				grid[(line-1)*10 + col]<= 0;
				line<= line + 1;
				col<= col +1;
				need<= 0;
		end
		
		else if (rotate && grid[(line + 1) * 10 + col+1] == 0 && grid[(line+1)*10 + col-1] == 0 ) begin
				grid[(line + 1) * 10 + col+1]<= 1;
				grid[(line+1)*10 + col-1]<= 1;
				grid[(line)*10 + col+1] <=0;
				grid[(line-1)*10 + col] <=0;
				line <=line + 1;
				col <=col;
				need <=0;
				piece <= 0;
		end
		
		else if (grid[(line+1)*10 + col + 1] == 0 && grid[(line+2)*10 + col] == 0)begin
				grid[(line+1)*10 + col + 1] <=1;
				grid[(line+2)*10 + col] <=1;
				grid[(line)*10 + col + 1]<= 0;
				grid[(line-1)*10 + col] <=0;
				line <=line + 1;
				col <=col;
				need<= 0;
		end
		
		else begin
				need <=1;
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
			if (grid[GRID_Y * 10 + (GRID_X-5)]) begin
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
	end
	else begin
		R <= 0;
		B <= 0;
		G <= 0;
	end
end

endmodule