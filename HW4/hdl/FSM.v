module FSM(
    input clk,
    input srst_n,             
    input start,     
    input rotate_complete,
    input scan_complete,                    
    input demask_complete,
    input decode_complete,   
    input loc_wrong,   
    input loc_complete,
    input pre_scan_complete,
    input end_of_file,
    input num_complete,
    output reg [3:0] state,
    output reg finish
         
);

parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;
reg [3:0] n_state;

always@*
  case(state)
    IDLE: n_state = (start)? PRE_SCAN : IDLE; 
    PRE_SCAN: n_state = (pre_scan_complete)? NUM : PRE_SCAN; 
    NUM: n_state = (num_complete)? SCAN : NUM;
    SCAN: //n_state = (scan_complete)? ROTATE : SCAN;
      case({scan_complete, end_of_file})
        2'b00: n_state = SCAN;
        2'b10: n_state = ROTATE;
        2'b01: n_state = FINISH;
        2'b11: n_state = FINISH;
        default: n_state = ROTATE;
      endcase
    ROTATE: //n_state = (rotate_complete)? DEMASK : ROTATE; 
      case({loc_wrong, rotate_complete})
        2'b00: n_state = ROTATE;
        2'b01: n_state = DEMASK;
        2'b11: n_state = LOC;
        default: n_state = ROTATE;
      endcase
    LOC: n_state = (loc_complete)? DEMASK : LOC;
    DEMASK: n_state = (demask_complete)? DECODE : DEMASK;
    DECODE: n_state = (decode_complete)? SCAN : DECODE;
    FINISH: n_state = FINISH;
    default: n_state = state;
  endcase

always@(posedge clk)
  if(~srst_n)
    state <= 0;
  else
    state <= n_state;

always@*
  if(state == FINISH)
    finish = 1;
  else
    finish = 0;


endmodule
