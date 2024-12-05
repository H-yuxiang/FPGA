`timescale 1ns / 1ps

module CP0(
    input clk,
    input rst,
    input ena,
    input mfc0,
    input mtc0,
    input eret,
    input [4:0] rd,
    input [31:0] pc,
    input [31:0] data_in,
    input [4:0] cause,
    output [31:0] data_out,
    output [31:0] excaddr
    );//break/syscall/teq/eret/mfc0/mtc0
    
    parameter SYSCALL = 5'b01000, BREAK = 5'b01001, TEQ = 5'b01101;
    parameter STATUS = 12,CAUSE = 13,EPC = 14;
    
    reg [31:0] cp0_reg [31:0];//cp0内部的寄存器，cp0相关指令就是对这些寄存器进行交互、操作
    reg [31:0] excaddr_tmp;
    assign excaddr = excaddr_tmp;
    assign data_out = (mfc0) ? cp0_reg[rd] : 32'hz;
    
    always@(negedge clk or posedge rst)begin
        if(ena && rst==1)begin
            cp0_reg[0] <= 0;
            cp0_reg[1] <= 0;
            cp0_reg[2] <= 0;
            cp0_reg[3] <= 0;
            cp0_reg[4] <= 0;
            cp0_reg[5] <= 0;
            cp0_reg[6] <= 0;
            cp0_reg[7] <= 0;
            cp0_reg[8] <= 0;
            cp0_reg[9] <= 0;
            cp0_reg[10] <= 0;
            cp0_reg[11] <= 0;
            cp0_reg[12] <= 0;
            cp0_reg[13] <= 0;
            cp0_reg[14] <= 0;
            cp0_reg[15] <= 0;
            cp0_reg[16] <= 0;
            cp0_reg[17] <= 0;
            cp0_reg[18] <= 0;
            cp0_reg[19] <= 0;
            cp0_reg[20] <= 0;
            cp0_reg[21] <= 0;
            cp0_reg[22] <= 0;
            cp0_reg[23] <= 0;
            cp0_reg[24] <= 0;
            cp0_reg[25] <= 0;
            cp0_reg[26] <= 0;
            cp0_reg[27] <= 0;
            cp0_reg[28] <= 0;
            cp0_reg[29] <= 0;
            cp0_reg[30] <= 0;
            cp0_reg[31] <= 0;
            excaddr_tmp <= 32'h12345678;
        end
        else if(ena) begin
            if(eret)begin//出中断
                cp0_reg[STATUS] <= cp0_reg[STATUS] >> 5;
                excaddr_tmp <= cp0_reg[EPC];
            end
            else if(cause == BREAK || cause == SYSCALL || cause == TEQ)begin//记录型
                cp0_reg[STATUS] <= cp0_reg[STATUS] << 5;//状态屏蔽
                cp0_reg[CAUSE]  <= cause;//中断原因
                cp0_reg[EPC]    <= pc;//当前指令地址
            end
            else if(mtc0)begin//存数型
                cp0_reg[rd] <= data_in;
            end
        end
    end
endmodule
