`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:44:53 07/04/2016
// Design Name:   PARITY_CHECK
// Module Name:   /home/g1ndac/Workplace/Verilog/I2CKeyboard/ParityTest.v
// Project Name:  I2CKeyboard
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: PARITY_CHECK
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ParityTest;

	// Inputs
	reg PARITY_BIT;
	reg [7:0] DATA_BUS;

	// Outputs
	wire PARITY;

	// Instantiate the Unit Under Test (UUT)
	PARITY_CHECK uut (
		.PARITY_BIT(PARITY_BIT), 
		.DATA_BUS(DATA_BUS), 
		.PARITY(PARITY)
	);

	initial begin
		// Initialize Inputs
		PARITY_BIT = 0;
		DATA_BUS = 0;

		
		#10 DATA_BUS = 8'b01010101;
			 PARITY_BIT = 1;
		#10 DATA_BUS = 8'b10111100;
			PARITY_BIT = 1;
	end
      
endmodule

