`timescale 1ns / 1ps

module TOP(
input FCLK,
input [7:0] PIXEL_DATA,
output DISPLAY_EN,
output [11:0] POS_X,
output [11:0] POS_Y,
output [2:0] R,
output [2:0] G,
output [1:0] B,
output HSYNC,
output VSYNC,
input RST_IN
);

wire VGACLK;
wire CLK0_OUT;
wire LOCKED_OUT;
wire [10:0] h;
wire [10:0] v;

VGA_Controller vga_ctrl(
		.control_clock(VGACLK),
		.v_sync(VSYNC),
		.h_sync(HSYNC),
		.h_pos(h),
		.v_pos(v)
    );

ComparatorForROM comparator(
		.HORIZONTAL(h),
		.VERTICAL(v),
		.PIX_CLK(VGACLK), 
		.DISP_EN(DISPLAY_EN),
		.POS_X(POS_X),
		.POS_Y(POS_Y)
);

DCM_DIVIDER instance_name (
    .CLKIN_IN(FCLK), 
    .RST_IN(RST_IN), 
    .CLKFX_OUT(VGACLK), 
    .CLK0_OUT(CLK0_OUT), 
    .LOCKED_OUT(LOCKED_OUT)
    );
assign R = PIXEL_DATA[7:5];
assign G = PIXEL_DATA[4:2];
assign B = PIXEL_DATA[1:0];


endmodule