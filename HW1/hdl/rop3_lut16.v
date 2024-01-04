/*
* Module      : rop3_lut16
* Description : Implement this module using the look-up table (LUT).
*               This module should support all the 15-modes listed in table-1.
*               For modes not in the table-1, set the Result to 0.
* Notes       : Please remember to make the bit-length of {Bitmap, Result} parameterizable.
*/

module rop3_lut16
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
    8'h00: ROP3_output = 0;
    8'h11: ROP3_output = ~(D|S);
    8'h33: ROP3_output = ~S;
    8'h44: ROP3_output = S&~D;
    8'h55: ROP3_output = ~D;
    8'h5A: ROP3_output = D^P;
    8'h66: ROP3_output = D^S;
    8'h88: ROP3_output = D&S;
    8'hBB: ROP3_output = D|~S;
    8'hC0: ROP3_output = P&S;
    8'hCC: ROP3_output = S;
    8'hEE: ROP3_output = D|S;
    8'hF0: ROP3_output = P;
    8'hFB: ROP3_output = D|P|~S;
    8'hFF: ROP3_output = D|~D;
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
