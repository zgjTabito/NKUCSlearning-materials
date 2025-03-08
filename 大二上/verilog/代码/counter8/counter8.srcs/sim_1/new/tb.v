`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 18:56:30
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


module tb(

    );
       reg [7:0] data;        // 输入数据
       reg load, ena, clk;    // 输入信号
       wire [7:0] cnt;        // 计数器输出
       wire cout;             // 进位输出
   
       // 实例化 counter8 模块
       counter8 uut (
           .cnt(cnt),
           .cout(cout),
           .data(data),
           .load(load),
           .ena(ena),
           .clk(clk)
       );
   
       // 时钟生成：每 10 ns 切换一次
       always begin
           #5 clk = ~clk;  // 时钟周期 10ns
       end
   
       initial begin
        // 测试 1: 加载数据到计数器
          ena=0;
          load = 1;    // 使能加载数据
          data = 8'b10101010; // 设置加载数据为 8'b10101010
          #10;         // 等待一个时钟周期
          ena = 1;     // 使能计数
          clk = 0;
          load = 0;
           #10;
           data = 8'b11111111; // 设置数据为 8'hFF
           load = 1;            // 加载数据
           #10;                 // 等待一个时钟周期
           load = 0;            // 禁用加载数据
       end
    
endmodule
