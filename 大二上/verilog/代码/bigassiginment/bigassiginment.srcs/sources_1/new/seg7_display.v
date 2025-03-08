`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/26 19:49:31
// Design Name: 
// Module Name: seg7_display
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


module seg7_display (
    input [3:0] digit,  // 4位BCD数值（0-9）
    output reg [7:0] seg7  // 7段数码管显示编码（a~g 和 dp）
);
    always @(*) begin
        case(digit)
            4'b0000: seg7 = 8'b01111110;  // 0
            4'b0001: seg7 = 8'b00110000;  // 1
            4'b0010: seg7 = 8'b01101101;  // 2
            4'b0011: seg7 = 8'b01111001;  // 3
            4'b0100: seg7 = 8'b00110011;  // 4
            4'b0101: seg7 = 8'b01011011;  // 5
            4'b0110: seg7 = 8'b01011111;  // 6
            4'b0111: seg7 = 8'b01110000;  // 7
            4'b1000: seg7 = 8'b01111111;  // 8
            4'b1001: seg7 = 8'b01111011;  // 9
            default: seg7 = 8'b01111110;  // 默认显示0
        endcase
    end
endmodule
