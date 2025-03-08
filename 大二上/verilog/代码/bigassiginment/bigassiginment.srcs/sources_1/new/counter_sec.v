`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/12/26 18:55:45
// Design Name: 
// Module Name: counter_sec
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


module counter_sec(
    input clock,    // 时钟信号(50MHz) 通过分频器得到每秒钟触发一次的时钟信号( 50MHz ) / ( 2^24) = 2.98 Hz
    input enable_sec,   //使能信号，表示计数器是否开始计数
    input reset_sec,    //复位信号，在高电平状态下将计数器清零。
    input load_sec,    // 加载数据模式，当接收到高电平信号时，启用加载数据模式，此时按下设置按钮可以加载新的秒数据。
	input setting_sec,   // 设置信号，当接收到高电平信号时，表示需要进行时间设置操作。   
    input [5:0] data_sec,      // 秒数据信号，6 位二进制数，用于设置计数器初始值。
    output reg [5:0]count_sec,  // 计数器输出信号，6 位二进制数，表示当前的秒数。
	output reg carry_sec,      // 进位信号，当秒计数器达到 59 时，进位信号会被置为高电平，并且允许分钟计数器执行加 1 操作。
	output reg carry_sec1   // 进位信号，当计时器达到 00:59:59 时，进位信号会被置为高电平，并且允许小时计数器执行加 1 操作 00:59:59 \rightarrow 01:00:00。
);
    
     always @ (posedge clock or posedge reset_sec )
        begin
            if (reset_sec)begin
                count_sec<=6'b000000;   // 复位秒计数器和进位控制信号
				carry_sec<=1'b0;
			end				
		     
		    else if (load_sec && setting_sec && count_sec<6'd59 ) begin   
			     count_sec<=count_sec+1;	  // 按钮按下：load +1 = sec +1
			end
			  
			else if (load_sec && setting_sec && count_sec==6'd59 ) begin          
			     count_sec<=6'b000000;	 // 按钮按下：load+1 = 59\rightarrow00
			end	
           
            else if (count_sec==6'd59 && load_sec==0 ) begin                      
		         count_sec<=6'b000000;     // 秒59 -> 00，启用分钟+1
				 carry_sec<=1'b0;          // 禁用分钟计数器+1                                            
			end	

            else if (count_sec==6'd58 && load_sec==0) begin	
                 count_sec<=count_sec+1;	   // 58\rightarrow59
				 carry_sec1<=1'b0;       // 禁用分钟进位控制信号，00:59:59 \rightarrow 01:00:00
				 carry_sec<=1'b1;         // 启用分钟计数器+1
            end			
			
            else if (count_sec==6'd57 && load_sec==0) begin	
			      count_sec<=count_sec+1;     // 57 -> 58
                  carry_sec1<=1'b1;        // 启用分钟进位控制信号，00:59:59 \rightarrow01:00:00                  
            end			

            else if (count_sec<6'd58 && enable_sec && load_sec==0) begin    // 秒计数器 + 1
		          count_sec<=count_sec+1;
				  carry_sec<=1'b0;                // 禁用分钟计数器+1  
			end	
		end		
endmodule
