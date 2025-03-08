`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/27 16:55:02
// Design Name: 
// Module Name: clk_divider
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


module clk_divider (
    input clock_in,     // 输入时钟 100MHz
    input reset,      // 低电平复位
    output reg clock_out // 输出1Hz时钟
);
    reg [24:0] counter; // 25 位计数器

    always @(posedge clock_in or negedge reset) begin
        if (!reset) begin
            counter <= 0;
            clock_out <= 0; // 初始化输出时钟
        end else if (counter == 25'd24999999) begin // 分频到 1Hz
            counter <= 0;
            clock_out <= ~clock_out; // 翻转输出时钟
        end else begin
            counter <= counter + 1;
        end
    end
endmodule


