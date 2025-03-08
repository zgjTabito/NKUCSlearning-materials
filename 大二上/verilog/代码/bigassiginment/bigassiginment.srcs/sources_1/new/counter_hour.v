`timescale 1ns / 1ps

module counter_hour( 
    input clock,                   
    input reset_hour,
    input enable_hour,
    input load_hour,          
	input setting_hour,             
    input [5:0] data_hour,          
    output reg [5:0] count_hour,    
	output reg carry_hour         
);
always @ (posedge clock or posedge reset_hour)
        begin
            if (reset_hour) begin    // ÇåÁã
                count_hour<=6'b000000;
				carry_hour<=1'b0;
			end
else if (load_hour && setting_hour && count_hour<6'd23) begin    
                             count_hour<=count_hour+1;           // load+1=sec+1                          
                       end
                             
                       else if (load_hour && setting_hour && count_hour==6'd23) begin
                             count_hour<=6'b000000;       // load hour +1 = 23 \rightarrow00                    
                       end        
                                                     
                       else if (count_hour==6'd23 && enable_hour && load_hour==0) begin
                             count_hour<=6'b000000;     // hour 23\rightarrow0                                 
                             carry_hour<=1'b1;          // day+1                                                 
                       end
                                
                       else if (count_hour>6'd23 && load_hour==0) begin                        
                              count_hour<=6'b000000;
                              carry_hour<=1'b0;       // ½ûÓÃ carry+hour                                        
                       end    
                          
                       else if (count_hour<6'd23 && enable_hour && load_hour==0) begin
                              count_hour<=count_hour+1;                                                     
                              carry_hour<=1'b0;       // ½ûÓÃ carry+hour                                         
                       end                                  
                    end                
            endmodule
