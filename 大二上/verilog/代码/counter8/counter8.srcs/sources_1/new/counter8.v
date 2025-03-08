`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 18:46:31
// Design Name: 
// Module Name: counter8
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


module  counter8 ( cnt,cout,data,load,clk,ena); 	
     output [7:0] cnt;
     output  cout; 			
     input [7:0] data; 			
     input load, ena,clk ;				
     reg[7:0] cnt; 
     always @(posedge clk)
        begin
            if(ena)
                begin
                    if(load)
			         	cnt <= data;                     // 同步预置数据
		            else
			         	cnt <= cnt + 1 ;      // 加1计数
                end
		end
        assign cout = &cnt & ena;   //若cnt为8'hFF，ena为1，则cout为1
endmodule
