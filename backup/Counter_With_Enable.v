module Counter_With_Enable #(parameter COUNTER_SIZE = 11,
													WHOLE_FRAME  = 11'b10100110000)(
		input 													  control_clock,
		input 													 counter_enable,
		output [COUNTER_SIZE - 1 : 0] 					 counter_output
    );
	 
		reg 	 [COUNTER_SIZE - 1 : 0]   		  internal_register = 0;
	 
	 always @ (posedge control_clock) begin
		if(internal_register >= WHOLE_FRAME)
			internal_register <= 0;
		else if(counter_enable)
			internal_register <= internal_register + 1;
			  else internal_register <= internal_register;
	 end

		assign counter_output = internal_register; 

endmodule 