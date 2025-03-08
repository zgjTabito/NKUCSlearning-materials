`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 21:04:13
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


module testbench(

    );
    reg tempa,tempb;//输入定义为reg
        wire tusm,tc;//输出定义为wire
        halfadder myha(tempa,tempb,tsum,tc);
        initial begin
            tempa=1'b0;
            tempb=1'b0;
        end
        always #5 tempa=~tempa;
        always #3 tempb=~tempb;
endmodule
