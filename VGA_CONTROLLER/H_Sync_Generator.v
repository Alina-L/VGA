module H_Sync_Generator #(parameter ZERO = 0, 
												THRESHOLD_HSYNC   = 11'b10000110000, 
												WHOLE_FRAME = 11'b10100110000,
												COUNTER_SIZE = 11)(
		
		input 						control_clock,
		output 		 						 h_sync
    );
	 
	 wire threshold_detected;
	 wire zero_detected		;
	 
	 Counter_With_Zero_And_Threshold_Detect 
	 #(ZERO, THRESHOLD_HSYNC, WHOLE_FRAME, COUNTER_SIZE) Counter_With_Zero_And_Threshold_Detect(
		.control_clock(control_clock),
		.threshold_detected(threshold_detected),
		.zero_detected(zero_detected)
		);
	 
	  Sync_Generator H_Sync_Generator(
		.set(zero_detected),
		.reset(threshold_detected),
		.sync(h_sync)
		);

endmodule
