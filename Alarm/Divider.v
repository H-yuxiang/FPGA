`timescale 1ns / 1ns

module Divider
#(parameter X=100)
(
    input I_CLK,
    input rst,
    output reg O_CLK
    );
    reg [31:0]count=0;//������
    //��Ƶ���ȳ��͵�ƽ
    always@(posedge I_CLK or posedge rst)
    begin
        if(rst)//��λ�źŸߵ�ƽ��Ч
            begin
                O_CLK<=0;
            end
        else//ʱ��������
            begin
                if(count==(X/2-1))//�м任λ
                begin
                    count<=count+1;
                    O_CLK=~O_CLK;
                end
                else if(count==(X-1))//ĩβ��λ
                begin
                    O_CLK=~O_CLK;
                    count<=5'b00000;
                end
                else//ƽ�����
                begin
                    count<=count+1;
                    O_CLK=O_CLK;
                end
            end
    end
endmodule
