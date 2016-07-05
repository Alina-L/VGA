module Counter #(parameter COUNTER_SIZE = 11,
									WHOLE_FRAME  = 11'b10100110000)(
		input 													 control_clock,
		output [COUNTER_SIZE - 1 : 0] 					counter_output
    );
	 
		reg [COUNTER_SIZE - 1 : 0]   		  internal_register = 0;
	 
	 always @ (posedge control_clock) begin
		if(internal_register >= WHOLE_FRAME)
			internal_register <= 0;
		else 
			internal_register <= internal_register + 1;
	 end

		assign counter_output = internal_register; 

endmodule