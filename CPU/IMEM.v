`timescale 1ns / 1ps
// 根据PC地址从IP核的COE文件中读取指令，在ALU、DMEM中进行操作
module IMEM(
    input [10:0] im_addr_in,
    output [31:0] out_instr
    );
    dist_mem_gen_0 your_instance_name (
      .a(im_addr_in),      // input wire [10 : 0] a
      .spo(out_instr)      // output wire [31 : 0] spo
    );
endmodule
