`timescale 1ns / 1ns

module mp3(//mp3
    input [1:0]sel,//选择地址，调取ip核的数据
    input clk,
    input rst,//地址复位
    input DREQ,//数据请求控制信号 高电平有效
    output reg XDCS,//data
    output reg XCS,//cmd
    output reg SI,
    output reg SCLK,
    output reg XRESET//复位信号 低电平有效
    ,output [13:0]o_music
    //,output [3:0]_state
    );
    wire clk_div;//分频后的时钟 1MHz
    Divider#(.X(100)) div_u(
        .I_CLK(clk),
        .rst(0),
        .O_CLK(clk_div)
    );
    
    reg [15:0]_addr;
    wire [15:0]addr;
    assign addr = _addr;
    wire [15:0]oData[3:0];//音频数据 
    wire [3:0]select;//选择信号 
    assign select[0] = ~(sel[0]||sel[1]);//00
    assign select[1] = sel[0]&&(~sel[1]);//01
    assign select[2] = (~sel[0])&&sel[1];//10
    //assign select[3] = sel[0]&&sel[1];//11
    
    //调取数据
    blk_mem_gen_music_0 uut_music_0 (
      .clka(clk_div),    // input wire clka
      .ena(select[0]),      // input wire ena
      .addra(addr),  // input wire [15 : 0] addra
      .douta(oData[0])  // output wire [15 : 0] douta
    );
    blk_mem_gen_music_1 uut_music_1 (
      .clka(clk_div),    // input wire clka
      .ena(select[1]),      // input wire ena
      .addra(addr),  // input wire [15 : 0] addra
      .douta(oData[1])  // output wire [15 : 0] douta
    );
     blk_mem_gen_music_2 uut_music_2 (
      .clka(clk_div),    // input wire clka
      .ena(select[2]),      // input wire ena
      .addra(addr),  // input wire [15 : 0] addra
      .douta(oData[2])  // output wire [15 : 0] douta
    );
    
    wire [15:0]Data;
    assign Data = (select[0]) ? oData[0] :((select[1]) ? oData[1] : ((select[2]) ? oData[2] : oData[0]));
    
    //状态机状态定义
    reg [3:0]state = 0;
    assign o_music = {state[3:0],10'd0};
//    assign _state = state;
    parameter DELAY = 4'd0;
//    parameter RST = 4'd1;
//    parameter S_rst = 4'd2;
    parameter Vol = 4'd3;
    parameter Load = 4'd4;
    parameter Play = 4'd5;
    parameter Cmd = 4'd6;
//    parameter pre_Play = 4'd7;
        
    reg [15:0]music_data;//播放的音乐
    
    //延迟控制
    parameter MAX_DELAY = 500000;//半秒
    integer delay = 0;
    
    reg [7:0] cmd_cnt;
    reg [7:0] data_cnt;
    reg [63:0]cmd={32'h02000804,32'h020B000F};//指令 复位+音量 共2个32位数据
    
    always@(posedge clk_div or negedge rst) begin
	    if(!rst)begin
	    	state <= DELAY;
	    	delay <= 0;
	    	XCS   <= 1'b1;
            XDCS  <= 1'b1;
            SCLK  <= 0;
            _addr <= 0;
            XRESET <= 1'b0;
	    end
	    else begin
	        case(state)
	            DELAY:begin //等待信号
	                if(delay==MAX_DELAY)begin
	                   //进入指令发送环节，进行软复位
	                    state<=Cmd;
	                    //将所有的数据先置一个初值
	                    XRESET<=1'b1;
	                    delay<=0;
	                    cmd_cnt<=0;
	                    data_cnt<=0;
	                    XCS<=1'b1;
	                    XDCS<=1'b1;
	                    SCLK<=0;
	                end
	                else begin
	                    delay<=delay+1;
	                end
	            end
	            Cmd:begin//播放前向vs1003发送指令进行软复位
	                if(DREQ)begin//有请求
	                    if(SCLK)begin//上升沿发送数据
	                        if(data_cnt==32)begin
	                            XCS<=1'b1;
	                            data_cnt<=0;
	                            XRESET<=1'b1;
	                            state<=Vol;
	                        end
	                        else begin
	                           XCS<=0;//开始传输信号
	                           SI<=cmd[63];
	                           cmd<={cmd[62:0],cmd[63]};
	                           data_cnt<=data_cnt+1; 
	                        end
	                    end//SCLK
	                    SCLK<=~SCLK;
	                end//DREQ
	            end
	            Vol:begin
	                if(DREQ)begin//有请求
	                    if(SCLK)begin//上升沿发送数据
	                        if(data_cnt==32)begin
	                            XCS<=1'b1;
	                            data_cnt<=0;
	                            state<=Load;
	                        end
	                        else begin
	                            XCS<=0;//开始传输信号
	                            SI<=cmd[63];
	                            cmd<={cmd[62:0],cmd[63]};
	                            data_cnt<=data_cnt+1; 
	                        end
	                    end//SCLK
	                    SCLK<=~SCLK;
	                end//DREQ
	               // SCLK<=~SCLK;
	            end
	            Load:begin
	                if(DREQ)begin
	                    SCLK<=0;
	                    state<=Play;
	                    music_data<=Data;
	                    data_cnt<=0;
	                end
	            end
	            Play:begin
                    //if(DREQ)begin
                        if(SCLK)begin
                            if(data_cnt==8)begin
                                XDCS<=1;
                                _addr<=_addr+1;
                                state<=Load;
                            end
                            else begin
                                XDCS<=0;
                                SI<=music_data[7];
                                music_data<={music_data[14:0],music_data[15]};
                                data_cnt<=data_cnt+1;
                            end
                        end
                        SCLK<=~SCLK;
                    //end//DREQ
	            end//play
	        endcase
	    end//end else of rst 
    end
endmodule
