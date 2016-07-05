module Test_Module_VGA_Controller();

		parameter CLOCK_PERIOD 		 = 		12;
		parameter ZERO = 0; 
		parameter THRESHOLD_HSYNC   = 11'd1024;
		parameter THRESHOLD_VSYNC   = 11'd 768;
		parameter WHOLE_LINE 		 = 11'd1368;
		parameter WHOLE_FRAME 		 = 11'd 806;
		parameter COUNTER_SIZE 		 =  4'd  11;
		
		
		reg 	CLOCK;
		wire v_sync;
		wire h_sync;
		wire counter_out_vsync;
		wire counter_out_hsync;

		VGA_Controller #(ZERO, 
							  THRESHOLD_HSYNC, 
							  THRESHOLD_VSYNC, 
							  WHOLE_LINE,
							  WHOLE_FRAME,
							  COUNTER_SIZE ) 					  
		DUT(
		.control_clock(CLOCK),
		.counter_out_vsync(counter_out_vsync),
		.counter_out_hsync(counter_out_hsync),
		.v_sync(v_sync),
		.h_sync(h_sync)
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
