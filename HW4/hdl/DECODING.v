module DECODING(
    input clk,
    input srst_n,             
    input [3:0] state,                         
    input [151:0] code_word,       
    output reg decode_complete,
    output reg [7:0] decode_text,
    output reg valid   
);

parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;
reg [7:0] decode_text_tmp;

// cnt
reg [4:0] decode_cnt, decode_cnt_tmp;
always@*
  if((state == DECODE) && (decode_cnt != (code_word[144:140]-1'b1)))
    decode_cnt_tmp = decode_cnt + 1'b1;
  else
    decode_cnt_tmp = 0;

always@*
  if((state == DECODE) && (decode_cnt == (code_word[144:140]-1'b1)))
    decode_complete = 1;
  else
    decode_complete = 0;

always@(posedge clk)
  if(~srst_n)
    decode_cnt <= 0;
  else
    decode_cnt <= decode_cnt_tmp;

// decode word from code_word array
always@*
  case(decode_cnt)
    5'd0: decode_text_tmp = code_word[139:132];
    5'd1: decode_text_tmp = code_word[131:124];
    5'd2: decode_text_tmp = code_word[123:116];
    5'd3: decode_text_tmp = code_word[115:108];
    5'd4: decode_text_tmp = code_word[107:100];
    5'd5: decode_text_tmp = code_word[99:92];
    5'd6: decode_text_tmp = code_word[91:84];
    5'd7: decode_text_tmp = code_word[83:76];
    5'd8: decode_text_tmp = code_word[75:68];
    5'd9: decode_text_tmp = code_word[67:60];
    5'd10: decode_text_tmp = code_word[59:52];
    5'd11: decode_text_tmp = code_word[51:44];
    5'd12: decode_text_tmp = code_word[43:36];
    5'd13: decode_text_tmp = code_word[35:28];
    5'd14: decode_text_tmp = code_word[27:20];
    5'd15: decode_text_tmp = code_word[19:12];
    5'd16: decode_text_tmp = code_word[11:4];
    5'd17: decode_text_tmp = code_word[3:0];
    default: decode_text_tmp = 0;
  endcase

always@(posedge clk)
  if(~srst_n)
    valid <= 0;
  else
    if(state == DECODE)
      valid <= 1;
    else
      valid <= 0;

always@(posedge clk)
  if(~srst_n)
    decode_text <= 0;
  else
    decode_text <= decode_text_tmp;


endmodule



