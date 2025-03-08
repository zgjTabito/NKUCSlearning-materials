`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 19:53:25
// Design Name: 
// Module Name: divider10
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


module divider10 (
    input clk_in,     // 输入时钟信号
    input reset,      // 复位信号
    output reg[3:0] count, // 计数器输出
    output reg clk_out // 输出的分频时钟信号
);
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            count <= 4'b0000;  // 初始化计数器为 0
            clk_out <= 1'b0; // 初始化 clk_out 为 0
        end
        else begin
            if (count == 9) begin
                count <= 4'b0000;        // 计数器归零
                clk_out <= ~clk_out;   // 反转 clk_out
            end
            else if (count == 4) begin
                 count <= count+1;
                 clk_out <= ~clk_out;   // 反转 clk_out
                 end
            else begin
                count <= count + 1;        // 计数器加 1
            end
        end
    end

endmodule
