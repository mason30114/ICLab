//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
 
module enigma_part1(clk, srst_n, load, code_in, code_out, code_valid, encrypt, crypt_mode, table_idx);

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
							// Note: We only use rotorA in part1.
							
output reg [6-1:0] code_out;   // encrypted code word (register output)
output reg code_valid;         // 0: non-valid code_out; 1: valid code_out (register output)

parameter IDLE = 2'b00, LOAD = 2'b01, READY = 2'b10;

// internal parameter
reg [6-1:0] rotA_o;
reg [6-1:0] ref_o;
reg [2-1:0] rotA_mode;
//reg [6-1:0] code_out_tmp;
reg code_valid_tmp;

// FSM
wire [1:0] n_state, state;
FSM FSM(.clk(clk), .srst_n(srst_n), .load(load), .state(state), .n_state(n_state));

// table handling
reg [6-1:0] rotorA_table[0:64-1];


integer i;
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


// table output FF
always@(posedge clk)
  if(~srst_n) 
    for(i = 0; i < 64; i = i+1) begin
      rotorA_table[i] <= 6'd0;
    end
  else 
    for(i = 0; i < 64; i = i+1) begin
      if((cnt == i) && (n_state == LOAD)&&(table_idx == 2'd1)) begin
        rotorA_table[i] <= code_in;
      end
      else begin
        rotorA_table[i] <= rotorA_table[i];
      end
    end

reg [5:0] shift_num, shift_num_tmp, rotA_in;

// store code_in value
always@(posedge clk)
  if(~srst_n)
    rotA_in <= 6'd0;
  else
    rotA_in <= code_in;

// rotA MUX
always@*
  case(rotA_in)
    6'd0: rotA_o = rotorA_table[6'd0-shift_num];
    6'd1: rotA_o = rotorA_table[6'd1-shift_num];
    6'd2: rotA_o = rotorA_table[6'd2-shift_num];
    6'd3: rotA_o = rotorA_table[6'd3-shift_num];
    6'd4: rotA_o = rotorA_table[6'd4-shift_num];
    6'd5: rotA_o = rotorA_table[6'd5-shift_num];
    6'd6: rotA_o = rotorA_table[6'd6-shift_num];
    6'd7: rotA_o = rotorA_table[6'd7-shift_num];
    6'd8: rotA_o = rotorA_table[6'd8-shift_num];
    6'd9: rotA_o = rotorA_table[6'd9-shift_num];
    6'd10: rotA_o = rotorA_table[6'd10-shift_num];
    6'd11: rotA_o = rotorA_table[6'd11-shift_num];
    6'd12: rotA_o = rotorA_table[6'd12-shift_num];
    6'd13: rotA_o = rotorA_table[6'd13-shift_num];
    6'd14: rotA_o = rotorA_table[6'd14-shift_num];
    6'd15: rotA_o = rotorA_table[6'd15-shift_num];
    6'd16: rotA_o = rotorA_table[6'd16-shift_num];
    6'd17: rotA_o = rotorA_table[6'd17-shift_num];
    6'd18: rotA_o = rotorA_table[6'd18-shift_num];
    6'd19: rotA_o = rotorA_table[6'd19-shift_num];
    6'd20: rotA_o = rotorA_table[6'd20-shift_num];
    6'd21: rotA_o = rotorA_table[6'd21-shift_num];
    6'd22: rotA_o = rotorA_table[6'd22-shift_num];
    6'd23: rotA_o = rotorA_table[6'd23-shift_num];
    6'd24: rotA_o = rotorA_table[6'd24-shift_num];
    6'd25: rotA_o = rotorA_table[6'd25-shift_num];
    6'd26: rotA_o = rotorA_table[6'd26-shift_num];
    6'd27: rotA_o = rotorA_table[6'd27-shift_num];
    6'd28: rotA_o = rotorA_table[6'd28-shift_num];
    6'd29: rotA_o = rotorA_table[6'd29-shift_num];
    6'd30: rotA_o = rotorA_table[6'd30-shift_num];
    6'd31: rotA_o = rotorA_table[6'd31-shift_num];
    6'd32: rotA_o = rotorA_table[6'd32-shift_num];
    6'd33: rotA_o = rotorA_table[6'd33-shift_num];
    6'd34: rotA_o = rotorA_table[6'd34-shift_num];
    6'd35: rotA_o = rotorA_table[6'd35-shift_num];
    6'd36: rotA_o = rotorA_table[6'd36-shift_num];
    6'd37: rotA_o = rotorA_table[6'd37-shift_num];
    6'd38: rotA_o = rotorA_table[6'd38-shift_num];
    6'd39: rotA_o = rotorA_table[6'd39-shift_num];
    6'd40: rotA_o = rotorA_table[6'd40-shift_num];
    6'd41: rotA_o = rotorA_table[6'd41-shift_num];
    6'd42: rotA_o = rotorA_table[6'd42-shift_num];
    6'd43: rotA_o = rotorA_table[6'd43-shift_num];
    6'd44: rotA_o = rotorA_table[6'd44-shift_num];
    6'd45: rotA_o = rotorA_table[6'd45-shift_num];
    6'd46: rotA_o = rotorA_table[6'd46-shift_num];
    6'd47: rotA_o = rotorA_table[6'd47-shift_num];
    6'd48: rotA_o = rotorA_table[6'd48-shift_num];
    6'd49: rotA_o = rotorA_table[6'd49-shift_num];
    6'd50: rotA_o = rotorA_table[6'd50-shift_num];
    6'd51: rotA_o = rotorA_table[6'd51-shift_num];
    6'd52: rotA_o = rotorA_table[6'd52-shift_num];
    6'd53: rotA_o = rotorA_table[6'd53-shift_num];
    6'd54: rotA_o = rotorA_table[6'd54-shift_num];
    6'd55: rotA_o = rotorA_table[6'd55-shift_num];
    6'd56: rotA_o = rotorA_table[6'd56-shift_num];
    6'd57: rotA_o = rotorA_table[6'd57-shift_num];
    6'd58: rotA_o = rotorA_table[6'd58-shift_num];
    6'd59: rotA_o = rotorA_table[6'd59-shift_num];
    6'd60: rotA_o = rotorA_table[6'd60-shift_num];
    6'd61: rotA_o = rotorA_table[6'd61-shift_num];
    6'd62: rotA_o = rotorA_table[6'd62-shift_num];
    6'd63: rotA_o = rotorA_table[6'd63-shift_num];
    default: rotA_o = 6'd0;
  endcase

// delay 1 cycle(for shift usage)
reg counting, counting_tmp;
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

// counter for table shift 
always@*
  if(counting)
    case(rotA_mode)
      2'b00:
        shift_num_tmp = shift_num;
      2'b01:
        shift_num_tmp = shift_num + 2'd1;
      2'b10:
        shift_num_tmp = shift_num + 2'd2;
      2'b11:
        shift_num_tmp = shift_num + 2'd3;
      default:
        shift_num_tmp = shift_num;
    endcase
  else
    shift_num_tmp = shift_num;
    

always@(posedge clk)
  if(~srst_n)
    shift_num <= 6'd0;
  else
    shift_num <= shift_num_tmp; 

// ref 
always@*
  ref_o = 6'd63 - rotA_o;

// mode control
always@*
  if((~crypt_mode))
    rotA_mode = rotA_o[1:0];
  else
    rotA_mode = ref_o[1:0];

reg [5:0] code_out_t;
// i_rotA MUX
always@*
  case(ref_o)
    rotorA_table[0]: code_out_t = 6'd0+shift_num;
    rotorA_table[1]: code_out_t = 6'd1+shift_num;
    rotorA_table[2]: code_out_t = 6'd2+shift_num;
    rotorA_table[3]: code_out_t = 6'd3+shift_num;
    rotorA_table[4]: code_out_t = 6'd4+shift_num;
    rotorA_table[5]: code_out_t = 6'd5+shift_num;
    rotorA_table[6]: code_out_t = 6'd6+shift_num;
    rotorA_table[7]: code_out_t = 6'd7+shift_num;
    rotorA_table[8]: code_out_t = 6'd8+shift_num;
    rotorA_table[9]: code_out_t = 6'd9+shift_num;
    rotorA_table[10]: code_out_t = 6'd10+shift_num;
    rotorA_table[11]: code_out_t = 6'd11+shift_num;
    rotorA_table[12]: code_out_t = 6'd12+shift_num;
    rotorA_table[13]: code_out_t = 6'd13+shift_num;
    rotorA_table[14]: code_out_t = 6'd14+shift_num;
    rotorA_table[15]: code_out_t = 6'd15+shift_num;
    rotorA_table[16]: code_out_t = 6'd16+shift_num;
    rotorA_table[17]: code_out_t = 6'd17+shift_num;
    rotorA_table[18]: code_out_t = 6'd18+shift_num;
    rotorA_table[19]: code_out_t = 6'd19+shift_num;
    rotorA_table[20]: code_out_t = 6'd20+shift_num;
    rotorA_table[21]: code_out_t = 6'd21+shift_num;
    rotorA_table[22]: code_out_t = 6'd22+shift_num;
    rotorA_table[23]: code_out_t = 6'd23+shift_num;
    rotorA_table[24]: code_out_t = 6'd24+shift_num;
    rotorA_table[25]: code_out_t = 6'd25+shift_num;
    rotorA_table[26]: code_out_t = 6'd26+shift_num;
    rotorA_table[27]: code_out_t = 6'd27+shift_num;
    rotorA_table[28]: code_out_t = 6'd28+shift_num;
    rotorA_table[29]: code_out_t = 6'd29+shift_num;
    rotorA_table[30]: code_out_t = 6'd30+shift_num;
    rotorA_table[31]: code_out_t = 6'd31+shift_num;
    rotorA_table[32]: code_out_t = 6'd32+shift_num;
    rotorA_table[33]: code_out_t = 6'd33+shift_num;
    rotorA_table[34]: code_out_t = 6'd34+shift_num;
    rotorA_table[35]: code_out_t = 6'd35+shift_num;
    rotorA_table[36]: code_out_t = 6'd36+shift_num;
    rotorA_table[37]: code_out_t = 6'd37+shift_num;
    rotorA_table[38]: code_out_t = 6'd38+shift_num;
    rotorA_table[39]: code_out_t = 6'd39+shift_num;
    rotorA_table[40]: code_out_t = 6'd40+shift_num;
    rotorA_table[41]: code_out_t = 6'd41+shift_num;
    rotorA_table[42]: code_out_t = 6'd42+shift_num;
    rotorA_table[43]: code_out_t = 6'd43+shift_num;
    rotorA_table[44]: code_out_t = 6'd44+shift_num;
    rotorA_table[45]: code_out_t = 6'd45+shift_num;
    rotorA_table[46]: code_out_t = 6'd46+shift_num;
    rotorA_table[47]: code_out_t = 6'd47+shift_num;
    rotorA_table[48]: code_out_t = 6'd48+shift_num;
    rotorA_table[49]: code_out_t = 6'd49+shift_num;
    rotorA_table[50]: code_out_t = 6'd50+shift_num;
    rotorA_table[51]: code_out_t = 6'd51+shift_num;
    rotorA_table[52]: code_out_t = 6'd52+shift_num;
    rotorA_table[53]: code_out_t = 6'd53+shift_num;
    rotorA_table[54]: code_out_t = 6'd54+shift_num;
    rotorA_table[55]: code_out_t = 6'd55+shift_num;
    rotorA_table[56]: code_out_t = 6'd56+shift_num;
    rotorA_table[57]: code_out_t = 6'd57+shift_num;
    rotorA_table[58]: code_out_t = 6'd58+shift_num;
    rotorA_table[59]: code_out_t = 6'd59+shift_num;
    rotorA_table[60]: code_out_t = 6'd60+shift_num;
    rotorA_table[61]: code_out_t = 6'd61+shift_num;
    rotorA_table[62]: code_out_t = 6'd62+shift_num;
    rotorA_table[63]: code_out_t = 6'd63+shift_num;
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
