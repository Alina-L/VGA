// default values for 1024 X 768 @ 70 Hz timing
// polarity is negative (0) or positive (1) 
// the rest of the values are pixels

	parameter pixel_freq = 75;		//MHz
 	
	parameter h_sync_polarity = 0; 	
	parameter v_sync_polarity = 0;		

	parameter h_visible_area = 1024;
	parameter h_front_porch = 24;
	parameter h_sync_pulse = 136;
	parameter h_back_porch = 144;
	parameter h_whole_line = 1328;
					
	parameter v_visible_area = 768;
	parameter v_front_porch = 3;
	parameter v_sync_pulse = 6;
	parameter v_back_porch = 29;
	parameter v_whole_line = 806;

