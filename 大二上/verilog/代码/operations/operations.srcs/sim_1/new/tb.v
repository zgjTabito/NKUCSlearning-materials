`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/21 20:18:25
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
reg [7:0] a,b;
wire  sumflag;
wire [7:0] leftshiftA;
wire lessflag,equalflag;
wire [8:0] sumab;
wire bitXorflag;
operations myop(a,b,sumflag,leftshiftA,lessflag,equalflag,sumab,bitXorflag);
initial begin
    a=8'b0; b=8'b0;
end
always #5 a = $random % 9'b1_0000_0000;
always #5 b = $random % 9'b1_0000_0000;
endmodule

