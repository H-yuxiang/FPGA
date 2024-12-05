`timescale 1ns / 1ps
// top
module sccomp_dataflow(
    input clk_in,
    input reset,
    //ǰ���桢�����
    output [31:0] inst,
    output [31:0] pc
    //�°�
//    output [7:0] o_seg,
//    output [7:0] o_sel
    );
    // CPU��Ҫ��ֵ
    wire [31:0] instruction;
    wire [31:0] dmem_data_read;//DMEM�ж�������
    
    // CPU���ص�ֵ
    wire [31:0] dmem_data_write;//��DMEM��д������
    wire dmem_ena,dmem_w,dmem_r;
    wire [31:0] pc_out;//pc_out���е�ĳ11λ����IMEM�Ի�ȡָ��
    wire [31:0] dmem_addr;//��DMEM��ȡ��ʱ��ALU����Ľ������һ����ַ
    wire [31:0] ALU_res;
    
    // IMEM��ȡָ��ĵ�ַ
    wire [31:0] im_addr;
    assign im_addr = pc_out - 32'h00400000;//[12:2]����Ϊ+4��+2'b100
    
    // DMEM��ȡʱ���õ�������ַ
    wire [31:0] dmem_addr_real;
    wire [1:0] b_r;
    wire [1:0] h_r;
    assign dmem_addr_real = (dmem_addr - 32'h10010000) / 4;//������DMEM�еĵ�ַ[10:0]->[6:0]���ܹؼ���������
    assign b_r = (dmem_addr - 32'h10010000) % 4;
    assign h_r = (dmem_addr - 32'h10010000) % 4;
    
    // �°� cpu���� cpu/dmem
//    wire clk_cpu;
//    Divider divider(
//        .clk(clk_in),.reset(reset),.clk_out(clk_cpu)
//    );
    
    // ʵ����
    IMEM imem(
        .im_addr_in(im_addr[12:2]),.out_instr(instruction)
    );
    //dmem ������
    wire is_sw,is_lw,is_sb,is_sh,is_lb,is_lh,is_lbu,is_lhu;
    CPU sccpu(
        .clk(clk_in),.ena(1'b1),.rst_n(reset),.instr(instruction),.dmem_data(dmem_data_read),
        .dmem_data_to_write(dmem_data_write),.dmem_ena(dmem_ena),.dmem_w(dmem_w),.dmem_r(dmem_r),
        .pc_out(pc_out),.dmem_addr(dmem_addr),.ALU_res(ALU_res)
        ,.issw(is_sw),.islw(is_lw),.issb(is_sb),.issh(is_sh),.islb(is_lb),.islh(is_lh),.islbu(is_lbu),.islhu(is_lhu)
    );
    DMEM dmem(
        .dmem_clk(clk_in),.dmem_ena(dmem_ena),.dmem_r(dmem_r),.dmem_w(dmem_w),.dmem_addr(dmem_addr_real[6:0]),
        .dmem_data_in(dmem_data_write),.dmem_data_out(dmem_data_read)
        ,.is_sw(is_sw),.is_lw(is_lw),.is_sb(is_sb),.is_sh(is_sh),.is_lb(is_lb),.is_lh(is_lh),.is_lbu(is_lbu),.is_lhu(is_lhu)
        //new
        ,.b_r(b_r),.h_r(h_r)
    );
    
    // ǰ�������output
    assign pc = pc_out;
    assign inst = instruction;
    
    // �°�output
//    seg7x16 seg7x16_inst(
//        .clk(clk_in),.reset(reset),.cs(1'b1),.i_data(pc_out),.o_seg(o_seg),.o_sel(o_sel)
//    );
    
endmodule
