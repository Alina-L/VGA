module Test_Module_VGA_Controller();

		parameter CLOCK_PERIOD = 12;
		parameter ZERO = 0; 
		parameter THRESHOLD_HSYNC   = 11'd135;
		parameter THRESHOLD_VSYNC   = 11'd5;
		parameter WHOLE_FRAME_VERTICAL =   11'b10100110000;
		parameter WHOLE_FRAME_HORIZONTAL = 11'b01100100110;
		parameter COUNTER_SIZE = 11;
		
		
		reg 						CLOCK;
		wire v_sync;
		wire h_sync;

		VGA_Controller #(ZERO, THRESHOLD_HSYNC, THRESHOLD_VSYNC, WHOLE_FRAME_VERTICAL, WHOLE_FRAME_HORIZONTAL,
									COUNTER_SIZE ) DUT(
		.control_clock(CLOCK),
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
