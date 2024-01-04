module FSM(clk, srst_n, load, state, n_state);
input clk;
input srst_n;
input load;
output reg [1:0] state;
output reg [1:0] n_state;

parameter IDLE = 2'b00, LOAD = 2'b01, READY = 2'b10;
always@*
  case(state)
    IDLE: n_state = LOAD;
    LOAD: 
      if(load)
        n_state = LOAD;
      else
        n_state = READY;
    READY: n_state = READY;
    default: n_state = IDLE;
  endcase

always@(posedge clk)
  if(~srst_n)
    state <= IDLE;
  else
    state <= n_state;

endmodule
