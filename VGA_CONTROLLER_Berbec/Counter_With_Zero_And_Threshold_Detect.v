module Counter_With_Zero_And_Threshold_Detect 
	#( 
	 parameter ZERO = 0, 
				  THRESHOLD   = 11'b10000110000, 
				  WHOLE_FRAME = 11'b10100110000,
				  COUNTER_SIZE = 11)(
    input  control_clock,
	 output [1:0] threshold_detected
	 );
		
		wire [COUNTER_SIZE - 1 : 0] counter_output;
	
		Counter #(COUNTER_SIZE, WHOLE_FRAME) Counter(
			.control_clock(control_clock),
			.counter_output(counter_output)
		);
		
		Zero_Detector #(COUNTER_SIZE) Zero_Detector(
			.data_to_compare(counter_output),
			.enabled(threshold_detected[0])
		);
		
		Comparator #(COUNTER_SIZE, THRESHOLD) Threshold_DETECTOR(
			.data_to_compare(counter_output),
			.enabled(threshold_detected[1])
		);
		
endmodule
