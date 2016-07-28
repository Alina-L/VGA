`timescale 1ns / 1ps

module SEG( input [7:0] SCANCODE,
            output [7:0] OUTPUT,
				output reg [3:0]ANODE,
				output reg [7:0] SEG1,
				input CLK
    );
	 

reg [3:0] out;

reg [15:0] cnt = 0;

always@(posedge CLK) begin
	cnt<= cnt+1;
end
always@(posedge CLK)begin
	case(cnt[15:14]) 
	2'b00:begin out = SCANCODE[3:0];
			 ANODE = 4'b1011; 
			 end
  2'b01: begin out = SCANCODE[7:4];
			 ANODE = 4'b0111; 
			 end
 endcase			 
end


always@(out) begin
	case(out) 
	  4'h0:SEG1=8'b00000011;
	  4'h1:SEG1=8'b10011111;
	  4'h2:SEG1=8'b00100101;
	  4'h3:SEG1=8'b00001101;
	  4'h4:SEG1=8'b10011001;
	  4'h5:SEG1=8'b01001001;
	  4'h6:SEG1=8'b01000001;
	  4'h7:SEG1=8'b00011111;
	  4'h8:SEG1=8'b00000001;
	  4'h9:SEG1=8'b00001001;
	  4'hA:SEG1=8'b00010001;
	  4'hB:SEG1=8'b11000001;
	  4'hC:SEG1=8'b01100011;
	  4'hD:SEG1=8'b10000101;
	  4'hE:SEG1=8'b01100001;
	  4'hF:SEG1=8'b01110001;
   endcase
end


		
endmodule
