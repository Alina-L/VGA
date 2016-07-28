`timescale 1ns / 1ps

module PARALEREG( input sSDA,
						input sSCL,
						input START,
						input RST,
						output reg  [7:0] PROR,
						output reg PARITY_BIT
    );
	 
reg [3:0] cnt = 1;


always @(negedge sSCL)begin
	if(START) begin
		if(cnt<9) begin
		 PROR[cnt - 1]<=sSDA;
		 cnt <= cnt + 1;
		 end
		else if(cnt==9)begin
		 PARITY_BIT<=sSDA;
		 cnt <= cnt + 1;
		 end
		 else if(cnt == 10)
		 cnt <= 1;
	end
   else
		cnt <= 1;
end

endmodule
