`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/14 20:29:13
// Design Name: 
// Module Name: fulladd
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


module fulladd(
   input a,
   input b,
   input ci,
   output sum,
   output co
   );
   wire t1,t2,t3;
   halfadder myha1(a,b,t1,t2);
   halfadder myad2(t1,ci,sum,t3);
   assign co=t2^t3;
    
    
endmodule
