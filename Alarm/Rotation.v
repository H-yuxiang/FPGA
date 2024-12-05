`timescale 1ns / 1ns

module rotation(//��ת������
    input iA,   //�ܽ�A
    input iB,   //�ܽ�B
    input SW,   //�ܽ�D
    input rst,  //��λ�ź�
    input clk,  //ʱ���ź�
    output reg [1:0] oData  //������ת������������󣬷��صı���
    );
    //reg [3:0]count;
    //��ʱ�ӷ�Ƶ�����ں���
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