`timescale 1ns / 1ps
// 对指令进行解析，判断32位指令对应的功能，取出相应的字段
module Decoder(
    input [31:0] instr,//指令
    output is_add,
    output is_addu,
    output is_sub,
    output is_subu,
    output is_and,
    output is_or,
    output is_xor,
    output is_nor,
    output is_slt,
    output is_sltu,
    output is_sll,
    output is_srl,
    output is_sra,
    output is_sllv,
    output is_srlv,
    output is_srav,
    output is_jr,
    output is_addi,
    output is_addiu,
    output is_andi,
    output is_ori,
    output is_xori,
    output is_lw,
    output is_sw,
    output is_beq,
    output is_bne,
    output is_slti,
    output is_sltiu,
    output is_lui,
    output is_j,
    output is_jal,
    output [4:0] Rsc,
    output [4:0] Rtc,
    output [4:0] Rdc,
    output [4:0] shamt,
    output [15:0] imm,
    output [25:0] addr
    //new
    ,output is_clz,output is_jalr,output is_mthi,output is_mtlo,output is_mfhi,
    output is_mflo,output is_sb,output is_sh,output is_lb,output is_lh,
    output is_lbu,output is_lhu,output is_eret,output is_break,output is_syscall,
    output is_teq,output is_mfc0,output is_mtc0,output is_mul,output is_multu,
    output is_div,output is_divu,output is_bgez
//    ,output [4:0]base//基址寄存器编号
    ,output [4:0]dec_cause//中断原因
    );
    //cp0
    parameter SYSCALL = 5'b01000, BREAK = 5'b01001, TEQ = 5'b01101;
    
    assign is_add = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100000) ? 1'b1 : 1'b0;
    assign is_addu= (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100001) ? 1'b1 : 1'b0;
    assign is_sub = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100010) ? 1'b1 : 1'b0;
    assign is_subu= (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100011) ? 1'b1 : 1'b0;
    assign is_and = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100100) ? 1'b1 : 1'b0;
    assign is_or  = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100101) ? 1'b1 : 1'b0;
    assign is_xor = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100110) ? 1'b1 : 1'b0;
    assign is_nor = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b100111) ? 1'b1 : 1'b0;
    
    assign is_slt = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b101010) ? 1'b1 : 1'b0;
    assign is_sltu= (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b101011) ? 1'b1 : 1'b0;
    
    assign is_sll = (instr[31:21] == 11'b0) && (instr[5:0] == 6'b000000) ? 1'b1 : 1'b0;
    assign is_srl = (instr[31:21] == 11'b0) && (instr[5:0] == 6'b000010) ? 1'b1 : 1'b0;
    assign is_sra = (instr[31:21] == 11'b0) && (instr[5:0] == 6'b000011) ? 1'b1 : 1'b0;
    
    assign is_sllv = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b000100) ? 1'b1 : 1'b0;
    assign is_srlv = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b000110) ? 1'b1 : 1'b0;
    assign is_srav = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b000111) ? 1'b1 : 1'b0;
    assign is_jr   = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b001000) ? 1'b1 : 1'b0;
    
    assign is_addi = (instr[31:26] == 6'b001000) ? 1'b1 : 1'b0;
    assign is_addiu= (instr[31:26] == 6'b001001) ? 1'b1 : 1'b0;
    assign is_andi = (instr[31:26] == 6'b001100) ? 1'b1 : 1'b0;
    assign is_ori  = (instr[31:26] == 6'b001101) ? 1'b1 : 1'b0;
    assign is_xori = (instr[31:26] == 6'b001110) ? 1'b1 : 1'b0;
    
    assign is_lw   = (instr[31:26] == 6'b100011) ? 1'b1 : 1'b0;
    assign is_sw   = (instr[31:26] == 6'b101011) ? 1'b1 : 1'b0;
    
    assign is_beq  = (instr[31:26] == 6'b000100) ? 1'b1 : 1'b0;
    assign is_bne  = (instr[31:26] == 6'b000101) ? 1'b1 : 1'b0;
    assign is_slti = (instr[31:26] == 6'b001010) ? 1'b1 : 1'b0;
    assign is_sltiu= (instr[31:26] == 6'b001011) ? 1'b1 : 1'b0;
    assign is_lui  = (instr[31:26] == 6'b001111) ? 1'b1 : 1'b0;
    
    assign is_j    = (instr[31:26] == 6'b000010) ? 1'b1 : 1'b0;
    assign is_jal  = (instr[31:26] == 6'b000011) && (instr[25:21] == 0) ? 1'b1 : 1'b0;
    
    //new
    assign is_clz  = (instr[31:26] == 6'b011100) && (instr[5:0] == 6'b100000) ? 1'b1 : 0;
    assign is_jalr = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b001001) ? 1'b1 : 0;
    
    assign is_mthi = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b010001) ? 1'b1 : 0;
    assign is_mtlo = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b010011) ? 1'b1 : 0;
    assign is_mfhi = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b010000) ? 1'b1 : 0;
    assign is_mflo = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b010010) ? 1'b1 : 0;
    
    assign is_sb   = (instr[31:26] == 6'b101000) ? 1'b1 : 0;
    assign is_sh   = (instr[31:26] == 6'b101001) ? 1'b1 : 0;
    assign is_lb   = (instr[31:26] == 6'b100000) ? 1'b1 : 0;
    assign is_lh   = (instr[31:26] == 6'b100001) ? 1'b1 : 0;
    assign is_lbu  = (instr[31:26] == 6'b100100) ? 1'b1 : 0;
    assign is_lhu  = (instr[31:26] == 6'b100101) ? 1'b1 : 0;
    
    assign is_eret = (instr[31:26] == 6'b010000) && (instr[5:0] == 6'b011000) ? 1'b1 : 0;
    assign is_break  =(instr[31:26] == 6'b000000) && (instr[5:0] == 6'b001101) ? 1'b1 : 0;
    assign is_syscall=(instr[31:26] == 6'b000000) && (instr[5:0] == 6'b001100) ? 1'b1 : 0;
    assign is_teq  = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b110100) ? 1'b1 : 0;
    assign is_mfc0 = (instr[31:26] == 6'b010000) && (instr[5:0] == 0) && (instr[25:21] == 5'b00000) ? 1 : 0;
    assign is_mtc0 = (instr[31:26] == 6'b010000) && (instr[5:0] == 0) && (instr[25:21] == 5'b00100) ? 1 : 0;
    
    assign is_mul  = (instr[31:26] == 6'b011100) && (instr[5:0] == 6'b000010) ? 1'b1 : 0;
    assign is_multu= (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b011001) ? 1'b1 : 0;
    assign is_div  = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b011010) ? 1'b1 : 0;
    assign is_divu = (instr[31:26] == 6'b000000) && (instr[5:0] == 6'b011011) ? 1'b1 : 0;
    
    assign is_bgez = (instr[31:26] == 6'b000001) && (instr[20:16] == 5'b00001) ? 1'b1 : 0;
    
    assign Rsc = (is_add | is_addu | is_sub | is_subu | is_and | is_or | is_xor | is_nor|
                  is_slt | is_sltu | is_sllv | is_srlv | is_srav | is_jr |
                  is_addi | is_addiu | is_andi | is_ori | is_xori | is_lw | is_sw |
                  is_beq | is_bne | is_slti | is_sltiu |
                  is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu |
                  is_clz | is_jalr | is_mthi | is_mtlo | is_teq | is_mul | is_multu | is_div | is_divu | is_bgez) ? instr[25:21] : 5'bz;
    assign Rtc = (is_add | is_addu | is_sub | is_subu | is_and | is_or | is_xor | is_nor|
                  is_slt | is_sltu | is_sllv | is_srlv | is_srav |
                  is_sll | is_srl | is_sra | is_lui |
                  is_addi | is_addiu | is_andi | is_ori | is_xori | is_lw | is_sw |
                  is_beq | is_bne | is_slti | is_sltiu |
                  is_clz | is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu | is_teq | is_mfc0 | is_mtc0 | is_mul | is_multu |
                  is_div | is_divu) ? instr[20:16] :5'bz;
    assign Rdc = (is_addi | is_addiu | is_andi | is_ori | is_xori | is_lw | is_slti | is_sltiu | is_lui) ? instr[20:16] : 
                 (is_jal) ? 5'd31 :
                 (is_add | is_addu | is_sub | is_subu | is_and | is_or | is_xor | is_nor |
                  is_slt | is_sltu | is_sllv | is_srlv | is_srav | is_sll | is_srl | is_sra | 
                  is_clz | is_jalr | is_mfhi | is_mflo | is_mul | is_mfc0 | is_mtc0) ? instr[15:11] : 5'bz;
    assign shamt = (is_sll | is_srl | is_sra) ? instr[10:6] : 5'bz;
    assign imm = (is_addi | is_addiu | is_andi | is_ori | is_xori | is_lw | is_sw |
                  is_beq | is_bne | is_slti | is_sltiu | is_lui |
                  is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu | is_bgez) ? instr[15:0] : 16'bz;
    assign addr= (is_j | is_jal) ? instr[25:0] : 26'bz;
    
    //new
//    assign base = (is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu) ? instr[25:21] : 5'bz;
    assign dec_cause = (is_break) ? BREAK : (is_syscall) ? SYSCALL : (is_teq) ? TEQ : 5'bz;
endmodule
