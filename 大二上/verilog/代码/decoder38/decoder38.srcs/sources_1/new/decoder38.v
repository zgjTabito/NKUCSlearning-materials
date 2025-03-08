`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 18:11:23
// Design Name: 
// Module Name: decoder38
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


module decoder38(
    input[2:0] myin,
    output[7:0]myout
    );
    
    assign myout=(myin==3'b001)?8'b0000_0001:
                 (myin==3'b010)?8'b0000_0010:
                 (myin==3'b011)?8'b0000_0100:
                 (myin==3'b100)?8'b0000_1000:
                 (myin==3'b101)?8'b0001_0000:
                 (myin==3'b110)?8'b0010_0000:
                 (myin==3'b111)?8'b0100_0000:
                 8'b1000_0000;
                 
                 
endmodule
