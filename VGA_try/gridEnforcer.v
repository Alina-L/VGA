`timescale 1ns / 1ps

module gridEnforcer(
input [10:0] POS_X,//adress from VGA_int for x coordinate
input [10:0] POS_Y,//adress from VGA_int for y coordinate
output reg [4:0] GRID_X,//adress to RAM for x coordinate
output reg [4:0] GRID_Y//adress to RAM for y coordinate
);

always @ (*) begin
if(POS_X >= 32*0 + 112 &&  POS_X < 32*1 + 112) GRID_X = 0;
if(POS_X >= 32*1 + 112 &&  POS_X < 32*2 + 112) GRID_X = 1;
if(POS_X >= 32*2 + 112 &&  POS_X < 32*3 + 112) GRID_X = 2;
if(POS_X >= 32*3 + 112 &&  POS_X < 32*4 + 112) GRID_X = 3;
if(POS_X >= 32*4 + 112 &&  POS_X < 32*5 + 112) GRID_X = 4;
if(POS_X >= 32*5 + 112 &&  POS_X < 32*6 + 112) GRID_X = 5;
if(POS_X >= 32*6 + 112 &&  POS_X < 32*7 + 112) GRID_X = 6;
if(POS_X >= 32*7 + 112 &&  POS_X < 32*8 + 112) GRID_X = 7;
if(POS_X >= 32*8 + 112 &&  POS_X < 32*9 + 112) GRID_X = 8;
if(POS_X >= 32*9 + 112 &&  POS_X < 32*10 + 112) GRID_X = 9;
if(POS_X >= 32*10 + 112 &&  POS_X < 32*11 + 112) GRID_X = 10;
if(POS_X >= 32*11 + 112 &&  POS_X < 32*12 + 112) GRID_X = 11;
if(POS_X >= 32*12 + 112 &&  POS_X < 32*13 + 112) GRID_X = 12;
if(POS_X >= 32*13 + 112 &&  POS_X < 32*14 + 112) GRID_X = 13;
if(POS_X >= 32*14 + 112 &&  POS_X < 32*15 + 112) GRID_X = 14;
if(POS_X >= 32*15 + 112 &&  POS_X < 32*16 + 112) GRID_X = 15;
if(POS_X >= 32*16 + 112 &&  POS_X < 32*17 + 112) GRID_X = 16;
if(POS_X >= 32*17 + 112 &&  POS_X < 32*18 + 112) GRID_X = 17;
if(POS_X >= 32*18 + 112 &&  POS_X < 32*19 + 112) GRID_X = 18;
if(POS_X >= 32*19 + 112 &&  POS_X < 32*20 + 112) GRID_X = 19;
end

always @ (*) begin
if(POS_Y >= 17*0 + 39 &&  POS_Y < 17*1 + 39) GRID_Y = 0;
if(POS_Y >= 17*1 + 39 &&  POS_Y < 17*2 + 39) GRID_Y = 1;
if(POS_Y >= 17*2 + 39 &&  POS_Y < 17*3 + 39) GRID_Y = 2;
if(POS_Y >= 17*3 + 39 &&  POS_Y < 17*4 + 39) GRID_Y = 3;
if(POS_Y >= 17*4 + 39 &&  POS_Y < 17*5 + 39) GRID_Y = 4;
if(POS_Y >= 17*5 + 39 &&  POS_Y < 17*6 + 39) GRID_Y = 5;
if(POS_Y >= 17*6 + 39 &&  POS_Y < 17*7 + 39) GRID_Y = 6;
if(POS_Y >= 17*7 + 39 &&  POS_Y < 17*8 + 39) GRID_Y = 7;
if(POS_Y >= 17*8 + 39 &&  POS_Y < 17*9 + 39) GRID_Y = 8;
if(POS_Y >= 17*9 + 39 &&  POS_Y < 17*10 + 39) GRID_Y = 9;
if(POS_Y >= 17*10 + 39 &&  POS_Y < 17*11 + 39) GRID_Y = 10;
if(POS_Y >= 17*11 + 39 &&  POS_Y < 17*12 + 39) GRID_Y = 11;
if(POS_Y >= 17*12 + 39 &&  POS_Y < 17*13 + 39) GRID_Y = 12;
if(POS_Y >= 17*13 + 39 &&  POS_Y < 17*14 + 39) GRID_Y = 13;
if(POS_Y >= 17*14 + 39 &&  POS_Y < 17*15 + 39) GRID_Y = 14;
if(POS_Y >= 17*15 + 39 &&  POS_Y < 17*16 + 39) GRID_Y = 15;
if(POS_Y >= 17*16 + 39 &&  POS_Y < 17*17 + 39) GRID_Y = 16;
if(POS_Y >= 17*17 + 39 &&  POS_Y < 17*18 + 39) GRID_Y = 17;
if(POS_Y >= 17*18 + 39 &&  POS_Y < 17*19 + 39) GRID_Y = 18;
if(POS_Y >= 17*19 + 39 &&  POS_Y < 17*20 + 39) GRID_Y = 19;

end




endmodule
