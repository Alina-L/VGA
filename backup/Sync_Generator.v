module Sync_Generator(
		input 				set,
		input 			 reset,
		output reg		  sync
    );
	
	always@(*)
		if(reset) sync  <= 1;
		else if(set) sync <= 0;


endmodule
