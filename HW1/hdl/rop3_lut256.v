/*
* Module      : rop3_lut256
* Description : Implement this module using the look-up table (LUT).
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to make the bit-length of {Bitmap, Result} parameterizable.
*/

module rop3_lut256
#(
  parameter N = 8
)
(
  input clk,
  input srst_n,
  input [N-1:0] Bitmap,
  input [7:0] Mode,
  output reg [N-1:0] Result,
  output reg valid
);

localparam IDLE = 2'd0, LOAD_P = 2'd1, LOAD_S = 2'd2, LOAD_D = 2'd3;

// fsm
wire [1:0] state;
wire valid_ctl;
// reg def
reg [N-1:0] P, S, D;
reg [7:0] M;
// DFF input, ROP output
reg [N-1:0] P_in, S_in, D_in, ROP3_output;

fsm fsm_U0(
	.clk(clk),
	.srst_n(srst_n),
	.state(state),
	.valid_ctl(valid_ctl)
);

// P S D MUX
always@*
begin
  case(state) 
    2'b01:
    begin 
      P_in = Bitmap;
      S_in = S;
      D_in = D;
    end
    2'b10:
    begin 
      P_in = P;
      S_in = Bitmap;
      D_in = D;
    end
    2'b11:
    begin 
      P_in = P;
      S_in = S;
      D_in = Bitmap;
    end
    default: 
    begin 
      P_in = P;
      S_in = S;
      D_in = D;
    end
  endcase
end

// ROP3
always@*
begin
  case(M) 
    8'b0000_0000: ROP3_output = 0;
    8'b0000_0001: ROP3_output = (~P&~S&~D);
    8'b0000_0010: ROP3_output = (~P&~S&D);
    8'b0000_0011: ROP3_output = (~P&~S&D)|(~P&~S&~D);
    8'b0000_0100: ROP3_output = (~P&S&~D);
    8'b0000_0101: ROP3_output = (~P&~S&~D)|(~P&S&~D);
    8'b0000_0110: ROP3_output = (~P&~S&D)|(~P&S&~D);
    8'b0000_0111: ROP3_output = (~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0000_1000: ROP3_output = (~P&S&D);
    8'b0000_1001: ROP3_output = (~P&~S&~D)|(~P&S&D);
    8'b0000_1010: ROP3_output = (~P&~S&D)|(~P&S&D);
    8'b0000_1011: ROP3_output = (~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0000_1100: ROP3_output = (~P&S&D)|(~P&S&~D);
    8'b0000_1101: ROP3_output = (~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0000_1110: ROP3_output = (~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0000_1111: ROP3_output = (~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);    

    8'b0001_0000: ROP3_output = (P&~S&~D);
    8'b0001_0001: ROP3_output = (P&~S&~D)|(~P&~S&~D);
    8'b0001_0010: ROP3_output = (P&~S&~D)|(~P&~S&D);
    8'b0001_0011: ROP3_output = (P&~S&~D)|(~P&~S&~D)|(~P&~S&D);
    8'b0001_0100: ROP3_output = (P&~S&~D)|(~P&S&~D);
    8'b0001_0101: ROP3_output = (P&~S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b0001_0110: ROP3_output = (P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b0001_0111: ROP3_output = (P&~S&~D)|(~P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b0001_1000: ROP3_output = (P&~S&~D)|(~P&S&D);
    8'b0001_1001: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&~S&~D);
    8'b0001_1010: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&~S&D);
    8'b0001_1011: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b0001_1100: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&S&~D);
    8'b0001_1101: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0001_1110: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0001_1111: ROP3_output = (P&~S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    8'b0010_0000: ROP3_output = (P&~S&D);
    8'b0010_0001: ROP3_output = (P&~S&D)|(~P&~S&~D);
    8'b0010_0010: ROP3_output = (P&~S&D)|(~P&~S&D);
    8'b0010_0011: ROP3_output = (P&~S&D)|(~P&~S&~D)|(~P&~S&D);
    8'b0010_0100: ROP3_output = (P&~S&D)|(~P&S&~D);
    8'b0010_0101: ROP3_output = (P&~S&D)|(~P&~S&~D)|(~P&S&~D);
    8'b0010_0110: ROP3_output = (P&~S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0010_0111: ROP3_output = (P&~S&D)|(~P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b0010_1000: ROP3_output = (P&~S&D)|(~P&S&D);
    8'b0010_1001: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&~S&~D);
    8'b0010_1010: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&~S&D);
    8'b0010_1011: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b0010_1100: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&S&~D);
    8'b0010_1101: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0010_1110: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0010_1111: ROP3_output = (P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    8'b0011_0000: ROP3_output = (P&~S&~D)|(P&~S&D);
    8'b0011_0001: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&~S&~D);
    8'b0011_0010: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&~S&D);
    8'b0011_0011: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&~S&~D)|(~P&~S&D);
    8'b0011_0100: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&~D);
    8'b0011_0101: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&~S&~D)|(~P&S&~D);
    8'b0011_0110: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0011_0111: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b0011_1000: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D);
    8'b0011_1001: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&~S&~D);
    8'b0011_1010: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&~S&D);
    8'b0011_1011: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b0011_1100: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D);
    8'b0011_1101: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0011_1110: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0011_1111: ROP3_output = (P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);

    8'b0100_0000: ROP3_output = (P&S&~D); 
    8'b0100_0001: ROP3_output = (P&S&~D)|(~P&~S&~D);
    8'b0100_0010: ROP3_output = (P&S&~D)|(~P&~S&D);
    8'b0100_0011: ROP3_output = (P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b0100_0100: ROP3_output = (P&S&~D)|(~P&S&~D);
    8'b0100_0101: ROP3_output = (P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b0100_0110: ROP3_output = (P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0100_0111: ROP3_output = (P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0100_1000: ROP3_output = (P&S&~D)|(~P&S&D);
    8'b0100_1001: ROP3_output = (P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b0100_1010: ROP3_output = (P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0100_1011: ROP3_output = (P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0100_1100: ROP3_output = (P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b0100_1101: ROP3_output = (P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0100_1110: ROP3_output = (P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0100_1111: ROP3_output = (P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
   
    8'b0101_0000: ROP3_output = (P&~S&~D)|(P&S&~D); 
    8'b0101_0001: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&~D);
    8'b0101_0010: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&D);
    8'b0101_0011: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b0101_0100: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&S&~D);
    8'b0101_0101: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b0101_0110: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0101_0111: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0101_1000: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&S&D);
    8'b0101_1001: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b0101_1010: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0101_1011: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0101_1100: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b0101_1101: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0101_1110: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0101_1111: ROP3_output = (P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);

    8'b0110_0000: ROP3_output = (P&~S&D)|(P&S&~D); 
    8'b0110_0001: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&~D);
    8'b0110_0010: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&D);
    8'b0110_0011: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b0110_0100: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&S&~D);
    8'b0110_0101: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b0110_0110: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0110_0111: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0110_1000: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&S&D);
    8'b0110_1001: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b0110_1010: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0110_1011: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0110_1100: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b0110_1101: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0110_1110: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0110_1111: ROP3_output = (P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    8'b0111_0000: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D); 
    8'b0111_0001: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D);
    8'b0111_0010: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D);
    8'b0111_0011: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b0111_0100: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&~D);
    8'b0111_0101: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b0111_0110: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0111_0111: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b0111_1000: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D);
    8'b0111_1001: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b0111_1010: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0111_1011: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b0111_1100: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b0111_1101: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b0111_1110: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b0111_1111: ROP3_output = (P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    



    8'b1000_0000: ROP3_output = (P&S&D);
    8'b1000_0001: ROP3_output = (P&S&D)|(~P&~S&~D);
    8'b1000_0010: ROP3_output = (P&S&D)|(~P&~S&D);
    8'b1000_0011: ROP3_output = (P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b1000_0100: ROP3_output = (P&S&D)|(~P&S&~D);
    8'b1000_0101: ROP3_output = (P&S&D)|(~P&~S&~D)|(~P&S&~D);
    8'b1000_0110: ROP3_output = (P&S&D)|(~P&~S&D)|(~P&S&~D);
    8'b1000_0111: ROP3_output = (P&S&D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1000_1000: ROP3_output = (P&S&D)|(~P&S&D);
    8'b1000_1001: ROP3_output = (P&S&D)|(~P&~S&~D)|(~P&S&D);
    8'b1000_1010: ROP3_output = (P&S&D)|(~P&~S&D)|(~P&S&D);
    8'b1000_1011: ROP3_output = (P&S&D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1000_1100: ROP3_output = (P&S&D)|(~P&S&D)|(~P&S&~D);
    8'b1000_1101: ROP3_output = (P&S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1000_1110: ROP3_output = (P&S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1000_1111: ROP3_output = (P&S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);    

    8'b1001_0000: ROP3_output = (P&S&D)|(P&~S&~D);
    8'b1001_0001: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&~S&~D);
    8'b1001_0010: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&~S&D);
    8'b1001_0011: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&~S&~D)|(~P&~S&D);
    8'b1001_0100: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&~D);
    8'b1001_0101: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b1001_0110: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b1001_0111: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b1001_1000: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D);
    8'b1001_1001: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&~S&~D);
    8'b1001_1010: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&~S&D);
    8'b1001_1011: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b1001_1100: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&S&~D);
    8'b1001_1101: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1001_1110: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1001_1111: ROP3_output = (P&S&D)|(P&~S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    8'b1010_0000: ROP3_output = (P&S&D)|(P&~S&D);
    8'b1010_0001: ROP3_output = (P&S&D)|(P&~S&D)|(~P&~S&~D);
    8'b1010_0010: ROP3_output = (P&S&D)|(P&~S&D)|(~P&~S&D);
    8'b1010_0011: ROP3_output = (P&S&D)|(P&~S&D)|(~P&~S&~D)|(~P&~S&D);
    8'b1010_0100: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&~D);
    8'b1010_0101: ROP3_output = (P&S&D)|(P&~S&D)|(~P&~S&~D)|(~P&S&~D);
    8'b1010_0110: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1010_0111: ROP3_output = (P&S&D)|(P&~S&D)|(~P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b1010_1000: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D);
    8'b1010_1001: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&~S&~D);
    8'b1010_1010: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&~S&D);
    8'b1010_1011: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b1010_1100: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&S&~D);
    8'b1010_1101: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1010_1110: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1010_1111: ROP3_output = (P&S&D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    8'b1011_0000: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D);
    8'b1011_0001: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&~S&~D);
    8'b1011_0010: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&~S&D);
    8'b1011_0011: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&~S&~D)|(~P&~S&D);
    8'b1011_0100: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&~D);
    8'b1011_0101: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&~S&~D)|(~P&S&~D);
    8'b1011_0110: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1011_0111: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&~S&~D)|(~P&S&~D)|(~P&~S&D);
    8'b1011_1000: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D);
    8'b1011_1001: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&~S&~D);
    8'b1011_1010: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&~S&D);
    8'b1011_1011: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&~S&D)|(~P&~S&~D);
    8'b1011_1100: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D);
    8'b1011_1101: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1011_1110: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1011_1111: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);

    8'b1100_0000: ROP3_output = (P&S&D)|(P&S&~D); 
    8'b1100_0001: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&~D);
    8'b1100_0010: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&D);
    8'b1100_0011: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b1100_0100: ROP3_output = (P&S&D)|(P&S&~D)|(~P&S&~D);
    8'b1100_0101: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b1100_0110: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1100_0111: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1100_1000: ROP3_output = (P&S&D)|(P&S&~D)|(~P&S&D);
    8'b1100_1001: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b1100_1010: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1100_1011: ROP3_output = (P&S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1100_1100: ROP3_output = (P&S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b1100_1101: ROP3_output = (P&S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1100_1110: ROP3_output = (P&S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1100_1111: ROP3_output = (P&S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
   
    8'b1101_0000: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D); 
    8'b1101_0001: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&~D);
    8'b1101_0010: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&D);
    8'b1101_0011: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b1101_0100: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&S&~D);
    8'b1101_0101: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b1101_0110: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1101_0111: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1101_1000: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&S&D);
    8'b1101_1001: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b1101_1010: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1101_1011: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1101_1100: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b1101_1101: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1101_1110: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1101_1111: ROP3_output = (P&S&D)|(P&~S&~D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);

    8'b1110_0000: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D); 
    8'b1110_0001: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D);
    8'b1110_0010: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&D);
    8'b1110_0011: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b1110_0100: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&S&~D);
    8'b1110_0101: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b1110_0110: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1110_0111: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1110_1000: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&S&D);
    8'b1110_1001: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b1110_1010: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1110_1011: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1110_1100: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b1110_1101: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1110_1110: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1110_1111: ROP3_output = (P&S&D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    8'b1111_0000: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D); 
    8'b1111_0001: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D);
    8'b1111_0010: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D);
    8'b1111_0011: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    8'b1111_0100: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&~D);
    8'b1111_0101: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&~D);
    8'b1111_0110: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1111_0111: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&~D);
    8'b1111_1000: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D);
    8'b1111_1001: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&S&D);
    8'b1111_1010: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1111_1011: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&~S&~D)|(~P&~S&D)|(~P&S&D);
    8'b1111_1100: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D);
    8'b1111_1101: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&~D);
    8'b1111_1110: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D);
    8'b1111_1111: ROP3_output = (P&S&D)|(P&~S&~D)|(P&~S&D)|(P&S&~D)|(~P&S&D)|(~P&S&~D)|(~P&~S&D)|(~P&~S&~D);
    
    default: ROP3_output = 0;
  endcase
end

//D-Flip flops
always@(posedge clk)
begin
  P <= P_in;
  S <= S_in;
  D <= D_in;
  M <= Mode;
  Result <= ROP3_output;
  valid <= valid_ctl;
end


endmodule
