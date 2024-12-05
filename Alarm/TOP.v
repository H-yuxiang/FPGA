`timescale 1ns / 1ns

module TOP(
    input clk,
    input rst,
    //rotation
    input iA,
    input iB,
    input SW,
    //mp3
    input DREQ,
    output XDCS,//data
    output XCS,//cmd
    output SI,
    output SCLK,
    output XRESET,//��λ�ź� �͵�ƽ��Ч 
    //vga
    output [3:0]VGA_R,
    output [3:0]VGA_G,
    output [3:0]VGA_B,
    output      VGA_HS,
    output      VGA_VS,
    //���
    output [1:0]o_sel
    ,output [13:0]o_music
    );
    
    //mp3�ĵ�ַ��λ�ź�(SW==0)
    //wire MP3_addr_rst_n;
    reg _MP3_addr_rst_n = 1'b1;
    //assign MP3_addr_rst_n = _MP3_addr_rst_n;
    
    //ѡ��
    wire [1:0]sel;
    //���ѡ�����Ŀ
    assign o_sel = sel;
    reg [1:0] sel_cur;
    assign sel = sel_cur;
    
    //ѡ���仯
    //rotation �����ź�
    wire [1:0]RO_data;
    
    //rotation
    rotation u_top_ro(
        .iA(iA),
        .iB(iB),
        .SW(SW),
        .rst(rst),
        .clk(clk),//i
        .oData(RO_data)//o
    );
    
    //����
    reg [16:0]count = 16'd0;
    //��¼��ֵ
    reg [1:0]RO_data_old = 2'b11;
    
    always@(posedge clk)begin
        if(_MP3_addr_rst_n == 1'b0)begin
            if(count==16'd32768)begin
                count <= 16'd0;
                _MP3_addr_rst_n <= 1'b1;
            end
            else
                count<=count+1;
        end
        else if(RO_data_old != RO_data)begin//״̬�ı�
            if(RO_data == 2'b11)begin
                sel_cur <= sel_cur;
            end
            else if(RO_data == 2'b01)begin
                if(sel_cur == 2'b10)
                    sel_cur <= 2'b00;
                else
                    sel_cur <= sel_cur+1;
            end
            else if(RO_data == 2'b10)begin
                if(sel_cur == 2'b00)
                    sel_cur <=2'b10;
                else
                    sel_cur <= sel_cur+2'd3;
            end
            else if(RO_data == 2'b00)begin
                _MP3_addr_rst_n <= 1'b0;
            end
            RO_data_old <= RO_data;//�������ڵ�״̬��old��
        end
    end
    
    wire mp3_rst;
    assign mp3_rst = _MP3_addr_rst_n && rst;//��һ����λ���ǵ�
    
    //mp3
    mp3 u_top_mp3(
        .sel(sel),
        .clk(clk),
        .rst(mp3_rst),
        .DREQ(DREQ),//i
        .XDCS(XDCS),
        .XCS(XCS),
        .SI(SI),
        .SCLK(SCLK),
        .XRESET(XRESET)
        ,.o_music(o_music)
    );
    //����۲�
    //assign o_music = {RO_data_old,RO_data,iA,iB,mp3_rst,7'b0};
    
    //VGA
    VGA u_top_VGA(
        .clk(clk),
        .rst(rst),
        .sel(sel),//i
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
    );
    
endmodule
