`timescale 1ns / 1ns

module rotation(//旋转编码器
    input iA,   //管教A
    input iB,   //管脚B
    input SW,   //管脚D
    input rst,  //复位信号
    input clk,  //时钟信号
    output reg [1:0] oData  //处理旋转编码器的输入后，返回的编码
    );
    //reg [3:0]count;
    //将时钟分频到周期合适
    wire clk_5000Hz;
    Divider#(.X(20000)) clk_div(
        .I_CLK(clk),
        .rst(0),
        .O_CLK(clk_5000Hz)
    );
    reg flag = 1'b1;
    always@(posedge clk_5000Hz or negedge rst)begin
        if(!rst)begin
            oData<=2'b11;
        end
        else if(SW==0)begin
            oData<=2'b00;
        end
        else begin
            if(flag&&(iA!=iB))begin
                if(iA)
                    oData<=2'b01;
                else
                    oData<=2'b10;
            end
            if(iA==iB)begin
                flag=~iA;
            end
            if(!flag&&(iA==iB))
                oData<=2'b11;
        end
    end
endmodule