`timescale 1ns / 1ps
// 根据指令，产生MUX控制、ALUC信号、rf_w、dmem_r、dmem_w、cat_ena
module Controller(
    input is_add,
    input is_addu,
    input is_sub,
    input is_subu,
    input is_and,
    input is_or,
    input is_xor,
    input is_nor,
    input is_slt,
    input is_sltu,
    input is_sll,
    input is_srl,
    input is_sra,
    input is_sllv,
    input is_srlv,
    input is_srav,
    input is_jr,
    input is_addi,
    input is_addiu,
    input is_andi,
    input is_ori,
    input is_xori,
    input is_lw,
    input is_sw,
    input is_beq,
    input is_bne,
    input is_slti,
    input is_sltiu,
    input is_lui,
    input is_j,
    input is_jal,
    output [4:0]ALUC,
    output rf_w,
    output dmem_r,
    output dmem_w,
    output [2:0] mux_pc,
//    output [2:0] mux_Rd,
    output [1:0] mux_B,
    output mux_A,
    output mux_sign,
    output [4:0] ext_ena,//ext_1/ext_5/ext_16s/ext_16u/ext_18
    output cat_ena//j/jal
    //new
    ,input is_clz, input is_jalr, input is_mthi, input is_mtlo, input is_mfhi,
    input is_mflo, input is_sb, input is_sh, input is_lb, input is_lh,
    input is_lbu, input is_lhu, input is_eret, input is_break, input is_syscall,
    input is_teq, input is_mfc0, input is_mtc0, input is_mul, input is_multu,
    input is_div, input is_divu, input is_bgez
//    ,output is_rt_in
    ,input equ_rs_rt
    ,output is_sign
    );
    // ALUC
    assign ALUC[4] = is_mul ? 1'b1 : 1'b0;//mul-10000
    assign ALUC[3] = (is_lui | is_slt | is_sltu | is_slti | is_sltiu |
                      is_sll | is_srl | is_sra | is_sllv | is_srlv | is_srav) ? 1'b1 : 1'b0;
    assign ALUC[2] = (is_and | is_or | is_xor | is_nor | is_andi | is_ori | is_xori |
                      is_sll | is_srl | is_sra | is_sllv | is_srlv | is_srav) ? 1'b1 : 1'b0;
    assign ALUC[1] = (is_sub | is_subu | is_beq | is_bne | is_xor | is_nor | is_xori |
                      is_slt | is_sltu | is_slti | is_sltiu | is_srl | is_srlv | is_bgez) ? 1'b1 : 1'b0;
    assign ALUC[0] = (is_add | is_addi | is_lw | is_sw |
                      is_sub | is_beq | is_bne |
                      is_or | is_ori | is_nor | is_sltu | is_sltiu |
                      is_sll | is_srl | is_sllv | is_srlv |
                      //new add
                      is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu | is_bgez) ? 1'b1 : 1'b0;
    // rf_w !!!!
    assign rf_w = (is_jr | is_sw | is_beq | is_bne | is_j | is_mthi | is_mtlo | is_sb | is_sh | is_mtc0
                   | is_eret | is_break | is_syscall | is_teq | is_multu | is_div | is_divu | is_bgez) ? 1'b0 : 1'b1;
    // dmem_r/dmem_w
    assign dmem_r = (is_lw | is_lb | is_lh | is_lbu | is_lhu) ? 1'b1 : 1'b0;
    assign dmem_w = (is_sw | is_sb | is_sh) ? 1'b1 : 1'b0;
    // mux_pc
    assign mux_pc = (is_jr | is_jalr) ? 3'b001 : (is_beq | is_bne | is_bgez) ? 3'b010 : (is_j | is_jal) ? 3'b011 : 
                    (is_eret) ? 3'b100 : (is_break | is_syscall | (equ_rs_rt & is_teq)) ? 3'b101 : 3'b000;//+4
    // mux_Rd 100-clz
//    assign mux_Rd = (is_jal | is_jalr) ? 3'b000 : (is_slt | is_sltu | is_slti | is_sltiu) ? 3'b001 : 
//                    (is_lw | is_clz) ? 3'b010 : (is_mfhi | is_mflo) ? 3'b101 :(is_mul) ? 3'b110 : 3'b011;//ALU_res
    // mux_B
    assign mux_B = (is_addiu | is_addi | is_lw | is_sw | is_slti | is_sltiu |
                    is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu) ? 2'b01 : 
                    (is_andi | is_ori | is_xori | is_lui) ? 2'b10 : 2'b00;//Rt
    // mux_A
    assign mux_A = (is_sll | is_srl | is_sra) ? 1'b1 : 1'b0;
    // mux_sign
    assign mux_sign = (is_slt | is_sltu) ? 1'b0 : 1'b1;//slti/sltiu
    
    // ext_ena
    reg [4:0] reg_ext_ena = 5'b0;
    assign ext_ena = reg_ext_ena;
    always@(*)begin
        //ext_1/ext_5/ext_16s/ext_16u/ext_18
        reg_ext_ena[0]<= (is_slt | is_sltu | is_slti | is_sltiu) ? 1'b1 : 1'b0;//ext1
        reg_ext_ena[1]<= (mux_A == 1'b1) ? 1'b1 : 1'b0;//ext5
        reg_ext_ena[2]<= (is_addi | is_lw | is_sw | is_slti | is_sltiu |  is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu) ? 1'b1 : 1'b0;//ext16s
        reg_ext_ena[3]<= (is_addiu | is_andi | is_ori | is_xori | is_lui) ? 1'b1 : 1'b0;//ext16u
        reg_ext_ena[4]<= (is_beq | is_bne | is_bgez) ? 1'b1 : 1'b0;//ext18
    end
    // cat_ena
    assign cat_ena = (is_j | is_jal | (is_bgez&equ_rs_rt)) ? 1'b1 : 1'b0;
    //new
//    assign is_rt_in = (is_lb | is_lh | is_lbu | is_lhu) ? 1 : 0; 
    assign is_sign  = (is_mul | is_div) ? 1 : (is_multu | is_divu) ? 0 : 1'bz;
endmodule
