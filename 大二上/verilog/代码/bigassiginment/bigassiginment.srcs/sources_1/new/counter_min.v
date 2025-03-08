`timescale 1ns / 1ps

module counter_min(
    input clock,  
    input reset_min, 
    input enable_min,     
    input enable_min1,    
    input load_min,      
    input setting_min,      
    input [5:0] data_min,      
    output reg [5:0]count_min,    
	output reg carry_min        
);
always @ (posedge clock or posedge reset_min)
        begin
            if (reset_min)begin     // 清零
                count_min<=6'b000000;
				carry_min<=1'b0;                                                
			end
else if (load_min && setting_min && count_min<6'd59) begin      
			    count_min<=count_min+1;	  // load+1=min+1
			end
else if (load_min && setting_min && count_min==6'd59) begin
                            count_min<=6'b000000;   // load+1=59\rightarrow00
                    end 
            
                    else if (count_min==6'd59 && enable_min1 && load_min==0 ) begin    // min=59    
                            carry_min<=1'b1;       // counter_hour +1                                 
                    end                
                            
                    else if (count_min==6'd59 && enable_min && load_min==0) begin    
                            count_min<=6'b000000;        // 00:59:59 \rightarrow 01:00:00                                 
                            carry_min<=1'b0;            // 禁用counter_min +1
                    end                
                        
                    else if (count_min==0 && enable_min==0 && load_min==0) begin
                            carry_min<=1'b0;           // 禁用counter_min +1
                    end        
                        
                    else if (count_min<6'd59 && enable_min && load_min==0) begin
                            count_min<=count_min+1;       // counter_min +1                                    
                            carry_min<=1'b0;             // 禁用 counter_min +1
                    end                                  
                 end        
            endmodule
