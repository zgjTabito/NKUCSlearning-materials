`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 19:56:03
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

    // 定义测试模块的信号
    reg clk_in;       // 输入时钟信号
    reg reset;        // 复位信号
    wire[3:0] count;       // 计数器输出信号
    wire clk_out;     // 输出的分频时钟信号

    // 实例化 divider10 模块
    divider10 uut (clk_in,reset,count,clk_out);

    // 产生测试时钟
    always begin
        #5 clk_in = ~clk_in;  // 每 5 个时间单位反转一次 clk_in，相当于周期 10ns
    end

     // 初始化信号
       initial begin
           clk_in = 1;      // 初始时钟为 0           
           reset = 1;       // 施加复位
           #5;              // 维持复位 5ns
           reset = 0;       // 解除复位
       end

endmodule
