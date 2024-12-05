`timescale 1ns / 1ps
// 调用ALU/Decoder/Controller/PC/Regfile，和DMEM/IMEM协同处理指令
module CPU(
    input clk,
    input ena,
    input rst_n,
    input [31:0] instr,
    input [31:0] dmem_data,
    output [31:0] dmem_data_to_write,
    output dmem_ena,
    output dmem_w,
    output dmem_r,
    output [31:0] pc_out,//to IMEM本次执行的指令地址，取下一条指令
    output [31:0] dmem_addr,
    output [31:0] ALU_res
    //new output sign for DMEM
    //wire is_sw,is_lw,is_sb,is_sh,is_lb,is_lh,is_lbu,is_lhu;
    ,output issw, output islw, output issb, output issh
    ,output islb, output islh, output islbu, output islhu 
    );
    // 指令辨别
    wire is_add, is_addu, is_sub, is_subu, is_and, is_or, is_xor, is_nor,
    is_slt, is_sltu, is_sll, is_srl, is_sra, is_sllv, is_srlv, is_srav,
    is_jr, is_addi, is_addiu, is_andi, is_ori, is_xori, is_lw, is_sw,
    is_beq, is_bne, is_slti, is_sltiu, is_lui, is_j, is_jal,
    //new
    is_clz, is_jalr, is_mthi, is_mtlo, is_mfhi,
    is_mflo, is_sb, is_sh, is_lb, is_lh,
    is_lbu, is_lhu, is_eret, is_break, is_syscall,
    is_teq, is_mfc0, is_mtc0, is_mul, is_multu,
    is_div, is_divu, is_bgez;
    //DMEM接口要用的标记
    assign issw = is_sw, islw = is_lw, issb = is_sb, issh = is_sh,
           islb = is_lb, islh = is_lh, islbu = is_lbu, islhu = is_lhu;
    //cp0中断原因
    wire [4:0]dec_cause;
    
    // Regfile
    wire rf_w;
    wire [4:0] Rdc;
    wire [4:0] Rsc;
    wire [4:0] Rtc;
    wire [4:0] shamt;
    wire [15:0] imm;
    wire [25:0] addr;//j/jal
    assign addr = (is_j | is_jal) ? instr[25:0] : 26'hz;
    wire [31:0] Rd_in;
    wire [31:0] Rs_out;
    wire [31:0] Rt_out;
    //new
//    wire [4:0]base;//基址寄存器，决定放在Rsc
//    wire [4:0]Rsc_tmp;
//    assign Rsc = (is_lb | is_lh | is_sb | is_sh | is_lbu | is_lhu) ? base : Rsc_tmp;
    wire is_rt_in;//in
    assign is_rt_in = (is_lb | is_lh | is_lbu | is_lhu | is_mfc0) ? 1'b1 : 0; 
    wire [31:0]Rt_in;//in
    wire equ_rs_rt;//out
    
    // ALU
    wire [31:0] A,B;
    wire [4:0] ALUC;
    wire [31:0] res;
    assign ALU_res = res;
    wire ZF,CF,SF,OF;
    //new
    wire is_sign;//control_out
    assign is_sign = (is_mul | is_div) ? 1 : (is_multu | is_divu) ? 0 : 1'bz;
    
    // PC
    wire [31:0] pc_addr_in;
    wire [31:0] pc_addr_out;
    
    //MUL output
    wire [31:0]HI;
    wire [31:0]LO;
    
    //DIV output
    wire [31:0]Q;
    wire [31:0]R;
    
    //HILO
    wire [31:0]HI_in;
    wire [31:0]LO_in;
    wire HI_w_r,LO_w_r;
    wire [31:0]HI_out;
    wire [31:0]LO_out;
    
    //CP0
    wire [4:0]cause;
    wire [31:0]cp0_data_in;
    wire [31:0]cp0_data_out;
    wire [31:0]cp0_excaddr;
    
    //CLZ
    wire [31:0]clz_data_in;
    wire [31:0]zero_num;
    
    //new 新接口关联
    assign clz_data_in = (is_clz) ? Rs_out : 32'h8000_0000;
    assign HI_in = (is_mthi) ? Rs_out : (is_multu) ? HI : (is_div | is_divu) ? R : 0;
    assign HI_w_r = (is_mthi | is_multu | is_div | is_divu) ? 1: 0;//w-1
    assign LO_in = (is_mtlo) ? Rs_out : (is_multu) ? LO : (is_div | is_divu) ? Q : 0;
    assign LO_w_r = (is_mtlo | is_multu | is_div | is_divu) ? 1: 0;
    assign cause = (is_break | is_syscall | is_teq) ? dec_cause : 5'bz;
    assign cp0_data_in = (is_mtc0) ? Rt_out : 0;
    assign Rt_in = (is_lb | is_lh | is_lbu | is_lhu) ? dmem_data : (is_mfc0) ? cp0_data_out : 0;
    
    // npc
    wire [31:0] npc;
    assign npc = pc_addr_out + 4;//顺序执行+4，可能的一个分支
    // pc_addr_in 经过选择器选择后从4类地址中（含npc）选择一个送入PC.v，并原样输出到pc_addr_out->pc_out，确定下一条指令的地址
    assign pc_out = pc_addr_out;//这里的pc_addr_out是+4/跳转后的结果，返还到上层通路后，IMEM取得的就是下一条要执行的指令
    
    // 扩展、拼接
    wire [4:0] ext_ena;
    wire [31:0] ext_out [4:0];//疑似多余了
    wire [31:0] cat_res;
    // ext1
    assign ext_out[0] = (is_slt | is_sltu) ? {31'b0,SF} : (is_slti | is_sltiu) ? {31'b0,CF} : 32'hz;
    // ext5i条
    assign ext_out[1] = (is_sll | is_srl | is_sra) ? {27'b0,shamt} : 32'hz;
    // ext16s
    assign ext_out[2] = (is_addiu | is_addi | is_lw | is_sw | is_slti | is_sltiu | 
                         is_sb | is_sh | is_lb | is_lh | is_lbu | is_lhu) ? {{16{imm[15]}},imm} : 32'hz;
    // ext16u
    assign ext_out[3] = (is_andi | is_ori | is_xori | is_lui) ? {16'b0,imm} : 32'hz;
    // ext18(s)
    assign ext_out[4] = (is_beq | is_bne | is_bgez) ? {{14{imm[15]}},imm[15:0],2'b00} : 32'hz;
    // cat
    wire cat_ena;
    // assign cat_ena = (is_j | is_jal) ? 1'b1 : 1'b0;
    assign cat_res = (is_j | is_jal) ? {pc_addr_out[31:28],addr,2'b00} : 32'hz;
    
    // MUX
    wire [2:0] mux_pc;
    wire [2:0] mux_Rd;
    wire [1:0] mux_B;
    wire mux_A;
    wire mux_sign;
    
    // MUX 选送的结果
    reg [31:0] reg_mux_pc_res;
    assign pc_addr_in = reg_mux_pc_res;//pc
//    reg [31:0] reg_mux_Rd_res = 32'h12345678;
//    assign Rd_in = reg_mux_Rd_res;//Rd
    reg [31:0] reg_mux_B_res;
    assign B = reg_mux_B_res;//B
    reg [31:0] reg_mux_A_res;
    assign A = reg_mux_A_res;//A
    wire [31:0] mux_sign_res;
    reg [31:0] reg_mux_sign_res;
    assign mux_sign_res = reg_mux_sign_res;//sign
    
    // 实例化
    ALU alu(
        .A(A),.B(B),.ALUC(ALUC),.res(res),.zero(ZF),.carry(CF),.sign(SF),.overflow(OF)
    );
    PC pc(
        .pc_clk(clk),.pc_ena(ena),.rst_n(rst_n),.pc_addr_in(pc_addr_in),.pc_addr_out(pc_addr_out)
    );
    Controller controller(
        .is_add(is_add),.is_addu(is_addu),.is_sub(is_sub),.is_subu(is_subu),.is_and(is_and),.is_or(is_or),
        .is_xor(is_xor),.is_nor(is_nor),.is_slt(is_slt),.is_sltu(is_sltu),.is_sll(is_sll),.is_srl(is_srl),
        .is_sra(is_sra),.is_sllv(is_sllv),.is_srlv(is_srlv),.is_srav(is_srav),.is_jr(is_jr),.is_addi(is_addi),
        .is_addiu(is_addiu),.is_andi(is_andi),.is_ori(is_ori),.is_xori(is_xori),.is_lw(is_lw),.is_sw(is_sw),
        .is_beq(is_beq),.is_bne(is_bne),.is_slti(is_slti),.is_sltiu(is_sltiu),.is_lui(is_lui),.is_j(is_j),.is_jal(is_jal),
        .ALUC(ALUC),.rf_w(rf_w),.dmem_r(dmem_r),.dmem_w(dmem_w),.mux_pc(mux_pc),.mux_B(mux_B),
        .mux_A(mux_A),.mux_sign(mux_sign),.ext_ena(ext_ena),.cat_ena(cat_ena)
//        ,.mux_Rd(mux_Rd)
        //new
        ,.is_clz(is_clz) ,.is_jalr(is_jalr) ,.is_mthi(is_mthi) ,.is_mtlo(is_mtlo) ,.is_mfhi(is_mfhi)
        ,.is_mflo(is_mflo) ,.is_sb(is_sb) ,.is_sh(is_sh) ,.is_lb(is_lb) ,.is_lh(is_lh)
        ,.is_lbu(is_lbu) ,.is_lhu(is_lhu) ,.is_eret(is_eret) ,.is_break(is_break) ,.is_syscall(is_syscall)
        ,.is_teq(is_teq) ,.is_mfc0(is_mfc0) ,.is_mtc0(is_mtc0) ,.is_mul(is_mul) ,.is_multu(is_multu)
        ,.is_div(is_div) ,.is_divu(is_divu) ,.is_bgez(is_bgez)
//        ,.is_rt_in(is_rt_in)
        ,.equ_rs_rt(equ_rs_rt),.is_sign(is_sign)
    );
    Decoder decoder(
        .instr(instr),
        .is_add(is_add),.is_addu(is_addu),.is_sub(is_sub),.is_subu(is_subu),.is_and(is_and),.is_or(is_or),
        .is_xor(is_xor),.is_nor(is_nor),.is_slt(is_slt),.is_sltu(is_sltu),.is_sll(is_sll),.is_srl(is_srl),
        .is_sra(is_sra),.is_sllv(is_sllv),.is_srlv(is_srlv),.is_srav(is_srav),.is_jr(is_jr),.is_addi(is_addi),
        .is_addiu(is_addiu),.is_andi(is_andi),.is_ori(is_ori),.is_xori(is_xori),.is_lw(is_lw),.is_sw(is_sw),
        .is_beq(is_beq),.is_bne(is_bne),.is_slti(is_slti),.is_sltiu(is_sltiu),.is_lui(is_lui),.is_j(is_j),.is_jal(is_jal),
        .Rsc(Rsc),.Rdc(Rdc),.Rtc(Rtc),.shamt(shamt),.imm(imm),.addr(addr)
        //new
        ,.is_clz(is_clz), .is_jalr(is_jalr), .is_mthi(is_mthi), .is_mtlo(is_mtlo), .is_mfhi(is_mfhi),
        .is_mflo(is_mflo), .is_sb(is_sb), .is_sh(is_sh), .is_lb(is_lb), .is_lh(is_lh),
        .is_lbu(is_lbu), .is_lhu(is_lhu), .is_eret(is_eret), .is_break(is_break), .is_syscall(is_syscall),
        .is_teq(is_teq), .is_mfc0(is_mfc0), .is_mtc0(is_mtc0), .is_mul(is_mul), .is_multu(is_multu),
        .is_div(is_div), .is_divu(is_divu), .is_bgez(is_bgez), .dec_cause(dec_cause)
        //, .base(base)
    );
    Regfile cpu_ref(
        .rf_clk(clk),.rf_ena(ena),.rf_w(rf_w),.rf_rst_n(rst_n),.Rdc(Rdc),.Rtc(Rtc),.Rsc(Rsc),.Rd_in(Rd_in),.Rs_out(Rs_out),.Rt_out(Rt_out)
        //new
        ,.is_rt_in(is_rt_in)
        ,.Rt_in(Rt_in),.equ_rs_rt(equ_rs_rt)
    );
    //new 实例化 MUL、DIV、HILO、CP0、CLZ
    MUL mul(
        .A(A),.B(B),.is_sign(is_sign),.HI(HI),.LO(LO)
    );
    DIV div(
        .A(A),.B(B),.is_sign(is_sign),.Q(Q),.R(R)
    );
    HILO hilo(
        .HI_in(HI_in),.LO_in(LO_in),.ena(ena),.clk(clk),.rst(rst_n),.HI_w_r(HI_w_r),.LO_w_r(LO_w_r),.HI_out(HI_out),.LO_out(LO_out)
    );
    CP0 cp0(
        .clk(clk),.rst(rst_n),.ena(ena),.mfc0(is_mfc0),.mtc0(is_mtc0),.eret(is_eret),.rd(Rdc),.pc(pc_addr_out)
        ,.data_in(cp0_data_in),.cause(cause),.data_out(cp0_data_out),.excaddr(cp0_excaddr)
    );
    CLZ clz(
        .data_in(clz_data_in),.zero_num(zero_num)
    );
    
    //MUX Rd 也可以不拿出来，调试的时候拿出来试一试
    assign Rd_in = (is_jal | is_jalr) ? pc_addr_out + 32'd4 : 
               (is_slt | is_sltu | is_slti | is_sltiu) ? ext_out[0] : 
               (is_lw | is_clz) ? ((is_lw) ? dmem_data : zero_num) : 
               (is_mfhi | is_mflo) ? ((is_mfhi) ? HI_out : (is_mflo) ? LO_out : 32'bz) : res;
    
    // MUX 逻辑处理
    always@(*) begin
        // mux_pc
        case(mux_pc)
            3'b000:
                reg_mux_pc_res <= npc;
            3'b001:
                reg_mux_pc_res <= Rs_out;//jr/jalr
            3'b010://update
                reg_mux_pc_res <= (is_bgez) ? ((equ_rs_rt) ? ext_out[4] + npc : npc) : (is_beq) ? ((ZF == 0) ? npc : ext_out[4] + npc) : ((ZF != 0) ? npc : ext_out[4] + npc);//ext_18+npc
            3'b011:
                reg_mux_pc_res <= cat_res;//j/jal
            //new
            3'b100:
                reg_mux_pc_res <= cp0_excaddr;
            3'b101:
                reg_mux_pc_res <= 32'h0000_0004;
        endcase
        
        // mux_Rd
//        case(mux_Rd)
//            3'b000:
//                reg_mux_Rd_res <= pc_addr_out + 32'd4;//jal/jalr
//            3'b001:
//                reg_mux_Rd_res <= ext_out[0];//ext1
//            3'b010:
//                reg_mux_Rd_res <= (is_lw) ? dmem_data : zero_num;//lw/zero_num
//            3'b011:
//                reg_mux_Rd_res <= res;//ALU
////            3'b100:
////                reg_mux_Rd_res <= zero_num;//CLZ
//            3'b101:
//                reg_mux_Rd_res <= (is_mfhi) ? HI_out : (is_mflo) ? LO_out : 32'bz;//MfHI/MfLO
//            3'b110:
//                reg_mux_Rd_res <= LO;
//        endcase
        
        // mux_B
        case(mux_B)
            2'b00:
                reg_mux_B_res <= Rt_out;
            2'b01:
                reg_mux_B_res <= ext_out[2];//ext16s
            2'b10:
                reg_mux_B_res <= ext_out[3];//ext16u
        endcase
        
        // mux_A
        case(mux_A)
            1'b0:
                reg_mux_A_res <= Rs_out;
            1'b1:
                reg_mux_A_res <= ext_out[1];//ext5
        endcase
        
        // mux_sign
        case(mux_sign)
            1'b0:
                reg_mux_sign_res <= SF;//slt/sltu
            1'b1:
                reg_mux_sign_res <= CF;//slti/sltiu
        endcase
    end//always
    
    // 其余的output 结果赋值 change
    assign dmem_data_to_write = Rt_out;//sw/sb/sh
    assign dmem_ena = (is_lw | is_sw | is_lb | is_lh | is_sb | is_sh | is_lbu | is_lhu) ? 1'b1 : 1'b0;//sw/lw...
    assign dmem_addr = (is_lw | is_sw | is_lb | is_lh | is_sb | is_sh | is_lbu | is_lhu) ? res : 32'hz;//ALU计算的地址
    
endmodule
