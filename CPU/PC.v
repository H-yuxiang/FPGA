`timescale 1ns / 1ps
// 读取COE文件指令的地址控制器
module PC(
    input pc_clk,
    input pc_ena,
    input rst_n,//高电平复位
    input [31:0] pc_addr_in,//经过选择器选择后，下次将被执行的指令，经过CPU的计算后送入，可能是+4或跳转
    output [31:0] pc_addr_out//本次执行的指令
    );
    // 上升沿执行指令，下降沿更新PC
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
