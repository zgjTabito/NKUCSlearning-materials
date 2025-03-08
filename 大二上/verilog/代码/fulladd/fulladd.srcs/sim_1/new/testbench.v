`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/16 16:36:52
// Design Name: 
// Module Name: testbench
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


module testbench();
    reg [7:0] tempa,tempb;
    reg tempci;
    wire [7:0] tempsum;
    wire tempco;
    addeight ea(tempa,tempb,tempci,tempsum,tempco);
    initial begin
        tempa=8'b0000_0000;
        tempb=8'b0000_0000;
        tempci=1'b0;
    end
    always #3 tempa = $random % 9'b1_0000_0000;
    always #5 tempb = $random % 9'b1_0000_0000;
    always #7 tempci=~tempci;
    
endmodule
