`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/17 13:02:14
// Design Name: 
// Module Name: addeight
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


module addeight(
    input [7:0] ain,
    input [7:0] bin,
    input cin,
    output [7:0] sumout,
    output cout
    );
    wire [7:0] carry;
    fulladd fad0(ain[0], bin[0], cin, sumout[0], carry[0]);
    fulladd fad1(ain[1], bin[1], carry[0], sumout[1], carry[1]);
    fulladd fad2(ain[2], bin[2], carry[1], sumout[2], carry[2]);
    fulladd fad3(ain[3], bin[3], carry[2], sumout[3], carry[3]);
    fulladd fad4(ain[4], bin[4], carry[3], sumout[4], carry[4]);
    fulladd fad5(ain[5], bin[5], carry[4], sumout[5], carry[5]);
    fulladd fad6(ain[6], bin[6], carry[5], sumout[6], carry[6]);
    fulladd fad7(ain[7], bin[7], carry[6], sumout[7], carry[7]);
    assign cout=carry[7];
endmodule
