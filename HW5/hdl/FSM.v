module FSM(
    input clk,
    input srst_n,             
    input enable,     
    input conv1_dw_complete,
    input conv1_pw_complete,    
    input conv2_dw_complete,
    input conv2_pw_complete,
    input conv3_complete,                
    output reg [2:0] state
         
);

parameter IDLE = 3'd0, CONV1_DW = 3'd1, CONV1_PW = 3'd2, CONV2_DW = 3'd3, CONV2_PW = 3'd4, CONV3 = 3'd5, FINISH = 3'd6;
reg [2:0] n_state;

always@*
  case(state)
    IDLE: n_state = (enable)? CONV1_DW : IDLE; 
    CONV1_DW: n_state = (conv1_dw_complete)? CONV1_PW : CONV1_DW; 
    CONV1_PW: n_state = (conv1_pw_complete)? CONV2_DW : CONV1_PW;
    CONV2_DW: n_state = (conv2_dw_complete)? CONV2_PW : CONV2_DW; 
    CONV2_PW: n_state = (conv2_pw_complete)? CONV3 : CONV2_PW;
    CONV3: n_state = (conv3_complete)? FINISH : CONV3;
    FINISH: n_state = FINISH;
    default: n_state = state;
  endcase

always@(posedge clk)
  if(~srst_n)
    state <= 0;
  else
    state <= n_state;



endmodule
