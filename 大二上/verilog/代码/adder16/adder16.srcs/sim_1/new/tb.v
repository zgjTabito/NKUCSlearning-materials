`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/21 18:45:17
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb();
reg[15:0] a,b;
reg cin;
wire[15:0]tsum;
wire tcout;
adder16 myunit(a,b,cin,tsum,tcout);
initial begin
    a=16'd0;b=16'd0;b=1'b0;
end
always #3 a=$random%17'b1_0000_0000_0000_0000;
always #5 b=$random%17'b1_0000_0000_0000_0000;
endmodule
