`timescale 1ns / 1ps

module PARITY_CHECK(
    input PARITY_BIT,
    input [7:0] DATA_BUS,
    output PARITY
    );
wire internalParity;
assign internalParity = ^DATA_BUS;

assign PARITY = (PARITY_BIT == internalParity);

endmodule
