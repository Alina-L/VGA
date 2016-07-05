module Zero_Detector	#(parameter DATA_SIZE = 11)(
		input [DATA_SIZE - 1 : 0] data_to_compare,
		output 					 			enabled
    );
	 
	 assign enabled = (data_to_compare == 0)?(1):(0);

endmodule 