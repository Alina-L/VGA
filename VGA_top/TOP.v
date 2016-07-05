`timescale 1ns / 1ps

module TOP(
input FCLK,
input [7:0] PIXEL_DATA,
output DISPLAY_EN,
output POS_X,
output POS_Y,
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
