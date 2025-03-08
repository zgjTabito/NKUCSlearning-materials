`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/12 18:17:29
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
    reg[2:0]indata;
    wire[7:0]outdata;
    decoder38 mydecoder(indata,outdata);
    initial begin
        indata=3'b000;
    end
    always #3 indata=indata+3'b001;
    
endmodule
