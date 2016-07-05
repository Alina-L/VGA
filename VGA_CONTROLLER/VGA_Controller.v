module VGA_Controller #(parameter ZERO = 0, 
											 THRESHOLD_HSYNC   = 11'd1024,
											 THRESHOLD_VSYNC   = 11'd768,
											 WHOLE_LINE 		 = 11'd1368,
											 WHOLE_FRAME		 = 11'd806,
											 COUNTER_SIZE 		 =  4'd 11)(
											 
		input 	control_clock,
		output 			 v_sync,
		output 			 h_sync
    );

	H_Sync_Generator #(ZERO, 
							 THRESHOLD_HSYNC, 
							 WHOLE_LINE, 
							 COUNTER_SIZE) 
	H_Sync_Generator (
		.control_clock(control_clock),
		.h_sync(h_sync)
    );
	 
	V_Sync_Generator #(ZERO, 
							 THRESHOLD_VSYNC, 
							 WHOLE_FRAME, 
							 COUNTER_SIZE) 
	V_Sync_Generator(
		.control_clock(control_clock),
		.v_sync(v_sync),
		.enable(h_sync)
	 );
	
endmodule
