`timescale 1ns / 1ps
// ��ȡCOE�ļ�ָ��ĵ�ַ������
module PC(
    input pc_clk,
    input pc_ena,
    input rst_n,//�ߵ�ƽ��λ
    input [31:0] pc_addr_in,//����ѡ����ѡ����´ν���ִ�е�ָ�����CPU�ļ�������룬������+4����ת
    output [31:0] pc_addr_out//����ִ�е�ָ��
    );
    // ������ִ��ָ��½��ظ���PC
    wire [31:0] pc_wire;
    reg [31:0] pc = 32'h00400000;
    assign pc_wire = pc;
    always@(posedge rst_n or negedge pc_clk)begin
        if(pc_ena && rst_n)begin
            pc <= 32'h00400000;
        end
        else if(pc_ena) begin
            pc <= pc_addr_in;
        end
    end
    assign pc_addr_out = (pc_ena) ? pc_wire : 32'hz;
endmodule
