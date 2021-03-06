module V_Sync_Generator #(parameter ZERO = 0, 
												THRESHOLD_VSYNC   = 11'b10000110000, 
												WHOLE_FRAME = 11'b10100110000,
												COUNTER_SIZE = 11)(
		input 						control_clock,
		input									 enable,
		output 		 						 v_sync,
		output	[COUNTER_SIZE - 1 : 0] v_counter
    );
	 
	 wire threshold_detected;
	 wire zero_detected		;

	 Enabled_Counter_With_Zero_And_Threshold_Detect
	 #(ZERO, THRESHOLD_VSYNC, WHOLE_FRAME, COUNTER_SIZE) Enabled_Counter_With_Zero_And_Threshold_Detect(
		.control_clock(control_clock),
		.counter_enable(enable),
		.threshold_detected(threshold_detected),
		.zero_detected(zero_detected),
		.counter_status(v_counter)
		);
	 
	  Sync_Generator V_Sync_Generator(
		.set(zero_detected),
		.reset(threshold_detected),
		.sync(v_sync)
		);

endmodule
