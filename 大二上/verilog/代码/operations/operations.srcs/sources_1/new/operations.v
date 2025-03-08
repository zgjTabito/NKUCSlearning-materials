`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/21 20:13:52
// Design Name: 
// Module Name: operations
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


module operations(
    input [7:0] ina,inb,
output  sumflag,
output [7:0] leftshiftA, //移位会发生溢出，位数最大可以为263（8+255）位，这里直接舍弃，故当(b)10大于8时，无论a为多少，结果都为0
output lessflag,equalflag,
output [8:0] sumab,  //设置为9位位宽，两个8位二进制数相加最大不会超过9位
output bitXorflag
    );
    assign sumab = ina + inb;    
    assign sumflag = (ina + inb) > 255 ? 1:0 ;  //超过8位（十进制为255）则进位为1
    assign leftshiftA = ina<<inb;
    assign lessflag = (ina < inb) ? 1:0 ;
    assign equalflag = (ina === inb) ? 1:0 ;
    assign bitXorflag = ^ina;
endmodule

