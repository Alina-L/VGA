module Sync_Generator(
		input 				set,
		input 			 reset,
		output 			  sync
    );
	 
	 reg internal;

	always@(*)
		if(reset) internal  = 1;
		else if(set) internal = 0;
		
		
	assign sync = internal;

endmodule
