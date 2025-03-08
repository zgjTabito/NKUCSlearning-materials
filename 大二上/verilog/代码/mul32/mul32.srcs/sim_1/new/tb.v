`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/05 18:53:46
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
    parameter N = 32;
    // 输入信号
    reg [N:1] a, b;
    // 输出信号
    wire [2*N:1] res;
    // 实例化被测模块
    mul32 uut (a,b,res);

    always #10 a = $random; // 生成随机数
    always #10 b = $random;
endmodule

