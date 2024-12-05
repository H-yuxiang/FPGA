`timescale 1ns / 1ns
module TOP_tb;
reg clk,rst,iA,iB,SW,DREQ;
wire XDCS,XCS,SI,SCLK,XRESET,VGA_R,VGA_G,VGA_B,VGA_HS,VGA_VS;
wire[1:0]o_sel;
wire[15:0]o_music;
initial
begin
    clk=0;
    forever #2 clk=~clk;
end
initial
begin
    iA = 1;
    iB = 1;
    SW = 1;
    DREQ = 1;
end
initial
begin
    rst = 0;#10
    rst = 1;
end
TOP uut(
    .clk(clk),
    .rst(rst),
    //rotation
    .iA(iA),
    .iB(iB),
    .SW(SW),
    //mp3
    .DREQ(DREQ),
    .XDCS(XDCS),//data
    .XCS(XCS),//cmd
    .SI(SI),
    .SCLK(SCLK),
    .XRESET(XRESET),//复位信号 低电平有效 
    //vga
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS),
    //检查
    .o_sel(o_sel)
    ,.o_music(o_music)
);
endmodule
