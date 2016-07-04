// default values for 1024 X 768 @ 70 Hz
// polarity is negative (0) or positive (1)

	parameter screen_refresh_rate = 70,
	parameter vertical refresh = 56.4759,
	parameter pixel_freq = 75,
 	
	parameter h_sync_polarity = 0, 	
	parameter v_sync_polarity = 0,		

	parameter h_visible_area_pixels = 1024,
	parameter h_front_porch_pixels = 24,
	parameter h_sync_pulse_pixels = 136,
	parameter h_back_porch_pixels = 144,
	parameter h_whole_line_pixels = 1328,
					
	parameter h_visible_area_time = 13.653,
	parameter h_front_porch_time = 0.32,
	parameter h_sync_pulse_time = 1.813,
	parameter h_back_porch_time = 1.92,
	parameter h_whole_line_time = 17.706,
					
	parameter v_visible_area_pixels = 768,
	parameter v_front_porch_pixels = 3,
	parameter v_sync_pulse_pixels = 6,
	parameter v_back_porch_pixels = 29,
	parameter v_whole_line_pixels = 806,
					
	parameter v_visible_area_time = 13.598,
	parameter v_front_porch_time = 0.053,
	parameter v_sync_pulse_time = 0.106,
	parameter v_back_porch_time = 0.513,
	parameter v_whole_line_time = 14.271,

