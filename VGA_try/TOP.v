`timescale 1ns / 1ps


  module TOP_KEYBOARD(input tSDA,
			  input tSCL,
			  input tCLK,
			  input RST,
			 output [7:0] tSCANCODE,
			 output tDVALID,
			 output [7:0] OUTPUT,
			 output [3:0] ANODE,
			 output [7:0] SEG1
    );
	 
	wire tsSDA;
	wire tsSCL;
	wire [7:0] tPROR;
	wire tPARITY_BIT;
	wire tparityOut;
	wire tPARITY;
	wire tSTART;
	wire tOE;
	wire [7:0] ttSCANCODE;
	
	assign tSCANCODE = ttSCANCODE;
	assign DVALID = tPARITY;
	assign tDVALID = DVALID;
	
	FFSYNC tFFSYNC(
	.SDA(tSDA),
	.SCL(tSCL),
	.CLK(tCLK),
	.sSDA(tsSDA),
	.sSCL(tsSCL)
	);
	
	PARALEREG tPARALEREG(
	.sSDA(tsSDA),
	.sSCL(tsSCL),
	.START(tSTART),
	.PARITY_BIT(tPARITY_BIT),
	.PROR(tPROR)
	);
	
	CTRL_CIRC tCTRL_CIRC(
	.sSDA(tsSDA),
	.sSCL(tsSCL),
	.CLK(tCLK),
	.START(tSTART)
	);
	
	PARITY_CHECK tPARITY_CHECK(
	.PARITY_BIT(tPARITY_BIT),
	.DATA_BUS(tPROR),
	.PARITY(tPARITY)
	);
	
	OUTREG tOUTREG(
	.PROR(tPROR),
	.CLK(tCLK),
	.OE(tDVALID),
	.SCANCODE(ttSCANCODE)
	);
	 
	 SEG segment (
	.SCANCODE(ttSCANCODE),
	.ANODE(ANODE),
	.SEG1(SEG1),
	.CLK(tCLK)
	 );
	
endmodule