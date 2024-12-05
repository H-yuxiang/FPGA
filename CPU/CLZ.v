`timescale 1ns / 1ps

module CLZ(
    input [31:0] data_in,
    output reg [31:0] zero_num
    );
    always@(*)begin
        if(data_in[31] == 1'b1)
            zero_num = 0;
        else if(data_in[31] == 0 && data_in[30] == 1'b1)
            zero_num = 1;
        else if(data_in[31:30] == 0 && data_in[29] == 1'b1)
            zero_num = 2;
        else if(data_in[31:29] == 0 && data_in[28] == 1'b1)
            zero_num = 3;
        else if(data_in[31:28] == 0 && data_in[27] == 1'b1)
            zero_num = 4;
        else if(data_in[31:27] == 0 && data_in[26] == 1'b1)
            zero_num = 5;
        else if(data_in[31:26] == 0 && data_in[25] == 1'b1)
            zero_num = 6;
        else if(data_in[31:25] == 0 && data_in[24] == 1'b1)
            zero_num = 7;
        else if(data_in[31:24] == 0 && data_in[23] == 1'b1)
            zero_num = 8;
        else if(data_in[31:23] == 0 && data_in[22] == 1'b1)
            zero_num = 9;
        else if(data_in[31:22] == 0 && data_in[21] == 1'b1)
            zero_num = 10;
        else if(data_in[31:21] == 0 && data_in[20] == 1'b1)
            zero_num = 11;
        else if(data_in[31:20] == 0 && data_in[19] == 1'b1)
            zero_num = 12;
        else if(data_in[31:19] == 0 && data_in[18] == 1'b1)
            zero_num = 13;
        else if(data_in[31:18] == 0 && data_in[17] == 1'b1)
            zero_num = 14;
        else if(data_in[31:17] == 0 && data_in[16] == 1'b1)
            zero_num = 15;
        else if(data_in[31:16] == 0 && data_in[15] == 1'b1)
            zero_num = 16;
        else if(data_in[31:15] == 0 && data_in[14] == 1'b1)
            zero_num = 17;
        else if(data_in[31:14] == 0 && data_in[13] == 1'b1)
            zero_num = 18;
        else if(data_in[31:13] == 0 && data_in[12] == 1'b1)
            zero_num = 19;
        else if(data_in[31:12] == 0 && data_in[11] == 1'b1)
            zero_num = 20;
        else if(data_in[31:11] == 0 && data_in[10] == 1'b1)
            zero_num = 21;
        else if(data_in[31:10] == 0 && data_in[9] == 1'b1)
            zero_num = 22;
        else if(data_in[31:9] == 0 && data_in[8] == 1'b1)
            zero_num = 23;
        else if(data_in[31:8] == 0 && data_in[7] == 1'b1)
            zero_num = 24;
        else if(data_in[31:7] == 0 && data_in[6] == 1'b1)
            zero_num = 25;
        else if(data_in[31:6] == 0 && data_in[5] == 1'b1)
            zero_num = 26;
        else if(data_in[31:5] == 0 && data_in[4] == 1'b1)
            zero_num = 27;
        else if(data_in[31:4] == 0 && data_in[3] == 1'b1)
            zero_num = 28;
        else if(data_in[31:3] == 0 && data_in[2] == 1'b1)
            zero_num = 29;
        else if(data_in[31:2] == 0 && data_in[1] == 1'b1)
            zero_num = 30;
        else if(data_in[31:1] == 0 && data_in[0] == 1'b1)
            zero_num = 31;
        else
            zero_num = 32;
    end//always
endmodule
