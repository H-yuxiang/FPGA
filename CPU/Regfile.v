`timescale 1ns / 1ps
// 寄存器堆，对应DMEM的大小，根据传入的寄存器地址对当中的寄存器进行读写
module Regfile(
    input rf_clk,
    input rf_ena,
    input rf_w,
    input rf_rst_n,
    input [4:0] Rdc,
    input [4:0] Rsc,
    input [4:0] Rtc,
    input [31:0] Rd_in,
    output [31:0] Rs_out,
    output [31:0] Rt_out
    //new
    ,input is_rt_in
    ,input [31:0] Rt_in
    ,output equ_rs_rt//判断rs>=0，本来用于teq，结果mips不测，移花接木到bgez
    );
    reg [31:0] array_reg [31:0];//存储空间
    
    always@(posedge rf_rst_n or negedge rf_clk)begin
        if(rf_ena && rf_rst_n == 1)begin
            array_reg[0] <= 32'h0;
            array_reg[1] <= 32'h0;
            array_reg[2] <= 32'h0;
            array_reg[3] <= 32'h0;
            array_reg[4] <= 32'h0;
            array_reg[5] <= 32'h0;
            array_reg[6] <= 32'h0;
            array_reg[7] <= 32'h0;
            array_reg[8] <= 32'h0;
            array_reg[9] <= 32'h0;
            array_reg[10] <= 32'h0;
            array_reg[11] <= 32'h0;
            array_reg[12] <= 32'h0;
            array_reg[13] <= 32'h0;
            array_reg[14] <= 32'h0;
            array_reg[15] <= 32'h0;
            array_reg[16] <= 32'h0;
            array_reg[17] <= 32'h0;
            array_reg[18] <= 32'h0;
            array_reg[19] <= 32'h0;
            array_reg[20] <= 32'h0;
            array_reg[21] <= 32'h0;
            array_reg[22] <= 32'h0;
            array_reg[23] <= 32'h0;
            array_reg[24] <= 32'h0;
            array_reg[25] <= 32'h0;
            array_reg[26] <= 32'h0;
            array_reg[27] <= 32'h0;
            array_reg[28] <= 32'h0;
            array_reg[29] <= 32'h0;
            array_reg[30] <= 32'h0;
            array_reg[31] <= 32'h0;
        end
        else if(rf_ena && rf_w) begin 
            if(is_rt_in && Rtc!=5'b00000)
                array_reg[Rtc] <= Rt_in;
            else if(Rdc!=5'b00000)
                array_reg[Rdc] <= Rd_in;
        end
    end //always
    
    // 输出内容供CPU选择
    assign Rs_out = (rf_ena==1'b1) ? array_reg[Rsc] : 32'hz;
    assign Rt_out = (rf_ena==1'b1) ? array_reg[Rtc] : 32'hz;
//    assign Rd_out = (rf_ena==1'b1 && is_rd_out) ? array_reg[Rdc] : 32'hz;
    wire signed [31:0] judge_rs;
    assign judge_rs = rf_ena ? array_reg[Rsc] : 32'hz;
    assign equ_rs_rt = rf_ena ? (judge_rs >= 0 ? 1 : 0) : 1'bz;
endmodule
