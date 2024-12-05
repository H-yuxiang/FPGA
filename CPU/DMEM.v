`timescale 1ns / 1ps
// 主存
module DMEM(
    input dmem_clk,//时钟信号
    input dmem_ena,//读写使能信号
    input dmem_r,//读数据使能信号
    input dmem_w,//写数据使能信号
    input [6:0] dmem_addr,//读写地址
    input [31:0] dmem_data_in,//输入数据
    input is_sw,
    input is_lw,
    input is_sb,
    input is_sh,
    input is_lb,
    input is_lh,
    input is_lbu,
    input is_lhu,
    output [31:0] dmem_data_out//读出数据
    //new
    ,input [1:0]b_r,input [1:0]h_r
    );
    reg [31:0]dmem[31:0];//存储区域
    
    // 读取数据
    assign dmem_data_out = (dmem_ena && is_lw && dmem_r && !dmem_w) ? dmem[dmem_addr]:
                           (dmem_ena && is_lb && dmem_r && !dmem_w&&b_r==2'd0) ? {{24{dmem[dmem_addr][7]}},dmem[dmem_addr][7:0]}:
                           (dmem_ena && is_lb && dmem_r && !dmem_w&&b_r==2'd1) ? {{24{dmem[dmem_addr][15]}},dmem[dmem_addr][15:8]}:
                           (dmem_ena && is_lb && dmem_r && !dmem_w&&b_r==2'd2) ? {{24{dmem[dmem_addr][23]}},dmem[dmem_addr][23:16]}:
                           (dmem_ena && is_lb && dmem_r && !dmem_w&&b_r==2'd3) ? {{24{dmem[dmem_addr][31]}},dmem[dmem_addr][31:24]}:
                           (dmem_ena && is_lh && dmem_r && !dmem_w&&h_r<=1) ? {{16{dmem[dmem_addr][15]}},dmem[dmem_addr][15:0]}:
                           (dmem_ena && is_lh && dmem_r && !dmem_w&&h_r>=2) ? {{16{dmem[dmem_addr][31]}},dmem[dmem_addr][31:16]}:
                           (dmem_ena && is_lbu && dmem_r && !dmem_w&&b_r==2'd0) ? {24'b0,dmem[dmem_addr][7:0]}:
                           (dmem_ena && is_lbu && dmem_r && !dmem_w&&b_r==2'd1) ? {24'b0,dmem[dmem_addr][15:8]}:
                           (dmem_ena && is_lbu && dmem_r && !dmem_w&&b_r==2'd2) ? {24'b0,dmem[dmem_addr][23:16]}:
                           (dmem_ena && is_lbu && dmem_r && !dmem_w&&b_r==2'd3) ? {24'b0,dmem[dmem_addr][31:24]}:
                           (dmem_ena && is_lhu && dmem_r && !dmem_w&&h_r<=1) ? {16'b0,dmem[dmem_addr][15:0]}:
                           (dmem_ena && is_lhu && dmem_r && !dmem_w&&h_r>=2) ? {16'b0,dmem[dmem_addr][31:16]}:32'hz;
//    assign dmem_data_out = (dmem_ena && dmem_r && !dmem_w) ?
//                           (is_lb ? { {24{dmem[dmem_addr][7]}} , dmem[dmem_addr][7:0]} :
//                           (is_lbu ? { 24'h0 , dmem[dmem_addr][7:0] }:
//                           (is_lh ? { {16{dmem[dmem_addr >> 1][15]}} ,dmem[dmem_addr >> 1][15:0] }:
//                           (is_lhu ? { 16'h0 , dmem[dmem_addr >> 1][15:0] }:
//                           (is_lw ? dmem[dmem_addr >> 2] : 32'hz))))) : 32'hz ;
    
    // 上升沿写入数据
    always@(negedge dmem_clk)begin
//        if(dmem_ena && is_sw && dmem_w && !dmem_r)
//            dmem[dmem_addr >> 2] <= dmem_data_in;
//        else if(dmem_ena && is_sb && dmem_w && !dmem_r)
//            dmem[dmem_addr][7:0] <= dmem_data_in[7:0];
//        else if(dmem_ena && is_sh && dmem_w && !dmem_r)
//            dmem[dmem_addr >> 1][15:0] <= dmem_data_in[15:0];
        if(dmem_ena && dmem_w && !dmem_r)begin
            if(is_sw)//sw
                dmem[dmem_addr] <= dmem_data_in;
            if(is_sb)begin//sb
                if(b_r==2'd0)
                    dmem[dmem_addr][7:0] <= dmem_data_in[7:0];
                else if(b_r==2'd1)
                    dmem[dmem_addr][15:8] <= dmem_data_in[7:0];
                else if(b_r==2'd2)
                    dmem[dmem_addr][23:16] <= dmem_data_in[7:0];
                else
                    dmem[dmem_addr][31:24] <= dmem_data_in[7:0];
            end
            if(is_sh)begin//sh
                if(h_r <= 1)
                    dmem[dmem_addr][15:0] <= dmem_data_in[15:0];
                else
                    dmem[dmem_addr][31:16] <= dmem_data_in[15:0];
            end
        end
    end
endmodule
