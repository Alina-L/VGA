module Comparator #(parameter DATA_SIZE = 11, THRESHOLD = 0)(
		input [DATA_SIZE - 1 : 0] data_to_compare,
		output 					 			enabled
    );
	 
	 assign enabled = (data_to_compare == THRESHOLD)?(1):(0);

endmodule 