`timescale 1ns / 1ps

module HILO(
    input [31:0] HI_in,
    input [31:0] LO_in,
    input ena,
    input clk,//ÏÂ½µÑØĞ´
    input rst,//1¸´Î»
    input HI_w_r,//0r-1w
    input LO_w_r,
    output [31:0] HI_out,
    output [31:0] LO_out
    );
    reg [31:0]reg_HI;
    reg [31:0]reg_LO;
    always@(posedge rst or negedge clk)begin
        if(ena && rst==1)begin
            reg_HI <= 0;
            reg_LO <= 0;
        end
        else if(ena)begin//¶ÁĞ´
            if(HI_w_r==1)//w
                reg_HI <= HI_in;
            if(LO_w_r==1)//w
                reg_LO <= LO_in;
        end
    end
    assign HI_out = (ena && HI_w_r == 0) ? reg_HI : 32'hz;
    assign LO_out = (ena && LO_w_r == 0) ? reg_LO : 32'hz;
endmodule
