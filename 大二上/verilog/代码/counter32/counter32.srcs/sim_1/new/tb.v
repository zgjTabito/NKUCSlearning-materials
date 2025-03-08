`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 19:33:21
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
reg [31:0] num;
wire [5:0] s1,s2;

counter32 mytest(num,s1,s2);
initial begin
    num = 32'b0;
end
always #5 num = $random%33'b1_0000_0000_0000_0000_0000_0000_0000_0000;
endmodule

