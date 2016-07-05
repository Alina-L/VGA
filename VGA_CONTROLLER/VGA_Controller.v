module VGA_Controller #(parameter ZERO = 0, 
											 THRESHOLD_HSYNC   = 11'b10000110000,
											 THRESHOLD_VSYNC   = 11'b10000110000,
											 WHOLE_FRAME_VERTICAL = 11'b10100110000,
											 WHOLE_FRAME_HORIZONTAL = 806,
											 COUNTER_SIZE = 11)(
		input 	control_clock,
		output 			 v_sync,
		output 			 h_sync
    );

	H_Sync_Generator #(ZERO, THRESHOLD_HSYNC, WHOLE_FRAME_HORIZONTAL, COUNTER_SIZE) H_Sync_Generator (
		.control_clock(control_clock),
		.h_sync(h_sync)
    );
	 
	V_Sync_Generator #(ZERO, THRESHOLD_VSYNC, WHOLE_FRAME_VERTICAL, COUNTER_SIZE) V_Sync_Generator(
		.control_clock(control_clock),
		.v_sync(v_sync),
		.enable(h_sync)
	 );
	
endmodule
