//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
 
module enigma_part3(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);

input clk;               // clock input
input srst_n;            // synchronous reset (active low)
input load;              // load control signal (level sensitive). 0/1: inactive/active
                         // effective in ST_IDLE and ST_LOAD states

input encrypt;           // encrypt control signal (level sensitive). 0/1: inactive/active
                         // effective in ST_READY state

input crypt_mode;        // 0: encrypt; 1:decrypt;

input [2-1:0] table_idx; // table_idx indicates which rotor to be load 
						 // 2'b00: plug board
						 // 2'b01: rotorA
						 // 2'b10: rotorB

input [6-1:0] code_in;		// When load is active, then code_in is input of rotors. 
							// When encrypy is active, then code_in is input of code words.
								
output reg [6-1:0] code_out;   // encrypted code word (register output)
output reg code_valid;         // 0: non-valid code_out; 1: valid code_out (register output)

// FSM
parameter IDLE = 2'b00, LOAD = 2'b01, READY = 2'b10;
wire [1:0] state;
FSM FSM(.clk(clk), .srst_n(srst_n), .load(load), .state(state));

// internal parameter
reg [6-1:0] rotA_o;
reg [6-1:0] ref_o;
reg [2-1:0] rotA_mode;
reg [2:0] rotB_mode;
reg code_valid_tmp;

// table handling
reg [6-1:0] rotorA_table[0:64-1];
reg [6-1:0] rotorB_table[0:64-1];
reg [6-1:0] plug_board[0:32-1];

integer i;
reg [5:0] i_s8_o[0:63];
reg [5:0] s8_o[0:63];
reg [5:0] i_s64_o[0:63];
reg [5:0] s64_o[0:63];
reg counting, counting_tmp;
reg shifting;

// plug board talbe
always@(posedge clk)
  if(~srst_n) 
    for(i = 0; i < 32; i = i+1)
      plug_board[i] <= 0;
  else  
    if(table_idx == 2'd0) begin
      for(i = 0; i < 31; i = i+1) 
        plug_board[i] <= plug_board[i+1];
      plug_board[31] <= code_in;
    end
    else 
      for(i = 0; i < 32; i = i+1)   
        plug_board[i] <= plug_board[i];


always@(posedge clk)
  if(~srst_n) 
    for(i = 0; i < 64; i = i+1)
      rotorA_table[i] <= 6'd0;
  else 
    if(table_idx == 2'd1) begin
      for(i = 0; i < 63; i = i+1)
        rotorA_table[i] <= rotorA_table[i+1];
      rotorA_table[63] <= code_in;
    end
    else
      for(i = 0; i < 64; i = i+1)
        rotorA_table[i] <= rotorA_table[i];
        
always@(posedge clk)
  if(~srst_n) 
    for(i = 0; i < 64; i = i+1)
      rotorB_table[i] <= 6'd0;
  else 
    if(table_idx == 2'd2) begin
      for(i = 0; i < 63; i = i+1)
        rotorB_table[i] <= rotorB_table[i+1];
      rotorB_table[63] <= code_in;
    end
    else 
      if (shifting)
        for(i = 0; i < 64; i = i+1)
          rotorB_table[i] <= s64_o[i];
      else
        for(i = 0; i < 64; i = i+1)
          rotorB_table[i] <= rotorB_table[i];
        

// handle S_BOX8
always@*
   case(rotB_mode)
    3'd0: begin
          s8_o[0] = rotorB_table[0];
          s8_o[1] = rotorB_table[1];
          s8_o[2] = rotorB_table[2];
          s8_o[3] = rotorB_table[3];
          s8_o[4] = rotorB_table[4];
          s8_o[5] = rotorB_table[5];
          s8_o[6] = rotorB_table[6];
          s8_o[7] = rotorB_table[7];
          s8_o[8] = rotorB_table[8];
          s8_o[9] = rotorB_table[9];
          s8_o[10] = rotorB_table[10];
          s8_o[11] = rotorB_table[11];
          s8_o[12] = rotorB_table[12];
          s8_o[13] = rotorB_table[13];
          s8_o[14] = rotorB_table[14];
          s8_o[15] = rotorB_table[15];
          s8_o[16] = rotorB_table[16];
          s8_o[17] = rotorB_table[17];
          s8_o[18] = rotorB_table[18];
          s8_o[19] = rotorB_table[19];
          s8_o[20] = rotorB_table[20];
          s8_o[21] = rotorB_table[21];
          s8_o[22] = rotorB_table[22];
          s8_o[23] = rotorB_table[23];
          s8_o[24] = rotorB_table[24];
          s8_o[25] = rotorB_table[25];
          s8_o[26] = rotorB_table[26];
          s8_o[27] = rotorB_table[27];
          s8_o[28] = rotorB_table[28];
          s8_o[29] = rotorB_table[29];
          s8_o[30] = rotorB_table[30];
          s8_o[31] = rotorB_table[31];
          s8_o[32] = rotorB_table[32];
          s8_o[33] = rotorB_table[33];
          s8_o[34] = rotorB_table[34];
          s8_o[35] = rotorB_table[35];
          s8_o[36] = rotorB_table[36];
          s8_o[37] = rotorB_table[37];
          s8_o[38] = rotorB_table[38];
          s8_o[39] = rotorB_table[39];
          s8_o[40] = rotorB_table[40];
          s8_o[41] = rotorB_table[41];
          s8_o[42] = rotorB_table[42];
          s8_o[43] = rotorB_table[43];
          s8_o[44] = rotorB_table[44];
          s8_o[45] = rotorB_table[45];
          s8_o[46] = rotorB_table[46];
          s8_o[47] = rotorB_table[47];
          s8_o[48] = rotorB_table[48];
          s8_o[49] = rotorB_table[49];
          s8_o[50] = rotorB_table[50];
          s8_o[51] = rotorB_table[51];
          s8_o[52] = rotorB_table[52];
          s8_o[53] = rotorB_table[53];
          s8_o[54] = rotorB_table[54];
          s8_o[55] = rotorB_table[55];
          s8_o[56] = rotorB_table[56];
          s8_o[57] = rotorB_table[57];
          s8_o[58] = rotorB_table[58];
          s8_o[59] = rotorB_table[59];
          s8_o[60] = rotorB_table[60];
          s8_o[61] = rotorB_table[61];
          s8_o[62] = rotorB_table[62];
          s8_o[63] = rotorB_table[63];
    end
    3'd1: begin
          s8_o[0] = rotorB_table[1];
          s8_o[1] = rotorB_table[0];
          s8_o[2] = rotorB_table[3];
          s8_o[3] = rotorB_table[2];
          s8_o[4] = rotorB_table[5];
          s8_o[5] = rotorB_table[4];
          s8_o[6] = rotorB_table[7];
          s8_o[7] = rotorB_table[6];
          s8_o[8] = rotorB_table[9];
          s8_o[9] = rotorB_table[8];
          s8_o[10] = rotorB_table[11];
          s8_o[11] = rotorB_table[10];
          s8_o[12] = rotorB_table[13];
          s8_o[13] = rotorB_table[12];
          s8_o[14] = rotorB_table[15];
          s8_o[15] = rotorB_table[14];
          s8_o[16] = rotorB_table[17];
          s8_o[17] = rotorB_table[16];
          s8_o[18] = rotorB_table[19];
          s8_o[19] = rotorB_table[18];
          s8_o[20] = rotorB_table[21];
          s8_o[21] = rotorB_table[20];
          s8_o[22] = rotorB_table[23];
          s8_o[23] = rotorB_table[22];
          s8_o[24] = rotorB_table[25];
          s8_o[25] = rotorB_table[24];
          s8_o[26] = rotorB_table[27];
          s8_o[27] = rotorB_table[26];
          s8_o[28] = rotorB_table[29];
          s8_o[29] = rotorB_table[28];
          s8_o[30] = rotorB_table[31];
          s8_o[31] = rotorB_table[30];
          s8_o[32] = rotorB_table[33];
          s8_o[33] = rotorB_table[32];
          s8_o[34] = rotorB_table[35];
          s8_o[35] = rotorB_table[34];
          s8_o[36] = rotorB_table[37];
          s8_o[37] = rotorB_table[36];
          s8_o[38] = rotorB_table[39];
          s8_o[39] = rotorB_table[38];
          s8_o[40] = rotorB_table[41];
          s8_o[41] = rotorB_table[40];
          s8_o[42] = rotorB_table[43];
          s8_o[43] = rotorB_table[42];
          s8_o[44] = rotorB_table[45];
          s8_o[45] = rotorB_table[44];
          s8_o[46] = rotorB_table[47];
          s8_o[47] = rotorB_table[46];
          s8_o[48] = rotorB_table[49];
          s8_o[49] = rotorB_table[48];
          s8_o[50] = rotorB_table[51];
          s8_o[51] = rotorB_table[50];
          s8_o[52] = rotorB_table[53];
          s8_o[53] = rotorB_table[52];
          s8_o[54] = rotorB_table[55];
          s8_o[55] = rotorB_table[54];
          s8_o[56] = rotorB_table[57];
          s8_o[57] = rotorB_table[56];
          s8_o[58] = rotorB_table[59];
          s8_o[59] = rotorB_table[58];
          s8_o[60] = rotorB_table[61];
          s8_o[61] = rotorB_table[60];
          s8_o[62] = rotorB_table[63];
          s8_o[63] = rotorB_table[62];
    end
    3'd2: begin
          s8_o[0] = rotorB_table[2];
          s8_o[1] = rotorB_table[3];
          s8_o[2] = rotorB_table[0];
          s8_o[3] = rotorB_table[1];
          s8_o[4] = rotorB_table[6];
          s8_o[5] = rotorB_table[7];
          s8_o[6] = rotorB_table[4];
          s8_o[7] = rotorB_table[5];
          s8_o[8] = rotorB_table[10];
          s8_o[9] = rotorB_table[11];
          s8_o[10] = rotorB_table[8];
          s8_o[11] = rotorB_table[9];
          s8_o[12] = rotorB_table[14];
          s8_o[13] = rotorB_table[15];
          s8_o[14] = rotorB_table[12];
          s8_o[15] = rotorB_table[13];
          s8_o[16] = rotorB_table[18];
          s8_o[17] = rotorB_table[19];
          s8_o[18] = rotorB_table[16];
          s8_o[19] = rotorB_table[17];
          s8_o[20] = rotorB_table[22];
          s8_o[21] = rotorB_table[23];
          s8_o[22] = rotorB_table[20];
          s8_o[23] = rotorB_table[21];
          s8_o[24] = rotorB_table[26];
          s8_o[25] = rotorB_table[27];
          s8_o[26] = rotorB_table[24];
          s8_o[27] = rotorB_table[25];
          s8_o[28] = rotorB_table[30];
          s8_o[29] = rotorB_table[31];
          s8_o[30] = rotorB_table[28];
          s8_o[31] = rotorB_table[29];
          s8_o[32] = rotorB_table[34];
          s8_o[33] = rotorB_table[35];
          s8_o[34] = rotorB_table[32];
          s8_o[35] = rotorB_table[33];
          s8_o[36] = rotorB_table[38];
          s8_o[37] = rotorB_table[39];
          s8_o[38] = rotorB_table[36];
          s8_o[39] = rotorB_table[37];
          s8_o[40] = rotorB_table[42];
          s8_o[41] = rotorB_table[43];
          s8_o[42] = rotorB_table[40];
          s8_o[43] = rotorB_table[41];
          s8_o[44] = rotorB_table[46];
          s8_o[45] = rotorB_table[47];
          s8_o[46] = rotorB_table[44];
          s8_o[47] = rotorB_table[45];
          s8_o[48] = rotorB_table[50];
          s8_o[49] = rotorB_table[51];
          s8_o[50] = rotorB_table[48];
          s8_o[51] = rotorB_table[49];
          s8_o[52] = rotorB_table[54];
          s8_o[53] = rotorB_table[55];
          s8_o[54] = rotorB_table[52];
          s8_o[55] = rotorB_table[53];
          s8_o[56] = rotorB_table[58];
          s8_o[57] = rotorB_table[59];
          s8_o[58] = rotorB_table[56];
          s8_o[59] = rotorB_table[57];
          s8_o[60] = rotorB_table[62];
          s8_o[61] = rotorB_table[63];
          s8_o[62] = rotorB_table[60];
          s8_o[63] = rotorB_table[61];
    end
    3'd3: begin
          s8_o[0] = rotorB_table[0];
          s8_o[1] = rotorB_table[4];
          s8_o[2] = rotorB_table[5];
          s8_o[3] = rotorB_table[6];
          s8_o[4] = rotorB_table[1];
          s8_o[5] = rotorB_table[2];
          s8_o[6] = rotorB_table[3];
          s8_o[7] = rotorB_table[7];
          s8_o[8] = rotorB_table[8];
          s8_o[9] = rotorB_table[12];
          s8_o[10] = rotorB_table[13];
          s8_o[11] = rotorB_table[14];
          s8_o[12] = rotorB_table[9];
          s8_o[13] = rotorB_table[10];
          s8_o[14] = rotorB_table[11];
          s8_o[15] = rotorB_table[15];
          s8_o[16] = rotorB_table[16];
          s8_o[17] = rotorB_table[20];
          s8_o[18] = rotorB_table[21];
          s8_o[19] = rotorB_table[22];
          s8_o[20] = rotorB_table[17];
          s8_o[21] = rotorB_table[18];
          s8_o[22] = rotorB_table[19];
          s8_o[23] = rotorB_table[23];
          s8_o[24] = rotorB_table[24];
          s8_o[25] = rotorB_table[28];
          s8_o[26] = rotorB_table[29];
          s8_o[27] = rotorB_table[30];
          s8_o[28] = rotorB_table[25];
          s8_o[29] = rotorB_table[26];
          s8_o[30] = rotorB_table[27];
          s8_o[31] = rotorB_table[31];
          s8_o[32] = rotorB_table[32];
          s8_o[33] = rotorB_table[36];
          s8_o[34] = rotorB_table[37];
          s8_o[35] = rotorB_table[38];
          s8_o[36] = rotorB_table[33];
          s8_o[37] = rotorB_table[34];
          s8_o[38] = rotorB_table[35];
          s8_o[39] = rotorB_table[39];
          s8_o[40] = rotorB_table[40];
          s8_o[41] = rotorB_table[44];
          s8_o[42] = rotorB_table[45];
          s8_o[43] = rotorB_table[46];
          s8_o[44] = rotorB_table[41];
          s8_o[45] = rotorB_table[42];
          s8_o[46] = rotorB_table[43];
          s8_o[47] = rotorB_table[47];
          s8_o[48] = rotorB_table[48];
          s8_o[49] = rotorB_table[52];
          s8_o[50] = rotorB_table[53];
          s8_o[51] = rotorB_table[54];
          s8_o[52] = rotorB_table[49];
          s8_o[53] = rotorB_table[50];
          s8_o[54] = rotorB_table[51];
          s8_o[55] = rotorB_table[55];
          s8_o[56] = rotorB_table[56];
          s8_o[57] = rotorB_table[60];
          s8_o[58] = rotorB_table[61];
          s8_o[59] = rotorB_table[62];
          s8_o[60] = rotorB_table[57];
          s8_o[61] = rotorB_table[58];
          s8_o[62] = rotorB_table[59];
          s8_o[63] = rotorB_table[63];
    end
    3'd4: begin
          s8_o[0] = rotorB_table[4];
          s8_o[1] = rotorB_table[5];
          s8_o[2] = rotorB_table[6];
          s8_o[3] = rotorB_table[7];
          s8_o[4] = rotorB_table[0];
          s8_o[5] = rotorB_table[1];
          s8_o[6] = rotorB_table[2];
          s8_o[7] = rotorB_table[3];
          s8_o[8] = rotorB_table[12];
          s8_o[9] = rotorB_table[13];
          s8_o[10] = rotorB_table[14];
          s8_o[11] = rotorB_table[15];
          s8_o[12] = rotorB_table[8];
          s8_o[13] = rotorB_table[9];
          s8_o[14] = rotorB_table[10];
          s8_o[15] = rotorB_table[11];
          s8_o[16] = rotorB_table[20];
          s8_o[17] = rotorB_table[21];
          s8_o[18] = rotorB_table[22];
          s8_o[19] = rotorB_table[23];
          s8_o[20] = rotorB_table[16];
          s8_o[21] = rotorB_table[17];
          s8_o[22] = rotorB_table[18];
          s8_o[23] = rotorB_table[19];
          s8_o[24] = rotorB_table[28];
          s8_o[25] = rotorB_table[29];
          s8_o[26] = rotorB_table[30];
          s8_o[27] = rotorB_table[31];
          s8_o[28] = rotorB_table[24];
          s8_o[29] = rotorB_table[25];
          s8_o[30] = rotorB_table[26];
          s8_o[31] = rotorB_table[27];
          s8_o[32] = rotorB_table[36];
          s8_o[33] = rotorB_table[37];
          s8_o[34] = rotorB_table[38];
          s8_o[35] = rotorB_table[39];
          s8_o[36] = rotorB_table[32];
          s8_o[37] = rotorB_table[33];
          s8_o[38] = rotorB_table[34];
          s8_o[39] = rotorB_table[35];
          s8_o[40] = rotorB_table[44];
          s8_o[41] = rotorB_table[45];
          s8_o[42] = rotorB_table[46];
          s8_o[43] = rotorB_table[47];
          s8_o[44] = rotorB_table[40];
          s8_o[45] = rotorB_table[41];
          s8_o[46] = rotorB_table[42];
          s8_o[47] = rotorB_table[43];
          s8_o[48] = rotorB_table[52];
          s8_o[49] = rotorB_table[53];
          s8_o[50] = rotorB_table[54];
          s8_o[51] = rotorB_table[55];
          s8_o[52] = rotorB_table[48];
          s8_o[53] = rotorB_table[49];
          s8_o[54] = rotorB_table[50];
          s8_o[55] = rotorB_table[51];
          s8_o[56] = rotorB_table[60];
          s8_o[57] = rotorB_table[61];
          s8_o[58] = rotorB_table[62];
          s8_o[59] = rotorB_table[63];
          s8_o[60] = rotorB_table[56];
          s8_o[61] = rotorB_table[57];
          s8_o[62] = rotorB_table[58];
          s8_o[63] = rotorB_table[59];
    end
    3'd5: begin
          s8_o[0] = rotorB_table[5];
          s8_o[1] = rotorB_table[6];
          s8_o[2] = rotorB_table[7];
          s8_o[3] = rotorB_table[3];
          s8_o[4] = rotorB_table[4];
          s8_o[5] = rotorB_table[0];
          s8_o[6] = rotorB_table[1];
          s8_o[7] = rotorB_table[2];
          s8_o[8] = rotorB_table[13];
          s8_o[9] = rotorB_table[14];
          s8_o[10] = rotorB_table[15];
          s8_o[11] = rotorB_table[11];
          s8_o[12] = rotorB_table[12];
          s8_o[13] = rotorB_table[8];
          s8_o[14] = rotorB_table[9];
          s8_o[15] = rotorB_table[10];
          s8_o[16] = rotorB_table[21];
          s8_o[17] = rotorB_table[22];
          s8_o[18] = rotorB_table[23];
          s8_o[19] = rotorB_table[19];
          s8_o[20] = rotorB_table[20];
          s8_o[21] = rotorB_table[16];
          s8_o[22] = rotorB_table[17];
          s8_o[23] = rotorB_table[18];
          s8_o[24] = rotorB_table[29];
          s8_o[25] = rotorB_table[30];
          s8_o[26] = rotorB_table[31];
          s8_o[27] = rotorB_table[27];
          s8_o[28] = rotorB_table[28];
          s8_o[29] = rotorB_table[24];
          s8_o[30] = rotorB_table[25];
          s8_o[31] = rotorB_table[26];
          s8_o[32] = rotorB_table[37];
          s8_o[33] = rotorB_table[38];
          s8_o[34] = rotorB_table[39];
          s8_o[35] = rotorB_table[35];
          s8_o[36] = rotorB_table[36];
          s8_o[37] = rotorB_table[32];
          s8_o[38] = rotorB_table[33];
          s8_o[39] = rotorB_table[34];
          s8_o[40] = rotorB_table[45];
          s8_o[41] = rotorB_table[46];
          s8_o[42] = rotorB_table[47];
          s8_o[43] = rotorB_table[43];
          s8_o[44] = rotorB_table[44];
          s8_o[45] = rotorB_table[40];
          s8_o[46] = rotorB_table[41];
          s8_o[47] = rotorB_table[42];
          s8_o[48] = rotorB_table[53];
          s8_o[49] = rotorB_table[54];
          s8_o[50] = rotorB_table[55];
          s8_o[51] = rotorB_table[51];
          s8_o[52] = rotorB_table[52];
          s8_o[53] = rotorB_table[48];
          s8_o[54] = rotorB_table[49];
          s8_o[55] = rotorB_table[50];
          s8_o[56] = rotorB_table[61];
          s8_o[57] = rotorB_table[62];
          s8_o[58] = rotorB_table[63];
          s8_o[59] = rotorB_table[59];
          s8_o[60] = rotorB_table[60];
          s8_o[61] = rotorB_table[56];
          s8_o[62] = rotorB_table[57];
          s8_o[63] = rotorB_table[58];
    end
    3'd6: begin
          s8_o[0] = rotorB_table[6];
          s8_o[1] = rotorB_table[7];
          s8_o[2] = rotorB_table[3];
          s8_o[3] = rotorB_table[2];
          s8_o[4] = rotorB_table[5];
          s8_o[5] = rotorB_table[4];
          s8_o[6] = rotorB_table[0];
          s8_o[7] = rotorB_table[1];
          s8_o[8] = rotorB_table[14];
          s8_o[9] = rotorB_table[15];
          s8_o[10] = rotorB_table[11];
          s8_o[11] = rotorB_table[10];
          s8_o[12] = rotorB_table[13];
          s8_o[13] = rotorB_table[12];
          s8_o[14] = rotorB_table[8];
          s8_o[15] = rotorB_table[9];
          s8_o[16] = rotorB_table[22];
          s8_o[17] = rotorB_table[23];
          s8_o[18] = rotorB_table[19];
          s8_o[19] = rotorB_table[18];
          s8_o[20] = rotorB_table[21];
          s8_o[21] = rotorB_table[20];
          s8_o[22] = rotorB_table[16];
          s8_o[23] = rotorB_table[17];
          s8_o[24] = rotorB_table[30];
          s8_o[25] = rotorB_table[31];
          s8_o[26] = rotorB_table[27];
          s8_o[27] = rotorB_table[26];
          s8_o[28] = rotorB_table[29];
          s8_o[29] = rotorB_table[28];
          s8_o[30] = rotorB_table[24];
          s8_o[31] = rotorB_table[25];
          s8_o[32] = rotorB_table[38];
          s8_o[33] = rotorB_table[39];
          s8_o[34] = rotorB_table[35];
          s8_o[35] = rotorB_table[34];
          s8_o[36] = rotorB_table[37];
          s8_o[37] = rotorB_table[36];
          s8_o[38] = rotorB_table[32];
          s8_o[39] = rotorB_table[33];
          s8_o[40] = rotorB_table[46];
          s8_o[41] = rotorB_table[47];
          s8_o[42] = rotorB_table[43];
          s8_o[43] = rotorB_table[42];
          s8_o[44] = rotorB_table[45];
          s8_o[45] = rotorB_table[44];
          s8_o[46] = rotorB_table[40];
          s8_o[47] = rotorB_table[41];
          s8_o[48] = rotorB_table[54];
          s8_o[49] = rotorB_table[55];
          s8_o[50] = rotorB_table[51];
          s8_o[51] = rotorB_table[50];
          s8_o[52] = rotorB_table[53];
          s8_o[53] = rotorB_table[52];
          s8_o[54] = rotorB_table[48];
          s8_o[55] = rotorB_table[49];
          s8_o[56] = rotorB_table[62];
          s8_o[57] = rotorB_table[63];
          s8_o[58] = rotorB_table[59];
          s8_o[59] = rotorB_table[58];
          s8_o[60] = rotorB_table[61];
          s8_o[61] = rotorB_table[60];
          s8_o[62] = rotorB_table[56];
          s8_o[63] = rotorB_table[57];
    end
    3'd7: begin
          s8_o[0] = rotorB_table[7];
          s8_o[1] = rotorB_table[6];
          s8_o[2] = rotorB_table[5];
          s8_o[3] = rotorB_table[4];
          s8_o[4] = rotorB_table[3];
          s8_o[5] = rotorB_table[2];
          s8_o[6] = rotorB_table[1];
          s8_o[7] = rotorB_table[0];
          s8_o[8] = rotorB_table[15];
          s8_o[9] = rotorB_table[14];
          s8_o[10] = rotorB_table[13];
          s8_o[11] = rotorB_table[12];
          s8_o[12] = rotorB_table[11];
          s8_o[13] = rotorB_table[10];
          s8_o[14] = rotorB_table[9];
          s8_o[15] = rotorB_table[8];
          s8_o[16] = rotorB_table[23];
          s8_o[17] = rotorB_table[22];
          s8_o[18] = rotorB_table[21];
          s8_o[19] = rotorB_table[20];
          s8_o[20] = rotorB_table[19];
          s8_o[21] = rotorB_table[18];
          s8_o[22] = rotorB_table[17];
          s8_o[23] = rotorB_table[16];
          s8_o[24] = rotorB_table[31];
          s8_o[25] = rotorB_table[30];
          s8_o[26] = rotorB_table[29];
          s8_o[27] = rotorB_table[28];
          s8_o[28] = rotorB_table[27];
          s8_o[29] = rotorB_table[26];
          s8_o[30] = rotorB_table[25];
          s8_o[31] = rotorB_table[24];
          s8_o[32] = rotorB_table[39];
          s8_o[33] = rotorB_table[38];
          s8_o[34] = rotorB_table[37];
          s8_o[35] = rotorB_table[36];
          s8_o[36] = rotorB_table[35];
          s8_o[37] = rotorB_table[34];
          s8_o[38] = rotorB_table[33];
          s8_o[39] = rotorB_table[32];
          s8_o[40] = rotorB_table[47];
          s8_o[41] = rotorB_table[46];
          s8_o[42] = rotorB_table[45];
          s8_o[43] = rotorB_table[44];
          s8_o[44] = rotorB_table[43];
          s8_o[45] = rotorB_table[42];
          s8_o[46] = rotorB_table[41];
          s8_o[47] = rotorB_table[40];
          s8_o[48] = rotorB_table[55];
          s8_o[49] = rotorB_table[54];
          s8_o[50] = rotorB_table[53];
          s8_o[51] = rotorB_table[52];
          s8_o[52] = rotorB_table[51];
          s8_o[53] = rotorB_table[50];
          s8_o[54] = rotorB_table[49];
          s8_o[55] = rotorB_table[48];
          s8_o[56] = rotorB_table[63];
          s8_o[57] = rotorB_table[62];
          s8_o[58] = rotorB_table[61];
          s8_o[59] = rotorB_table[60];
          s8_o[60] = rotorB_table[59];
          s8_o[61] = rotorB_table[58];
          s8_o[62] = rotorB_table[57];
          s8_o[63] = rotorB_table[56];
    end
    default: 
      for(i = 0; i < 64; i = i+1)
        s8_o[i] = rotorB_table[i];
  endcase
 //end

// handle S_BOX64
always@* begin
      s64_o[0] = s8_o[20];
      s64_o[1] = s8_o[50];
      s64_o[2] = s8_o[8];
      s64_o[3] = s8_o[36];
      s64_o[4] = s8_o[48];
      s64_o[5] = s8_o[26];
      s64_o[6] = s8_o[55];
      s64_o[7] = s8_o[13];
      s64_o[8] = s8_o[44];
      s64_o[9] = s8_o[43];
      s64_o[10] = s8_o[10];
      s64_o[11] = s8_o[52];
      s64_o[12] = s8_o[54];
      s64_o[13] = s8_o[25];
      s64_o[14] = s8_o[41];
      s64_o[15] = s8_o[0];
      s64_o[16] = s8_o[63];
      s64_o[17] = s8_o[16];
      s64_o[18] = s8_o[34];
      s64_o[19] = s8_o[6];
      s64_o[20] = s8_o[61];
      s64_o[21] = s8_o[30];
      s64_o[22] = s8_o[7];
      s64_o[23] = s8_o[5];
      s64_o[24] = s8_o[47];
      s64_o[25] = s8_o[17];
      s64_o[26] = s8_o[11];
      s64_o[27] = s8_o[38];
      s64_o[28] = s8_o[12];
      s64_o[29] = s8_o[27];
      s64_o[30] = s8_o[3];
      s64_o[31] = s8_o[9];
      s64_o[32] = s8_o[35];
      s64_o[33] = s8_o[14];
      s64_o[34] = s8_o[40];
      s64_o[35] = s8_o[56];
      s64_o[36] = s8_o[32];
      s64_o[37] = s8_o[57];
      s64_o[38] = s8_o[49];
      s64_o[39] = s8_o[21];
      s64_o[40] = s8_o[19];
      s64_o[41] = s8_o[45];
      s64_o[42] = s8_o[18];
      s64_o[43] = s8_o[60];
      s64_o[44] = s8_o[15];
      s64_o[45] = s8_o[22];
      s64_o[46] = s8_o[53];
      s64_o[47] = s8_o[4];
      s64_o[48] = s8_o[1];
      s64_o[49] = s8_o[46];
      s64_o[50] = s8_o[2];
      s64_o[51] = s8_o[62];
      s64_o[52] = s8_o[28];
      s64_o[53] = s8_o[31];
      s64_o[54] = s8_o[23];
      s64_o[55] = s8_o[58];
      s64_o[56] = s8_o[29];
      s64_o[57] = s8_o[33];
      s64_o[58] = s8_o[51];
      s64_o[59] = s8_o[42];
      s64_o[60] = s8_o[24];
      s64_o[61] = s8_o[39];
      s64_o[62] = s8_o[37];
      s64_o[63] = s8_o[59];
end

reg [5:0] plug_in, plug_o;
reg [5:0] shiftA_num, shiftA_num_tmp2, shiftA_num_tmp;
// store code_in value
always@(posedge clk)
  if(~srst_n)
    plug_in <= 6'd0;
  else
    plug_in <= code_in;

// plug 
always@*
  case(plug_in)
    plug_board[0]: plug_o = plug_board[1];
    plug_board[1]: plug_o = plug_board[0];
    plug_board[2]: plug_o = plug_board[3];
    plug_board[3]: plug_o = plug_board[2];
    plug_board[4]: plug_o = plug_board[5];
    plug_board[5]: plug_o = plug_board[4];
    plug_board[6]: plug_o = plug_board[7];
    plug_board[7]: plug_o = plug_board[6];
    plug_board[8]: plug_o = plug_board[9];
    plug_board[9]: plug_o = plug_board[8];
    plug_board[10]: plug_o = plug_board[11];
    plug_board[11]: plug_o = plug_board[10];
    plug_board[12]: plug_o = plug_board[13];
    plug_board[13]: plug_o = plug_board[12];
    plug_board[14]: plug_o = plug_board[15];
    plug_board[15]: plug_o = plug_board[14];
    plug_board[16]: plug_o = plug_board[17];
    plug_board[17]: plug_o = plug_board[16];
    plug_board[18]: plug_o = plug_board[19];
    plug_board[19]: plug_o = plug_board[18];
    plug_board[20]: plug_o = plug_board[21];
    plug_board[21]: plug_o = plug_board[20];
    plug_board[22]: plug_o = plug_board[23];
    plug_board[23]: plug_o = plug_board[22];
    plug_board[24]: plug_o = plug_board[25];
    plug_board[25]: plug_o = plug_board[24];
    plug_board[26]: plug_o = plug_board[27];
    plug_board[27]: plug_o = plug_board[26];
    plug_board[28]: plug_o = plug_board[29];
    plug_board[29]: plug_o = plug_board[28];
    plug_board[30]: plug_o = plug_board[31];
    plug_board[31]: plug_o = plug_board[30];
    default: plug_o = plug_in;
  endcase

reg [5:0] pipe_1;
// pipe_line1
always@(posedge clk)
  if(~srst_n)
    pipe_1 <= 0;
  else
    pipe_1 <= plug_o;
    
// rotA 
always@*
  rotA_o = rotorA_table[pipe_1-shiftA_num];

// A mode control
reg [5:0] i_rotB_o;
always@*
  if(~crypt_mode)
    rotA_mode = rotA_o[1:0];
  else
    rotA_mode = i_rotB_o[1:0];

// counting == 1: decoding/encoding
always@*
  if(encrypt)
    counting_tmp = 1'b1;
  else
    counting_tmp = 1'b0;

always@(posedge clk)
  if(~srst_n)
    counting <= 1'b0;
  else
    counting <= counting_tmp;


always@(posedge clk)
  if(~srst_n)
    shifting <= 1'b0;
  else
    shifting <= counting;

// counter for rot_A shift 
always@*
  if(shifting)
    case(rotA_mode)
      2'b00:
        shiftA_num_tmp = shiftA_num;
      2'b01:
        shiftA_num_tmp = shiftA_num + 2'd1;
      2'b10:
        shiftA_num_tmp = shiftA_num + 2'd2;
      2'b11:
        shiftA_num_tmp = shiftA_num + 2'd3;
      default:
        shiftA_num_tmp = shiftA_num;
    endcase
  else
    shiftA_num_tmp = shiftA_num;

always@(posedge clk)
  if(~srst_n)
    shiftA_num <= 6'd0;
  else
    shiftA_num <= shiftA_num_tmp; 
    
reg [5:0] rotB_o;

// rotB 
always@*
  rotB_o = rotorB_table[rotA_o];

// mode control

always@*
  if(~crypt_mode)
    rotB_mode = rotB_o[2:0];
  else if (crypt_mode)
    rotB_mode = ref_o[2:0];

// ref 
always@*
  ref_o = ~rotB_o;

// i_rotB MUX
always@*
  case(ref_o)
    rotorB_table[0]: i_rotB_o = 6'd0;
    rotorB_table[1]: i_rotB_o = 6'd1;
    rotorB_table[2]: i_rotB_o = 6'd2;
    rotorB_table[3]: i_rotB_o = 6'd3;
    rotorB_table[4]: i_rotB_o = 6'd4;
    rotorB_table[5]: i_rotB_o = 6'd5;
    rotorB_table[6]: i_rotB_o = 6'd6;
    rotorB_table[7]: i_rotB_o = 6'd7;
    rotorB_table[8]: i_rotB_o = 6'd8;
    rotorB_table[9]: i_rotB_o = 6'd9;
    rotorB_table[10]: i_rotB_o = 6'd10;
    rotorB_table[11]: i_rotB_o = 6'd11;
    rotorB_table[12]: i_rotB_o = 6'd12;
    rotorB_table[13]: i_rotB_o = 6'd13;
    rotorB_table[14]: i_rotB_o = 6'd14;
    rotorB_table[15]: i_rotB_o = 6'd15;
    rotorB_table[16]: i_rotB_o = 6'd16;
    rotorB_table[17]: i_rotB_o = 6'd17;
    rotorB_table[18]: i_rotB_o = 6'd18;
    rotorB_table[19]: i_rotB_o = 6'd19;
    rotorB_table[20]: i_rotB_o = 6'd20;
    rotorB_table[21]: i_rotB_o = 6'd21;
    rotorB_table[22]: i_rotB_o = 6'd22;
    rotorB_table[23]: i_rotB_o = 6'd23;
    rotorB_table[24]: i_rotB_o = 6'd24;
    rotorB_table[25]: i_rotB_o = 6'd25;
    rotorB_table[26]: i_rotB_o = 6'd26;
    rotorB_table[27]: i_rotB_o = 6'd27;
    rotorB_table[28]: i_rotB_o = 6'd28;
    rotorB_table[29]: i_rotB_o = 6'd29;
    rotorB_table[30]: i_rotB_o = 6'd30;
    rotorB_table[31]: i_rotB_o = 6'd31;
    rotorB_table[32]: i_rotB_o = 6'd32;
    rotorB_table[33]: i_rotB_o = 6'd33;
    rotorB_table[34]: i_rotB_o = 6'd34;
    rotorB_table[35]: i_rotB_o = 6'd35;
    rotorB_table[36]: i_rotB_o = 6'd36;
    rotorB_table[37]: i_rotB_o = 6'd37;
    rotorB_table[38]: i_rotB_o = 6'd38;
    rotorB_table[39]: i_rotB_o = 6'd39;
    rotorB_table[40]: i_rotB_o = 6'd40;
    rotorB_table[41]: i_rotB_o = 6'd41;
    rotorB_table[42]: i_rotB_o = 6'd42;
    rotorB_table[43]: i_rotB_o = 6'd43;
    rotorB_table[44]: i_rotB_o = 6'd44;
    rotorB_table[45]: i_rotB_o = 6'd45;
    rotorB_table[46]: i_rotB_o = 6'd46;
    rotorB_table[47]: i_rotB_o = 6'd47;
    rotorB_table[48]: i_rotB_o = 6'd48;
    rotorB_table[49]: i_rotB_o = 6'd49;
    rotorB_table[50]: i_rotB_o = 6'd50;
    rotorB_table[51]: i_rotB_o = 6'd51;
    rotorB_table[52]: i_rotB_o = 6'd52;
    rotorB_table[53]: i_rotB_o = 6'd53;
    rotorB_table[54]: i_rotB_o = 6'd54;
    rotorB_table[55]: i_rotB_o = 6'd55;
    rotorB_table[56]: i_rotB_o = 6'd56;
    rotorB_table[57]: i_rotB_o = 6'd57;
    rotorB_table[58]: i_rotB_o = 6'd58;
    rotorB_table[59]: i_rotB_o = 6'd59;
    rotorB_table[60]: i_rotB_o = 6'd60;
    rotorB_table[61]: i_rotB_o = 6'd61;
    rotorB_table[62]: i_rotB_o = 6'd62;
    rotorB_table[63]: i_rotB_o = 6'd63;
    default: i_rotB_o = 6'd0;
  endcase
  
reg [5:0] i_rotA_o;
reg [5:0] pipe_2;
reg [5:0] i_shiftA_num;
// pipe_line2
always@(posedge clk)
  if(~srst_n)
    pipe_2 <= 0;
  else
    pipe_2 <= i_rotB_o;
    
always@(posedge clk)
  if(~srst_n)
    i_shiftA_num <= 0;
  else
    i_shiftA_num <= shiftA_num;
    
// i_rotA MUX
always@*
  case(pipe_2)
    rotorA_table[0]: i_rotA_o = 6'd0+i_shiftA_num;
    rotorA_table[1]: i_rotA_o = 6'd1+i_shiftA_num;
    rotorA_table[2]: i_rotA_o = 6'd2+i_shiftA_num;
    rotorA_table[3]: i_rotA_o = 6'd3+i_shiftA_num;
    rotorA_table[4]: i_rotA_o = 6'd4+i_shiftA_num;
    rotorA_table[5]: i_rotA_o = 6'd5+i_shiftA_num;
    rotorA_table[6]: i_rotA_o = 6'd6+i_shiftA_num;
    rotorA_table[7]: i_rotA_o = 6'd7+i_shiftA_num;
    rotorA_table[8]: i_rotA_o = 6'd8+i_shiftA_num;
    rotorA_table[9]: i_rotA_o = 6'd9+i_shiftA_num;
    rotorA_table[10]: i_rotA_o = 6'd10+i_shiftA_num;
    rotorA_table[11]: i_rotA_o = 6'd11+i_shiftA_num;
    rotorA_table[12]: i_rotA_o = 6'd12+i_shiftA_num;
    rotorA_table[13]: i_rotA_o = 6'd13+i_shiftA_num;
    rotorA_table[14]: i_rotA_o = 6'd14+i_shiftA_num;
    rotorA_table[15]: i_rotA_o = 6'd15+i_shiftA_num;
    rotorA_table[16]: i_rotA_o = 6'd16+i_shiftA_num;
    rotorA_table[17]: i_rotA_o = 6'd17+i_shiftA_num;
    rotorA_table[18]: i_rotA_o = 6'd18+i_shiftA_num;
    rotorA_table[19]: i_rotA_o = 6'd19+i_shiftA_num;
    rotorA_table[20]: i_rotA_o = 6'd20+i_shiftA_num;
    rotorA_table[21]: i_rotA_o = 6'd21+i_shiftA_num;
    rotorA_table[22]: i_rotA_o = 6'd22+i_shiftA_num;
    rotorA_table[23]: i_rotA_o = 6'd23+i_shiftA_num;
    rotorA_table[24]: i_rotA_o = 6'd24+i_shiftA_num;
    rotorA_table[25]: i_rotA_o = 6'd25+i_shiftA_num;
    rotorA_table[26]: i_rotA_o = 6'd26+i_shiftA_num;
    rotorA_table[27]: i_rotA_o = 6'd27+i_shiftA_num;
    rotorA_table[28]: i_rotA_o = 6'd28+i_shiftA_num;
    rotorA_table[29]: i_rotA_o = 6'd29+i_shiftA_num;
    rotorA_table[30]: i_rotA_o = 6'd30+i_shiftA_num;
    rotorA_table[31]: i_rotA_o = 6'd31+i_shiftA_num;
    rotorA_table[32]: i_rotA_o = 6'd32+i_shiftA_num;
    rotorA_table[33]: i_rotA_o = 6'd33+i_shiftA_num;
    rotorA_table[34]: i_rotA_o = 6'd34+i_shiftA_num;
    rotorA_table[35]: i_rotA_o = 6'd35+i_shiftA_num;
    rotorA_table[36]: i_rotA_o = 6'd36+i_shiftA_num;
    rotorA_table[37]: i_rotA_o = 6'd37+i_shiftA_num;
    rotorA_table[38]: i_rotA_o = 6'd38+i_shiftA_num;
    rotorA_table[39]: i_rotA_o = 6'd39+i_shiftA_num;
    rotorA_table[40]: i_rotA_o = 6'd40+i_shiftA_num;
    rotorA_table[41]: i_rotA_o = 6'd41+i_shiftA_num;
    rotorA_table[42]: i_rotA_o = 6'd42+i_shiftA_num;
    rotorA_table[43]: i_rotA_o = 6'd43+i_shiftA_num;
    rotorA_table[44]: i_rotA_o = 6'd44+i_shiftA_num;
    rotorA_table[45]: i_rotA_o = 6'd45+i_shiftA_num;
    rotorA_table[46]: i_rotA_o = 6'd46+i_shiftA_num;
    rotorA_table[47]: i_rotA_o = 6'd47+i_shiftA_num;
    rotorA_table[48]: i_rotA_o = 6'd48+i_shiftA_num;
    rotorA_table[49]: i_rotA_o = 6'd49+i_shiftA_num;
    rotorA_table[50]: i_rotA_o = 6'd50+i_shiftA_num;
    rotorA_table[51]: i_rotA_o = 6'd51+i_shiftA_num;
    rotorA_table[52]: i_rotA_o = 6'd52+i_shiftA_num;
    rotorA_table[53]: i_rotA_o = 6'd53+i_shiftA_num;
    rotorA_table[54]: i_rotA_o = 6'd54+i_shiftA_num;
    rotorA_table[55]: i_rotA_o = 6'd55+i_shiftA_num;
    rotorA_table[56]: i_rotA_o = 6'd56+i_shiftA_num;
    rotorA_table[57]: i_rotA_o = 6'd57+i_shiftA_num;
    rotorA_table[58]: i_rotA_o = 6'd58+i_shiftA_num;
    rotorA_table[59]: i_rotA_o = 6'd59+i_shiftA_num;
    rotorA_table[60]: i_rotA_o = 6'd60+i_shiftA_num;
    rotorA_table[61]: i_rotA_o = 6'd61+i_shiftA_num;
    rotorA_table[62]: i_rotA_o = 6'd62+i_shiftA_num;
    rotorA_table[63]: i_rotA_o = 6'd63+i_shiftA_num;
    default: i_rotA_o = 6'd0;
  endcase
  
    
reg [5:0] pipe_3;
always@(posedge clk)
  if(~srst_n)
    pipe_3 <= 0;
  else
    pipe_3 <= i_rotA_o;

reg [5:0] code_out_t;
// plug 
always@*
  case(pipe_3)
    plug_board[0]: code_out_t = plug_board[1];
    plug_board[1]: code_out_t = plug_board[0];
    plug_board[2]: code_out_t = plug_board[3];
    plug_board[3]: code_out_t = plug_board[2];
    plug_board[4]: code_out_t = plug_board[5];
    plug_board[5]: code_out_t = plug_board[4];
    plug_board[6]: code_out_t = plug_board[7];
    plug_board[7]: code_out_t = plug_board[6];
    plug_board[8]: code_out_t = plug_board[9];
    plug_board[9]: code_out_t = plug_board[8];
    plug_board[10]: code_out_t = plug_board[11];
    plug_board[11]: code_out_t = plug_board[10];
    plug_board[12]: code_out_t = plug_board[13];
    plug_board[13]: code_out_t = plug_board[12];
    plug_board[14]: code_out_t = plug_board[15];
    plug_board[15]: code_out_t = plug_board[14];
    plug_board[16]: code_out_t = plug_board[17];
    plug_board[17]: code_out_t = plug_board[16];
    plug_board[18]: code_out_t = plug_board[19];
    plug_board[19]: code_out_t = plug_board[18];
    plug_board[20]: code_out_t = plug_board[21];
    plug_board[21]: code_out_t = plug_board[20];
    plug_board[22]: code_out_t = plug_board[23];
    plug_board[23]: code_out_t = plug_board[22];
    plug_board[24]: code_out_t = plug_board[25];
    plug_board[25]: code_out_t = plug_board[24];
    plug_board[26]: code_out_t = plug_board[27];
    plug_board[27]: code_out_t = plug_board[26];
    plug_board[28]: code_out_t = plug_board[29];
    plug_board[29]: code_out_t = plug_board[28];
    plug_board[30]: code_out_t = plug_board[31];
    plug_board[31]: code_out_t = plug_board[30];
    default: code_out_t = pipe_3;
  endcase

always@(posedge clk)
  if(~srst_n)
    code_out <= 0;
  else
    code_out <= code_out_t;


always@(posedge clk)
  if(~srst_n)
    code_valid_tmp <= 0;
  else
    code_valid_tmp <= shifting;

reg code_valid_tmp2;

always@(posedge clk)
  if(~srst_n)
    code_valid_tmp2 <= 0;
  else
    code_valid_tmp2 <= code_valid_tmp;


// output FF
always@(posedge clk)
  if(~srst_n)
    code_valid <= 1'b0;
  else
    code_valid <= code_valid_tmp2;



endmodule



