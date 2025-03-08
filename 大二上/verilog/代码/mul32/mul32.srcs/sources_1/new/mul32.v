`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 18:52:48
// Design Name: 
// Module Name: mul32
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


module mul32(a,b,res);
    parameter N = 32;
    output [2*N:1] res;
    input [N:1] a,b;
    reg [2*N:1] temp;   //中间变量来存储结果
    integer i;
    always@(a or b)
    begin
    temp=0;
   	for(i=1;i<=N;i=i+1)  //用b的每位分别去乘a，当b[i]=1时，b[i]*a的结果为a左移i-1位，最后将所有结果求和即实现了乘法。
        if(b[i])  //上述思路可简化为下面的语句
            temp = temp + (a << (i-1)); 
    end
    assign res = temp;
endmodule

