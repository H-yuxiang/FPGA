`timescale 1ns / 1ps

module MUL(
    input [31:0] A,
    input [31:0] B,
    input is_sign,
    output [31:0] HI,
    output [31:0] LO
    );
    wire [63:0]A_real = is_sign ? {{32{A[31]}},A}:{{32'b0},A};
    wire [63:0]B_real = is_sign ? {{32{B[31]}},B}:{{32'b0},B};
    
    wire [63:0]res = A_real * B_real;
    
    assign HI = res[63:32];
    assign LO = res[31:0];
endmodule
