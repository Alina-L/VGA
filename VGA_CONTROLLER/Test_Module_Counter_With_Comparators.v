module Test_Module_Counter_With_Comparators();

		parameter CLOCK_PERIOD = 2;
		
		parameter 							 ZERO = 0;
		parameter THRESHOLD   = 11'b10100110000; 
		parameter WHOLE_FRAME = 11'b10100110000;
		parameter 				 COUNTER_SIZE = 11;

		reg 						CLOCK;
		wire 	  threshold_detected;
		wire 			 zero_detected;

	Counter_With_Zero_And_Threshold_Detect #(ZERO, THRESHOLD, WHOLE_FRAME, COUNTER_SIZE) Counter_With_Zero_And_Threshold_Detect (
		.control_clock(CLOCK),
		.threshold_detected(threshold_detected),
		.zero_detected(zero_detected)
		);

		initial begin
			CLOCK = 1'b0;
			#(CLOCK_PERIOD/2);
			forever
				#(CLOCK_PERIOD/2) CLOCK = ~CLOCK;
		end

		initial begin
			
		end



endmodule
