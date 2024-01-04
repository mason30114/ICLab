/*
* Module      : rop3_smart
* Description : Implement this module using the formulation mentioned in the assignment handout.
*               This module should support all the possible modes of ROP3.
* Notes       : Please remember to make the bit-length of {Bitmap, Result} parameterizable.
*/

module rop3_smart
#(
    parameter N = 32
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

//temp def
reg [7:0] temp1 [N-1:0];
reg [7:0] temp2 [N-1:0];
// reg def
reg [N-1:0] P, S, D;
reg [7:0] M;
// DFF input, ROP output
reg [N-1:0] P_in, S_in, D_in, ROP3_output;
// counter for loop
integer i;
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

// ROP3 smart function
always@*
begin
  for (i = 0; i < N; i = i+1)
  begin
    temp1[i] = 8'h1 << {P[i], S[i], D[i]};
    temp2[i] = temp1[i] & M;
    ROP3_output[i] = |temp2[i];
  end
end

//D-Flip flops
always@(posedge clk)
  if(~srst_n)
  begin
    P <= 0;
    S <= 0;
    D <= 0;
    M <= 0;
    Result <= 0;
    valid <= 0;
  end
  else
  begin
    P <= P_in;
    S <= S_in;
    D <= D_in;
    M <= Mode;
    Result <= ROP3_output;
    valid <= valid_ctl;
  end

endmodule
