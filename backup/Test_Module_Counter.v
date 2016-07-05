module Test_Module_Counter();

		parameter CLOCK_PERIOD = 2;

		reg 						CLOCK;
		wire [10 : 0] 	  		  OUT;

		Counter #(11, 11'd1328) Counter(
			.control_clock(CLOCK),
			.counter_output(OUT)
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
