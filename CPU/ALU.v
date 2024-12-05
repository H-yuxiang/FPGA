`timescale 1ns / 1ps

module ALU(
    input [31:0] A,
    input [31:0] B,
    input [4:0] ALUC,
    output [31:0] res,  //计算的结果，用于返回值
    output zero,        //ZF标志位，BEQ/BNE使用
    output carry,       //进位标志位，SLTI/SLTIU使用
    output sign,        //SF标志位，SLT/SLTU使用
    output overflow
    );
    parameter ADDU = 5'b00000;//i
    parameter ADD  = 5'b00001;//lw/sw/i
    parameter SUBU = 5'b00010;
    parameter SUB  = 5'b00011;//beq/bne
    
    parameter AND  = 5'b00100;//i
    parameter OR   = 5'b00101;//i
    parameter XOR  = 5'b00110;//i
    parameter NOR  = 5'b00111;
    
    parameter LUI1 = 5'b01000;
    parameter LUI2 = 5'b01001;
    parameter SLT  = 5'b01010;//i
    parameter SLTU = 5'b01011;//i
    
    parameter SRA  = 5'b01100;//v
    parameter SLL  = 5'b01101;//v
    parameter SLA  = 5'b01110;
    parameter SRL  = 5'b01111;//v
    
    parameter MUL  = 5'b10000;//v
    
    //定义内部变量
    reg [32:0] reg_res;         //多一位观察溢出和进位
    wire signed [31:0] sA,sB;   //有符号化的输入参数A、B
    assign sA = A;
    assign sB = B;
    
    always @(*) begin
        case(ALUC)
            ADDU: begin     reg_res <= A + B;       end
            ADD:  begin     reg_res <= sA + sB;     end
            SUBU: begin     reg_res <= A - B;       end
            SUB:  begin     reg_res <= sA - sB;     end
            
            AND:  begin     reg_res <= A & B;       end
            OR:   begin     reg_res <= A | B;       end
            XOR:  begin     reg_res <= A ^ B;       end
            NOR:  begin     reg_res <= ~(A | B);    end
            
            LUI1,LUI2: begin  reg_res <= {B[15:0],16'b0};   end
            
            SLT:  begin     reg_res <= sA - sB;     end
            SLTU: begin     reg_res <= A - B;       end
            SRA:  begin     reg_res <= sB>>>sA;     end//算数
            SLL,SLA: begin  reg_res <= B << A;      end
            SRL:  begin     reg_res <= B >> A;      end//逻辑
            
            MUL:  begin     reg_res <= sA * sB;     end//截断
        endcase
    end
    
    assign res = reg_res[31:0];
    assign zero = (res==32'b0) ? 1'b1 : 1'b0;//beq/bne
    assign carry = reg_res[32];//slti/sltiu
    assign sign = (ALUC==SLT) ? (sA<sB) : ((ALUC==SLTU) ? (A<B) : 0);//slt/sltu
    assign overflow = 1'b0;//暂时无用
    
endmodule
