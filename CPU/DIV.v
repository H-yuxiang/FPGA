`timescale 1ns / 1ps

module DIV(
    input [31:0] A,
    input [31:0] B,
    input is_sign,
    output [31:0] Q,
    output [31:0] R
    );
    wire [63:0]A_real = is_sign ? {{32{A[31]}},A}:{{32'b0},A};
    wire [63:0]B_real = is_sign ? {{32{B[31]}},B}:{{32'b0},B};
    
    assign Q = A_real/B_real;
    assign R = A_real%B_real;
endmodule
