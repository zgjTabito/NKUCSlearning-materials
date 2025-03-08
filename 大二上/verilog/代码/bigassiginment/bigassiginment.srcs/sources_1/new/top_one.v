`timescale 1ns / 1ps

module top_one(
    input clock,               // 时钟信号，100MHz
    input reset_n,             // 复位信号，低电平有效
    input enable,
    input load_sec,
    input load_min,
    input load_hour,
    output reg [7:0] seg,      // 段选信号（数码管）
    output reg [7:0] seg1,     // 用于秒计时的段选信号
    output reg [3:0] bit_select, // 位选信号（动态扫描）
    output reg [3:0] bit_select1, // 位选信号（动态扫描）
    output debug_clk_1hz,
    output carry_day
);



    // 分频器模块，生成 1Hz 的时钟信号
    wire clock_1hz;

    clk_divider clk_gen (
        .clock_in(clock),
        .reset(reset_n),
        .clock_out(clock_1hz)
    );
assign debug_clk_1hz = enable;
    // 中间信号
    wire s_to_m;    // 秒进位到分钟
    wire s1_to_m;   // 秒进位信号到分钟
    wire m_to_h;    // 分钟进位到小时
    wire reset;
    assign reset = ~reset_n; // 转换低电平有效的复位为高电平有效


    // 秒、分、小时数据寄存器
    reg [5:0] data_sec;
    reg [5:0] data_min;
    reg [5:0] data_hour;
    wire [5:0] count_sec;
    wire [5:0] count_min;
    wire [5:0] count_hour;

    // 复位或计数更新
    always @(posedge clock_1hz or negedge reset_n) begin
        if (!reset_n) begin
            data_sec <= 6'b0;
            data_min <= 6'b0;
            data_hour <= 6'b0;

        end 
    end


    // 秒计数模块
    counter_sec go1(
        .clock(clock_1hz),
        .reset_sec(reset),
        .enable_sec(enable),
        .load_sec(load_sec),
        .setting_sec(load_sec),
        .data_sec(data_sec),
        .count_sec(count_sec),
        .carry_sec(s_to_m),
        .carry_sec1(s1_to_m)
    );

    // 分钟计数模块
    counter_min go2(
        .clock(clock_1hz),
        .reset_min(reset),
        .enable_min(s_to_m),
        .enable_min1(s1_to_m), 
        .load_min(load_min),
        .setting_min(load_min),
        .data_min(data_min),
        .count_min(count_min),
        .carry_min(m_to_h)
    );

    // 小时计数模块
    counter_hour go3(
        .clock(clock_1hz),
        .reset_hour(reset),
        .enable_hour(m_to_h),
        .load_hour(load_hour),
        .setting_hour(load_hour),
        .data_hour(data_hour),
        .count_hour(count_hour),
        .carry_hour(carry_day) 
    );
 	
    // 动态扫描逻辑
    reg [1:0] scan_pos = 0;
    reg [19:0] scan_clk_div = 0;
    reg scan_clk = 0;

// 扫描时钟生成：100MHz -> 1kHz
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            scan_clk_div <= 0;
            scan_clk <= 0;
        end else if (scan_clk_div == 18'd49_999) begin // 修改分频值
            scan_clk_div <= 0;
            scan_clk <= ~scan_clk;
        end else begin
            scan_clk_div <= scan_clk_div + 1;
        end
    end

// 扫描位置更新
always @(posedge scan_clk or negedge reset_n) begin
    if (!reset_n)   // 低电平复位
        scan_pos <= 0;
    else
        scan_pos <= scan_pos + 1;
end


    // 当前扫描位的数字选择
    reg [3:0] current_digit;
    reg [3:0] current_digit1;
    always @(*) begin
        current_digit = 4'd0;
        current_digit1 = 4'd0;
        case (scan_pos)
            2'd0: begin
                current_digit1 = count_min % 10; // 分个位
                current_digit = count_hour / 10; // 时十位
            end
            2'd1: begin
                current_digit1 = 4'b1111; 
                current_digit =count_hour % 10; 
            end
            2'd2: begin
                current_digit = 4'b1111; 
                current_digit1 = count_sec / 10; 
            end
            2'd3: begin
                current_digit1 = count_min / 10;
                current_digit1 = count_sec % 10; 
            end
        endcase
    end

    // 段选信号生成
    always @(*) begin
        case (current_digit)
            4'd0: seg = 8'b0011_1111;
            4'd1: seg = 8'b0000_0110;
            4'd2: seg = 8'b0101_1011;
            4'd3: seg = 8'b0100_1111;
            4'd4: seg = 8'b0110_0110;
            4'd5: seg = 8'b0110_1101;
            4'd6: seg = 8'b0111_1101;
            4'd7: seg = 8'b0000_0111;
            4'd8: seg = 8'b0111_1111;
            4'd9: seg = 8'b0110_1111;
            default: seg = 8'b0000_0000; // 默认熄灭
        endcase
    end

    always @(*) begin
        case (current_digit1)
            4'd0: seg1 = 8'b0011_1111;
            4'd1: seg1 = 8'b0000_0110;
            4'd2: seg1 = 8'b0101_1011;
            4'd3: seg1 = 8'b0100_1111;
            4'd4: seg1 = 8'b0110_0110;
            4'd5: seg1 = 8'b0110_1101;
            4'd6: seg1 = 8'b0111_1101;
            4'd7: seg1 = 8'b0000_0111;
            4'd8: seg1 = 8'b0111_1111;
            4'd9: seg1 = 8'b0110_1111;
            default: seg1 = 8'b0000_0000; // 默认熄灭
        endcase
    end

    // 位选信号生成
    always @(*) begin
        bit_select = 4'b0000;
        bit_select1 = 4'b0000;
        case (scan_pos)
            2'd0: begin
                bit_select1 = 4'b0001; // 秒个位
                bit_select = 4'b0001; // 分十位
            end
            2'd1: begin
                bit_select1 = 4'b0010; // 秒十位
                bit_select=4'b0010;
            end
            2'd2: begin
                bit_select = 4'b0100; // 时个位
                bit_select1 = 4'b0100; // 时个位
            end
            2'd3: begin
              bit_select1 = 4'b1000;  // 分个位
              bit_select = 4'b1000; // 时十位
            end
        endcase
    end


endmodule
