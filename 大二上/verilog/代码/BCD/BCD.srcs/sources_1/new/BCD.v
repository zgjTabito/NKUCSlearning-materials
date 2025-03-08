`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 19:48:34
// Design Name: 
// Module Name: BCD
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// reset
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module BCD(
    input clk,              // 输入时钟
    input button,           // 按钮输入
    input reset,            // 复位输入
    output reg[7:0] seg,    // 数码管显示的段选信号
    output reg[1:0] digit_select  // 数码管的位选择信号
);

    reg [7:0] tens_seg;       // 十位数码管显示信号
    reg [7:0] ones_seg;       // 个位数码管显示信号

    reg clk_400Hz;            // 400Hz 时钟信号
    reg [24:0] clk_400Hz_counter; // 计数器用于时钟分频

    reg [5:0] countdown;      // 倒计时计数器，最大支持 40 秒

    reg button_prev;          // 存储上一个按钮状态，用于检测边沿

    // 控制数码管选择信号：切换显示十位和个位
    always @(posedge clk_400Hz or posedge reset) begin
        if (reset) begin
            digit_select <= 2'b01;  // 默认为显示十位
            seg <= tens_seg;
        end 
        else begin
            if (digit_select == 2'b01) begin
                digit_select <= 2'b10;  // 切换到显示个位
                seg <= tens_seg;
            end else begin
                digit_select <= 2'b01;  // 切换到显示十位
                seg <= ones_seg;
            end
        end
    end

    // 时钟分频器：从 100MHz 时钟分频为 400Hz 时钟
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_400Hz_counter <= 0;
            clk_400Hz <= 0;
        end else begin
            if (clk_400Hz_counter == 25_000_0) begin  // 100 MHz -> 400Hz
                clk_400Hz <= ~clk_400Hz;
                clk_400Hz_counter <= 0;
            end else begin
                clk_400Hz_counter <= clk_400Hz_counter + 1;
            end
        end
    end

    // 计数器更新逻辑：按钮由 0 到 1 时增加计数
    always @(posedge clk_400Hz or posedge reset) begin
        if (reset) begin
            countdown <= 0;   // 复位时计数器清零
            button_prev <= 0; // 初始化按钮上一个状态为 0
        end else begin
            // 边沿检测：按钮由 0 到 1 时增加计数
            if (button && !button_prev) begin
                if (countdown == 40) begin
                    countdown <= 0;  // 计数到40时重置
                end else begin
                    countdown <= countdown + 1;  // 按钮按下时加1
                end
            end
            button_prev <= button;  // 更新按钮状态
        end
    end

    // 数码管显示逻辑
    always @(countdown) begin
        // 显示十位
        case (countdown / 10)
            4: tens_seg = 8'b00110011; // 显示 4
            3: tens_seg = 8'b01111001; // 显示 3
            2: tens_seg = 8'b01101101; // 显示 2
            1: tens_seg = 8'b00110000; // 显示 1
            default: tens_seg = 8'b00000000; // 关闭显示
        endcase

        // 显示个位
        case (countdown % 10)
            0: ones_seg = 8'b01111110; // 显示 0
            1: ones_seg = 8'b00110000; // 显示 1
            2: ones_seg = 8'b01101101; // 显示 2
            3: ones_seg = 8'b01111001; // 显示 3
            4: ones_seg = 8'b00110011; // 显示 4
            5: ones_seg = 8'b01011011; // 显示 5
            6: ones_seg = 8'b01011111; // 显示 6
            7: ones_seg = 8'b01110000; // 显示 7
            8: ones_seg = 8'b01111111; // 显示 8
            9: ones_seg = 8'b01111011; // 显示 9
            default: ones_seg = 8'b00000000; // 关闭显示
        endcase
    end

endmodule
