`timescale 1ns / 1ns

module Divider
#(parameter X=100)
(
    input I_CLK,
    input rst,
    output reg O_CLK
    );
    reg [31:0]count=0;//计数器
    //分频器先出低电平
    always@(posedge I_CLK or posedge rst)
    begin
        if(rst)//复位信号高电平有效
            begin
                O_CLK<=0;
            end
        else//时钟上升沿
            begin
                if(count==(X/2-1))//中间换位
                begin
                    count<=count+1;
                    O_CLK=~O_CLK;
                end
                else if(count==(X-1))//末尾换位
                begin
                    O_CLK=~O_CLK;
                    count<=5'b00000;
                end
                else//平常情况
                begin
                    count<=count+1;
                    O_CLK=O_CLK;
                end
            end
    end
endmodule
