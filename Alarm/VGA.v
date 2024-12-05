`timescale 1ns / 1ns

module VGA(
    input clk,
    input rst,
    input [1:0]sel,
    
    output reg [3:0]VGA_R,
    output reg [3:0]VGA_G,
    output reg [3:0]VGA_B,
    output       VGA_HS,
    output       VGA_VS
    
    //,output [11:0]outData//检查信号 调试使用
    );
    
    //系统时钟分频
    wire clk_div;

    //IP核调取65MHz的时钟
    //wire lock_res;
    clk_wiz_0 clk_65_u(
         // Clock in ports
         .clk_in1(clk),      // input clk_in1
         // Clock out ports
         .clk_out1(clk_div)     // output clk_out1
    ); 
    
    //该设备参数定义 信号所占的周期数 1024*768
    //行同步信号
    parameter H_SYNC = 10'd136;
    parameter H_BACK = 10'd160;
    parameter H_DISP = 11'd1024;
    parameter H_FRONT = 10'd24;
    parameter H_TOTAL = 11'd1344;
    
    //场同步信号
    parameter V_SYNC = 10'd6;
    parameter V_BACK = 10'd29;
    parameter V_DISP = 10'd768;
    parameter V_FRONT = 10'd3;
    parameter V_TOTAL = 10'd806;
    
    //图片信息 256*184 => 512*386
    parameter Image_h = 11'd512;
    parameter Image_v = 11'd368;
    
    //左边距、上边距
    parameter Lef_margin = 10'd256;
    parameter Top_margin = 10'd200;
    
    //计数器
    reg [15:0]h_cnt = 16'b0;
    reg [15:0]v_cnt = 16'b0;
    
    //VGA的行、场同步信号
    assign VGA_HS = (h_cnt<H_SYNC) ? 1'b0 : 1'b1;
    assign VGA_VS = (v_cnt<V_SYNC) ? 1'b0 : 1'b1;
    
    //判断是否处于数据有效的显示区域
    wire VGA_ena = ((h_cnt>=H_SYNC+H_BACK+Lef_margin)&&(h_cnt<H_SYNC+H_BACK+Lef_margin+Image_h)
                    &&(v_cnt>=V_SYNC+V_BACK+Top_margin)&&(v_cnt<V_SYNC+V_BACK+Top_margin+Image_v)) ? 1'b1 : 1'b0;
    //assign o_VGA_RGB = VGA_ena ? VGA_RGB : 16'b0;
    
    //行周期计数
    always@(posedge clk_div)begin
        if(!rst)begin
            h_cnt<=1'd0;
        end
        else begin
            if(h_cnt<H_TOTAL-1'b1)
                h_cnt<=h_cnt+1;
            else
                h_cnt<=1'd0;
        end
    end
    
    //场周期计数
    always@(posedge clk_div)begin
        if(!rst)begin
            v_cnt<=1'd0;
        end
        else begin
            if(h_cnt==H_TOTAL-1'b1)begin
                if(v_cnt<V_TOTAL-1'b1)
                    v_cnt<=v_cnt+1;
                else
                    v_cnt<=1'd0;
            end
        end
    end
    
    //从IP核获取颜色数据 RGB值
    wire[11:0]Data[3:0];
    reg [15:0]addr = 16'd0;
    wire [15:0]addr_in;
    assign addr_in = addr;
    wire [3:0]select;
    assign select[0] = ~(sel[0]||sel[1]);//00
    assign select[1] = sel[0]&&(~sel[1]);//01
    assign select[2] = (~sel[0])&&sel[1];//10
    //assign select[3] = sel[0]&&sel[1];//11
    
    blk_mem_gen_picture_0 uut_pic_0 (
      .clka(clk_div),    // input wire clka
      .ena(select[0]),      // input wire ena
      .addra(addr_in),  // input wire [15 : 0] addra
      .douta(Data[0])  // output wire [11 : 0] douta
    );
    blk_mem_gen_picture_1 uut_pic_1 (
      .clka(clk_div),    // input wire clka
      .ena(select[1]),      // input wire ena
      .addra(addr_in),  // input wire [15 : 0] addra
      .douta(Data[1])  // output wire [11 : 0] douta
    );
    blk_mem_gen_picture_2 uut_pic_2 (
      .clka(clk_div),    // input wire clka
      .ena(select[2]),      // input wire ena
      .addra(addr_in),  // input wire [15 : 0] addra
      .douta(Data[2])  // output wire [11 : 0] douta
    );
    
    wire [11:0]oData;
    assign oData = (select[0]) ? Data[0] :((select[1]) ? Data[1] : ((select[2]) ? Data[2] : Data[0]));
    
    //assign outData={h_cnt[11:1],clk_div};
    
    //512*368
    always@(posedge clk_div or negedge rst)begin
        if(!rst)begin
            addr <= 4'd0;
            VGA_R <= 4'd15;
            VGA_G <= 4'd15;
            VGA_B <= 4'd15;
        end
        else begin
            if(VGA_ena)begin
                addr <= (Image_v - (v_cnt - V_SYNC - V_BACK - Top_margin - 1'b1))/2 * 256 + (h_cnt - H_SYNC - H_BACK - Lef_margin - 1'b1)/2;
                VGA_R <= oData[3:0];
                VGA_G <= oData[7:4];
                VGA_B <= oData[11:8];
            end
            else begin //否则黑屏
                addr <= 4'd0;
                VGA_R <= 4'd15;
                VGA_G <= 4'd15;
                VGA_B <= 4'd15;
            end
        end
    end
endmodule


