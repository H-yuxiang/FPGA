`timescale 1ns / 1ps
// ����PC��ַ��IP�˵�COE�ļ��ж�ȡָ���ALU��DMEM�н��в���
module IMEM(
    input [10:0] im_addr_in,
    output [31:0] out_instr
    );
    dist_mem_gen_0 your_instance_name (
      .a(im_addr_in),      // input wire [10 : 0] a
      .spo(out_instr)      // output wire [31 : 0] spo
    );
endmodule
