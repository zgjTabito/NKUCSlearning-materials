`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 19:32:45
// Design Name: 
// Module Name: counter32
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


module counter32(
input [31:0] num,   //输入的32位二进制数;
output [5:0] ret1,ret0   //分别用来存储1和0出现的次数;
    );
    reg [5:0] count1,count0;  //临时变量统计次数最后赋值给ret1和ret0;
    integer i;
    always @(num)
begin
    count1=0;
    count0=0;
    for(i=0;i<=31;i=i+1)  //利用for循环统计1和0的个数;
    if(num[i]) count1 = count1+1;  //该位为1 ，count+1;
    else count0 = count0+1;      //该位为0，count0+1;
end
    assign ret1 = count1;
    assign ret0 = count0;
endmodule

