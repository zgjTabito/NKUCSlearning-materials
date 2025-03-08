`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/19 18:52:24
// Design Name: 
// Module Name: smg_ip
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


module smg_ip(clk,sm_wei,sm_duan); 
    input clk;
    output [3:0]sm_wei; 
    output [7:0]sm_duan;
//----------------------------------------------------------
    wire [15:0]data;
//----------------------------------------------------------
    test U0 (.clk(clk),.data(data));
    smg_ip_model U1 (.clk(clk),.data(data),.sm_wei(sm_wei),.sm_duan(sm_duan)); 
endmodule
