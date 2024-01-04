//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
 
module enigma_part2(clk, srst_n, load, encrypt, crypt_mode, table_idx, code_in, code_out, code_valid);

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
							// Note: We only use rotorA and rotor B in part2.
							
output reg [6-1:0] code_out;   // encrypted code word (register output)
output reg code_valid;         // 0: non-valid code_out; 1: valid code_out (register output)

// FSM
parameter IDLE = 2'b00, LOAD = 2'b01, READY = 2'b10;
wire [1:0] n_state, state;
FSM FSM(.clk(clk), .srst_n(srst_n), .load(load), .state(state), .n_state(n_state));

// internal parameter
reg [6-1:0] rotA_o;
reg [6-1:0] ref_o;
reg [2-1:0] rotA_mode;
reg [2:0] rotB_mode;
reg code_valid_tmp;

// table handling
reg [6-1:0] rotorA_table[0:64-1];
reg [6-1:0] rotorB_table[0:64-1];
integer i, j;
reg [5:0] cnt, cnt_tmp;

// counter for initialization
always@*
  if(state == LOAD)
    cnt_tmp = cnt + 1'b1;
  else
    cnt_tmp = cnt;

always@(posedge clk)
  if(~srst_n)
    cnt <= 0;
  else
    cnt <= cnt_tmp;

reg [5:0] s8_o[0:63];
reg [5:0] s64_o[0:63];
reg counting, counting_tmp;
// table output FF
always@(posedge clk)
  if(~srst_n) 
    for(i = 0; i < 64; i = i+1) begin
      rotorA_table[i] <= 6'd0;
      rotorB_table[i] <= 6'd0;
    end
  else 
    for(i = 0; i < 64; i = i+1) begin
      if((cnt == i) && (n_state == LOAD) && (table_idx == 2'd1) && (~counting)) begin
        rotorA_table[i] <= code_in;
        rotorB_table[i] <= rotorB_table[i];
      end
      else if ((cnt == i) && (n_state == LOAD) && (table_idx == 2'd2) && (~counting)) begin
        rotorA_table[i] <= rotorA_table[i];
        rotorB_table[i] <= code_in;
      end
      else if (counting) begin
        rotorA_table[i] <= rotorA_table[i];
        rotorB_table[i] <= s64_o[i];
      end
      else begin
        rotorA_table[i] <= rotorA_table[i];
        rotorB_table[i] <= rotorB_table[i];
      end
    end

reg [31:0] int_sel[0:63];
reg [31:0] int_sel2[0:63];


// handle S_BOX8
always@*
  for(i = 0; i < 64; i = i+1)begin 
   int_sel[i] = i;
   case(rotB_mode)
    3'd0:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd1:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd2:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd3:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd4:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd5:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd6:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    3'd7:
        case(int_sel[i][2:0])
          3'd0: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd7}];
          3'd1: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd6}];
          3'd2: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd5}];
          3'd3: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd4}];
          3'd4: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd3}];
          3'd5: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd2}];
          3'd6: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd1}];
          3'd7: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
          default: s8_o[i] = rotorB_table[{int_sel[i][5:3], 3'd0}];
        endcase
    default: 
        s8_o[i] = rotorB_table[i];
  endcase
 end

// handle S_BOX64
always@*
  if(~counting)
    for(i = 0; i < 64; i = i+1)
      s64_o[i] = rotorB_table[i];
  else begin
    for(i = 0; i < 64; i = i+1) begin
      int_sel2[i] = i;
      case(int_sel2[i][5:0])
      6'd0: s64_o[i] = s8_o[20];
      6'd1: s64_o[i] = s8_o[50];
      6'd2: s64_o[i] = s8_o[8];
      6'd3: s64_o[i] = s8_o[36];
      6'd4: s64_o[i] = s8_o[48];
      6'd5: s64_o[i] = s8_o[26];
      6'd6: s64_o[i] = s8_o[55];
      6'd7: s64_o[i] = s8_o[13];
      6'd8: s64_o[i] = s8_o[44];
      6'd9: s64_o[i] = s8_o[43];
      6'd10: s64_o[i] = s8_o[10];
      6'd11: s64_o[i] = s8_o[52];
      6'd12: s64_o[i] = s8_o[54];
      6'd13: s64_o[i] = s8_o[25];
      6'd14: s64_o[i] = s8_o[41];
      6'd15: s64_o[i] = s8_o[0];
      6'd16: s64_o[i] = s8_o[63];
      6'd17: s64_o[i] = s8_o[16];
      6'd18: s64_o[i] = s8_o[34];
      6'd19: s64_o[i] = s8_o[6];
      6'd20: s64_o[i] = s8_o[61];
      6'd21: s64_o[i] = s8_o[30];
      6'd22: s64_o[i] = s8_o[7];
      6'd23: s64_o[i] = s8_o[5];
      6'd24: s64_o[i] = s8_o[47];
      6'd25: s64_o[i] = s8_o[17];
      6'd26: s64_o[i] = s8_o[11];
      6'd27: s64_o[i] = s8_o[38];
      6'd28: s64_o[i] = s8_o[12];
      6'd29: s64_o[i] = s8_o[27];
      6'd30: s64_o[i] = s8_o[3];
      6'd31: s64_o[i] = s8_o[9];
      6'd32: s64_o[i] = s8_o[35];
      6'd33: s64_o[i] = s8_o[14];
      6'd34: s64_o[i] = s8_o[40];
      6'd35: s64_o[i] = s8_o[56];
      6'd36: s64_o[i] = s8_o[32];
      6'd37: s64_o[i] = s8_o[57];
      6'd38: s64_o[i] = s8_o[49];
      6'd39: s64_o[i] = s8_o[21];
      6'd40: s64_o[i] = s8_o[19];
      6'd41: s64_o[i] = s8_o[45];
      6'd42: s64_o[i] = s8_o[18];
      6'd43: s64_o[i] = s8_o[60];
      6'd44: s64_o[i] = s8_o[15];
      6'd45: s64_o[i] = s8_o[22];
      6'd46: s64_o[i] = s8_o[53];
      6'd47: s64_o[i] = s8_o[4];
      6'd48: s64_o[i] = s8_o[1];
      6'd49: s64_o[i] = s8_o[46];
      6'd50: s64_o[i] = s8_o[2];
      6'd51: s64_o[i] = s8_o[62];
      6'd52: s64_o[i] = s8_o[28];
      6'd53: s64_o[i] = s8_o[31];
      6'd54: s64_o[i] = s8_o[23];
      6'd55: s64_o[i] = s8_o[58];
      6'd56: s64_o[i] = s8_o[29];
      6'd57: s64_o[i] = s8_o[33];
      6'd58: s64_o[i] = s8_o[51];
      6'd59: s64_o[i] = s8_o[42];
      6'd60: s64_o[i] = s8_o[24];
      6'd61: s64_o[i] = s8_o[39];
      6'd62: s64_o[i] = s8_o[37];
      6'd63: s64_o[i] = s8_o[59];
      default: s64_o[i] = s8_o[0];
      endcase
    end
  end


reg [5:0] rotA_in;
reg [5:0] shiftA_num, shiftA_num_tmp;
// store code_in value
always@(posedge clk)
  if(~srst_n)
    rotA_in <= 6'd0;
  else
    rotA_in <= code_in;

// rotA MUX
always@*
  case(rotA_in)
    6'd0: rotA_o = rotorA_table[6'd0-shiftA_num];
    6'd1: rotA_o = rotorA_table[6'd1-shiftA_num];
    6'd2: rotA_o = rotorA_table[6'd2-shiftA_num];
    6'd3: rotA_o = rotorA_table[6'd3-shiftA_num];
    6'd4: rotA_o = rotorA_table[6'd4-shiftA_num];
    6'd5: rotA_o = rotorA_table[6'd5-shiftA_num];
    6'd6: rotA_o = rotorA_table[6'd6-shiftA_num];
    6'd7: rotA_o = rotorA_table[6'd7-shiftA_num];
    6'd8: rotA_o = rotorA_table[6'd8-shiftA_num];
    6'd9: rotA_o = rotorA_table[6'd9-shiftA_num];
    6'd10: rotA_o = rotorA_table[6'd10-shiftA_num];
    6'd11: rotA_o = rotorA_table[6'd11-shiftA_num];
    6'd12: rotA_o = rotorA_table[6'd12-shiftA_num];
    6'd13: rotA_o = rotorA_table[6'd13-shiftA_num];
    6'd14: rotA_o = rotorA_table[6'd14-shiftA_num];
    6'd15: rotA_o = rotorA_table[6'd15-shiftA_num];
    6'd16: rotA_o = rotorA_table[6'd16-shiftA_num];
    6'd17: rotA_o = rotorA_table[6'd17-shiftA_num];
    6'd18: rotA_o = rotorA_table[6'd18-shiftA_num];
    6'd19: rotA_o = rotorA_table[6'd19-shiftA_num];
    6'd20: rotA_o = rotorA_table[6'd20-shiftA_num];
    6'd21: rotA_o = rotorA_table[6'd21-shiftA_num];
    6'd22: rotA_o = rotorA_table[6'd22-shiftA_num];
    6'd23: rotA_o = rotorA_table[6'd23-shiftA_num];
    6'd24: rotA_o = rotorA_table[6'd24-shiftA_num];
    6'd25: rotA_o = rotorA_table[6'd25-shiftA_num];
    6'd26: rotA_o = rotorA_table[6'd26-shiftA_num];
    6'd27: rotA_o = rotorA_table[6'd27-shiftA_num];
    6'd28: rotA_o = rotorA_table[6'd28-shiftA_num];
    6'd29: rotA_o = rotorA_table[6'd29-shiftA_num];
    6'd30: rotA_o = rotorA_table[6'd30-shiftA_num];
    6'd31: rotA_o = rotorA_table[6'd31-shiftA_num];
    6'd32: rotA_o = rotorA_table[6'd32-shiftA_num];
    6'd33: rotA_o = rotorA_table[6'd33-shiftA_num];
    6'd34: rotA_o = rotorA_table[6'd34-shiftA_num];
    6'd35: rotA_o = rotorA_table[6'd35-shiftA_num];
    6'd36: rotA_o = rotorA_table[6'd36-shiftA_num];
    6'd37: rotA_o = rotorA_table[6'd37-shiftA_num];
    6'd38: rotA_o = rotorA_table[6'd38-shiftA_num];
    6'd39: rotA_o = rotorA_table[6'd39-shiftA_num];
    6'd40: rotA_o = rotorA_table[6'd40-shiftA_num];
    6'd41: rotA_o = rotorA_table[6'd41-shiftA_num];
    6'd42: rotA_o = rotorA_table[6'd42-shiftA_num];
    6'd43: rotA_o = rotorA_table[6'd43-shiftA_num];
    6'd44: rotA_o = rotorA_table[6'd44-shiftA_num];
    6'd45: rotA_o = rotorA_table[6'd45-shiftA_num];
    6'd46: rotA_o = rotorA_table[6'd46-shiftA_num];
    6'd47: rotA_o = rotorA_table[6'd47-shiftA_num];
    6'd48: rotA_o = rotorA_table[6'd48-shiftA_num];
    6'd49: rotA_o = rotorA_table[6'd49-shiftA_num];
    6'd50: rotA_o = rotorA_table[6'd50-shiftA_num];
    6'd51: rotA_o = rotorA_table[6'd51-shiftA_num];
    6'd52: rotA_o = rotorA_table[6'd52-shiftA_num];
    6'd53: rotA_o = rotorA_table[6'd53-shiftA_num];
    6'd54: rotA_o = rotorA_table[6'd54-shiftA_num];
    6'd55: rotA_o = rotorA_table[6'd55-shiftA_num];
    6'd56: rotA_o = rotorA_table[6'd56-shiftA_num];
    6'd57: rotA_o = rotorA_table[6'd57-shiftA_num];
    6'd58: rotA_o = rotorA_table[6'd58-shiftA_num];
    6'd59: rotA_o = rotorA_table[6'd59-shiftA_num];
    6'd60: rotA_o = rotorA_table[6'd60-shiftA_num];
    6'd61: rotA_o = rotorA_table[6'd61-shiftA_num];
    6'd62: rotA_o = rotorA_table[6'd62-shiftA_num];
    6'd63: rotA_o = rotorA_table[6'd63-shiftA_num];
    default: rotA_o = 6'd0;
  endcase

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

// counter for rot_A shift 
always@*
  if(counting)
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

// rotB MUX
always@*
  case(rotA_o)
    6'd0: rotB_o = rotorB_table[6'd0];
    6'd1: rotB_o = rotorB_table[6'd1];
    6'd2: rotB_o = rotorB_table[6'd2];
    6'd3: rotB_o = rotorB_table[6'd3];
    6'd4: rotB_o = rotorB_table[6'd4];
    6'd5: rotB_o = rotorB_table[6'd5];
    6'd6: rotB_o = rotorB_table[6'd6];
    6'd7: rotB_o = rotorB_table[6'd7];
    6'd8: rotB_o = rotorB_table[6'd8];
    6'd9: rotB_o = rotorB_table[6'd9];
    6'd10: rotB_o = rotorB_table[6'd10];
    6'd11: rotB_o = rotorB_table[6'd11];
    6'd12: rotB_o = rotorB_table[6'd12];
    6'd13: rotB_o = rotorB_table[6'd13];
    6'd14: rotB_o = rotorB_table[6'd14];
    6'd15: rotB_o = rotorB_table[6'd15];
    6'd16: rotB_o = rotorB_table[6'd16];
    6'd17: rotB_o = rotorB_table[6'd17];
    6'd18: rotB_o = rotorB_table[6'd18];
    6'd19: rotB_o = rotorB_table[6'd19];
    6'd20: rotB_o = rotorB_table[6'd20];
    6'd21: rotB_o = rotorB_table[6'd21];
    6'd22: rotB_o = rotorB_table[6'd22];
    6'd23: rotB_o = rotorB_table[6'd23];
    6'd24: rotB_o = rotorB_table[6'd24];
    6'd25: rotB_o = rotorB_table[6'd25];
    6'd26: rotB_o = rotorB_table[6'd26];
    6'd27: rotB_o = rotorB_table[6'd27];
    6'd28: rotB_o = rotorB_table[6'd28];
    6'd29: rotB_o = rotorB_table[6'd29];
    6'd30: rotB_o = rotorB_table[6'd30];
    6'd31: rotB_o = rotorB_table[6'd31];
    6'd32: rotB_o = rotorB_table[6'd32];
    6'd33: rotB_o = rotorB_table[6'd33];
    6'd34: rotB_o = rotorB_table[6'd34];
    6'd35: rotB_o = rotorB_table[6'd35];
    6'd36: rotB_o = rotorB_table[6'd36];
    6'd37: rotB_o = rotorB_table[6'd37];
    6'd38: rotB_o = rotorB_table[6'd38];
    6'd39: rotB_o = rotorB_table[6'd39];
    6'd40: rotB_o = rotorB_table[6'd40];
    6'd41: rotB_o = rotorB_table[6'd41];
    6'd42: rotB_o = rotorB_table[6'd42];
    6'd43: rotB_o = rotorB_table[6'd43];
    6'd44: rotB_o = rotorB_table[6'd44];
    6'd45: rotB_o = rotorB_table[6'd45];
    6'd46: rotB_o = rotorB_table[6'd46];
    6'd47: rotB_o = rotorB_table[6'd47];
    6'd48: rotB_o = rotorB_table[6'd48];
    6'd49: rotB_o = rotorB_table[6'd49];
    6'd50: rotB_o = rotorB_table[6'd50];
    6'd51: rotB_o = rotorB_table[6'd51];
    6'd52: rotB_o = rotorB_table[6'd52];
    6'd53: rotB_o = rotorB_table[6'd53];
    6'd54: rotB_o = rotorB_table[6'd54];
    6'd55: rotB_o = rotorB_table[6'd55];
    6'd56: rotB_o = rotorB_table[6'd56];
    6'd57: rotB_o = rotorB_table[6'd57];
    6'd58: rotB_o = rotorB_table[6'd58];
    6'd59: rotB_o = rotorB_table[6'd59];
    6'd60: rotB_o = rotorB_table[6'd60];
    6'd61: rotB_o = rotorB_table[6'd61];
    6'd62: rotB_o = rotorB_table[6'd62];
    6'd63: rotB_o = rotorB_table[6'd63];
    default: rotB_o = 6'd0;
  endcase

// mode control

always@*
  if(counting && ~crypt_mode)
    rotB_mode = rotB_o[2:0];
  else if (counting && crypt_mode)
    rotB_mode = ref_o[2:0];
  else
    rotB_mode = 3'd0;

// ref 
always@*
  ref_o = 6'd63 - rotB_o;

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
  

reg [5:0] code_out_t;
// i_rotA MUX
always@*
  case(i_rotB_o)
    rotorA_table[0]: code_out_t = 6'd0+shiftA_num;
    rotorA_table[1]: code_out_t = 6'd1+shiftA_num;
    rotorA_table[2]: code_out_t = 6'd2+shiftA_num;
    rotorA_table[3]: code_out_t = 6'd3+shiftA_num;
    rotorA_table[4]: code_out_t = 6'd4+shiftA_num;
    rotorA_table[5]: code_out_t = 6'd5+shiftA_num;
    rotorA_table[6]: code_out_t = 6'd6+shiftA_num;
    rotorA_table[7]: code_out_t = 6'd7+shiftA_num;
    rotorA_table[8]: code_out_t = 6'd8+shiftA_num;
    rotorA_table[9]: code_out_t = 6'd9+shiftA_num;
    rotorA_table[10]: code_out_t = 6'd10+shiftA_num;
    rotorA_table[11]: code_out_t = 6'd11+shiftA_num;
    rotorA_table[12]: code_out_t = 6'd12+shiftA_num;
    rotorA_table[13]: code_out_t = 6'd13+shiftA_num;
    rotorA_table[14]: code_out_t = 6'd14+shiftA_num;
    rotorA_table[15]: code_out_t = 6'd15+shiftA_num;
    rotorA_table[16]: code_out_t = 6'd16+shiftA_num;
    rotorA_table[17]: code_out_t = 6'd17+shiftA_num;
    rotorA_table[18]: code_out_t = 6'd18+shiftA_num;
    rotorA_table[19]: code_out_t = 6'd19+shiftA_num;
    rotorA_table[20]: code_out_t = 6'd20+shiftA_num;
    rotorA_table[21]: code_out_t = 6'd21+shiftA_num;
    rotorA_table[22]: code_out_t = 6'd22+shiftA_num;
    rotorA_table[23]: code_out_t = 6'd23+shiftA_num;
    rotorA_table[24]: code_out_t = 6'd24+shiftA_num;
    rotorA_table[25]: code_out_t = 6'd25+shiftA_num;
    rotorA_table[26]: code_out_t = 6'd26+shiftA_num;
    rotorA_table[27]: code_out_t = 6'd27+shiftA_num;
    rotorA_table[28]: code_out_t = 6'd28+shiftA_num;
    rotorA_table[29]: code_out_t = 6'd29+shiftA_num;
    rotorA_table[30]: code_out_t = 6'd30+shiftA_num;
    rotorA_table[31]: code_out_t = 6'd31+shiftA_num;
    rotorA_table[32]: code_out_t = 6'd32+shiftA_num;
    rotorA_table[33]: code_out_t = 6'd33+shiftA_num;
    rotorA_table[34]: code_out_t = 6'd34+shiftA_num;
    rotorA_table[35]: code_out_t = 6'd35+shiftA_num;
    rotorA_table[36]: code_out_t = 6'd36+shiftA_num;
    rotorA_table[37]: code_out_t = 6'd37+shiftA_num;
    rotorA_table[38]: code_out_t = 6'd38+shiftA_num;
    rotorA_table[39]: code_out_t = 6'd39+shiftA_num;
    rotorA_table[40]: code_out_t = 6'd40+shiftA_num;
    rotorA_table[41]: code_out_t = 6'd41+shiftA_num;
    rotorA_table[42]: code_out_t = 6'd42+shiftA_num;
    rotorA_table[43]: code_out_t = 6'd43+shiftA_num;
    rotorA_table[44]: code_out_t = 6'd44+shiftA_num;
    rotorA_table[45]: code_out_t = 6'd45+shiftA_num;
    rotorA_table[46]: code_out_t = 6'd46+shiftA_num;
    rotorA_table[47]: code_out_t = 6'd47+shiftA_num;
    rotorA_table[48]: code_out_t = 6'd48+shiftA_num;
    rotorA_table[49]: code_out_t = 6'd49+shiftA_num;
    rotorA_table[50]: code_out_t = 6'd50+shiftA_num;
    rotorA_table[51]: code_out_t = 6'd51+shiftA_num;
    rotorA_table[52]: code_out_t = 6'd52+shiftA_num;
    rotorA_table[53]: code_out_t = 6'd53+shiftA_num;
    rotorA_table[54]: code_out_t = 6'd54+shiftA_num;
    rotorA_table[55]: code_out_t = 6'd55+shiftA_num;
    rotorA_table[56]: code_out_t = 6'd56+shiftA_num;
    rotorA_table[57]: code_out_t = 6'd57+shiftA_num;
    rotorA_table[58]: code_out_t = 6'd58+shiftA_num;
    rotorA_table[59]: code_out_t = 6'd59+shiftA_num;
    rotorA_table[60]: code_out_t = 6'd60+shiftA_num;
    rotorA_table[61]: code_out_t = 6'd61+shiftA_num;
    rotorA_table[62]: code_out_t = 6'd62+shiftA_num;
    rotorA_table[63]: code_out_t = 6'd63+shiftA_num;
    default: code_out_t = 6'd0;
  endcase

always@*
  if(code_valid)
    code_out = code_out_t;
  else
    code_out = 6'd0;
// valid control
always@*
  if(state == READY)
    code_valid_tmp = 1'b1;
  else
    code_valid_tmp = 1'b0;

// output FF
always@(posedge clk)
  if(~srst_n)
      code_valid <= 1'b0;
  else
      code_valid <= code_valid_tmp;

endmodule
