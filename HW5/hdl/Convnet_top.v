//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module Convnet_top #(
parameter CH_NUM = 4,
parameter ACT_PER_ADDR = 4,
parameter BW_PER_ACT = 12,
parameter WEIGHT_PER_ADDR = 9, 
parameter BIAS_PER_ADDR = 1,
parameter BW_PER_PARAM = 8
)
(
input clk,                          
input srst_n,     // synchronous reset (active low)
input enable,     // enable signal for notifying that the unshuffled image is ready in SRAM A
output reg valid, // output valid for testbench to check answers in corresponding SRAM groups
// read data from SRAM group A
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_a3,
// read data from SRAM group B
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b0,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b1,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b2,
input [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_rdata_b3,
// read data from parameter SRAM
input [WEIGHT_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_weight,  
input [BIAS_PER_ADDR*BW_PER_PARAM-1:0] sram_rdata_bias,     
// read address to SRAM group A
output reg [6-1:0] sram_raddr_a0,
output reg [6-1:0] sram_raddr_a1,
output reg [6-1:0] sram_raddr_a2,
output reg [6-1:0] sram_raddr_a3,
// read address to SRAM group B
output reg [5-1:0] sram_raddr_b0,
output reg [5-1:0] sram_raddr_b1,
output reg [5-1:0] sram_raddr_b2,
output reg [5-1:0] sram_raddr_b3,
// read address to parameter SRAM
output reg [10-1:0] sram_raddr_weight,       
output reg [7-1:0] sram_raddr_bias,         
// write enable for SRAM groups A & B
output reg sram_wen_a0,
output reg sram_wen_a1,
output reg sram_wen_a2,
output reg sram_wen_a3,
output reg sram_wen_b0,
output reg sram_wen_b1,
output reg sram_wen_b2,
output reg sram_wen_b3,
// word mask for SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a,
output reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b,
// write addrress to SRAM groups A & B
output reg [6-1:0] sram_waddr_a,
output reg [5-1:0] sram_waddr_b,
// write data to SRAM groups A & B
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_a,
output reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b

);
// FSM
wire [2:0] state;
reg conv1_dw_complete, conv1_pw_complete, conv2_dw_complete, conv2_pw_complete, conv3_complete;
FSM FSM (.clk(clk), .srst_n(srst_n), .enable(enable), .conv1_dw_complete(conv1_dw_complete), .conv1_pw_complete(conv1_pw_complete), .conv2_dw_complete(conv2_dw_complete), 
         .conv2_pw_complete(conv2_pw_complete), .conv3_complete(conv3_complete), .state(state));
parameter IDLE = 3'd0, CONV1_DW = 3'd1, CONV1_PW = 3'd2, CONV2_DW = 3'd3, CONV2_PW = 3'd4, CONV3 = 3'd5, FINISH = 3'd6;

parameter READ = 1'b0, CONV = 1'b1;
integer i;



// ---------------------------------------------------------------------------------conv1_dw---------------------------------------------------------------------//

// FSM for read/conv
//parameter READ = 1'b0, CONV = 1'b1;
reg op_state_1_dw, n_op_state_1_dw;
reg read_complete_1_dw;                      // bias and weight read complete
reg conv_complete_1_dw;                      // convolution complete

always@*
  case(op_state_1_dw)
    READ: n_op_state_1_dw = (read_complete_1_dw)? CONV : READ;
    CONV: n_op_state_1_dw = (conv_complete_1_dw)? READ : CONV;
    default: n_op_state_1_dw = op_state_1_dw;
  endcase

always@(posedge clk)
  if(~srst_n)
    op_state_1_dw <= 0;
  else
    op_state_1_dw <= n_op_state_1_dw;



// read counter for bias and weight
reg [3:0] read_cnt_1_dw;
always@(posedge clk)
  if(~srst_n)
    read_cnt_1_dw <= 0;
  else
    if(state == CONV1_DW && op_state_1_dw == READ && read_cnt_1_dw != 4'd4)
      read_cnt_1_dw <= read_cnt_1_dw + 1'b1;
    else
      read_cnt_1_dw <= 0;

// read_complete
always@*
  if(state == CONV1_DW && op_state_1_dw == READ && read_cnt_1_dw == 4'd4)
    read_complete_1_dw = 1;
  else
    read_complete_1_dw = 0;



// bias and weight register
reg signed [7:0] bias_0_1_dw;
reg signed [7:0] bias_1_1_dw;
reg signed [7:0] bias_2_1_dw;
reg signed [7:0] bias_3_1_dw;


// read bias 0
always@(posedge clk)
  if(~srst_n)
      bias_0_1_dw <= 0;
  else
    if((state == CONV1_DW) && (read_cnt_1_dw == 4'd1))
      bias_0_1_dw <= sram_rdata_bias;
    else
      bias_0_1_dw <= bias_0_1_dw;

// read bias 1
always@(posedge clk)
  if(~srst_n)
      bias_1_1_dw <= 0;
  else
    if((state == CONV1_DW) && (read_cnt_1_dw == 4'd2))
      bias_1_1_dw <= sram_rdata_bias;
    else
      bias_1_1_dw <= bias_1_1_dw;

// read bias 2
always@(posedge clk)
  if(~srst_n)
      bias_2_1_dw <= 0;
  else
    if((state == CONV1_DW) && (read_cnt_1_dw == 4'd3))
      bias_2_1_dw <= sram_rdata_bias;
    else
      bias_2_1_dw <= bias_2_1_dw;

// read bias 3
always@(posedge clk)
  if(~srst_n)
      bias_3_1_dw <= 0;
  else
    if((state == CONV1_DW) && (read_cnt_1_dw == 4'd4))
      bias_3_1_dw <= sram_rdata_bias;
    else
      bias_3_1_dw <= bias_3_1_dw;



    

// weight addr
reg [10-1:0] sram_raddr_weight_1_dw;
always@(posedge clk)
  if(~srst_n)
    sram_raddr_weight_1_dw <= 10'd0;
  else
    if(state == CONV1_DW && op_state_1_dw == READ && read_cnt_1_dw <= 4'd3)                        ////
      sram_raddr_weight_1_dw <= sram_raddr_weight_1_dw + 1'b1;
    else
      sram_raddr_weight_1_dw <= sram_raddr_weight_1_dw;


// bias_addr
reg [7-1:0] sram_raddr_bias_1_dw;
always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_1_dw <= 7'd0;
  else
    if(state == CONV1_DW && op_state_1_dw == READ && read_cnt_1_dw <= 4'd3)                       ////
      sram_raddr_bias_1_dw <= sram_raddr_bias_1_dw + 1'b1;
    else
      sram_raddr_bias_1_dw <= sram_raddr_bias_1_dw;




// conv1_dw complete
always@(posedge clk)
  if(~srst_n)
    conv1_dw_complete <= 0;
  else
    if(state == CONV1_DW && op_state_1_dw == CONV && conv_complete_1_dw && sram_raddr_bias_1_dw == 7'd4)          /////
      conv1_dw_complete <= 1;
    else
      conv1_dw_complete <= 0;


// counter for convolution
reg [5:0] conv_cnt_1_dw;
always@(posedge clk)
  if(~srst_n)
    conv_cnt_1_dw <= 0;
  else
    if(state == CONV1_DW && op_state_1_dw == CONV && conv_cnt_1_dw != 6'd42)
      conv_cnt_1_dw <= conv_cnt_1_dw + 1'b1;
    else
      conv_cnt_1_dw <= 0;

// conv complete(1 output channel needs 37 cycle)
always@*
  if(state == CONV1_DW && op_state_1_dw == CONV && conv_cnt_1_dw == 6'd42)                
    conv_complete_1_dw = 1;
  else
    conv_complete_1_dw = 0;

// addr for SRAM A offset(0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, .....)
reg [5:0] root_addr_1_dw;
always@(posedge clk)
  if(~srst_n)
    root_addr_1_dw <= 0;
  else
    if((op_state_1_dw == CONV) && ((root_addr_1_dw % 3'd4) != 2'd2) && ((conv_cnt_1_dw % 3'd4) == 3'd3))
      root_addr_1_dw <= root_addr_1_dw + 1'd1;
    else if((op_state_1_dw == CONV) && ((root_addr_1_dw % 3'd4) == 2'd2) && ((conv_cnt_1_dw % 3'd4) == 3'd3))
      root_addr_1_dw <= root_addr_1_dw + 2'd2;
    else if(op_state_1_dw == CONV)
      root_addr_1_dw <= root_addr_1_dw;
    else
      root_addr_1_dw <= 0;

// bank offset (0, 1, 2, 3, 0, 1, 2, 3, ......)
reg [1:0] bank_mode_1_dw;
reg [1:0] bank_mode_delay_1_dw;
always@(posedge clk)
  if(~srst_n)
    bank_mode_1_dw <= 0;
  else
    if(op_state_1_dw == CONV)
      bank_mode_1_dw <= bank_mode_1_dw + 1'b1;
    else
      bank_mode_1_dw <= 0;

always@(posedge clk)
  if(~srst_n)
    bank_mode_delay_1_dw <= 0;
  else
    bank_mode_delay_1_dw <= bank_mode_1_dw;

// bank offset addr
reg [2:0] bank_offset_addr_0_1_dw;
reg [2:0] bank_offset_addr_1_1_dw;
reg [2:0] bank_offset_addr_2_1_dw;
reg [2:0] bank_offset_addr_3_1_dw;
always@*
  case(bank_mode_1_dw)
    2'd0: begin
      bank_offset_addr_0_1_dw = 6'd0;
      bank_offset_addr_1_1_dw = 6'd0;
      bank_offset_addr_2_1_dw = 6'd0;
      bank_offset_addr_3_1_dw = 6'd0;
    end
    2'd1: begin
      bank_offset_addr_0_1_dw = 6'd1;
      bank_offset_addr_1_1_dw = 6'd0;
      bank_offset_addr_2_1_dw = 6'd1;
      bank_offset_addr_3_1_dw = 6'd0;
    end
    2'd2: begin
      bank_offset_addr_0_1_dw = 6'd4;
      bank_offset_addr_1_1_dw = 6'd4;
      bank_offset_addr_2_1_dw = 6'd0;
      bank_offset_addr_3_1_dw = 6'd0;
    end
    2'd3: begin
      bank_offset_addr_0_1_dw = 6'd5;
      bank_offset_addr_1_1_dw = 6'd4;
      bank_offset_addr_2_1_dw = 6'd1;
      bank_offset_addr_3_1_dw = 6'd0;
    end
    default: begin
      bank_offset_addr_0_1_dw = 6'd0;
      bank_offset_addr_1_1_dw = 6'd0;
      bank_offset_addr_2_1_dw = 6'd0;
      bank_offset_addr_3_1_dw = 6'd0;
    end
  endcase

// SRAM A read addr
reg [6-1:0] sram_raddr_a0_1_dw;
reg [6-1:0] sram_raddr_a1_1_dw;
reg [6-1:0] sram_raddr_a2_1_dw;
reg [6-1:0] sram_raddr_a3_1_dw;
always@* begin
  sram_raddr_a0_1_dw = root_addr_1_dw + bank_offset_addr_0_1_dw;
  sram_raddr_a1_1_dw = root_addr_1_dw + bank_offset_addr_1_1_dw;
  sram_raddr_a2_1_dw = root_addr_1_dw + bank_offset_addr_2_1_dw;
  sram_raddr_a3_1_dw = root_addr_1_dw + bank_offset_addr_3_1_dw;
end



reg [5:0] conv_cnt_delay_1_dw;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_1_dw <= 0;
  else
    conv_cnt_delay_1_dw <= conv_cnt_1_dw;


// addr for SRAM B
reg [5-1:0] sram_waddr_b_1_dw;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_b_1_dw <= 0;
  else
    if((op_state_1_dw == CONV) && (((conv_cnt_delay_1_dw-6'd6) % 3'd4) == 3'd3) && conv_cnt_delay_1_dw > 6'd6)              ////
      sram_waddr_b_1_dw <= sram_waddr_b_1_dw + 1'b1;
    else if(op_state_1_dw == CONV)
      sram_waddr_b_1_dw <= sram_waddr_b_1_dw;
    else
      sram_waddr_b_1_dw <= 0;



// write enable for SRAM B 
reg sram_wen_b0_1_dw;
reg sram_wen_b1_1_dw;
reg sram_wen_b2_1_dw;
reg sram_wen_b3_1_dw;                                                 ////
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_1_dw <= 1;
    sram_wen_b1_1_dw <= 1;
    sram_wen_b2_1_dw <= 1;
    sram_wen_b3_1_dw <= 1;
  end
  else 
    if(op_state_1_dw == CONV && conv_cnt_1_dw < 6'd42 && conv_cnt_1_dw >= 6'd6)
      case(bank_mode_1_dw)
        2'd2: begin
          sram_wen_b0_1_dw <= 0;
          sram_wen_b1_1_dw <= 1;
          sram_wen_b2_1_dw <= 1;
          sram_wen_b3_1_dw <= 1;
        end
        2'd3: begin
          sram_wen_b0_1_dw <= 1;
          sram_wen_b1_1_dw <= 0;
          sram_wen_b2_1_dw <= 1;
          sram_wen_b3_1_dw <= 1;
        end
        2'd0: begin
          sram_wen_b0_1_dw <= 1;
          sram_wen_b1_1_dw <= 1;
          sram_wen_b2_1_dw <= 0;
          sram_wen_b3_1_dw <= 1;
        end
        2'd1: begin
          sram_wen_b0_1_dw <= 1;
          sram_wen_b1_1_dw <= 1;
          sram_wen_b2_1_dw <= 1;
          sram_wen_b3_1_dw <= 0;
        end
        default: begin
          sram_wen_b0_1_dw <= 1;
          sram_wen_b1_1_dw <= 1;
          sram_wen_b2_1_dw <= 1;
          sram_wen_b3_1_dw <= 1;
        end
      endcase
    else begin
      sram_wen_b0_1_dw <= 1;
      sram_wen_b1_1_dw <= 1;
      sram_wen_b2_1_dw <= 1;
      sram_wen_b3_1_dw <= 1;
    end

    
    


reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b_1_dw;
// wordmask for SRAM B                                             /////
always@(posedge clk)
  if(~srst_n)
    sram_wordmask_b_1_dw <= 16'b1111_1111_1111_1111;
  else 
    if(op_state_1_dw == CONV)
      sram_wordmask_b_1_dw <= 16'b0000_0000_0000_0000;
    else
      sram_wordmask_b_1_dw <= 16'b1111_1111_1111_1111;



// ---------------------------------------------------------------------------------conv1_dw---------------------------------------------------------------------//





// ---------------------------------------------------------------------------------conv2_dw---------------------------------------------------------------------//
// FSM for read/conv
//parameter READ = 1'b0, CONV = 1'b1;
reg op_state_2_dw, n_op_state_2_dw;
reg read_complete_2_dw;                      // bias and weight read complete
reg conv_complete_2_dw;                      // convolution complete

always@*
  case(op_state_2_dw)
    READ: n_op_state_2_dw = (read_complete_2_dw)? CONV : READ;
    CONV: n_op_state_2_dw = (conv_complete_2_dw)? READ : CONV;
    default: n_op_state_2_dw = op_state_2_dw;
  endcase

always@(posedge clk)
  if(~srst_n)
    op_state_2_dw <= 0;
  else
    op_state_2_dw <= n_op_state_2_dw;

//integer i;

reg signed [7:0] bias_0_2_dw;
reg signed [7:0] bias_1_2_dw;
reg signed [7:0] bias_2_2_dw;
reg signed [7:0] bias_3_2_dw;

// read cnt
reg [3:0] read_cnt_2_dw;
always@(posedge clk)
  if(~srst_n)
    read_cnt_2_dw <= 0;
  else
    if(state == CONV2_DW && op_state_2_dw == READ && read_cnt_2_dw != 4'd4)
      read_cnt_2_dw <= read_cnt_2_dw + 1'b1;
    else
      read_cnt_2_dw <= 0;

// weight addr
reg [10-1:0] sram_raddr_weight_2_dw;       
always@(posedge clk)
  if(~srst_n)
    sram_raddr_weight_2_dw <= 10'd6;
  else
    if(state == CONV2_DW && op_state_2_dw == READ && read_cnt_2_dw <= 4'd3)
      sram_raddr_weight_2_dw <= sram_raddr_weight_2_dw + 1'b1;
    else
      sram_raddr_weight_2_dw <= sram_raddr_weight_2_dw;


// bias_addr
reg [7-1:0] sram_raddr_bias_2_dw; 
always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_2_dw <= 7'd8;
  else
    if(state == CONV2_DW && op_state_2_dw == READ && read_cnt_2_dw <= 4'd3)
      sram_raddr_bias_2_dw <= sram_raddr_bias_2_dw + 1'b1;
    else
      sram_raddr_bias_2_dw <= sram_raddr_bias_2_dw;

// read_complete
always@*
  if(state == CONV2_DW && op_state_2_dw == READ && read_cnt_2_dw == 4'd4)
    read_complete_2_dw = 1;
  else
    read_complete_2_dw = 0;



// read bias 0
always@(posedge clk)
  if(~srst_n)
      bias_0_2_dw <= 0;
  else
    if((state == CONV2_DW) && (read_cnt_2_dw == 4'd1))
      bias_0_2_dw <= sram_rdata_bias;
    else
      bias_0_2_dw <= bias_0_2_dw;

// read bias 1
always@(posedge clk)
  if(~srst_n)
      bias_1_2_dw <= 0;
  else
    if((state == CONV2_DW) && (read_cnt_2_dw == 4'd2))
      bias_1_2_dw <= sram_rdata_bias;
    else
      bias_1_2_dw <= bias_1_2_dw;

// read bias 2
always@(posedge clk)
  if(~srst_n)
      bias_2_2_dw <= 0;
  else
    if((state == CONV2_DW) && (read_cnt_2_dw == 4'd3))
      bias_2_2_dw <= sram_rdata_bias;
    else
      bias_2_2_dw <= bias_2_2_dw;

// read bias 3
always@(posedge clk)
  if(~srst_n)
      bias_3_2_dw <= 0;
  else
    if((state == CONV2_DW) && (read_cnt_2_dw == 4'd4))
      bias_3_2_dw <= sram_rdata_bias;
    else
      bias_3_2_dw <= bias_3_2_dw;

// conv2_dw complete
always@(posedge clk)
  if(~srst_n)
    conv2_dw_complete <= 0;
  else
    if(state == CONV2_DW && op_state_2_dw == CONV && conv_complete_2_dw && sram_raddr_bias_2_dw == 7'd12)
      conv2_dw_complete <= 1;
    else
      conv2_dw_complete <= 0;


// counter for convolution
reg [5:0] conv_cnt_2_dw;
always@(posedge clk)
  if(~srst_n)
    conv_cnt_2_dw <= 0;
  else
    if(state == CONV2_DW && op_state_2_dw == CONV && conv_cnt_2_dw != 6'd42)
      conv_cnt_2_dw <= conv_cnt_2_dw + 1'b1;
    else
      conv_cnt_2_dw <= 0;

// conv complete(1 output channel needs 37 cycle)
always@*
  if(state == CONV2_DW && op_state_2_dw == CONV && conv_cnt_2_dw == 6'd42)                 //////
    conv_complete_2_dw = 1;
  else
    conv_complete_2_dw = 0;

// addr for SRAM A offset(0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 4, 4, .....)
reg [5:0] root_addr_2_dw;
always@(posedge clk)
  if(~srst_n)
    root_addr_2_dw <= 0;
  else
    if((op_state_2_dw == CONV) && ((root_addr_2_dw % 3'd4) != 2'd2) && ((conv_cnt_2_dw % 3'd4) == 3'd3))
      root_addr_2_dw <= root_addr_2_dw + 1'd1;
    else if((op_state_2_dw == CONV) && ((root_addr_2_dw % 3'd4) == 2'd2) && ((conv_cnt_2_dw % 3'd4) == 3'd3))
      root_addr_2_dw <= root_addr_2_dw + 2'd2;
    else if(op_state_2_dw == CONV)
      root_addr_2_dw <= root_addr_2_dw;
    else
      root_addr_2_dw <= 0;

// bank offset (0, 1, 2, 3, 0, 1, 2, 3, ......)
reg [1:0] bank_mode_2_dw;
reg [1:0] bank_mode_delay_2_dw;
always@(posedge clk)
  if(~srst_n)
    bank_mode_2_dw <= 0;
  else
    if(op_state_2_dw == CONV)
      bank_mode_2_dw <= bank_mode_2_dw + 1'b1;
    else
      bank_mode_2_dw <= 0;

always@(posedge clk)
  if(~srst_n)
    bank_mode_delay_2_dw <= 0;
  else
    bank_mode_delay_2_dw <= bank_mode_2_dw;



// bank offset addr
reg [2:0] bank_offset_addr_0_2_dw;
reg [2:0] bank_offset_addr_1_2_dw;
reg [2:0] bank_offset_addr_2_2_dw;
reg [2:0] bank_offset_addr_3_2_dw;
always@*
  case(bank_mode_2_dw)
    2'd0: begin
      bank_offset_addr_0_2_dw = 6'd0;
      bank_offset_addr_1_2_dw = 6'd0;
      bank_offset_addr_2_2_dw = 6'd0;
      bank_offset_addr_3_2_dw = 6'd0;
    end
    2'd1: begin
      bank_offset_addr_0_2_dw = 6'd1;
      bank_offset_addr_1_2_dw = 6'd0;
      bank_offset_addr_2_2_dw = 6'd1;
      bank_offset_addr_3_2_dw = 6'd0;
    end
    2'd2: begin
      bank_offset_addr_0_2_dw = 6'd4;
      bank_offset_addr_1_2_dw = 6'd4;
      bank_offset_addr_2_2_dw = 6'd0;
      bank_offset_addr_3_2_dw = 6'd0;
    end
    2'd3: begin
      bank_offset_addr_0_2_dw = 6'd5;
      bank_offset_addr_1_2_dw = 6'd4;
      bank_offset_addr_2_2_dw = 6'd1;
      bank_offset_addr_3_2_dw = 6'd0;
    end
    default: begin
      bank_offset_addr_0_2_dw = 6'd0;
      bank_offset_addr_1_2_dw = 6'd0;
      bank_offset_addr_2_2_dw = 6'd0;
      bank_offset_addr_3_2_dw = 6'd0;
    end
  endcase

// SRAM A read addr
reg [6-1:0] sram_raddr_a0_2_dw;
reg [6-1:0] sram_raddr_a1_2_dw;
reg [6-1:0] sram_raddr_a2_2_dw;
reg [6-1:0] sram_raddr_a3_2_dw;
always@* begin
  sram_raddr_a0_2_dw = root_addr_2_dw + bank_offset_addr_0_2_dw;
  sram_raddr_a1_2_dw = root_addr_2_dw + bank_offset_addr_1_2_dw;
  sram_raddr_a2_2_dw = root_addr_2_dw + bank_offset_addr_2_2_dw;
  sram_raddr_a3_2_dw = root_addr_2_dw + bank_offset_addr_3_2_dw;
end


reg [5:0] conv_cnt_delay_2_dw;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_dw <= 0;
  else
    conv_cnt_delay_2_dw <= conv_cnt_2_dw;

// addr for SRAM B
reg [5-1:0] sram_waddr_b_2_dw;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_b_2_dw <= 0;
  else
    if((op_state_2_dw == CONV) && (((conv_cnt_delay_2_dw-6'd6) % 3'd4) == 3'd3) && conv_cnt_delay_2_dw > 6'd6)
      sram_waddr_b_2_dw <= sram_waddr_b_2_dw + 1'b1;
    else if(op_state_2_dw == CONV)
      sram_waddr_b_2_dw <= sram_waddr_b_2_dw;
    else
      sram_waddr_b_2_dw <= 0;



// write enable for SRAM B
reg sram_wen_b0_2_dw;
reg sram_wen_b1_2_dw;
reg sram_wen_b2_2_dw;
reg sram_wen_b3_2_dw;
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw <= 1;
    sram_wen_b1_2_dw <= 1;
    sram_wen_b2_2_dw <= 1;
    sram_wen_b3_2_dw <= 1;
  end
  else 
    if(op_state_2_dw == CONV && conv_cnt_2_dw < 6'd36)
      case(bank_mode_2_dw)
        2'd0: begin
          sram_wen_b0_2_dw <= 0;
          sram_wen_b1_2_dw <= 1;
          sram_wen_b2_2_dw <= 1;
          sram_wen_b3_2_dw <= 1;
        end
        2'd1:
          if((root_addr_2_dw == 5'd2) || (root_addr_2_dw == 5'd6) || (root_addr_2_dw == 5'd10)) begin
            sram_wen_b0_2_dw <= 1;
            sram_wen_b1_2_dw <= 1;
            sram_wen_b2_2_dw <= 1;
            sram_wen_b3_2_dw <= 1;
          end
          else begin
            sram_wen_b0_2_dw <= 1;
            sram_wen_b1_2_dw <= 0;
            sram_wen_b2_2_dw <= 1;
            sram_wen_b3_2_dw <= 1;
          end
        2'd2:
          if((root_addr_2_dw == 5'd8) || (root_addr_2_dw == 5'd9) || (root_addr_2_dw == 5'd10)) begin
            sram_wen_b0_2_dw <= 1;
            sram_wen_b1_2_dw <= 1;
            sram_wen_b2_2_dw <= 1;
            sram_wen_b3_2_dw <= 1;
          end
          else begin
            sram_wen_b0_2_dw <= 1;
            sram_wen_b1_2_dw <= 1;
            sram_wen_b2_2_dw <= 0;
            sram_wen_b3_2_dw <= 1;
          end
        2'd3:
          if((root_addr_2_dw == 5'd2) || (root_addr_2_dw == 5'd6) || (root_addr_2_dw == 5'd8) || (root_addr_2_dw == 5'd9) || (root_addr_2_dw == 5'd10)) begin
            sram_wen_b0_2_dw <= 1;
            sram_wen_b1_2_dw <= 1;
            sram_wen_b2_2_dw <= 1;
            sram_wen_b3_2_dw <= 1;
          end
          else begin
            sram_wen_b0_2_dw <= 1;
            sram_wen_b1_2_dw <= 1;
            sram_wen_b2_2_dw <= 1;
            sram_wen_b3_2_dw <= 0;
          end
      endcase
    else begin
      sram_wen_b0_2_dw <= 1;
      sram_wen_b1_2_dw <= 1;
      sram_wen_b2_2_dw <= 1;
      sram_wen_b3_2_dw <= 1;
    end

// write enable for SRAM B (delay 1)
reg sram_wen_b0_2_dw_delay_1;
reg sram_wen_b1_2_dw_delay_1;
reg sram_wen_b2_2_dw_delay_1;
reg sram_wen_b3_2_dw_delay_1; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw_delay_1 <= 0;
    sram_wen_b1_2_dw_delay_1 <= 0;
    sram_wen_b2_2_dw_delay_1 <= 0;
    sram_wen_b3_2_dw_delay_1 <= 0;
  end
  else begin
    sram_wen_b0_2_dw_delay_1 <= sram_wen_b0_2_dw;
    sram_wen_b1_2_dw_delay_1 <= sram_wen_b1_2_dw;
    sram_wen_b2_2_dw_delay_1 <= sram_wen_b2_2_dw;
    sram_wen_b3_2_dw_delay_1 <= sram_wen_b3_2_dw;
  end

// write enable for SRAM B (delay 2)
reg sram_wen_b0_2_dw_delay_2;
reg sram_wen_b1_2_dw_delay_2;
reg sram_wen_b2_2_dw_delay_2;
reg sram_wen_b3_2_dw_delay_2; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw_delay_2 <= 0;
    sram_wen_b1_2_dw_delay_2 <= 0;
    sram_wen_b2_2_dw_delay_2 <= 0;
    sram_wen_b3_2_dw_delay_2 <= 0;
  end
  else begin
    sram_wen_b0_2_dw_delay_2 <= sram_wen_b0_2_dw_delay_1;
    sram_wen_b1_2_dw_delay_2 <= sram_wen_b1_2_dw_delay_1;
    sram_wen_b2_2_dw_delay_2 <= sram_wen_b2_2_dw_delay_1;
    sram_wen_b3_2_dw_delay_2 <= sram_wen_b3_2_dw_delay_1;
  end

// write enable for SRAM B (delay 3)
reg sram_wen_b0_2_dw_delay_3;
reg sram_wen_b1_2_dw_delay_3;
reg sram_wen_b2_2_dw_delay_3;
reg sram_wen_b3_2_dw_delay_3; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw_delay_3 <= 0;
    sram_wen_b1_2_dw_delay_3 <= 0;
    sram_wen_b2_2_dw_delay_3 <= 0;
    sram_wen_b3_2_dw_delay_3 <= 0;
  end
  else begin
    sram_wen_b0_2_dw_delay_3 <= sram_wen_b0_2_dw_delay_2;
    sram_wen_b1_2_dw_delay_3 <= sram_wen_b1_2_dw_delay_2;
    sram_wen_b2_2_dw_delay_3 <= sram_wen_b2_2_dw_delay_2;
    sram_wen_b3_2_dw_delay_3 <= sram_wen_b3_2_dw_delay_2;
  end

// write enable for SRAM B (delay 4)
reg sram_wen_b0_2_dw_delay_4;
reg sram_wen_b1_2_dw_delay_4;
reg sram_wen_b2_2_dw_delay_4;
reg sram_wen_b3_2_dw_delay_4; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw_delay_4 <= 0;
    sram_wen_b1_2_dw_delay_4 <= 0;
    sram_wen_b2_2_dw_delay_4 <= 0;
    sram_wen_b3_2_dw_delay_4 <= 0;
  end
  else begin
    sram_wen_b0_2_dw_delay_4 <= sram_wen_b0_2_dw_delay_3;
    sram_wen_b1_2_dw_delay_4 <= sram_wen_b1_2_dw_delay_3;
    sram_wen_b2_2_dw_delay_4 <= sram_wen_b2_2_dw_delay_3;
    sram_wen_b3_2_dw_delay_4 <= sram_wen_b3_2_dw_delay_3;
  end

// write enable for SRAM B (delay 5)
reg sram_wen_b0_2_dw_delay_5;
reg sram_wen_b1_2_dw_delay_5;
reg sram_wen_b2_2_dw_delay_5;
reg sram_wen_b3_2_dw_delay_5; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw_delay_5 <= 0;
    sram_wen_b1_2_dw_delay_5 <= 0;
    sram_wen_b2_2_dw_delay_5 <= 0;
    sram_wen_b3_2_dw_delay_5 <= 0;
  end
  else begin
    sram_wen_b0_2_dw_delay_5 <= sram_wen_b0_2_dw_delay_4;
    sram_wen_b1_2_dw_delay_5 <= sram_wen_b1_2_dw_delay_4;
    sram_wen_b2_2_dw_delay_5 <= sram_wen_b2_2_dw_delay_4;
    sram_wen_b3_2_dw_delay_5 <= sram_wen_b3_2_dw_delay_4;
  end

// write enable for SRAM B (delay 6)
reg sram_wen_b0_2_dw_delay_6;
reg sram_wen_b1_2_dw_delay_6;
reg sram_wen_b2_2_dw_delay_6;
reg sram_wen_b3_2_dw_delay_6; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_2_dw_delay_6 <= 0;
    sram_wen_b1_2_dw_delay_6 <= 0;
    sram_wen_b2_2_dw_delay_6 <= 0;
    sram_wen_b3_2_dw_delay_6 <= 0;
  end
  else begin
    sram_wen_b0_2_dw_delay_6 <= sram_wen_b0_2_dw_delay_5;
    sram_wen_b1_2_dw_delay_6 <= sram_wen_b1_2_dw_delay_5;
    sram_wen_b2_2_dw_delay_6 <= sram_wen_b2_2_dw_delay_5;
    sram_wen_b3_2_dw_delay_6 <= sram_wen_b3_2_dw_delay_5;
  end

reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b_2_dw;
// wordmask for SRAM B
always@(posedge clk)
  if(~srst_n)
    sram_wordmask_b_2_dw <= 16'b1111_1111_1111_1111;
  else 
    if(op_state_2_dw == CONV)
      sram_wordmask_b_2_dw <= 0;
    else
      sram_wordmask_b_2_dw <= sram_wordmask_b_2_dw;



// ---------------------------------------------------------------------------------conv2_dw---------------------------------------------------------------------//




// ---------------------------------------------------------------------------------conv3---------------------------------------------------------------------//
// FSM for read/conv
//parameter READ = 1'b0, CONV = 1'b1;
reg op_state_3, n_op_state_3;
reg read_complete_3;                      // bias and weight read complete
reg conv_complete_3;                      // convolution complete

always@*
  case(op_state_3)
    READ: n_op_state_3 = (read_complete_3)? CONV : READ;
    CONV: n_op_state_3 =  CONV;
    default: n_op_state_3 = op_state_3;
  endcase

always@(posedge clk)
  if(~srst_n)
    op_state_3 <= 0;
  else
    op_state_3 <= n_op_state_3;



reg [7:0] bias_in_3;               // current bias 
reg [3:0] read_cnt_3;



// read cnt
always@(posedge clk)
  if(~srst_n)
    read_cnt_3 <= 0;
  else
    if(state == CONV3 && op_state_3 == READ && read_cnt_3 != 4'd12)
      read_cnt_3 <= read_cnt_3 + 1'b1;
    else
      read_cnt_3 <= 0;

// counter for convolution
reg [5:0] conv_cnt_3;
reg [7-1:0] sram_raddr_bias_3;
always@(posedge clk)
  if(~srst_n)
    conv_cnt_3 <= 0;
  else
    //if(state == CONV3 && op_state_3 == CONV && conv_cnt_3 != 6'd56)
    if(state == CONV3 && op_state_3 == CONV && conv_cnt_3 != 6'd47 && sram_raddr_bias_3 != 7'd89)
      conv_cnt_3 <= conv_cnt_3 + 1'b1;
    else if(state == CONV3 && op_state_3 == CONV && conv_cnt_3 != 6'd56 && sram_raddr_bias_3 == 7'd89)
      conv_cnt_3 <= conv_cnt_3 + 1'b1;
    else if (conv_complete_3)
      conv_cnt_3 <= 0;
    else
      conv_cnt_3 <= 0;

// weight addr
reg [10-1:0] sram_raddr_weight_3; 
always@(posedge clk)
  if(~srst_n)
    sram_raddr_weight_3 <= 10'd16;
  else
    if((state == CONV3 && op_state_3 == READ && read_cnt_3 <= 4'd11) || (state == CONV3 && op_state_3 == CONV && conv_cnt_3 >=6'd1 && conv_cnt_3 <=6'd12))
      sram_raddr_weight_3 <= sram_raddr_weight_3 + 1'b1;
    else
      sram_raddr_weight_3 <= sram_raddr_weight_3;







// bias_addr

always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_3 <= 7'd24;
  else
    if((state == CONV3 && op_state_3 == READ && read_cnt_3 == 4'd0) || (state == CONV3 && op_state_3 == CONV && conv_cnt_3 == 6'd6))
      sram_raddr_bias_3 <= sram_raddr_bias_3 + 1'b1;
    else
      sram_raddr_bias_3 <= sram_raddr_bias_3;

reg [7-1:0] sram_raddr_bias_3_delay_1;
reg [7-1:0] sram_raddr_bias_3_delay_2;
always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_3_delay_1 <= 0;
  else
    sram_raddr_bias_3_delay_1 <= sram_raddr_bias_3;

always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_3_delay_2 <= 0;
  else
    sram_raddr_bias_3_delay_2 <= sram_raddr_bias_3_delay_1;



reg [5:0] write_cnt;
// read_complete
always@*
  if(state == CONV3 && op_state_3 == READ && read_cnt_3 == 4'd12)
    read_complete_3 = 1;
  else
    read_complete_3 = 0;


reg [7:0] bias_in_3_tmp;               // next_bias
always@(posedge clk)
  if(~srst_n)
      bias_in_3_tmp <= 0;
  else
    if((op_state_3 == CONV) && (conv_cnt_3 == 6'd7))
      bias_in_3_tmp <= sram_rdata_bias;
    else
      bias_in_3_tmp <= bias_in_3_tmp;



// read bias
always@(posedge clk)
  if(~srst_n)
      bias_in_3 <= 0;
  else
    if((state == CONV3) && (read_cnt_3 == 4'd1))
      bias_in_3 <= sram_rdata_bias;
    else if ((write_cnt == 6'd47)/* && sram_raddr_bias >= 7'd27*/)
    //else if (conv_complete_3)
      bias_in_3 <= bias_in_3_tmp;
    else
      bias_in_3 <= bias_in_3;


// conv3 complete
always@(posedge clk)
  if(~srst_n)
    conv3_complete <= 0;
  else
    if(state == CONV3 && op_state_3 == CONV && conv_complete_3 && sram_raddr_bias_3 == 7'd89)
      conv3_complete <= 1;
    else
      conv3_complete <= 0;






// conv complete(1 output channel needs 49 cycle)
always@*
  if(state == CONV3 && sram_raddr_bias_3 == 7'd89 && conv_cnt_3 == 6'd56)
    conv_complete_3 = 1;
  else if(state == CONV3 && op_state_3 == CONV && conv_cnt_3 == 6'd47 && sram_raddr_bias_3 != 7'd89)                 //////
    conv_complete_3 = 1;
  else
    conv_complete_3 = 0;

reg conv_complete_3_delay;
always@(posedge clk)
  if(~srst_n)
    conv_complete_3_delay <= 0;
  else
    conv_complete_3_delay <= conv_complete_3;


// addr for SRAM A offset(0, 0, ...., 0(12 times), 1, 1, ...., 1, 4, 4, 4, ..., 5, 5, 5, ....)
reg [5:0] root_addr_3;
always@(posedge clk)
  if(~srst_n)
    root_addr_3 <= 0;
  else
    if(conv_complete_3)
      root_addr_3 <=  0;
    else if((op_state_3 == CONV) && ((conv_cnt_3 == 6'd11) || (conv_cnt_3 == 6'd35)))
      root_addr_3 <= root_addr_3 + 1'b1;
    else if((op_state_3 == CONV) && (conv_cnt_3 == 6'd23))
      root_addr_3 <= root_addr_3 + 2'd3;
    else if(op_state_3 == CONV)
      root_addr_3 <= root_addr_3;
    else
      root_addr_3 <= 0;

// select channel
reg [1:0] mode_3;     // 0, 1, 2, 0, 1, 2,....
reg [1:0] mode_delay_3;
reg [1:0] mode_delay_3_1;
reg [1:0] mode_delay_3_2;
reg [1:0] mode_delay_3_3;
//reg [1:0] mode_delay_3_4;
//reg [1:0] mode_delay_3_5;
always@(posedge clk)
  if(~srst_n) 
    mode_3 <= 0;
  else
    /*if(conv_complete_3)
      mode_3 <= 0;*/
    /*else*/ if(op_state_3 == CONV && mode_3 != 2'd2)
      mode_3 <= mode_3 + 1'b1;
    else
      mode_3 <= 0;

always@(posedge clk)
  if(~srst_n) 
    mode_delay_3 <= 0;
  else
    mode_delay_3 <= mode_3;

always@(posedge clk)
  if(~srst_n) 
    mode_delay_3_1 <= 0;
  else
    mode_delay_3_1 <= mode_delay_3;

always@(posedge clk)
  if(~srst_n) 
    mode_delay_3_2 <= 0;
  else
    mode_delay_3_2 <= mode_delay_3_1;

always@(posedge clk)
  if(~srst_n) 
    mode_delay_3_3 <= 0;
  else
    mode_delay_3_3 <= mode_delay_3_2;



// mode offset addr(0, 12, 24, 0, 12, 24...)
reg [5:0] mode_offset_addr_3;
always@*
  case(mode_3)
    2'd0: mode_offset_addr_3 = 6'd0;
    2'd1: mode_offset_addr_3 = 6'd12;
    2'd2: mode_offset_addr_3 = 6'd24;
    default: mode_offset_addr_3 = 6'd0;
  endcase



// bank offset (0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 0, 0, 0, ....)
reg [2:0] bank_mode_3;
reg [2:0] bank_mode_delay_3;
always@(posedge clk)
  if(~srst_n)
    bank_mode_3 <= 0;
  else
    if(conv_complete_3)
      bank_mode_3 <= 0;
    else if(op_state_3 == CONV && (conv_cnt_3 % 3'd3) == 3'd2 && bank_mode_3 == 3'd3)
      bank_mode_3 <= 0;
    else if(op_state_3 == CONV && ((conv_cnt_3 % 3'd3) == 3'd2) && bank_mode_3 != 3'd3)
      bank_mode_3 <= bank_mode_3 + 1'b1;
    else if(op_state_3 == CONV)
      bank_mode_3 <= bank_mode_3;
    else
      bank_mode_3 <= 0;

always@(posedge clk)
  if(~srst_n)
    bank_mode_delay_3 <= 0;
  else
    bank_mode_delay_3 <= bank_mode_3;



// bank offset addr
reg [2:0] bank_offset_addr_0_3;
reg [2:0] bank_offset_addr_1_3;
reg [2:0] bank_offset_addr_2_3;
reg [2:0] bank_offset_addr_3_3;
always@*
  case(bank_mode_3)
    3'd0: begin
      bank_offset_addr_0_3 = 6'd0;
      bank_offset_addr_1_3 = 6'd0;
      bank_offset_addr_2_3 = 6'd0;
      bank_offset_addr_3_3 = 6'd0;
    end
    3'd1: begin
      bank_offset_addr_0_3 = 6'd1;
      bank_offset_addr_1_3 = 6'd0;
      bank_offset_addr_2_3 = 6'd1;
      bank_offset_addr_3_3 = 6'd0;
    end
    3'd2: begin
      bank_offset_addr_0_3 = 6'd4;
      bank_offset_addr_1_3 = 6'd4;
      bank_offset_addr_2_3 = 6'd0;
      bank_offset_addr_3_3 = 6'd0;
    end
    3'd3: begin
      bank_offset_addr_0_3 = 6'd5;
      bank_offset_addr_1_3 = 6'd4;
      bank_offset_addr_2_3 = 6'd1;
      bank_offset_addr_3_3 = 6'd0;
    end
    default: begin
      bank_offset_addr_0_3 = 6'd0;
      bank_offset_addr_1_3 = 6'd0;
      bank_offset_addr_2_3 = 6'd0;
      bank_offset_addr_3_3 = 6'd0;
    end
  endcase

// SRAM A read addr
reg [6-1:0] sram_raddr_a0_3;
reg [6-1:0] sram_raddr_a1_3;
reg [6-1:0] sram_raddr_a2_3;
reg [6-1:0] sram_raddr_a3_3;
always@* begin
  sram_raddr_a0_3 = root_addr_3 + mode_offset_addr_3 + bank_offset_addr_0_3;
  sram_raddr_a1_3 = root_addr_3 + mode_offset_addr_3 + bank_offset_addr_1_3;
  sram_raddr_a2_3 = root_addr_3 + mode_offset_addr_3 + bank_offset_addr_2_3;
  sram_raddr_a3_3 = root_addr_3 + mode_offset_addr_3 + bank_offset_addr_3_3;
end




// addr for SRAM B
reg [5-1:0] sram_waddr_b_3;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_b_3 <= 0;
  else
    if((state == CONV3) && ((conv_cnt_3 == 4'd8) && sram_raddr_bias_3 > 7'd26) && (((sram_raddr_bias_3-5'd2) % 3'd4) == 3'd0))
      sram_waddr_b_3 <= sram_waddr_b_3 + 1'b1;
    else
      sram_waddr_b_3 <= sram_waddr_b_3;



reg write_valid;
always@(posedge clk)
  if(~srst_n)
    write_valid <= 0;
  else
    if(state == CONV3 && (conv_cnt_3 == 6'd7))
      write_valid <= 1;
    else
      write_valid <= write_valid;
      


always@(posedge clk)
  if(~srst_n)
    write_cnt <= 0;
  else
    if(write_cnt == 6'd47)
      write_cnt <= 0;
    else if(write_valid)
      write_cnt <= write_cnt + 1'b1;
    else
      write_cnt <= write_cnt;



// write enable for SRAM B
reg sram_wen_b0_3;
reg sram_wen_b1_3;
reg sram_wen_b2_3;
reg sram_wen_b3_3;
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_b0_3 <= 1;
    sram_wen_b1_3 <= 1;
    sram_wen_b2_3 <= 1;
    sram_wen_b3_3 <= 1;
  end
  else 
    //if(op_state_3 == CONV && (((conv_cnt_3-6'd7) % 3'd3) == 3'd0) && conv_cnt_3 > 6'd7)
    if(write_valid && ((write_cnt % 2'd3) == 2'd2))
      //case((conv_cnt_3-6'd7) / 6'd13)
      case(write_cnt / 4'd12)
        6'd0: begin
          sram_wen_b0_3 <= 0;
          sram_wen_b1_3 <= 1;
          sram_wen_b2_3 <= 1;
          sram_wen_b3_3 <= 1;
        end
        6'd1: begin
          sram_wen_b0_3 <= 1;
          sram_wen_b1_3 <= 0;
          sram_wen_b2_3 <= 1;
          sram_wen_b3_3 <= 1;
        end
        6'd2: begin
          sram_wen_b0_3 <= 1;
          sram_wen_b1_3 <= 1;
          sram_wen_b2_3 <= 0;
          sram_wen_b3_3 <= 1;
        end
        6'd3: begin
          sram_wen_b0_3 <= 1;
          sram_wen_b1_3 <= 1;
          sram_wen_b2_3 <= 1;
          sram_wen_b3_3 <= 0;
        end
        default: begin
          sram_wen_b0_3 <= 1;
          sram_wen_b1_3 <= 1;
          sram_wen_b2_3 <= 1;
          sram_wen_b3_3 <= 1;
        end
      endcase
    else begin
      sram_wen_b0_3 <= 1;
      sram_wen_b1_3 <= 1;
      sram_wen_b2_3 <= 1;
      sram_wen_b3_3 <= 1;
    end
    


// wordmask for SRAM B
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_b_3;
always@(posedge clk)
  if(~srst_n)
    sram_wordmask_b_3 <= 16'b1111_1111_1111_1111;
  else 
    //if(op_state_3 == CONV && (((conv_cnt_3-6'd7) % 3'd3) == 0) && conv_cnt_3 > 6'd7)   // 3, 6, 9, 12, ....  // 10, 13, 16, ....
    if(write_valid && ((write_cnt % 2'd3) == 2'd2))
      case(sram_raddr_bias_3_delay_2 % 3'd4)
        7'd2:
          case(write_cnt)
            6'd2: sram_wordmask_b_3 <= 16'b0111_1111_1111_1111;       
            6'd5: sram_wordmask_b_3 <= 16'b1011_1111_1111_1111;       
            6'd8: sram_wordmask_b_3 <= 16'b1101_1111_1111_1111;      
            6'd11: sram_wordmask_b_3 <= 16'b1110_1111_1111_1111;       
            6'd14: sram_wordmask_b_3 <= 16'b0111_1111_1111_1111;       
            6'd17: sram_wordmask_b_3 <= 16'b1011_1111_1111_1111;       
            6'd20: sram_wordmask_b_3 <= 16'b1101_1111_1111_1111;      
            6'd23: sram_wordmask_b_3 <= 16'b1110_1111_1111_1111;  
            6'd26: sram_wordmask_b_3 <= 16'b0111_1111_1111_1111;       
            6'd29: sram_wordmask_b_3 <= 16'b1011_1111_1111_1111;       
            6'd32: sram_wordmask_b_3 <= 16'b1101_1111_1111_1111;      
            6'd35: sram_wordmask_b_3 <= 16'b1110_1111_1111_1111;  
            6'd38: sram_wordmask_b_3 <= 16'b0111_1111_1111_1111;       
            6'd41: sram_wordmask_b_3 <= 16'b1011_1111_1111_1111;       
            6'd44: sram_wordmask_b_3 <= 16'b1101_1111_1111_1111;      
            6'd47: sram_wordmask_b_3 <= 16'b1110_1111_1111_1111;  
            default: sram_wordmask_b_3 <= 16'b1111_1111_1111_1111;    
          endcase
        7'd3:
          case(write_cnt)
            6'd2: sram_wordmask_b_3 <= 16'b1111_0111_1111_1111;       
            6'd5: sram_wordmask_b_3 <= 16'b1111_1011_1111_1111;       
            6'd8: sram_wordmask_b_3 <= 16'b1111_1101_1111_1111;      
            6'd11: sram_wordmask_b_3 <= 16'b1111_1110_1111_1111;       
            6'd14: sram_wordmask_b_3 <= 16'b1111_0111_1111_1111;       
            6'd17: sram_wordmask_b_3 <= 16'b1111_1011_1111_1111;       
            6'd20: sram_wordmask_b_3 <= 16'b1111_1101_1111_1111;      
            6'd23: sram_wordmask_b_3 <= 16'b1111_1110_1111_1111;  
            6'd26: sram_wordmask_b_3 <= 16'b1111_0111_1111_1111;       
            6'd29: sram_wordmask_b_3 <= 16'b1111_1011_1111_1111;       
            6'd32: sram_wordmask_b_3 <= 16'b1111_1101_1111_1111;      
            6'd35: sram_wordmask_b_3 <= 16'b1111_1110_1111_1111;  
            6'd38: sram_wordmask_b_3 <= 16'b1111_0111_1111_1111;       
            6'd41: sram_wordmask_b_3 <= 16'b1111_1011_1111_1111;       
            6'd44: sram_wordmask_b_3 <= 16'b1111_1101_1111_1111;      
            6'd47: sram_wordmask_b_3 <= 16'b1111_1110_1111_1111;  
            default: sram_wordmask_b_3 <= 16'b1111_1111_1111_1111;    
          endcase
        7'd0:
          case(write_cnt)
            6'd2: sram_wordmask_b_3 <= 16'b1111_1111_0111_1111;       
            6'd5: sram_wordmask_b_3 <= 16'b1111_1111_1011_1111;       
            6'd8: sram_wordmask_b_3 <= 16'b1111_1111_1101_1111;      
            6'd11: sram_wordmask_b_3 <= 16'b1111_1111_1110_1111;       
            6'd14: sram_wordmask_b_3 <= 16'b1111_1111_0111_1111;       
            6'd17: sram_wordmask_b_3 <= 16'b1111_1111_1011_1111;       
            6'd20: sram_wordmask_b_3 <= 16'b1111_1111_1101_1111;      
            6'd23: sram_wordmask_b_3 <= 16'b1111_1111_1110_1111;  
            6'd26: sram_wordmask_b_3 <= 16'b1111_1111_0111_1111;       
            6'd29: sram_wordmask_b_3 <= 16'b1111_1111_1011_1111;       
            6'd32: sram_wordmask_b_3 <= 16'b1111_1111_1101_1111;      
            6'd35: sram_wordmask_b_3 <= 16'b1111_1111_1110_1111;  
            6'd38: sram_wordmask_b_3 <= 16'b1111_1111_0111_1111;       
            6'd41: sram_wordmask_b_3 <= 16'b1111_1111_1011_1111;       
            6'd44: sram_wordmask_b_3 <= 16'b1111_1111_1101_1111;      
            6'd47: sram_wordmask_b_3 <= 16'b1111_1111_1110_1111;  
            default: sram_wordmask_b_3 <= 16'b1111_1111_1111_1111;    
          endcase
        7'd1:
          case(write_cnt)
            6'd2: sram_wordmask_b_3 <= 16'b1111_1111_1111_0111;       
            6'd5: sram_wordmask_b_3 <= 16'b1111_1111_1111_1011;       
            6'd8: sram_wordmask_b_3 <= 16'b1111_1111_1111_1101;      
            6'd11: sram_wordmask_b_3 <= 16'b1111_1111_1111_1110;       
            6'd14: sram_wordmask_b_3 <= 16'b1111_1111_1111_0111;       
            6'd17: sram_wordmask_b_3 <= 16'b1111_1111_1111_1011;       
            6'd20: sram_wordmask_b_3 <= 16'b1111_1111_1111_1101;      
            6'd23: sram_wordmask_b_3 <= 16'b1111_1111_1111_1110;  
            6'd26: sram_wordmask_b_3 <= 16'b1111_1111_1111_0111;       
            6'd29: sram_wordmask_b_3 <= 16'b1111_1111_1111_1011;       
            6'd32: sram_wordmask_b_3 <= 16'b1111_1111_1111_1101;      
            6'd35: sram_wordmask_b_3 <= 16'b1111_1111_1111_1110;  
            6'd38: sram_wordmask_b_3 <= 16'b1111_1111_1111_0111;       
            6'd41: sram_wordmask_b_3 <= 16'b1111_1111_1111_1011;       
            6'd44: sram_wordmask_b_3 <= 16'b1111_1111_1111_1101;      
            6'd47: sram_wordmask_b_3 <= 16'b1111_1111_1111_1110;  
            default: sram_wordmask_b_3 <= 16'b1111_1111_1111_1111;    
          endcase
        default: sram_wordmask_b_3 <= 16'b1111_1111_1111_1111; 
      endcase     
    else
      sram_wordmask_b_3 <= 16'b1111_1111_1111_1111;






// ---------------------------------------------------------------------------------conv3---------------------------------------------------------------------//


// ---------------------------------------------------------------------------------conv1_pw---------------------------------------------------------------------//
// FSM for read/conv
reg op_state_1_pw, n_op_state_1_pw;
reg read_complete_1_pw;                      // bias and weight read complete
reg conv_complete_1_pw;                      // convolution complete

always@*
  case(op_state_1_pw)
    READ: n_op_state_1_pw = (read_complete_1_pw)? CONV : READ;
    CONV: n_op_state_1_pw = (conv_complete_1_pw)? READ : CONV;
    default: n_op_state_1_pw = op_state_1_pw;
  endcase


always@(posedge clk)
  if(~srst_n)
    op_state_1_pw <= 0;
  else
    op_state_1_pw <= n_op_state_1_pw;


reg signed [7:0] bias_0_1_pw;             // channel
reg signed [7:0] bias_1_1_pw;
reg signed [7:0] bias_2_1_pw;
reg signed [7:0] bias_3_1_pw;
reg [3:0] read_cnt_1_pw;

// read cnt
always@(posedge clk)
  if(~srst_n)
    read_cnt_1_pw <= 0;
  else
    if(state == CONV1_PW && op_state_1_pw == READ && read_cnt_1_pw != 4'd4)
      read_cnt_1_pw <= read_cnt_1_pw + 1'b1;
    else
      read_cnt_1_pw <= 0;


// weight addr
reg [10-1:0] sram_raddr_weight_1_pw; 
always@(posedge clk)
  if(~srst_n)
    sram_raddr_weight_1_pw <= 10'd4;
  else
    if(state == CONV1_PW && op_state_1_pw == READ && read_cnt_1_pw <= 4'd1)
      sram_raddr_weight_1_pw <= sram_raddr_weight_1_pw + 1'b1;
    else
      sram_raddr_weight_1_pw <= sram_raddr_weight_1_pw;


// bias_addr     
reg [7-1:0] sram_raddr_bias_1_pw;  
always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_1_pw <= 7'd4;
  else
    if(state == CONV1_PW && op_state_1_pw == READ && read_cnt_1_pw <= 4'd3)
      sram_raddr_bias_1_pw <= sram_raddr_bias_1_pw + 1'b1;
    else
      sram_raddr_bias_1_pw <= sram_raddr_bias_1_pw;

// read_complete
always@*
  if(state == CONV1_PW && op_state_1_pw == READ && read_cnt_1_pw == 4'd4)
    read_complete_1_pw = 1;
  else
    read_complete_1_pw = 0;



// read bias_0
always@(posedge clk)
  if(~srst_n)
      bias_0_1_pw <= 0;
  else
    if((state == CONV1_PW) && (read_cnt_1_pw == 6'd1))
      bias_0_1_pw <= sram_rdata_bias;
    else
      bias_0_1_pw <= bias_0_1_pw;

// read bias_1
always@(posedge clk)
  if(~srst_n)
      bias_1_1_pw <= 0;
  else
    if((state == CONV1_PW) && (read_cnt_1_pw == 6'd2))
      bias_1_1_pw <= sram_rdata_bias;
    else
      bias_1_1_pw <= bias_1_1_pw;

// read bias_2
always@(posedge clk)
  if(~srst_n)
      bias_2_1_pw <= 0;
  else
    if((state == CONV1_PW) && (read_cnt_1_pw == 6'd3))
      bias_2_1_pw <= sram_rdata_bias;
    else
      bias_2_1_pw <= bias_2_1_pw;

// read bias_3
always@(posedge clk)
  if(~srst_n)
      bias_3_1_pw <= 0;
  else
    if((state == CONV1_PW) && (read_cnt_1_pw == 6'd4))
      bias_3_1_pw <= sram_rdata_bias;
    else
      bias_3_1_pw <= bias_3_1_pw;


// conv1_pw complete
always@(posedge clk)
  if(~srst_n)
    conv1_pw_complete <= 0;
  else
    if(state == CONV1_PW && op_state_1_pw == CONV && conv_complete_1_pw && sram_raddr_bias_1_pw == 7'd8)
      conv1_pw_complete <= 1;
    else
      conv1_pw_complete <= 0;


// counter for convolution
reg [5:0] conv_cnt_1_pw;
always@(posedge clk)
  if(~srst_n)
    conv_cnt_1_pw <= 0;
  else
    if(state == CONV1_PW && op_state_1_pw == CONV && conv_cnt_1_pw != 6'd42)
      conv_cnt_1_pw <= conv_cnt_1_pw + 1'b1;
    else
      conv_cnt_1_pw <= 0;

// conv complete(1 output channel needs 37 cycle)
always@*
  if(state == CONV1_PW && op_state_1_pw == CONV && conv_cnt_1_pw == 6'd42)                 //////
    conv_complete_1_pw = 1;
  else
    conv_complete_1_pw = 0;


reg [4:0] root_addr_1_pw;

// addr for SRAM B offset
always@(posedge clk)
  if(~srst_n)
    root_addr_1_pw <= 0;
  else
    if((state == CONV1_PW) && ((conv_cnt_1_pw % 3'd4) == 3'd3))
      root_addr_1_pw <= root_addr_1_pw + 1'd1;
    else if((state == CONV1_PW))
      root_addr_1_pw <= root_addr_1_pw;
    else
      root_addr_1_pw <= 0;

// SRAM B read addr 
reg [6-1:0] sram_raddr_b0_1_pw;
reg [6-1:0] sram_raddr_b1_1_pw;
reg [6-1:0] sram_raddr_b2_1_pw;
reg [6-1:0] sram_raddr_b3_1_pw;
always@* begin
  sram_raddr_b0_1_pw = root_addr_1_pw;
  sram_raddr_b1_1_pw = root_addr_1_pw;
  sram_raddr_b2_1_pw = root_addr_1_pw;
  sram_raddr_b3_1_pw = root_addr_1_pw;
end

reg [5:0] conv_cnt_delay_1_pw;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_1_pw <= 0;
  else
    conv_cnt_delay_1_pw <= conv_cnt_1_pw;

// addr for SRAM A
reg [6-1:0] sram_waddr_a_1_pw;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_1_pw <= 0;
  else
    if((state == CONV1_PW) && ((sram_waddr_a_1_pw % 3'd4) != 2'd2) && (((conv_cnt_delay_1_pw-6'd6) % 3'd4) == 3'd3) && conv_cnt_delay_1_pw > 6'd6)
      sram_waddr_a_1_pw <= sram_waddr_a_1_pw + 1'd1;
    else if((state == CONV1_PW) && ((sram_waddr_a_1_pw % 3'd4) == 2'd2) && (((conv_cnt_delay_1_pw-6'd6) % 3'd4) == 3'd3) && conv_cnt_delay_1_pw > 6'd6)
      sram_waddr_a_1_pw <= sram_waddr_a_1_pw + 2'd2;
    else if((state == CONV1_PW))
      sram_waddr_a_1_pw <= sram_waddr_a_1_pw;
    else
      sram_waddr_a_1_pw <= 0;

// write enable for SRAM A
reg sram_wen_a0_1_pw;
reg sram_wen_a1_1_pw;
reg sram_wen_a2_1_pw;
reg sram_wen_a3_1_pw;
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_1_pw <= 1;
    sram_wen_a1_1_pw <= 1;
    sram_wen_a2_1_pw <= 1;
    sram_wen_a3_1_pw <= 1;
  end
  else 
    if(op_state_1_pw == CONV && conv_cnt_1_pw < 6'd42 && conv_cnt_1_pw >= 6'd6)
      case((conv_cnt_1_pw - 6'd6) % 3'd4)
        6'd0: begin
          sram_wen_a0_1_pw <= 0;
          sram_wen_a1_1_pw <= 1;
          sram_wen_a2_1_pw <= 1;
          sram_wen_a3_1_pw <= 1;
        end
        6'd1: begin
          sram_wen_a0_1_pw <= 1;
          sram_wen_a1_1_pw <= 0;
          sram_wen_a2_1_pw <= 1;
          sram_wen_a3_1_pw <= 1;
        end
        6'd2: begin
          sram_wen_a0_1_pw <= 1;
          sram_wen_a1_1_pw <= 1;
          sram_wen_a2_1_pw <= 0;
          sram_wen_a3_1_pw <= 1;
        end
        6'd3: begin
          sram_wen_a0_1_pw <= 1;
          sram_wen_a1_1_pw <= 1;
          sram_wen_a2_1_pw <= 1;
          sram_wen_a3_1_pw <= 0;
        end
        default: begin
          sram_wen_a0_1_pw <= 1;
          sram_wen_a1_1_pw <= 1;
          sram_wen_a2_1_pw <= 1;
          sram_wen_a3_1_pw <= 1;
        end
      endcase
    else begin
      sram_wen_a0_1_pw <= 1;
      sram_wen_a1_1_pw <= 1;
      sram_wen_a2_1_pw <= 1;
      sram_wen_a3_1_pw <= 1;
    end




// wordmask for SRAM A
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_1_pw;
always@(posedge clk)
  if(~srst_n)
    sram_wordmask_a_1_pw <= 16'b1111_1111_1111_1111;
  else 
    if(op_state_1_pw == CONV)
      sram_wordmask_a_1_pw <= 0;
    else
      sram_wordmask_a_1_pw <= sram_wordmask_a_1_pw;


// ---------------------------------------------------------------------------------conv1_pw---------------------------------------------------------------------//



// ---------------------------------------------------------------------------------conv2_pw---------------------------------------------------------------------//
// FSM for read/conv
reg op_state_2_pw, n_op_state_2_pw;
reg read_complete_2_pw;                      // bias and weight read complete
reg conv_complete_2_pw;                      // convolution complete

always@*
  case(op_state_2_pw)
    READ: n_op_state_2_pw = (read_complete_2_pw)? CONV : READ;
    CONV: n_op_state_2_pw = (conv_complete_2_pw)? READ : CONV;
    default: n_op_state_2_pw = op_state_2_pw;
  endcase


always@(posedge clk)
  if(~srst_n)
    op_state_2_pw <= 0;
  else
    op_state_2_pw <= n_op_state_2_pw;


reg signed [7:0] bias_0_2_pw;             // channel(n)
reg signed [7:0] bias_1_2_pw;
reg signed [7:0] bias_2_2_pw;
reg signed [7:0] bias_3_2_pw;
reg signed [7:0] bias_4_2_pw;             
reg signed [7:0] bias_5_2_pw;
reg signed [7:0] bias_6_2_pw;
reg signed [7:0] bias_7_2_pw;
reg signed [7:0] bias_8_2_pw;             
reg signed [7:0] bias_9_2_pw;
reg signed [7:0] bias_10_2_pw;
reg signed [7:0] bias_11_2_pw;


// read cnt
reg [3:0] read_cnt_2_pw;
always@(posedge clk)
  if(~srst_n)
    read_cnt_2_pw <= 0;
  else
    if(state == CONV2_PW && op_state_2_pw == READ && read_cnt_2_pw != 4'd12)
      read_cnt_2_pw <= read_cnt_2_pw + 1'b1;
    else
      read_cnt_2_pw <= 0;


// weight addr
reg [10-1:0] sram_raddr_weight_2_pw;       
 
always@(posedge clk)
  if(~srst_n)
    sram_raddr_weight_2_pw <= 10'd10;
  else
    if(state == CONV2_PW && op_state_2_pw == READ && read_cnt_2_pw <= 4'd5)
      sram_raddr_weight_2_pw <= sram_raddr_weight_2_pw + 1'b1;
    else
      sram_raddr_weight_2_pw <= sram_raddr_weight_2_pw;


// bias_addr      
reg [7-1:0] sram_raddr_bias_2_pw;  
always@(posedge clk)
  if(~srst_n)
    sram_raddr_bias_2_pw <= 7'd12;
  else
    if(state == CONV2_PW && op_state_2_pw == READ && read_cnt_2_pw <= 4'd11)
      sram_raddr_bias_2_pw <= sram_raddr_bias_2_pw + 1'b1;
    else
      sram_raddr_bias_2_pw <= sram_raddr_bias_2_pw;

// read_complete
always@*
  if(state == CONV2_PW && op_state_2_pw == READ && read_cnt_2_pw == 4'd12)
    read_complete_2_pw = 1;
  else
    read_complete_2_pw = 0;



// read bias_0
always@(posedge clk)
  if(~srst_n)
      bias_0_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd1))
      bias_0_2_pw <= sram_rdata_bias;
    else
      bias_0_2_pw <= bias_0_2_pw;

// read bias_1
always@(posedge clk)
  if(~srst_n)
      bias_1_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd2))
      bias_1_2_pw <= sram_rdata_bias;
    else
      bias_1_2_pw <= bias_1_2_pw;

// read bias_2
always@(posedge clk)
  if(~srst_n)
      bias_2_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd3))
      bias_2_2_pw <= sram_rdata_bias;
    else
      bias_2_2_pw <= bias_2_2_pw;

// read bias_3
always@(posedge clk)
  if(~srst_n)
      bias_3_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd4))
      bias_3_2_pw <= sram_rdata_bias;
    else
      bias_3_2_pw <= bias_3_2_pw;

// read bias_4
always@(posedge clk)
  if(~srst_n)
      bias_4_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd5))
      bias_4_2_pw <= sram_rdata_bias;
    else
      bias_4_2_pw <= bias_4_2_pw;

// read bias_5
always@(posedge clk)
  if(~srst_n)
      bias_5_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd6))
      bias_5_2_pw <= sram_rdata_bias;
    else
      bias_5_2_pw <= bias_5_2_pw;

// read bias_6
always@(posedge clk)
  if(~srst_n)
      bias_6_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd7))
      bias_6_2_pw <= sram_rdata_bias;
    else
      bias_6_2_pw <= bias_6_2_pw;

// read bias_7
always@(posedge clk)
  if(~srst_n)
      bias_7_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd8))
      bias_7_2_pw <= sram_rdata_bias;
    else
      bias_7_2_pw <= bias_7_2_pw;

// read bias_8
always@(posedge clk)
  if(~srst_n)
      bias_8_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd9))
      bias_8_2_pw <= sram_rdata_bias;
    else
      bias_8_2_pw <= bias_8_2_pw;

// read bias_9
always@(posedge clk)
  if(~srst_n)
      bias_9_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd10))
      bias_9_2_pw <= sram_rdata_bias;
    else
      bias_9_2_pw <= bias_9_2_pw;

// read bias_10
always@(posedge clk)
  if(~srst_n)
      bias_10_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd11))
      bias_10_2_pw <= sram_rdata_bias;
    else
      bias_10_2_pw <= bias_10_2_pw;

// read bias_11
always@(posedge clk)
  if(~srst_n)
      bias_11_2_pw <= 0;
  else
    if((state == CONV2_PW) && (read_cnt_2_pw == 6'd12))
      bias_11_2_pw <= sram_rdata_bias;
    else
      bias_11_2_pw <= bias_11_2_pw;

// conv2_pw complete
always@(posedge clk)
  if(~srst_n)
    conv2_pw_complete <= 0;
  else
    if(state == CONV2_PW && op_state_2_pw == CONV && conv_complete_2_pw && sram_raddr_bias_2_pw == 7'd24)
      conv2_pw_complete <= 1;
    else
      conv2_pw_complete <= 0;


// counter for convolution
reg [5:0] conv_cnt_2_pw;
always@(posedge clk)
  if(~srst_n)
    conv_cnt_2_pw <= 0;
  else
    if(state == CONV2_PW && op_state_2_pw == CONV && conv_cnt_2_pw != 6'd33)
      conv_cnt_2_pw <= conv_cnt_2_pw + 1'b1;
    else
      conv_cnt_2_pw <= 0;

reg [6:0] conv_cnt_delay_2_pw;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_pw <= 0;
  else
    conv_cnt_delay_2_pw <= conv_cnt_2_pw;


reg [6:0] conv_cnt_delay_2_pw_1;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_pw_1 <= 0;
  else
    conv_cnt_delay_2_pw_1 <= conv_cnt_delay_2_pw;

reg [6:0] conv_cnt_delay_2_pw_2;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_pw_2 <= 0;
  else
    conv_cnt_delay_2_pw_2 <= conv_cnt_delay_2_pw_1;

reg [6:0] conv_cnt_delay_2_pw_3;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_pw_3 <= 0;
  else
    conv_cnt_delay_2_pw_3 <= conv_cnt_delay_2_pw_2;

reg [6:0] conv_cnt_delay_2_pw_4;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_pw_4 <= 0;
  else
    conv_cnt_delay_2_pw_4 <= conv_cnt_delay_2_pw_3;

reg [6:0] conv_cnt_delay_2_pw_5;
// delay counter
always@(posedge clk)
  if(~srst_n)
    conv_cnt_delay_2_pw_5 <= 0;
  else
    conv_cnt_delay_2_pw_5 <= conv_cnt_delay_2_pw_4;


// write addr offset(mode)
reg [1:0] mode_2_pw;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw <= 0;
  else
    if(state == CONV2_PW && conv_cnt_2_pw == 6'd33)
      mode_2_pw <= mode_2_pw + 1'b1;
    else if(state == CONV2_PW)
      mode_2_pw <= mode_2_pw;
    else
      mode_2_pw <= 0;

reg [1:0] mode_2_pw_delay;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw_delay <= 0;
  else
    mode_2_pw_delay <= mode_2_pw;
reg [1:0] mode_2_pw_delay_1;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw_delay_1 <= 0;
  else
    mode_2_pw_delay_1 <= mode_2_pw_delay;

reg [1:0] mode_2_pw_delay_2;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw_delay_2 <= 0;
  else
    mode_2_pw_delay_2 <= mode_2_pw_delay_1;

reg [1:0] mode_2_pw_delay_3;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw_delay_3 <= 0;
  else
    mode_2_pw_delay_3 <= mode_2_pw_delay_2;

reg [1:0] mode_2_pw_delay_4;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw_delay_4 <= 0;
  else
    mode_2_pw_delay_4 <= mode_2_pw_delay_3;

reg [1:0] mode_2_pw_delay_5;
always@(posedge clk)
  if(~srst_n) 
    mode_2_pw_delay_5 <= 0;
  else
    mode_2_pw_delay_5 <= mode_2_pw_delay_4;


// conv complete(1 output channel needs 33 cycle)
always@*
  if(state == CONV2_PW && op_state_2_pw == CONV && conv_cnt_delay_2_pw_5 == 6'd33 && mode_2_pw_delay_5 == 2'd2)                 //////
    conv_complete_2_pw = 1;
  else
    conv_complete_2_pw = 0;


reg [4:0] root_addr_2_pw;

// addr for SRAM B offset
always@(posedge clk)
  if(~srst_n)
    root_addr_2_pw <= 0;
  else
    if((state == CONV2_PW) && ((conv_cnt_2_pw % 3'd4) == 3'd3))
      root_addr_2_pw <= root_addr_2_pw + 1'd1;
    else if((state == CONV2_PW) && (root_addr_2_pw == 5'd8))
      root_addr_2_pw <= 0;
    else if(state == CONV2_PW)
      root_addr_2_pw <= root_addr_2_pw;
    else
      root_addr_2_pw <= 0;


// SRAM B read addr
reg [6-1:0] sram_raddr_b0_2_pw;
reg [6-1:0] sram_raddr_b1_2_pw;
reg [6-1:0] sram_raddr_b2_2_pw;
reg [6-1:0] sram_raddr_b3_2_pw;
always@* begin
  sram_raddr_b0_2_pw = root_addr_2_pw;
  sram_raddr_b1_2_pw = root_addr_2_pw;
  sram_raddr_b2_2_pw = root_addr_2_pw;
  sram_raddr_b3_2_pw = root_addr_2_pw;
end



  
// addr for SRAM A
reg [6-1:0] sram_waddr_a_2_pw;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw <= 0;
  else
    if((state == CONV2_PW) && ((sram_waddr_a_2_pw % 3'd4) != 2'd2) && ((conv_cnt_delay_2_pw % 3'd4) == 3'd3))
      sram_waddr_a_2_pw <= sram_waddr_a_2_pw + 1'd1;
    else if((state == CONV2_PW) && ((sram_waddr_a_2_pw % 3'd4) == 2'd2) && ((conv_cnt_delay_2_pw % 3'd4) == 3'd3))
      sram_waddr_a_2_pw <= sram_waddr_a_2_pw + 2'd2;
    else if((state == CONV2_PW) && conv_cnt_2_pw == 7'd33 && mode_2_pw == 2'd0)
      sram_waddr_a_2_pw <= 6'd12;
    else if((state == CONV2_PW) && conv_cnt_2_pw == 7'd33 && mode_2_pw == 2'd1)
      sram_waddr_a_2_pw <= 6'd24;
    else if((state == CONV2_PW))
      sram_waddr_a_2_pw <= sram_waddr_a_2_pw;
    else
      sram_waddr_a_2_pw <= 0;


// addr for SRAM A (delay 1)
reg [6-1:0] sram_waddr_a_2_pw_delay_1;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw_delay_1 <= 0;
  else
    sram_waddr_a_2_pw_delay_1 <= sram_waddr_a_2_pw;

// addr for SRAM A (delay 2)
reg [6-1:0] sram_waddr_a_2_pw_delay_2;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw_delay_2 <= 0;
  else
    sram_waddr_a_2_pw_delay_2 <= sram_waddr_a_2_pw_delay_1;

// addr for SRAM A (delay 3)
reg [6-1:0] sram_waddr_a_2_pw_delay_3;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw_delay_3 <= 0;
  else
    sram_waddr_a_2_pw_delay_3 <= sram_waddr_a_2_pw_delay_2;

// addr for SRAM A (delay 4)
reg [6-1:0] sram_waddr_a_2_pw_delay_4;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw_delay_4 <= 0;
  else
    sram_waddr_a_2_pw_delay_4 <= sram_waddr_a_2_pw_delay_3;

// addr for SRAM A (delay 5)
reg [6-1:0] sram_waddr_a_2_pw_delay_5;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw_delay_5 <= 0;
  else
    sram_waddr_a_2_pw_delay_5 <= sram_waddr_a_2_pw_delay_4;

// addr for SRAM A (delay 6)
reg [6-1:0] sram_waddr_a_2_pw_delay_6;
always@(posedge clk)
  if(~srst_n)
    sram_waddr_a_2_pw_delay_6 <= 0;
  else
    sram_waddr_a_2_pw_delay_6 <= sram_waddr_a_2_pw_delay_5;


// write enable for SRAM A
reg sram_wen_a0_2_pw;
reg sram_wen_a1_2_pw;
reg sram_wen_a2_2_pw;
reg sram_wen_a3_2_pw;
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw <= 1;
    sram_wen_a1_2_pw <= 1;
    sram_wen_a2_2_pw <= 1;
    sram_wen_a3_2_pw <= 1;
  end
  else 
    if(op_state_2_pw == CONV && !(conv_cnt_2_pw == 7'd33 && mode_2_pw == 2'd2) && conv_cnt_2_pw < 7'd33)
      case(conv_cnt_2_pw % 3'd4)
        6'd0: begin
          sram_wen_a0_2_pw <= 0;
          sram_wen_a1_2_pw <= 1;
          sram_wen_a2_2_pw <= 1;
          sram_wen_a3_2_pw <= 1;
        end
        6'd1: 
          if((root_addr_2_pw == 5'd2) || (root_addr_2_pw == 5'd5) || (root_addr_2_pw == 5'd8)) begin
            sram_wen_a0_2_pw <= 1;
            sram_wen_a1_2_pw <= 1;
            sram_wen_a2_2_pw <= 1;
            sram_wen_a3_2_pw <= 1;
          end
          else begin
            sram_wen_a0_2_pw <= 1;
            sram_wen_a1_2_pw <= 0;
            sram_wen_a2_2_pw <= 1;
            sram_wen_a3_2_pw <= 1;
          end
        6'd2:
          if((root_addr_2_pw == 5'd6) || (root_addr_2_pw == 5'd7) || (root_addr_2_pw == 5'd8)) begin
            sram_wen_a0_2_pw <= 1;
            sram_wen_a1_2_pw <= 1;
            sram_wen_a2_2_pw <= 1;
            sram_wen_a3_2_pw <= 1;
          end
          else begin
            sram_wen_a0_2_pw <= 1;
            sram_wen_a1_2_pw <= 1;
            sram_wen_a2_2_pw <= 0;
            sram_wen_a3_2_pw <= 1;
          end
        6'd3:
          if((root_addr_2_pw == 5'd2) || (root_addr_2_pw == 5'd5) || (root_addr_2_pw == 5'd6) || (root_addr_2_pw == 5'd7) || (root_addr_2_pw == 5'd8)) begin
            sram_wen_a0_2_pw <= 1;
            sram_wen_a1_2_pw <= 1;
            sram_wen_a2_2_pw <= 1;
            sram_wen_a3_2_pw <= 1;
          end
          else begin
            sram_wen_a0_2_pw <= 1;
            sram_wen_a1_2_pw <= 1;
            sram_wen_a2_2_pw <= 1;
            sram_wen_a3_2_pw <= 0;
          end
        default: begin
          sram_wen_a0_2_pw <= 1;
          sram_wen_a1_2_pw <= 1;
          sram_wen_a2_2_pw <= 1;
          sram_wen_a3_2_pw <= 1;
        end
      endcase
    else begin
      sram_wen_a0_2_pw <= 1;
      sram_wen_a1_2_pw <= 1;
      sram_wen_a2_2_pw <= 1;
      sram_wen_a3_2_pw <= 1;
    end

// write enable for SRAM A (delay 1)
reg sram_wen_a0_2_pw_delay_1;
reg sram_wen_a1_2_pw_delay_1;
reg sram_wen_a2_2_pw_delay_1;
reg sram_wen_a3_2_pw_delay_1; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw_delay_1 <= 0;
    sram_wen_a1_2_pw_delay_1 <= 0;
    sram_wen_a2_2_pw_delay_1 <= 0;
    sram_wen_a3_2_pw_delay_1 <= 0;
  end
  else begin
    sram_wen_a0_2_pw_delay_1 <= sram_wen_a0_2_pw;
    sram_wen_a1_2_pw_delay_1 <= sram_wen_a1_2_pw;
    sram_wen_a2_2_pw_delay_1 <= sram_wen_a2_2_pw;
    sram_wen_a3_2_pw_delay_1 <= sram_wen_a3_2_pw;

  end

// write enable for SRAM A (delay 2)
reg sram_wen_a0_2_pw_delay_2;
reg sram_wen_a1_2_pw_delay_2;
reg sram_wen_a2_2_pw_delay_2;
reg sram_wen_a3_2_pw_delay_2; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw_delay_2 <= 0;
    sram_wen_a1_2_pw_delay_2 <= 0;
    sram_wen_a2_2_pw_delay_2 <= 0;
    sram_wen_a3_2_pw_delay_2 <= 0;
  end
  else begin
    sram_wen_a0_2_pw_delay_2 <= sram_wen_a0_2_pw_delay_1;
    sram_wen_a1_2_pw_delay_2 <= sram_wen_a1_2_pw_delay_1;
    sram_wen_a2_2_pw_delay_2 <= sram_wen_a2_2_pw_delay_1;
    sram_wen_a3_2_pw_delay_2 <= sram_wen_a3_2_pw_delay_1;

  end

// write enable for SRAM A (delay 3)
reg sram_wen_a0_2_pw_delay_3;
reg sram_wen_a1_2_pw_delay_3;
reg sram_wen_a2_2_pw_delay_3;
reg sram_wen_a3_2_pw_delay_3; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw_delay_3 <= 0;
    sram_wen_a1_2_pw_delay_3 <= 0;
    sram_wen_a2_2_pw_delay_3 <= 0;
    sram_wen_a3_2_pw_delay_3 <= 0;
  end
  else begin
    sram_wen_a0_2_pw_delay_3 <= sram_wen_a0_2_pw_delay_2;
    sram_wen_a1_2_pw_delay_3 <= sram_wen_a1_2_pw_delay_2;
    sram_wen_a2_2_pw_delay_3 <= sram_wen_a2_2_pw_delay_2;
    sram_wen_a3_2_pw_delay_3 <= sram_wen_a3_2_pw_delay_2;

  end

// write enable for SRAM A (delay 4)
reg sram_wen_a0_2_pw_delay_4;
reg sram_wen_a1_2_pw_delay_4;
reg sram_wen_a2_2_pw_delay_4;
reg sram_wen_a3_2_pw_delay_4; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw_delay_4 <= 0;
    sram_wen_a1_2_pw_delay_4 <= 0;
    sram_wen_a2_2_pw_delay_4 <= 0;
    sram_wen_a3_2_pw_delay_4 <= 0;
  end
  else begin
    sram_wen_a0_2_pw_delay_4 <= sram_wen_a0_2_pw_delay_3;
    sram_wen_a1_2_pw_delay_4 <= sram_wen_a1_2_pw_delay_3;
    sram_wen_a2_2_pw_delay_4 <= sram_wen_a2_2_pw_delay_3;
    sram_wen_a3_2_pw_delay_4 <= sram_wen_a3_2_pw_delay_3;

  end

// write enable for SRAM A (delay 5)
reg sram_wen_a0_2_pw_delay_5;
reg sram_wen_a1_2_pw_delay_5;
reg sram_wen_a2_2_pw_delay_5;
reg sram_wen_a3_2_pw_delay_5; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw_delay_5 <= 0;
    sram_wen_a1_2_pw_delay_5 <= 0;
    sram_wen_a2_2_pw_delay_5 <= 0;
    sram_wen_a3_2_pw_delay_5 <= 0;
  end
  else begin
    sram_wen_a0_2_pw_delay_5 <= sram_wen_a0_2_pw_delay_4;
    sram_wen_a1_2_pw_delay_5 <= sram_wen_a1_2_pw_delay_4;
    sram_wen_a2_2_pw_delay_5 <= sram_wen_a2_2_pw_delay_4;
    sram_wen_a3_2_pw_delay_5 <= sram_wen_a3_2_pw_delay_4;

  end

// write enable for SRAM A (delay 6)
reg sram_wen_a0_2_pw_delay_6;
reg sram_wen_a1_2_pw_delay_6;
reg sram_wen_a2_2_pw_delay_6;
reg sram_wen_a3_2_pw_delay_6; 
always@(posedge clk)
  if(~srst_n) begin
    sram_wen_a0_2_pw_delay_6 <= 0;
    sram_wen_a1_2_pw_delay_6 <= 0;
    sram_wen_a2_2_pw_delay_6 <= 0;
    sram_wen_a3_2_pw_delay_6 <= 0;
  end
  else begin
    sram_wen_a0_2_pw_delay_6 <= sram_wen_a0_2_pw_delay_5;
    sram_wen_a1_2_pw_delay_6 <= sram_wen_a1_2_pw_delay_5;
    sram_wen_a2_2_pw_delay_6 <= sram_wen_a2_2_pw_delay_5;
    sram_wen_a3_2_pw_delay_6 <= sram_wen_a3_2_pw_delay_5;

  end


// wordmask for SRAM A
reg [CH_NUM*ACT_PER_ADDR-1:0] sram_wordmask_a_2_pw;
always@(posedge clk)
  if(~srst_n)
    sram_wordmask_a_2_pw <= 16'b1111_1111_1111_1111;
  else 
    if(op_state_2_pw == CONV)
      sram_wordmask_a_2_pw <= 0;
    else
      sram_wordmask_a_2_pw <= sram_wordmask_a_2_pw;




// ---------------------------------------------------------------------------------conv2_pw---------------------------------------------------------------------//


// ---------------------------------------------------------------------------------global output valid---------------------------------------------------------------------//
// output valid
reg conv3_valid;
always@(posedge clk)
  if(~srst_n)
    conv3_valid <= 0;
  else
    if(state == CONV3 && op_state_3 == CONV && conv_complete_3 && sram_raddr_bias_3 == 7'd89)                    
      conv3_valid <= 1;
    else
      conv3_valid <= 0;

// ---------------------------------------------------------------------------------global output valid---------------------------------------------------------------------//



// ---------------------------------------------------------------------------------output selection(except write data)---------------------------------------------------------------------//

// SRAM A read addr sel
always@*
  case(state)
    CONV1_DW: begin
      sram_raddr_a0 = sram_raddr_a0_1_dw;
      sram_raddr_a1 = sram_raddr_a1_1_dw;
      sram_raddr_a2 = sram_raddr_a2_1_dw;
      sram_raddr_a3 = sram_raddr_a3_1_dw;
    end
    CONV2_DW: begin
      sram_raddr_a0 = sram_raddr_a0_2_dw;
      sram_raddr_a1 = sram_raddr_a1_2_dw;
      sram_raddr_a2 = sram_raddr_a2_2_dw;
      sram_raddr_a3 = sram_raddr_a3_2_dw;
    end
    CONV3: begin
      sram_raddr_a0 = sram_raddr_a0_3;
      sram_raddr_a1 = sram_raddr_a1_3;
      sram_raddr_a2 = sram_raddr_a2_3;
      sram_raddr_a3 = sram_raddr_a3_3;
    end
    default: begin
      sram_raddr_a0 = 0;
      sram_raddr_a1 = 0;
      sram_raddr_a2 = 0;
      sram_raddr_a3 = 0;
    end
  endcase

// SRAM B wordmask sel
always@* 
  case(state)
    CONV1_DW: sram_wordmask_b = sram_wordmask_b_1_dw;
    CONV2_DW: sram_wordmask_b = sram_wordmask_b_2_dw;
    CONV3: sram_wordmask_b = sram_wordmask_b_3;
    default: sram_wordmask_b = 16'b1111_1111_1111_1111;
  endcase

// SRAM B write addr sel
always@*
  case(state)
    CONV1_DW: sram_waddr_b = sram_waddr_b_1_dw;
    CONV2_DW: sram_waddr_b = sram_waddr_b_2_dw;
    CONV3: sram_waddr_b = sram_waddr_b_3;
    default: sram_waddr_b = 0;
  endcase


// SRAM B write enable sel
always@*
  case(state)
    CONV1_DW: begin
      sram_wen_b0 = sram_wen_b0_1_dw;
      sram_wen_b1 = sram_wen_b1_1_dw;
      sram_wen_b2 = sram_wen_b2_1_dw;
      sram_wen_b3 = sram_wen_b3_1_dw;
    end 
    CONV2_DW: begin
      sram_wen_b0 = sram_wen_b0_2_dw_delay_6;
      sram_wen_b1 = sram_wen_b1_2_dw_delay_6;
      sram_wen_b2 = sram_wen_b2_2_dw_delay_6;
      sram_wen_b3 = sram_wen_b3_2_dw_delay_6;
    end 
    CONV3: begin
      sram_wen_b0 = sram_wen_b0_3;
      sram_wen_b1 = sram_wen_b1_3;
      sram_wen_b2 = sram_wen_b2_3;
      sram_wen_b3 = sram_wen_b3_3;
    end 
    default: begin
      sram_wen_b0 = 1;
      sram_wen_b1 = 1;
      sram_wen_b2 = 1;
      sram_wen_b3 = 1;
    end 
  endcase

// SRAM B read addr sel
always@*
  case(state)
    CONV1_PW: begin
      sram_raddr_b0 = sram_raddr_b0_1_pw;
      sram_raddr_b1 = sram_raddr_b1_1_pw;
      sram_raddr_b2 = sram_raddr_b2_1_pw;
      sram_raddr_b3 = sram_raddr_b3_1_pw;
    end
    CONV2_PW: begin
      sram_raddr_b0 = sram_raddr_b0_2_pw;
      sram_raddr_b1 = sram_raddr_b1_2_pw;
      sram_raddr_b2 = sram_raddr_b2_2_pw;
      sram_raddr_b3 = sram_raddr_b3_2_pw;
    end
    default: begin
      sram_raddr_b0 = 0;
      sram_raddr_b1 = 0;
      sram_raddr_b2 = 0;
      sram_raddr_b3 = 0;
    end
  endcase


// SRAM A wordmask sel
always@* 
  case(state)
    CONV1_PW: sram_wordmask_a = sram_wordmask_a_1_pw;
    CONV2_PW: sram_wordmask_a = sram_wordmask_a_2_pw;
    default: sram_wordmask_a = 16'b1111_1111_1111_1111;
  endcase

// SRAM A write addr sel
always@*
  case(state)
    CONV1_PW: sram_waddr_a = sram_waddr_a_1_pw;
    CONV2_PW: sram_waddr_a = sram_waddr_a_2_pw_delay_6;
    default: sram_waddr_a = 0;
  endcase


// SRAM A write enable sel
always@*
  case(state)
    CONV1_PW: begin
      sram_wen_a0 = sram_wen_a0_1_pw;
      sram_wen_a1 = sram_wen_a1_1_pw;
      sram_wen_a2 = sram_wen_a2_1_pw;
      sram_wen_a3 = sram_wen_a3_1_pw;
    end 
    CONV2_PW: begin
      sram_wen_a0 = sram_wen_a0_2_pw_delay_6;
      sram_wen_a1 = sram_wen_a1_2_pw_delay_6;
      sram_wen_a2 = sram_wen_a2_2_pw_delay_6;
      sram_wen_a3 = sram_wen_a3_2_pw_delay_6;
    end 
    default: begin
      sram_wen_a0 = 1;
      sram_wen_a1 = 1;
      sram_wen_a2 = 1;
      sram_wen_a3 = 1;
    end 
  endcase



// SRAM weight addr sel
always@* 
  case(state)
    CONV1_DW: sram_raddr_weight = sram_raddr_weight_1_dw;
    CONV1_PW: sram_raddr_weight = sram_raddr_weight_1_pw;
    CONV2_DW: sram_raddr_weight = sram_raddr_weight_2_dw;
    CONV2_PW: sram_raddr_weight = sram_raddr_weight_2_pw;
    CONV3: sram_raddr_weight = sram_raddr_weight_3;
    default: sram_raddr_weight = 0;
  endcase

// SRAM bias addr sel
always@* 
  case(state)
    CONV1_DW: sram_raddr_bias = sram_raddr_bias_1_dw;
    CONV1_PW: sram_raddr_bias = sram_raddr_bias_1_pw;
    CONV2_DW: sram_raddr_bias = sram_raddr_bias_2_dw;
    CONV2_PW: sram_raddr_bias = sram_raddr_bias_2_pw;
    CONV3: sram_raddr_bias = sram_raddr_bias_3;
    default: sram_raddr_bias = 0;
  endcase


// ---------------------------------------------------------------------------------output selection(except write data)---------------------------------------------------------------------//


// ---------------------------------------------------------------------------------weight3_tmp---------------------------------------------------------------------//

reg [7:0] weight_c0_tmp[0:8];        // cx: original channel  array index: corner
reg [7:0] weight_c1_tmp[0:8];
reg [7:0] weight_c2_tmp[0:8];
reg [7:0] weight_c3_tmp[0:8];
reg [7:0] weight_c4_tmp[0:8];
reg [7:0] weight_c5_tmp[0:8];
reg [7:0] weight_c6_tmp[0:8];
reg [7:0] weight_c7_tmp[0:8];
reg [7:0] weight_c8_tmp[0:8];
reg [7:0] weight_c9_tmp[0:8];
reg [7:0] weight_c10_tmp[0:8];
reg [7:0] weight_c11_tmp[0:8];

// read weight tmp (channel 0)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c0_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd2)) begin
      weight_c0_tmp[0] <= sram_rdata_weight[71:64];
      weight_c0_tmp[1] <= sram_rdata_weight[63:56];
      weight_c0_tmp[2] <= sram_rdata_weight[55:48];
      weight_c0_tmp[3] <= sram_rdata_weight[47:40];
      weight_c0_tmp[4] <= sram_rdata_weight[39:32];
      weight_c0_tmp[5] <= sram_rdata_weight[31:24];
      weight_c0_tmp[6] <= sram_rdata_weight[23:16];
      weight_c0_tmp[7] <= sram_rdata_weight[15:8];
      weight_c0_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c0_tmp[i] <= weight_c0_tmp[i];

// read weight tmp (channel 1)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c1_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd3)) begin
      weight_c1_tmp[0] <= sram_rdata_weight[71:64];
      weight_c1_tmp[1] <= sram_rdata_weight[63:56];
      weight_c1_tmp[2] <= sram_rdata_weight[55:48];
      weight_c1_tmp[3] <= sram_rdata_weight[47:40];
      weight_c1_tmp[4] <= sram_rdata_weight[39:32];
      weight_c1_tmp[5] <= sram_rdata_weight[31:24];
      weight_c1_tmp[6] <= sram_rdata_weight[23:16];
      weight_c1_tmp[7] <= sram_rdata_weight[15:8];
      weight_c1_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c1_tmp[i] <= weight_c1_tmp[i];

// read weight tmp (channel 2)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c2_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd4)) begin
      weight_c2_tmp[0] <= sram_rdata_weight[71:64];
      weight_c2_tmp[1] <= sram_rdata_weight[63:56];
      weight_c2_tmp[2] <= sram_rdata_weight[55:48];
      weight_c2_tmp[3] <= sram_rdata_weight[47:40];
      weight_c2_tmp[4] <= sram_rdata_weight[39:32];
      weight_c2_tmp[5] <= sram_rdata_weight[31:24];
      weight_c2_tmp[6] <= sram_rdata_weight[23:16];
      weight_c2_tmp[7] <= sram_rdata_weight[15:8];
      weight_c2_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c2_tmp[i] <= weight_c2_tmp[i];

// read weight tmp (channel 3)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c3_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd5)) begin
      weight_c3_tmp[0] <= sram_rdata_weight[71:64];
      weight_c3_tmp[1] <= sram_rdata_weight[63:56];
      weight_c3_tmp[2] <= sram_rdata_weight[55:48];
      weight_c3_tmp[3] <= sram_rdata_weight[47:40];
      weight_c3_tmp[4] <= sram_rdata_weight[39:32];
      weight_c3_tmp[5] <= sram_rdata_weight[31:24];
      weight_c3_tmp[6] <= sram_rdata_weight[23:16];
      weight_c3_tmp[7] <= sram_rdata_weight[15:8];
      weight_c3_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c3_tmp[i] <= weight_c3_tmp[i];

// read weight tmp (channel 4)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c4_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd6)) begin
      weight_c4_tmp[0] <= sram_rdata_weight[71:64];
      weight_c4_tmp[1] <= sram_rdata_weight[63:56];
      weight_c4_tmp[2] <= sram_rdata_weight[55:48];
      weight_c4_tmp[3] <= sram_rdata_weight[47:40];
      weight_c4_tmp[4] <= sram_rdata_weight[39:32];
      weight_c4_tmp[5] <= sram_rdata_weight[31:24];
      weight_c4_tmp[6] <= sram_rdata_weight[23:16];
      weight_c4_tmp[7] <= sram_rdata_weight[15:8];
      weight_c4_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c4_tmp[i] <= weight_c4_tmp[i];

// read weight tmp (channel 5)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c5_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd7)) begin
      weight_c5_tmp[0] <= sram_rdata_weight[71:64];
      weight_c5_tmp[1] <= sram_rdata_weight[63:56];
      weight_c5_tmp[2] <= sram_rdata_weight[55:48];
      weight_c5_tmp[3] <= sram_rdata_weight[47:40];
      weight_c5_tmp[4] <= sram_rdata_weight[39:32];
      weight_c5_tmp[5] <= sram_rdata_weight[31:24];
      weight_c5_tmp[6] <= sram_rdata_weight[23:16];
      weight_c5_tmp[7] <= sram_rdata_weight[15:8];
      weight_c5_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c5_tmp[i] <= weight_c5_tmp[i];

// read weight tmp (channel 6)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c6_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd8)) begin
      weight_c6_tmp[0] <= sram_rdata_weight[71:64];
      weight_c6_tmp[1] <= sram_rdata_weight[63:56];
      weight_c6_tmp[2] <= sram_rdata_weight[55:48];
      weight_c6_tmp[3] <= sram_rdata_weight[47:40];
      weight_c6_tmp[4] <= sram_rdata_weight[39:32];
      weight_c6_tmp[5] <= sram_rdata_weight[31:24];
      weight_c6_tmp[6] <= sram_rdata_weight[23:16];
      weight_c6_tmp[7] <= sram_rdata_weight[15:8];
      weight_c6_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c6_tmp[i] <= weight_c6_tmp[i];

// read weight tmp (channel 7)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c7_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd9)) begin
      weight_c7_tmp[0] <= sram_rdata_weight[71:64];
      weight_c7_tmp[1] <= sram_rdata_weight[63:56];
      weight_c7_tmp[2] <= sram_rdata_weight[55:48];
      weight_c7_tmp[3] <= sram_rdata_weight[47:40];
      weight_c7_tmp[4] <= sram_rdata_weight[39:32];
      weight_c7_tmp[5] <= sram_rdata_weight[31:24];
      weight_c7_tmp[6] <= sram_rdata_weight[23:16];
      weight_c7_tmp[7] <= sram_rdata_weight[15:8];
      weight_c7_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c7_tmp[i] <= weight_c7_tmp[i];

// read weight tmp (channel 8)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c8_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd10)) begin
      weight_c8_tmp[0] <= sram_rdata_weight[71:64];
      weight_c8_tmp[1] <= sram_rdata_weight[63:56];
      weight_c8_tmp[2] <= sram_rdata_weight[55:48];
      weight_c8_tmp[3] <= sram_rdata_weight[47:40];
      weight_c8_tmp[4] <= sram_rdata_weight[39:32];
      weight_c8_tmp[5] <= sram_rdata_weight[31:24];
      weight_c8_tmp[6] <= sram_rdata_weight[23:16];
      weight_c8_tmp[7] <= sram_rdata_weight[15:8];
      weight_c8_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c8_tmp[i] <= weight_c8_tmp[i];

// read weight tmp (channel 9)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c9_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd11)) begin
      weight_c9_tmp[0] <= sram_rdata_weight[71:64];
      weight_c9_tmp[1] <= sram_rdata_weight[63:56];
      weight_c9_tmp[2] <= sram_rdata_weight[55:48];
      weight_c9_tmp[3] <= sram_rdata_weight[47:40];
      weight_c9_tmp[4] <= sram_rdata_weight[39:32];
      weight_c9_tmp[5] <= sram_rdata_weight[31:24];
      weight_c9_tmp[6] <= sram_rdata_weight[23:16];
      weight_c9_tmp[7] <= sram_rdata_weight[15:8];
      weight_c9_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c9_tmp[i] <= weight_c9_tmp[i];

// read weight tmp (channel 10)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c10_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd12)) begin
      weight_c10_tmp[0] <= sram_rdata_weight[71:64];
      weight_c10_tmp[1] <= sram_rdata_weight[63:56];
      weight_c10_tmp[2] <= sram_rdata_weight[55:48];
      weight_c10_tmp[3] <= sram_rdata_weight[47:40];
      weight_c10_tmp[4] <= sram_rdata_weight[39:32];
      weight_c10_tmp[5] <= sram_rdata_weight[31:24];
      weight_c10_tmp[6] <= sram_rdata_weight[23:16];
      weight_c10_tmp[7] <= sram_rdata_weight[15:8];
      weight_c10_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c10_tmp[i] <= weight_c10_tmp[i];

// read weight tmp (channel 11)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c11_tmp[i] <= 0;
  else
    if((state == CONV3) && (conv_cnt_3 == 6'd13)) begin
      weight_c11_tmp[0] <= sram_rdata_weight[71:64];
      weight_c11_tmp[1] <= sram_rdata_weight[63:56];
      weight_c11_tmp[2] <= sram_rdata_weight[55:48];
      weight_c11_tmp[3] <= sram_rdata_weight[47:40];
      weight_c11_tmp[4] <= sram_rdata_weight[39:32];
      weight_c11_tmp[5] <= sram_rdata_weight[31:24];
      weight_c11_tmp[6] <= sram_rdata_weight[23:16];
      weight_c11_tmp[7] <= sram_rdata_weight[15:8];
      weight_c11_tmp[8] <= sram_rdata_weight[7:0];
    end
    else
      for(i = 0; i < 9; i = i+1)
        weight_c11_tmp[i] <= weight_c11_tmp[i];
// ---------------------------------------------------------------------------------weight3_tmp---------------------------------------------------------------------//



// ---------------------------------------------------------------------------------global weight---------------------------------------------------------------------//
reg [7:0] weight_c0[0:8];
// read weight (channel 0)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c0[i] <= 0;
  else
    case(state)
      CONV1_DW: begin
	    if(read_cnt_1_dw == 4'd1) begin
	      weight_c0[0] <= sram_rdata_weight[71:64];
	      weight_c0[1] <= sram_rdata_weight[63:56];
	      weight_c0[2] <= sram_rdata_weight[55:48];
	      weight_c0[3] <= sram_rdata_weight[47:40];
	      weight_c0[4] <= sram_rdata_weight[39:32];
	      weight_c0[5] <= sram_rdata_weight[31:24];
	      weight_c0[6] <= sram_rdata_weight[23:16];
	      weight_c0[7] <= sram_rdata_weight[15:8];
	      weight_c0[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c0[i] <= weight_c0[i];
      end
      CONV2_DW: begin
	    if(read_cnt_2_dw == 4'd1) begin
	      weight_c0[0] <= sram_rdata_weight[71:64];
	      weight_c0[1] <= sram_rdata_weight[63:56];
	      weight_c0[2] <= sram_rdata_weight[55:48];
	      weight_c0[3] <= sram_rdata_weight[47:40];
	      weight_c0[4] <= sram_rdata_weight[39:32];
	      weight_c0[5] <= sram_rdata_weight[31:24];
	      weight_c0[6] <= sram_rdata_weight[23:16];
	      weight_c0[7] <= sram_rdata_weight[15:8];
	      weight_c0[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c0[i] <= weight_c0[i];
      end
      CONV3: begin
	    if(read_cnt_3 == 4'd1) begin
	      weight_c0[0] <= sram_rdata_weight[71:64];
	      weight_c0[1] <= sram_rdata_weight[63:56];
	      weight_c0[2] <= sram_rdata_weight[55:48];
	      weight_c0[3] <= sram_rdata_weight[47:40];
	      weight_c0[4] <= sram_rdata_weight[39:32];
	      weight_c0[5] <= sram_rdata_weight[31:24];
	      weight_c0[6] <= sram_rdata_weight[23:16];
	      weight_c0[7] <= sram_rdata_weight[15:8];
	      weight_c0[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c0[i] <= weight_c0_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c0[i] <= weight_c0[i];

      end
      CONV1_PW: begin
	    if(read_cnt_1_pw == 4'd1) begin
	      weight_c0[0] <= sram_rdata_weight[71:64];
	      weight_c0[1] <= sram_rdata_weight[63:56];
	      weight_c0[2] <= sram_rdata_weight[55:48];
	      weight_c0[3] <= sram_rdata_weight[47:40];
	      weight_c0[4] <= weight_c0[4];
	      weight_c0[5] <= weight_c0[5];
	      weight_c0[6] <= weight_c0[6];
	      weight_c0[7] <= weight_c0[7];
	      weight_c0[8] <= weight_c0[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c0[i] <= weight_c0[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd1) begin
	      weight_c0[0] <= sram_rdata_weight[71:64];
	      weight_c0[1] <= sram_rdata_weight[63:56];
	      weight_c0[2] <= sram_rdata_weight[55:48];
	      weight_c0[3] <= sram_rdata_weight[47:40];
	      weight_c0[4] <= weight_c0[4];
	      weight_c0[5] <= weight_c0[5];
	      weight_c0[6] <= weight_c0[6];
	      weight_c0[7] <= weight_c0[7];
	      weight_c0[8] <= weight_c0[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c0[i] <= weight_c0[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c0[i] <= weight_c0[i];
    endcase


        
reg [7:0] weight_c1[0:8];
// read weight (channel 1)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c1[i] <= 0;
  else
    case(state)
      CONV1_DW: begin
	    if(read_cnt_1_dw == 4'd2) begin
	      weight_c1[0] <= sram_rdata_weight[71:64];
	      weight_c1[1] <= sram_rdata_weight[63:56];
	      weight_c1[2] <= sram_rdata_weight[55:48];
	      weight_c1[3] <= sram_rdata_weight[47:40];
	      weight_c1[4] <= sram_rdata_weight[39:32];
	      weight_c1[5] <= sram_rdata_weight[31:24];
	      weight_c1[6] <= sram_rdata_weight[23:16];
	      weight_c1[7] <= sram_rdata_weight[15:8];
	      weight_c1[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c1[i] <= weight_c1[i];
      end
      CONV2_DW: begin
	    if(read_cnt_2_dw == 4'd2) begin
	      weight_c1[0] <= sram_rdata_weight[71:64];
	      weight_c1[1] <= sram_rdata_weight[63:56];
	      weight_c1[2] <= sram_rdata_weight[55:48];
	      weight_c1[3] <= sram_rdata_weight[47:40];
	      weight_c1[4] <= sram_rdata_weight[39:32];
	      weight_c1[5] <= sram_rdata_weight[31:24];
	      weight_c1[6] <= sram_rdata_weight[23:16];
	      weight_c1[7] <= sram_rdata_weight[15:8];
	      weight_c1[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c1[i] <= weight_c1[i];
      end
      CONV3: begin
	    if(read_cnt_3 == 4'd2) begin
	      weight_c1[0] <= sram_rdata_weight[71:64];
	      weight_c1[1] <= sram_rdata_weight[63:56];
	      weight_c1[2] <= sram_rdata_weight[55:48];
	      weight_c1[3] <= sram_rdata_weight[47:40];
	      weight_c1[4] <= sram_rdata_weight[39:32];
	      weight_c1[5] <= sram_rdata_weight[31:24];
	      weight_c1[6] <= sram_rdata_weight[23:16];
	      weight_c1[7] <= sram_rdata_weight[15:8];
	      weight_c1[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c1[i] <= weight_c1_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c1[i] <= weight_c1[i];

      end
      CONV1_PW: begin
	    if(read_cnt_1_pw == 4'd1) begin
	      weight_c1[0] <= sram_rdata_weight[39:32];
	      weight_c1[1] <= sram_rdata_weight[31:24];
	      weight_c1[2] <= sram_rdata_weight[23:16];
	      weight_c1[3] <= sram_rdata_weight[15:8];
	      weight_c1[4] <= weight_c1[4];
	      weight_c1[5] <= weight_c1[5];
	      weight_c1[6] <= weight_c1[6];
	      weight_c1[7] <= weight_c1[7];
	      weight_c1[8] <= weight_c1[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c1[i] <= weight_c1[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd1) begin
	      weight_c1[0] <= sram_rdata_weight[39:32];
	      weight_c1[1] <= sram_rdata_weight[31:24];
	      weight_c1[2] <= sram_rdata_weight[23:16];
	      weight_c1[3] <= sram_rdata_weight[15:8];
	      weight_c1[4] <= weight_c1[4];
	      weight_c1[5] <= weight_c1[5];
	      weight_c1[6] <= weight_c1[6];
	      weight_c1[7] <= weight_c1[7];
	      weight_c1[8] <= weight_c1[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c1[i] <= weight_c1[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c1[i] <= weight_c1[i];
    endcase


reg [7:0] weight_c2[0:8];

// read weight (channel 2)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c2[i] <= 0;
  else
    case(state)
      CONV1_DW: begin
	    if(read_cnt_1_dw == 4'd3) begin
	      weight_c2[0] <= sram_rdata_weight[71:64];
	      weight_c2[1] <= sram_rdata_weight[63:56];
	      weight_c2[2] <= sram_rdata_weight[55:48];
	      weight_c2[3] <= sram_rdata_weight[47:40];
	      weight_c2[4] <= sram_rdata_weight[39:32];
	      weight_c2[5] <= sram_rdata_weight[31:24];
	      weight_c2[6] <= sram_rdata_weight[23:16];
	      weight_c2[7] <= sram_rdata_weight[15:8];
	      weight_c2[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c2[i] <= weight_c2[i];
      end
      CONV2_DW: begin
	    if(read_cnt_2_dw == 4'd3) begin
	      weight_c2[0] <= sram_rdata_weight[71:64];
	      weight_c2[1] <= sram_rdata_weight[63:56];
	      weight_c2[2] <= sram_rdata_weight[55:48];
	      weight_c2[3] <= sram_rdata_weight[47:40];
	      weight_c2[4] <= sram_rdata_weight[39:32];
	      weight_c2[5] <= sram_rdata_weight[31:24];
	      weight_c2[6] <= sram_rdata_weight[23:16];
	      weight_c2[7] <= sram_rdata_weight[15:8];
	      weight_c2[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c2[i] <= weight_c2[i];
      end
      CONV3: begin
	    if(read_cnt_3 == 4'd3) begin
	      weight_c2[0] <= sram_rdata_weight[71:64];
	      weight_c2[1] <= sram_rdata_weight[63:56];
	      weight_c2[2] <= sram_rdata_weight[55:48];
	      weight_c2[3] <= sram_rdata_weight[47:40];
	      weight_c2[4] <= sram_rdata_weight[39:32];
	      weight_c2[5] <= sram_rdata_weight[31:24];
	      weight_c2[6] <= sram_rdata_weight[23:16];
	      weight_c2[7] <= sram_rdata_weight[15:8];
	      weight_c2[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c2[i] <= weight_c2_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c2[i] <= weight_c2[i];
      end
      CONV1_PW: begin
	    if(read_cnt_1_pw == 4'd1) begin
	      weight_c2[0] <= sram_rdata_weight[7:0];
	      weight_c2[1] <= weight_c2[1];
	      weight_c2[2] <= weight_c2[2];
	      weight_c2[3] <= weight_c2[3];
	      weight_c2[4] <= weight_c2[4];
	      weight_c2[5] <= weight_c2[5];
	      weight_c2[6] <= weight_c2[6];
	      weight_c2[7] <= weight_c2[7];
	      weight_c2[8] <= weight_c2[8];
	    end
	    else if(read_cnt_1_pw == 4'd2) begin
	      weight_c2[0] <= weight_c2[0];
	      weight_c2[1] <= sram_rdata_weight[71:64];
	      weight_c2[2] <= sram_rdata_weight[63:56];
	      weight_c2[3] <= sram_rdata_weight[55:48];
	      weight_c2[4] <= weight_c2[4];
	      weight_c2[5] <= weight_c2[5];
	      weight_c2[6] <= weight_c2[6];
	      weight_c2[7] <= weight_c2[7];
	      weight_c2[8] <= weight_c2[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c2[i] <= weight_c2[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd1) begin
	      weight_c2[0] <= sram_rdata_weight[7:0];
	      weight_c2[1] <= weight_c2[1];
	      weight_c2[2] <= weight_c2[2];
	      weight_c2[3] <= weight_c2[3];
	      weight_c2[4] <= weight_c2[4];
	      weight_c2[5] <= weight_c2[5];
	      weight_c2[6] <= weight_c2[6];
	      weight_c2[7] <= weight_c2[7];
	      weight_c2[8] <= weight_c2[8];
	    end
	    else if(read_cnt_2_pw == 4'd2) begin
	      weight_c2[0] <= weight_c2[0];
	      weight_c2[1] <= sram_rdata_weight[71:64];
	      weight_c2[2] <= sram_rdata_weight[63:56];
	      weight_c2[3] <= sram_rdata_weight[55:48];
	      weight_c2[4] <= weight_c2[4];
	      weight_c2[5] <= weight_c2[5];
	      weight_c2[6] <= weight_c2[6];
	      weight_c2[7] <= weight_c2[7];
	      weight_c2[8] <= weight_c2[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c2[i] <= weight_c2[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c2[i] <= weight_c2[i];
    endcase

reg [7:0] weight_c3[0:8];
// read weight (channel 3)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c3[i] <= 0;
  else
    case(state)
      CONV1_DW: begin
	    if(read_cnt_1_dw == 4'd4) begin
	      weight_c3[0] <= sram_rdata_weight[71:64];
	      weight_c3[1] <= sram_rdata_weight[63:56];
	      weight_c3[2] <= sram_rdata_weight[55:48];
	      weight_c3[3] <= sram_rdata_weight[47:40];
	      weight_c3[4] <= sram_rdata_weight[39:32];
	      weight_c3[5] <= sram_rdata_weight[31:24];
	      weight_c3[6] <= sram_rdata_weight[23:16];
	      weight_c3[7] <= sram_rdata_weight[15:8];
	      weight_c3[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c3[i] <= weight_c3[i];
      end
      CONV2_DW: begin
	    if(read_cnt_2_dw == 4'd4) begin
	      weight_c3[0] <= sram_rdata_weight[71:64];
	      weight_c3[1] <= sram_rdata_weight[63:56];
	      weight_c3[2] <= sram_rdata_weight[55:48];
	      weight_c3[3] <= sram_rdata_weight[47:40];
	      weight_c3[4] <= sram_rdata_weight[39:32];
	      weight_c3[5] <= sram_rdata_weight[31:24];
	      weight_c3[6] <= sram_rdata_weight[23:16];
	      weight_c3[7] <= sram_rdata_weight[15:8];
	      weight_c3[8] <= sram_rdata_weight[7:0];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c3[i] <= weight_c3[i];
      end
      CONV3: begin
	    if(read_cnt_3 == 4'd4) begin
	      weight_c3[0] <= sram_rdata_weight[71:64];
	      weight_c3[1] <= sram_rdata_weight[63:56];
	      weight_c3[2] <= sram_rdata_weight[55:48];
	      weight_c3[3] <= sram_rdata_weight[47:40];
	      weight_c3[4] <= sram_rdata_weight[39:32];
	      weight_c3[5] <= sram_rdata_weight[31:24];
	      weight_c3[6] <= sram_rdata_weight[23:16];
	      weight_c3[7] <= sram_rdata_weight[15:8];
	      weight_c3[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c3[i] <= weight_c3_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c3[i] <= weight_c3[i];
      end
      CONV1_PW: begin
	    if(read_cnt_1_pw == 4'd2) begin
	      weight_c3[0] <= sram_rdata_weight[47:40];
	      weight_c3[1] <= sram_rdata_weight[39:32];
	      weight_c3[2] <= sram_rdata_weight[31:24];
	      weight_c3[3] <= sram_rdata_weight[23:16];
	      weight_c3[4] <= weight_c3[4];
	      weight_c3[5] <= weight_c3[5];
	      weight_c3[6] <= weight_c3[6];
	      weight_c3[7] <= weight_c3[7];
	      weight_c3[8] <= weight_c3[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c3[i] <= weight_c3[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd2) begin
	      weight_c3[0] <= sram_rdata_weight[47:40];
	      weight_c3[1] <= sram_rdata_weight[39:32];
	      weight_c3[2] <= sram_rdata_weight[31:24];
	      weight_c3[3] <= sram_rdata_weight[23:16];
	      weight_c3[4] <= weight_c3[4];
	      weight_c3[5] <= weight_c3[5];
	      weight_c3[6] <= weight_c3[6];
	      weight_c3[7] <= weight_c3[7];
	      weight_c3[8] <= weight_c3[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c3[i] <= weight_c3[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c3[i] <= weight_c3[i];
    endcase


reg [7:0] weight_c4[0:8];
// read weight (channel 4)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c4[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd5) begin
	      weight_c4[0] <= sram_rdata_weight[71:64];
	      weight_c4[1] <= sram_rdata_weight[63:56];
	      weight_c4[2] <= sram_rdata_weight[55:48];
	      weight_c4[3] <= sram_rdata_weight[47:40];
	      weight_c4[4] <= sram_rdata_weight[39:32];
	      weight_c4[5] <= sram_rdata_weight[31:24];
	      weight_c4[6] <= sram_rdata_weight[23:16];
	      weight_c4[7] <= sram_rdata_weight[15:8];
	      weight_c4[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c4[i] <= weight_c4_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c4[i] <= weight_c4[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd3) begin
	      weight_c4[0] <= sram_rdata_weight[71:64];
	      weight_c4[1] <= sram_rdata_weight[63:56];
	      weight_c4[2] <= sram_rdata_weight[55:48];
	      weight_c4[3] <= sram_rdata_weight[47:40];
	      weight_c4[4] <= weight_c4[4];
	      weight_c4[5] <= weight_c4[5];
	      weight_c4[6] <= weight_c4[6];
	      weight_c4[7] <= weight_c4[7];
	      weight_c4[8] <= weight_c4[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c4[i] <= weight_c4[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c4[i] <= weight_c4[i];
    endcase

reg [7:0] weight_c5[0:8];
// read weight (channel 5)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c5[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd6) begin
	      weight_c5[0] <= sram_rdata_weight[71:64];
	      weight_c5[1] <= sram_rdata_weight[63:56];
	      weight_c5[2] <= sram_rdata_weight[55:48];
	      weight_c5[3] <= sram_rdata_weight[47:40];
	      weight_c5[4] <= sram_rdata_weight[39:32];
	      weight_c5[5] <= sram_rdata_weight[31:24];
	      weight_c5[6] <= sram_rdata_weight[23:16];
	      weight_c5[7] <= sram_rdata_weight[15:8];
	      weight_c5[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c5[i] <= weight_c5_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c5[i] <= weight_c5[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd3) begin
	      weight_c5[0] <= sram_rdata_weight[39:32];
	      weight_c5[1] <= sram_rdata_weight[31:24];
	      weight_c5[2] <= sram_rdata_weight[23:16];
	      weight_c5[3] <= sram_rdata_weight[15:8];
	      weight_c5[4] <= weight_c5[4];
	      weight_c5[5] <= weight_c5[5];
	      weight_c5[6] <= weight_c5[6];
	      weight_c5[7] <= weight_c5[7];
	      weight_c5[8] <= weight_c5[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c5[i] <= weight_c5[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c5[i] <= weight_c5[i];
    endcase

reg [7:0] weight_c6[0:8];
// read weight (channel 6)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c6[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd7) begin
	      weight_c6[0] <= sram_rdata_weight[71:64];
	      weight_c6[1] <= sram_rdata_weight[63:56];
	      weight_c6[2] <= sram_rdata_weight[55:48];
	      weight_c6[3] <= sram_rdata_weight[47:40];
	      weight_c6[4] <= sram_rdata_weight[39:32];
	      weight_c6[5] <= sram_rdata_weight[31:24];
	      weight_c6[6] <= sram_rdata_weight[23:16];
	      weight_c6[7] <= sram_rdata_weight[15:8];
	      weight_c6[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c6[i] <= weight_c6_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c6[i] <= weight_c6[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd3) begin
	      weight_c6[0] <= sram_rdata_weight[7:0];
	      weight_c6[1] <= weight_c6[1];
	      weight_c6[2] <= weight_c6[2];
	      weight_c6[3] <= weight_c6[3];
	      weight_c6[4] <= weight_c6[4];
	      weight_c6[5] <= weight_c6[5];
	      weight_c6[6] <= weight_c6[6];
	      weight_c6[7] <= weight_c6[7];
	      weight_c6[8] <= weight_c6[8];
	    end
	    else if(read_cnt_2_pw == 4'd4) begin
	      weight_c6[0] <= weight_c6[0];
	      weight_c6[1] <= sram_rdata_weight[71:64];
	      weight_c6[2] <= sram_rdata_weight[63:56];
	      weight_c6[3] <= sram_rdata_weight[55:48];
	      weight_c6[4] <= weight_c6[4];
	      weight_c6[5] <= weight_c6[5];
	      weight_c6[6] <= weight_c6[6];
	      weight_c6[7] <= weight_c6[7];
	      weight_c6[8] <= weight_c6[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c6[i] <= weight_c6[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c6[i] <= weight_c6[i];
    endcase

reg [7:0] weight_c7[0:8];
// read weight (channel 7)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c7[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd8) begin
	      weight_c7[0] <= sram_rdata_weight[71:64];
	      weight_c7[1] <= sram_rdata_weight[63:56];
	      weight_c7[2] <= sram_rdata_weight[55:48];
	      weight_c7[3] <= sram_rdata_weight[47:40];
	      weight_c7[4] <= sram_rdata_weight[39:32];
	      weight_c7[5] <= sram_rdata_weight[31:24];
	      weight_c7[6] <= sram_rdata_weight[23:16];
	      weight_c7[7] <= sram_rdata_weight[15:8];
	      weight_c7[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c7[i] <= weight_c7_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c7[i] <= weight_c7[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd4) begin
	      weight_c7[0] <= sram_rdata_weight[47:40];
	      weight_c7[1] <= sram_rdata_weight[39:32];
	      weight_c7[2] <= sram_rdata_weight[31:24];
	      weight_c7[3] <= sram_rdata_weight[23:16];
	      weight_c7[4] <= weight_c7[4];
	      weight_c7[5] <= weight_c7[5];
	      weight_c7[6] <= weight_c7[6];
	      weight_c7[7] <= weight_c7[7];
	      weight_c7[8] <= weight_c7[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c7[i] <= weight_c7[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c7[i] <= weight_c7[i];
    endcase

reg [7:0] weight_c8[0:8];
// read weight (channel 8)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c8[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd9) begin
	      weight_c8[0] <= sram_rdata_weight[71:64];
	      weight_c8[1] <= sram_rdata_weight[63:56];
	      weight_c8[2] <= sram_rdata_weight[55:48];
	      weight_c8[3] <= sram_rdata_weight[47:40];
	      weight_c8[4] <= sram_rdata_weight[39:32];
	      weight_c8[5] <= sram_rdata_weight[31:24];
	      weight_c8[6] <= sram_rdata_weight[23:16];
	      weight_c8[7] <= sram_rdata_weight[15:8];
	      weight_c8[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c8[i] <= weight_c8_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c8[i] <= weight_c8[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd5) begin
	      weight_c8[0] <= sram_rdata_weight[71:64];
	      weight_c8[1] <= sram_rdata_weight[63:56];
	      weight_c8[2] <= sram_rdata_weight[55:48];
	      weight_c8[3] <= sram_rdata_weight[47:40];
	      weight_c8[4] <= weight_c8[4];
	      weight_c8[5] <= weight_c8[5];
	      weight_c8[6] <= weight_c8[6];
	      weight_c8[7] <= weight_c8[7];
	      weight_c8[8] <= weight_c8[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c8[i] <= weight_c8[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c8[i] <= weight_c8[i];
    endcase

reg [7:0] weight_c9[0:8];
// read weight (channel 9)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c9[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd10) begin
	      weight_c9[0] <= sram_rdata_weight[71:64];
	      weight_c9[1] <= sram_rdata_weight[63:56];
	      weight_c9[2] <= sram_rdata_weight[55:48];
	      weight_c9[3] <= sram_rdata_weight[47:40];
	      weight_c9[4] <= sram_rdata_weight[39:32];
	      weight_c9[5] <= sram_rdata_weight[31:24];
	      weight_c9[6] <= sram_rdata_weight[23:16];
	      weight_c9[7] <= sram_rdata_weight[15:8];
	      weight_c9[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c9[i] <= weight_c9_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c9[i] <= weight_c9[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd5) begin
	      weight_c9[0] <= sram_rdata_weight[39:32];
	      weight_c9[1] <= sram_rdata_weight[31:24];
	      weight_c9[2] <= sram_rdata_weight[23:16];
	      weight_c9[3] <= sram_rdata_weight[15:8];
	      weight_c9[4] <= weight_c9[4];
	      weight_c9[5] <= weight_c9[5];
	      weight_c9[6] <= weight_c9[6];
	      weight_c9[7] <= weight_c9[7];
	      weight_c9[8] <= weight_c9[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c9[i] <= weight_c9[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c9[i] <= weight_c9[i];
    endcase

reg [7:0] weight_c10[0:8];
// read weight (channel 10)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c10[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd11) begin
	      weight_c10[0] <= sram_rdata_weight[71:64];
	      weight_c10[1] <= sram_rdata_weight[63:56];
	      weight_c10[2] <= sram_rdata_weight[55:48];
	      weight_c10[3] <= sram_rdata_weight[47:40];
	      weight_c10[4] <= sram_rdata_weight[39:32];
	      weight_c10[5] <= sram_rdata_weight[31:24];
	      weight_c10[6] <= sram_rdata_weight[23:16];
	      weight_c10[7] <= sram_rdata_weight[15:8];
	      weight_c10[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c10[i] <= weight_c10_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c10[i] <= weight_c10[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd5) begin
	      weight_c10[0] <= sram_rdata_weight[7:0];
	      weight_c10[1] <= weight_c10[1];
	      weight_c10[2] <= weight_c10[2];
	      weight_c10[3] <= weight_c10[3];
	      weight_c10[4] <= weight_c10[4];
	      weight_c10[5] <= weight_c10[5];
	      weight_c10[6] <= weight_c10[6];
	      weight_c10[7] <= weight_c10[7];
	      weight_c10[8] <= weight_c10[8];
	    end
	    else if(read_cnt_2_pw == 4'd6) begin
	      weight_c10[0] <= weight_c10[0];
	      weight_c10[1] <= sram_rdata_weight[71:64];
	      weight_c10[2] <= sram_rdata_weight[63:56];
	      weight_c10[3] <= sram_rdata_weight[55:48];
	      weight_c10[4] <= weight_c10[4];
	      weight_c10[5] <= weight_c10[5];
	      weight_c10[6] <= weight_c10[6];
	      weight_c10[7] <= weight_c10[7];
	      weight_c10[8] <= weight_c10[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c10[i] <= weight_c10[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c10[i] <= weight_c10[i];
    endcase

reg [7:0] weight_c11[0:8];
// read weight (channel 11)
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 9; i = i+1)
      weight_c11[i] <= 0;
  else
    case(state)
      CONV3: begin
	    if(read_cnt_3 == 4'd12) begin
	      weight_c11[0] <= sram_rdata_weight[71:64];
	      weight_c11[1] <= sram_rdata_weight[63:56];
	      weight_c11[2] <= sram_rdata_weight[55:48];
	      weight_c11[3] <= sram_rdata_weight[47:40];
	      weight_c11[4] <= sram_rdata_weight[39:32];
	      weight_c11[5] <= sram_rdata_weight[31:24];
	      weight_c11[6] <= sram_rdata_weight[23:16];
	      weight_c11[7] <= sram_rdata_weight[15:8];
	      weight_c11[8] <= sram_rdata_weight[7:0];
	    end
	    else if(conv_complete_3_delay)
              for(i = 0; i < 9; i = i+1)
                weight_c11[i] <= weight_c11_tmp[i];
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c11[i] <= weight_c11[i];
      end
      CONV2_PW: begin
	    if(read_cnt_2_pw == 4'd6) begin
	      weight_c11[0] <= sram_rdata_weight[47:40];
	      weight_c11[1] <= sram_rdata_weight[39:32];
	      weight_c11[2] <= sram_rdata_weight[31:24];
	      weight_c11[3] <= sram_rdata_weight[23:16];
	      weight_c11[4] <= weight_c11[4];
	      weight_c11[5] <= weight_c11[5];
	      weight_c11[6] <= weight_c11[6];
	      weight_c11[7] <= weight_c11[7];
	      weight_c11[8] <= weight_c11[8];
	    end
	    else
	      for(i = 0; i < 9; i = i+1)
		weight_c11[i] <= weight_c11[i];
      end
      default:
        for(i = 0; i < 9; i = i+1)
          weight_c11[i] <= weight_c11[i];
    endcase
// ---------------------------------------------------------------------------------global weight---------------------------------------------------------------------//




// ---------------------------------------------------------------------------------convolution input selection---------------------------------------------------------------------//
// multipier weight input
reg [7:0] weight_0_in [0:8];
reg [7:0] weight_1_in [0:8];
reg [7:0] weight_2_in [0:8];
reg [7:0] weight_3_in [0:8];
always@(posedge clk)
  if(~srst_n)begin
    for(i = 0; i < 9; i = i+1)
      weight_0_in[i] <= 0;
    for(i = 0; i < 9; i = i+1)
      weight_1_in[i] <= 0;
    for(i = 0; i < 9; i = i+1)
      weight_2_in[i] <= 0;
    for(i = 0; i < 9; i = i+1)
      weight_3_in[i] <= 0;
  end
  
  else
  case(state)
    CONV1_DW: begin
      for(i = 0; i < 9; i = i+1)
        weight_0_in[i] <= weight_c0[i];
      for(i = 0; i < 9; i = i+1)
        weight_1_in[i] <= weight_c1[i];
      for(i = 0; i < 9; i = i+1)
        weight_2_in[i] <= weight_c2[i];
      for(i = 0; i < 9; i = i+1)
        weight_3_in[i] <= weight_c3[i];
    end
    CONV1_PW: begin
      for(i = 0; i < 9; i = i+1)
        weight_0_in[i] <= weight_c0[i];
      for(i = 0; i < 9; i = i+1)
        weight_1_in[i] <= weight_c1[i];
      for(i = 0; i < 9; i = i+1)
        weight_2_in[i] <= weight_c2[i];
      for(i = 0; i < 9; i = i+1)
        weight_3_in[i] <= weight_c3[i];
    end
    CONV2_DW: begin
      for(i = 0; i < 9; i = i+1)
        weight_0_in[i] <= weight_c0[i];
      for(i = 0; i < 9; i = i+1)
        weight_1_in[i] <= weight_c1[i];
      for(i = 0; i < 9; i = i+1)
        weight_2_in[i] <= weight_c2[i];
      for(i = 0; i < 9; i = i+1)
        weight_3_in[i] <= weight_c3[i];
    end

    CONV2_PW:
      case(mode_2_pw)
        2'd0: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= weight_c0[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= weight_c1[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= weight_c2[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= weight_c3[i];
	end
        2'd1: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= weight_c4[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= weight_c5[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= weight_c6[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= weight_c7[i];
	end
        2'd2: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= weight_c8[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= weight_c9[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= weight_c10[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= weight_c11[i];
	end
        default: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= 0;
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= 0;
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= 0;
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= 0;
	end
     endcase
    CONV3:
      case(mode_delay_3)
        2'd0: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= weight_c0[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= weight_c1[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= weight_c2[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= weight_c3[i];
	end
        2'd1: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= weight_c4[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= weight_c5[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= weight_c6[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= weight_c7[i];
	end
        2'd2: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= weight_c8[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= weight_c9[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= weight_c10[i];
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= weight_c11[i];
	end
        default: begin
	  for(i = 0; i < 9; i = i+1)
            weight_0_in[i] <= 0;
	  for(i = 0; i < 9; i = i+1)
	    weight_1_in[i] <= 0;
	  for(i = 0; i < 9; i = i+1)
	    weight_2_in[i] <= 0;
	  for(i = 0; i < 9; i = i+1)
	    weight_3_in[i] <= 0;
	end
     endcase
    default: begin
      for(i = 0; i < 9; i = i+1)
        weight_0_in[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        weight_1_in[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        weight_2_in[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        weight_3_in[i] <= 0;
    end
  endcase



// bias input
reg signed [7:0] bias_0_in;
reg signed [7:0] bias_1_in;
reg signed [7:0] bias_2_in;
reg signed [7:0] bias_3_in;

always@*
  case(state)
    CONV1_DW: begin
      bias_0_in = bias_0_1_dw;
      bias_1_in = bias_1_1_dw;
      bias_2_in = bias_2_1_dw;
      bias_3_in = bias_3_1_dw;
    end
    CONV1_PW: begin
      bias_0_in = bias_0_1_pw;
      bias_1_in = bias_1_1_pw;
      bias_2_in = bias_2_1_pw;
      bias_3_in = bias_3_1_pw;
    end
    CONV2_DW: begin
      bias_0_in = bias_0_2_dw;
      bias_1_in = bias_1_2_dw;
      bias_2_in = bias_2_2_dw;
      bias_3_in = bias_3_2_dw;
    end
    CONV2_PW:
      case(mode_2_pw_delay_3)
        2'd0: begin
          bias_0_in = bias_0_2_pw;
          bias_1_in = bias_1_2_pw;
          bias_2_in = bias_2_2_pw;
          bias_3_in = bias_3_2_pw;
        end
        2'd1: begin
          bias_0_in = bias_4_2_pw;
          bias_1_in = bias_5_2_pw;
          bias_2_in = bias_6_2_pw;
          bias_3_in = bias_7_2_pw;
        end
        2'd2: begin
          bias_0_in = bias_8_2_pw;
          bias_1_in = bias_9_2_pw;
          bias_2_in = bias_10_2_pw;
          bias_3_in = bias_11_2_pw;
        end
        default: begin
          bias_0_in = 0;
          bias_1_in = 0;
          bias_2_in = 0;
          bias_3_in = 0;
        end
      endcase
    CONV3: begin
      bias_0_in = bias_in_3;
      bias_1_in = 0;
      bias_2_in = 0;
      bias_3_in = 0;
    end
    default: begin
      bias_0_in = 0;
      bias_1_in = 0;
      bias_2_in = 0;
      bias_3_in = 0;
    end
  endcase

// bank mode delay in  (for dw)
reg [1:0] bank_mode_delay;
always@*
  case(state)
    CONV1_DW: bank_mode_delay = bank_mode_delay_1_dw;
    CONV2_DW: bank_mode_delay = bank_mode_delay_2_dw;
    CONV3: bank_mode_delay = bank_mode_delay_3;
    default: bank_mode_delay = 0;
  endcase

// conv delay in (for pw)
reg [1:0] conv_cnt_delay_pw;
always@*
  case(state)
    CONV1_PW: conv_cnt_delay_pw = conv_cnt_delay_1_pw;
    CONV2_PW: conv_cnt_delay_pw = conv_cnt_delay_2_pw;
    default: conv_cnt_delay_pw = 0;
  endcase


// multiplier input selection (dw)
reg [11:0] sram_rdata_in_0_c0 [0:8];
reg [11:0] sram_rdata_in_1_c0 [0:8];
reg [11:0] sram_rdata_in_2_c0 [0:8];
reg [11:0] sram_rdata_in_3_c0 [0:8];
reg [11:0] sram_rdata_in_0_c1 [0:8];
reg [11:0] sram_rdata_in_1_c1 [0:8];
reg [11:0] sram_rdata_in_2_c1 [0:8];
reg [11:0] sram_rdata_in_3_c1 [0:8];
reg [11:0] sram_rdata_in_0_c2 [0:8];
reg [11:0] sram_rdata_in_1_c2 [0:8];
reg [11:0] sram_rdata_in_2_c2 [0:8];
reg [11:0] sram_rdata_in_3_c2 [0:8];
reg [11:0] sram_rdata_in_0_c3 [0:8];
reg [11:0] sram_rdata_in_1_c3 [0:8];
reg [11:0] sram_rdata_in_2_c3 [0:8];
reg [11:0] sram_rdata_in_3_c3 [0:8];


// channel (0/4/8) (dw)
always@*
  case(bank_mode_delay)
    2'd0: begin
      sram_rdata_in_0_c0[0] = sram_rdata_a0[191:180];
      sram_rdata_in_0_c0[1] = sram_rdata_a0[179:168];
      sram_rdata_in_0_c0[2] = sram_rdata_a1[191:180];
      sram_rdata_in_0_c0[3] = sram_rdata_a0[167:156];
      sram_rdata_in_0_c0[4] = sram_rdata_a0[155:144];
      sram_rdata_in_0_c0[5] = sram_rdata_a1[167:156];
      sram_rdata_in_0_c0[6] = sram_rdata_a2[191:180];
      sram_rdata_in_0_c0[7] = sram_rdata_a2[179:168];
      sram_rdata_in_0_c0[8] = sram_rdata_a3[191:180];

      sram_rdata_in_1_c0[0] = sram_rdata_a0[179:168];
      sram_rdata_in_1_c0[1] = sram_rdata_a1[191:180];
      sram_rdata_in_1_c0[2] = sram_rdata_a1[179:168];
      sram_rdata_in_1_c0[3] = sram_rdata_a0[155:144];
      sram_rdata_in_1_c0[4] = sram_rdata_a1[167:156];
      sram_rdata_in_1_c0[5] = sram_rdata_a1[155:144];
      sram_rdata_in_1_c0[6] = sram_rdata_a2[179:168];
      sram_rdata_in_1_c0[7] = sram_rdata_a3[191:180];
      sram_rdata_in_1_c0[8] = sram_rdata_a3[179:168];

      sram_rdata_in_2_c0[0] = sram_rdata_a0[167:156];
      sram_rdata_in_2_c0[1] = sram_rdata_a0[155:144];
      sram_rdata_in_2_c0[2] = sram_rdata_a1[167:156];
      sram_rdata_in_2_c0[3] = sram_rdata_a2[191:180];
      sram_rdata_in_2_c0[4] = sram_rdata_a2[179:168];
      sram_rdata_in_2_c0[5] = sram_rdata_a3[191:180];
      sram_rdata_in_2_c0[6] = sram_rdata_a2[167:156];
      sram_rdata_in_2_c0[7] = sram_rdata_a2[155:144];
      sram_rdata_in_2_c0[8] = sram_rdata_a3[167:156];

      sram_rdata_in_3_c0[0] = sram_rdata_a0[155:144];
      sram_rdata_in_3_c0[1] = sram_rdata_a1[167:156];
      sram_rdata_in_3_c0[2] = sram_rdata_a1[155:144];
      sram_rdata_in_3_c0[3] = sram_rdata_a2[179:168];
      sram_rdata_in_3_c0[4] = sram_rdata_a3[191:180];
      sram_rdata_in_3_c0[5] = sram_rdata_a3[179:168];
      sram_rdata_in_3_c0[6] = sram_rdata_a2[155:144];
      sram_rdata_in_3_c0[7] = sram_rdata_a3[167:156];
      sram_rdata_in_3_c0[8] = sram_rdata_a3[155:144];
    end
    2'd1: begin
      sram_rdata_in_0_c0[0] = sram_rdata_a1[191:180];
      sram_rdata_in_0_c0[1] = sram_rdata_a1[179:168];
      sram_rdata_in_0_c0[2] = sram_rdata_a0[191:180];
      sram_rdata_in_0_c0[3] = sram_rdata_a1[167:156];
      sram_rdata_in_0_c0[4] = sram_rdata_a1[155:144];
      sram_rdata_in_0_c0[5] = sram_rdata_a0[167:156];
      sram_rdata_in_0_c0[6] = sram_rdata_a3[191:180];
      sram_rdata_in_0_c0[7] = sram_rdata_a3[179:168];
      sram_rdata_in_0_c0[8] = sram_rdata_a2[191:180];

      sram_rdata_in_1_c0[0] = sram_rdata_a1[179:168];
      sram_rdata_in_1_c0[1] = sram_rdata_a0[191:180];
      sram_rdata_in_1_c0[2] = sram_rdata_a0[179:168];
      sram_rdata_in_1_c0[3] = sram_rdata_a1[155:144];
      sram_rdata_in_1_c0[4] = sram_rdata_a0[167:156];
      sram_rdata_in_1_c0[5] = sram_rdata_a0[155:144];
      sram_rdata_in_1_c0[6] = sram_rdata_a3[179:168];
      sram_rdata_in_1_c0[7] = sram_rdata_a2[191:180];
      sram_rdata_in_1_c0[8] = sram_rdata_a2[179:168];

      sram_rdata_in_2_c0[0] = sram_rdata_a1[167:156];
      sram_rdata_in_2_c0[1] = sram_rdata_a1[155:144];
      sram_rdata_in_2_c0[2] = sram_rdata_a0[167:156];
      sram_rdata_in_2_c0[3] = sram_rdata_a3[191:180];
      sram_rdata_in_2_c0[4] = sram_rdata_a3[179:168];
      sram_rdata_in_2_c0[5] = sram_rdata_a2[191:180];
      sram_rdata_in_2_c0[6] = sram_rdata_a3[167:156];
      sram_rdata_in_2_c0[7] = sram_rdata_a3[155:144];
      sram_rdata_in_2_c0[8] = sram_rdata_a2[167:156];

      sram_rdata_in_3_c0[0] = sram_rdata_a1[155:144];
      sram_rdata_in_3_c0[1] = sram_rdata_a0[167:156];
      sram_rdata_in_3_c0[2] = sram_rdata_a0[155:144];
      sram_rdata_in_3_c0[3] = sram_rdata_a3[179:168];
      sram_rdata_in_3_c0[4] = sram_rdata_a2[191:180];
      sram_rdata_in_3_c0[5] = sram_rdata_a2[179:168];
      sram_rdata_in_3_c0[6] = sram_rdata_a3[155:144];
      sram_rdata_in_3_c0[7] = sram_rdata_a2[167:156];
      sram_rdata_in_3_c0[8] = sram_rdata_a2[155:144];
    end
    2'd2: begin
      sram_rdata_in_0_c0[0] = sram_rdata_a2[191:180];
      sram_rdata_in_0_c0[1] = sram_rdata_a2[179:168];
      sram_rdata_in_0_c0[2] = sram_rdata_a3[191:180];
      sram_rdata_in_0_c0[3] = sram_rdata_a2[167:156];
      sram_rdata_in_0_c0[4] = sram_rdata_a2[155:144];
      sram_rdata_in_0_c0[5] = sram_rdata_a3[167:156];
      sram_rdata_in_0_c0[6] = sram_rdata_a0[191:180];
      sram_rdata_in_0_c0[7] = sram_rdata_a0[179:168];
      sram_rdata_in_0_c0[8] = sram_rdata_a1[191:180];

      sram_rdata_in_1_c0[0] = sram_rdata_a2[179:168];
      sram_rdata_in_1_c0[1] = sram_rdata_a3[191:180];
      sram_rdata_in_1_c0[2] = sram_rdata_a3[179:168];
      sram_rdata_in_1_c0[3] = sram_rdata_a2[155:144];
      sram_rdata_in_1_c0[4] = sram_rdata_a3[167:156];
      sram_rdata_in_1_c0[5] = sram_rdata_a3[155:144];
      sram_rdata_in_1_c0[6] = sram_rdata_a0[179:168];
      sram_rdata_in_1_c0[7] = sram_rdata_a1[191:180];
      sram_rdata_in_1_c0[8] = sram_rdata_a1[179:168];

      sram_rdata_in_2_c0[0] = sram_rdata_a2[167:156];
      sram_rdata_in_2_c0[1] = sram_rdata_a2[155:144];
      sram_rdata_in_2_c0[2] = sram_rdata_a3[167:156];
      sram_rdata_in_2_c0[3] = sram_rdata_a0[191:180];
      sram_rdata_in_2_c0[4] = sram_rdata_a0[179:168];
      sram_rdata_in_2_c0[5] = sram_rdata_a1[191:180];
      sram_rdata_in_2_c0[6] = sram_rdata_a0[167:156];
      sram_rdata_in_2_c0[7] = sram_rdata_a0[155:144];
      sram_rdata_in_2_c0[8] = sram_rdata_a1[167:156];

      sram_rdata_in_3_c0[0] = sram_rdata_a2[155:144];
      sram_rdata_in_3_c0[1] = sram_rdata_a3[167:156];
      sram_rdata_in_3_c0[2] = sram_rdata_a3[155:144];
      sram_rdata_in_3_c0[3] = sram_rdata_a0[179:168];
      sram_rdata_in_3_c0[4] = sram_rdata_a1[191:180];
      sram_rdata_in_3_c0[5] = sram_rdata_a1[179:168];
      sram_rdata_in_3_c0[6] = sram_rdata_a0[155:144];
      sram_rdata_in_3_c0[7] = sram_rdata_a1[167:156];
      sram_rdata_in_3_c0[8] = sram_rdata_a1[155:144];
    end
    2'd3: begin
      sram_rdata_in_0_c0[0] = sram_rdata_a3[191:180];
      sram_rdata_in_0_c0[1] = sram_rdata_a3[179:168];
      sram_rdata_in_0_c0[2] = sram_rdata_a2[191:180];
      sram_rdata_in_0_c0[3] = sram_rdata_a3[167:156];
      sram_rdata_in_0_c0[4] = sram_rdata_a3[155:144];
      sram_rdata_in_0_c0[5] = sram_rdata_a2[167:156];
      sram_rdata_in_0_c0[6] = sram_rdata_a1[191:180];
      sram_rdata_in_0_c0[7] = sram_rdata_a1[179:168];
      sram_rdata_in_0_c0[8] = sram_rdata_a0[191:180];

      sram_rdata_in_1_c0[0] = sram_rdata_a3[179:168];
      sram_rdata_in_1_c0[1] = sram_rdata_a2[191:180];
      sram_rdata_in_1_c0[2] = sram_rdata_a2[179:168];
      sram_rdata_in_1_c0[3] = sram_rdata_a3[155:144];
      sram_rdata_in_1_c0[4] = sram_rdata_a2[167:156];
      sram_rdata_in_1_c0[5] = sram_rdata_a2[155:144];
      sram_rdata_in_1_c0[6] = sram_rdata_a1[179:168];
      sram_rdata_in_1_c0[7] = sram_rdata_a0[191:180];
      sram_rdata_in_1_c0[8] = sram_rdata_a0[179:168];

      sram_rdata_in_2_c0[0] = sram_rdata_a3[167:156];
      sram_rdata_in_2_c0[1] = sram_rdata_a3[155:144];
      sram_rdata_in_2_c0[2] = sram_rdata_a2[167:156];
      sram_rdata_in_2_c0[3] = sram_rdata_a1[191:180];
      sram_rdata_in_2_c0[4] = sram_rdata_a1[179:168];
      sram_rdata_in_2_c0[5] = sram_rdata_a0[191:180];
      sram_rdata_in_2_c0[6] = sram_rdata_a1[167:156];
      sram_rdata_in_2_c0[7] = sram_rdata_a1[155:144];
      sram_rdata_in_2_c0[8] = sram_rdata_a0[167:156];

      sram_rdata_in_3_c0[0] = sram_rdata_a3[155:144];
      sram_rdata_in_3_c0[1] = sram_rdata_a2[167:156];
      sram_rdata_in_3_c0[2] = sram_rdata_a2[155:144];
      sram_rdata_in_3_c0[3] = sram_rdata_a1[179:168];
      sram_rdata_in_3_c0[4] = sram_rdata_a0[191:180];
      sram_rdata_in_3_c0[5] = sram_rdata_a0[179:168];
      sram_rdata_in_3_c0[6] = sram_rdata_a1[155:144];
      sram_rdata_in_3_c0[7] = sram_rdata_a0[167:156];
      sram_rdata_in_3_c0[8] = sram_rdata_a0[155:144];
    end
    default: begin
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c0[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c0[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c0[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c0[i] = 0;
    end
  endcase


// channel (1/5/9) 
always@*
  case(bank_mode_delay)
    2'd0: begin
      sram_rdata_in_0_c1[0] = sram_rdata_a0[143:132];
      sram_rdata_in_0_c1[1] = sram_rdata_a0[131:120];
      sram_rdata_in_0_c1[2] = sram_rdata_a1[143:132];
      sram_rdata_in_0_c1[3] = sram_rdata_a0[119:108];
      sram_rdata_in_0_c1[4] = sram_rdata_a0[107:96];
      sram_rdata_in_0_c1[5] = sram_rdata_a1[119:108];
      sram_rdata_in_0_c1[6] = sram_rdata_a2[143:132];
      sram_rdata_in_0_c1[7] = sram_rdata_a2[131:120];
      sram_rdata_in_0_c1[8] = sram_rdata_a3[143:132];

      sram_rdata_in_1_c1[0] = sram_rdata_a0[131:120];
      sram_rdata_in_1_c1[1] = sram_rdata_a1[143:132];
      sram_rdata_in_1_c1[2] = sram_rdata_a1[131:120];
      sram_rdata_in_1_c1[3] = sram_rdata_a0[107:96];
      sram_rdata_in_1_c1[4] = sram_rdata_a1[119:108];
      sram_rdata_in_1_c1[5] = sram_rdata_a1[107:96];
      sram_rdata_in_1_c1[6] = sram_rdata_a2[131:120];
      sram_rdata_in_1_c1[7] = sram_rdata_a3[143:132];
      sram_rdata_in_1_c1[8] = sram_rdata_a3[131:120];

      sram_rdata_in_2_c1[0] = sram_rdata_a0[119:108];
      sram_rdata_in_2_c1[1] = sram_rdata_a0[107:96];
      sram_rdata_in_2_c1[2] = sram_rdata_a1[119:108];
      sram_rdata_in_2_c1[3] = sram_rdata_a2[143:132];
      sram_rdata_in_2_c1[4] = sram_rdata_a2[131:120];
      sram_rdata_in_2_c1[5] = sram_rdata_a3[143:132];
      sram_rdata_in_2_c1[6] = sram_rdata_a2[119:108];
      sram_rdata_in_2_c1[7] = sram_rdata_a2[107:96];
      sram_rdata_in_2_c1[8] = sram_rdata_a3[119:108];

      sram_rdata_in_3_c1[0] = sram_rdata_a0[107:96];
      sram_rdata_in_3_c1[1] = sram_rdata_a1[119:108];
      sram_rdata_in_3_c1[2] = sram_rdata_a1[107:96];
      sram_rdata_in_3_c1[3] = sram_rdata_a2[131:120];
      sram_rdata_in_3_c1[4] = sram_rdata_a3[143:132];
      sram_rdata_in_3_c1[5] = sram_rdata_a3[131:120];
      sram_rdata_in_3_c1[6] = sram_rdata_a2[107:96];
      sram_rdata_in_3_c1[7] = sram_rdata_a3[119:108];
      sram_rdata_in_3_c1[8] = sram_rdata_a3[107:96];
    end
    2'd1: begin
      sram_rdata_in_0_c1[0] = sram_rdata_a1[143:132];
      sram_rdata_in_0_c1[1] = sram_rdata_a1[131:120];
      sram_rdata_in_0_c1[2] = sram_rdata_a0[143:132];
      sram_rdata_in_0_c1[3] = sram_rdata_a1[119:108];
      sram_rdata_in_0_c1[4] = sram_rdata_a1[107:96];
      sram_rdata_in_0_c1[5] = sram_rdata_a0[119:108];
      sram_rdata_in_0_c1[6] = sram_rdata_a3[143:132];
      sram_rdata_in_0_c1[7] = sram_rdata_a3[131:120];
      sram_rdata_in_0_c1[8] = sram_rdata_a2[143:132];

      sram_rdata_in_1_c1[0] = sram_rdata_a1[131:120];
      sram_rdata_in_1_c1[1] = sram_rdata_a0[143:132];
      sram_rdata_in_1_c1[2] = sram_rdata_a0[131:120];
      sram_rdata_in_1_c1[3] = sram_rdata_a1[107:96];
      sram_rdata_in_1_c1[4] = sram_rdata_a0[119:108];
      sram_rdata_in_1_c1[5] = sram_rdata_a0[107:96];
      sram_rdata_in_1_c1[6] = sram_rdata_a3[131:120];
      sram_rdata_in_1_c1[7] = sram_rdata_a2[143:132];
      sram_rdata_in_1_c1[8] = sram_rdata_a2[131:120];

      sram_rdata_in_2_c1[0] = sram_rdata_a1[119:108];
      sram_rdata_in_2_c1[1] = sram_rdata_a1[107:96];
      sram_rdata_in_2_c1[2] = sram_rdata_a0[119:108];
      sram_rdata_in_2_c1[3] = sram_rdata_a3[143:132];
      sram_rdata_in_2_c1[4] = sram_rdata_a3[131:120];
      sram_rdata_in_2_c1[5] = sram_rdata_a2[143:132];
      sram_rdata_in_2_c1[6] = sram_rdata_a3[119:108];
      sram_rdata_in_2_c1[7] = sram_rdata_a3[107:96];
      sram_rdata_in_2_c1[8] = sram_rdata_a2[119:108];

      sram_rdata_in_3_c1[0] = sram_rdata_a1[107:96];
      sram_rdata_in_3_c1[1] = sram_rdata_a0[119:108];
      sram_rdata_in_3_c1[2] = sram_rdata_a0[107:96];
      sram_rdata_in_3_c1[3] = sram_rdata_a3[131:120];
      sram_rdata_in_3_c1[4] = sram_rdata_a2[143:132];
      sram_rdata_in_3_c1[5] = sram_rdata_a2[131:120];
      sram_rdata_in_3_c1[6] = sram_rdata_a3[107:96];
      sram_rdata_in_3_c1[7] = sram_rdata_a2[119:108];
      sram_rdata_in_3_c1[8] = sram_rdata_a2[107:96];
    end
    2'd2: begin
      sram_rdata_in_0_c1[0] = sram_rdata_a2[143:132];
      sram_rdata_in_0_c1[1] = sram_rdata_a2[131:120];
      sram_rdata_in_0_c1[2] = sram_rdata_a3[143:132];
      sram_rdata_in_0_c1[3] = sram_rdata_a2[119:108];
      sram_rdata_in_0_c1[4] = sram_rdata_a2[107:96];
      sram_rdata_in_0_c1[5] = sram_rdata_a3[119:108];
      sram_rdata_in_0_c1[6] = sram_rdata_a0[143:132];
      sram_rdata_in_0_c1[7] = sram_rdata_a0[131:120];
      sram_rdata_in_0_c1[8] = sram_rdata_a1[143:132];

      sram_rdata_in_1_c1[0] = sram_rdata_a2[131:120];
      sram_rdata_in_1_c1[1] = sram_rdata_a3[143:132];
      sram_rdata_in_1_c1[2] = sram_rdata_a3[131:120];
      sram_rdata_in_1_c1[3] = sram_rdata_a2[107:96];
      sram_rdata_in_1_c1[4] = sram_rdata_a3[119:108];
      sram_rdata_in_1_c1[5] = sram_rdata_a3[107:96];
      sram_rdata_in_1_c1[6] = sram_rdata_a0[131:120];
      sram_rdata_in_1_c1[7] = sram_rdata_a1[143:132];
      sram_rdata_in_1_c1[8] = sram_rdata_a1[131:120];

      sram_rdata_in_2_c1[0] = sram_rdata_a2[119:108];
      sram_rdata_in_2_c1[1] = sram_rdata_a2[107:96];
      sram_rdata_in_2_c1[2] = sram_rdata_a3[119:108];
      sram_rdata_in_2_c1[3] = sram_rdata_a0[143:132];
      sram_rdata_in_2_c1[4] = sram_rdata_a0[131:120];
      sram_rdata_in_2_c1[5] = sram_rdata_a1[143:132];
      sram_rdata_in_2_c1[6] = sram_rdata_a0[119:108];
      sram_rdata_in_2_c1[7] = sram_rdata_a0[107:96];
      sram_rdata_in_2_c1[8] = sram_rdata_a1[119:108];

      sram_rdata_in_3_c1[0] = sram_rdata_a2[107:96];
      sram_rdata_in_3_c1[1] = sram_rdata_a3[119:108];
      sram_rdata_in_3_c1[2] = sram_rdata_a3[107:96];
      sram_rdata_in_3_c1[3] = sram_rdata_a0[131:120];
      sram_rdata_in_3_c1[4] = sram_rdata_a1[143:132];
      sram_rdata_in_3_c1[5] = sram_rdata_a1[131:120];
      sram_rdata_in_3_c1[6] = sram_rdata_a0[107:96];
      sram_rdata_in_3_c1[7] = sram_rdata_a1[119:108];
      sram_rdata_in_3_c1[8] = sram_rdata_a1[107:96];
    end
    2'd3: begin
      sram_rdata_in_0_c1[0] = sram_rdata_a3[143:132];
      sram_rdata_in_0_c1[1] = sram_rdata_a3[131:120];
      sram_rdata_in_0_c1[2] = sram_rdata_a2[143:132];
      sram_rdata_in_0_c1[3] = sram_rdata_a3[119:108];
      sram_rdata_in_0_c1[4] = sram_rdata_a3[107:96];
      sram_rdata_in_0_c1[5] = sram_rdata_a2[119:108];
      sram_rdata_in_0_c1[6] = sram_rdata_a1[143:132];
      sram_rdata_in_0_c1[7] = sram_rdata_a1[131:120];
      sram_rdata_in_0_c1[8] = sram_rdata_a0[143:132];

      sram_rdata_in_1_c1[0] = sram_rdata_a3[131:120];
      sram_rdata_in_1_c1[1] = sram_rdata_a2[143:132];
      sram_rdata_in_1_c1[2] = sram_rdata_a2[131:120];
      sram_rdata_in_1_c1[3] = sram_rdata_a3[107:96];
      sram_rdata_in_1_c1[4] = sram_rdata_a2[119:108];
      sram_rdata_in_1_c1[5] = sram_rdata_a2[107:96];
      sram_rdata_in_1_c1[6] = sram_rdata_a1[131:120];
      sram_rdata_in_1_c1[7] = sram_rdata_a0[143:132];
      sram_rdata_in_1_c1[8] = sram_rdata_a0[131:120];

      sram_rdata_in_2_c1[0] = sram_rdata_a3[119:108];
      sram_rdata_in_2_c1[1] = sram_rdata_a3[107:96];
      sram_rdata_in_2_c1[2] = sram_rdata_a2[119:108];
      sram_rdata_in_2_c1[3] = sram_rdata_a1[143:132];
      sram_rdata_in_2_c1[4] = sram_rdata_a1[131:120];
      sram_rdata_in_2_c1[5] = sram_rdata_a0[143:132];
      sram_rdata_in_2_c1[6] = sram_rdata_a1[119:108];
      sram_rdata_in_2_c1[7] = sram_rdata_a1[107:96];
      sram_rdata_in_2_c1[8] = sram_rdata_a0[119:108];

      sram_rdata_in_3_c1[0] = sram_rdata_a3[107:96];
      sram_rdata_in_3_c1[1] = sram_rdata_a2[119:108];
      sram_rdata_in_3_c1[2] = sram_rdata_a2[107:96];
      sram_rdata_in_3_c1[3] = sram_rdata_a1[131:120];
      sram_rdata_in_3_c1[4] = sram_rdata_a0[143:132];
      sram_rdata_in_3_c1[5] = sram_rdata_a0[131:120];
      sram_rdata_in_3_c1[6] = sram_rdata_a1[107:96];
      sram_rdata_in_3_c1[7] = sram_rdata_a0[119:108];
      sram_rdata_in_3_c1[8] = sram_rdata_a0[107:96];
    end
    default: begin
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c1[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c1[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c1[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c1[i] = 0;
    end
  endcase

// channel (2/6/10) 
always@*
  case(bank_mode_delay)
    2'd0: begin
      sram_rdata_in_0_c2[0] = sram_rdata_a0[95:84];
      sram_rdata_in_0_c2[1] = sram_rdata_a0[83:72];
      sram_rdata_in_0_c2[2] = sram_rdata_a1[95:84];
      sram_rdata_in_0_c2[3] = sram_rdata_a0[71:60];
      sram_rdata_in_0_c2[4] = sram_rdata_a0[59:48];
      sram_rdata_in_0_c2[5] = sram_rdata_a1[71:60];
      sram_rdata_in_0_c2[6] = sram_rdata_a2[95:84];
      sram_rdata_in_0_c2[7] = sram_rdata_a2[83:72];
      sram_rdata_in_0_c2[8] = sram_rdata_a3[95:84];

      sram_rdata_in_1_c2[0] = sram_rdata_a0[83:72];
      sram_rdata_in_1_c2[1] = sram_rdata_a1[95:84];
      sram_rdata_in_1_c2[2] = sram_rdata_a1[83:72];
      sram_rdata_in_1_c2[3] = sram_rdata_a0[59:48];
      sram_rdata_in_1_c2[4] = sram_rdata_a1[71:60];
      sram_rdata_in_1_c2[5] = sram_rdata_a1[59:48];
      sram_rdata_in_1_c2[6] = sram_rdata_a2[83:72];
      sram_rdata_in_1_c2[7] = sram_rdata_a3[95:84];
      sram_rdata_in_1_c2[8] = sram_rdata_a3[83:72];

      sram_rdata_in_2_c2[0] = sram_rdata_a0[71:60];
      sram_rdata_in_2_c2[1] = sram_rdata_a0[59:48];
      sram_rdata_in_2_c2[2] = sram_rdata_a1[71:60];
      sram_rdata_in_2_c2[3] = sram_rdata_a2[95:84];
      sram_rdata_in_2_c2[4] = sram_rdata_a2[83:72];
      sram_rdata_in_2_c2[5] = sram_rdata_a3[95:84];
      sram_rdata_in_2_c2[6] = sram_rdata_a2[71:60];
      sram_rdata_in_2_c2[7] = sram_rdata_a2[59:48];
      sram_rdata_in_2_c2[8] = sram_rdata_a3[71:60];

      sram_rdata_in_3_c2[0] = sram_rdata_a0[59:48];
      sram_rdata_in_3_c2[1] = sram_rdata_a1[71:60];
      sram_rdata_in_3_c2[2] = sram_rdata_a1[59:48];
      sram_rdata_in_3_c2[3] = sram_rdata_a2[83:72];
      sram_rdata_in_3_c2[4] = sram_rdata_a3[95:84];
      sram_rdata_in_3_c2[5] = sram_rdata_a3[83:72];
      sram_rdata_in_3_c2[6] = sram_rdata_a2[59:48];
      sram_rdata_in_3_c2[7] = sram_rdata_a3[71:60];
      sram_rdata_in_3_c2[8] = sram_rdata_a3[59:48];
    end
    2'd1: begin
      sram_rdata_in_0_c2[0] = sram_rdata_a1[95:84];
      sram_rdata_in_0_c2[1] = sram_rdata_a1[83:72];
      sram_rdata_in_0_c2[2] = sram_rdata_a0[95:84];
      sram_rdata_in_0_c2[3] = sram_rdata_a1[71:60];
      sram_rdata_in_0_c2[4] = sram_rdata_a1[59:48];
      sram_rdata_in_0_c2[5] = sram_rdata_a0[71:60];
      sram_rdata_in_0_c2[6] = sram_rdata_a3[95:84];
      sram_rdata_in_0_c2[7] = sram_rdata_a3[83:72];
      sram_rdata_in_0_c2[8] = sram_rdata_a2[95:84];

      sram_rdata_in_1_c2[0] = sram_rdata_a1[83:72];
      sram_rdata_in_1_c2[1] = sram_rdata_a0[95:84];
      sram_rdata_in_1_c2[2] = sram_rdata_a0[83:72];
      sram_rdata_in_1_c2[3] = sram_rdata_a1[59:48];
      sram_rdata_in_1_c2[4] = sram_rdata_a0[71:60];
      sram_rdata_in_1_c2[5] = sram_rdata_a0[59:48];
      sram_rdata_in_1_c2[6] = sram_rdata_a3[83:72];
      sram_rdata_in_1_c2[7] = sram_rdata_a2[95:84];
      sram_rdata_in_1_c2[8] = sram_rdata_a2[83:72];

      sram_rdata_in_2_c2[0] = sram_rdata_a1[71:60];
      sram_rdata_in_2_c2[1] = sram_rdata_a1[59:48];
      sram_rdata_in_2_c2[2] = sram_rdata_a0[71:60];
      sram_rdata_in_2_c2[3] = sram_rdata_a3[95:84];
      sram_rdata_in_2_c2[4] = sram_rdata_a3[83:72];
      sram_rdata_in_2_c2[5] = sram_rdata_a2[95:84];
      sram_rdata_in_2_c2[6] = sram_rdata_a3[71:60];
      sram_rdata_in_2_c2[7] = sram_rdata_a3[59:48];
      sram_rdata_in_2_c2[8] = sram_rdata_a2[71:60];

      sram_rdata_in_3_c2[0] = sram_rdata_a1[59:48];
      sram_rdata_in_3_c2[1] = sram_rdata_a0[71:60];
      sram_rdata_in_3_c2[2] = sram_rdata_a0[59:48];
      sram_rdata_in_3_c2[3] = sram_rdata_a3[83:72];
      sram_rdata_in_3_c2[4] = sram_rdata_a2[95:84];
      sram_rdata_in_3_c2[5] = sram_rdata_a2[83:72];
      sram_rdata_in_3_c2[6] = sram_rdata_a3[59:48];
      sram_rdata_in_3_c2[7] = sram_rdata_a2[71:60];
      sram_rdata_in_3_c2[8] = sram_rdata_a2[59:48];
    end
    2'd2: begin
      sram_rdata_in_0_c2[0] = sram_rdata_a2[95:84];
      sram_rdata_in_0_c2[1] = sram_rdata_a2[83:72];
      sram_rdata_in_0_c2[2] = sram_rdata_a3[95:84];
      sram_rdata_in_0_c2[3] = sram_rdata_a2[71:60];
      sram_rdata_in_0_c2[4] = sram_rdata_a2[59:48];
      sram_rdata_in_0_c2[5] = sram_rdata_a3[71:60];
      sram_rdata_in_0_c2[6] = sram_rdata_a0[95:84];
      sram_rdata_in_0_c2[7] = sram_rdata_a0[83:72];
      sram_rdata_in_0_c2[8] = sram_rdata_a1[95:84];

      sram_rdata_in_1_c2[0] = sram_rdata_a2[83:72];
      sram_rdata_in_1_c2[1] = sram_rdata_a3[95:84];
      sram_rdata_in_1_c2[2] = sram_rdata_a3[83:72];
      sram_rdata_in_1_c2[3] = sram_rdata_a2[59:48];
      sram_rdata_in_1_c2[4] = sram_rdata_a3[71:60];
      sram_rdata_in_1_c2[5] = sram_rdata_a3[59:48];
      sram_rdata_in_1_c2[6] = sram_rdata_a0[83:72];
      sram_rdata_in_1_c2[7] = sram_rdata_a1[95:84];
      sram_rdata_in_1_c2[8] = sram_rdata_a1[83:72];

      sram_rdata_in_2_c2[0] = sram_rdata_a2[71:60];
      sram_rdata_in_2_c2[1] = sram_rdata_a2[59:48];
      sram_rdata_in_2_c2[2] = sram_rdata_a3[71:60];
      sram_rdata_in_2_c2[3] = sram_rdata_a0[95:84];
      sram_rdata_in_2_c2[4] = sram_rdata_a0[83:72];
      sram_rdata_in_2_c2[5] = sram_rdata_a1[95:84];
      sram_rdata_in_2_c2[6] = sram_rdata_a0[71:60];
      sram_rdata_in_2_c2[7] = sram_rdata_a0[59:48];
      sram_rdata_in_2_c2[8] = sram_rdata_a1[71:60];

      sram_rdata_in_3_c2[0] = sram_rdata_a2[59:48];
      sram_rdata_in_3_c2[1] = sram_rdata_a3[71:60];
      sram_rdata_in_3_c2[2] = sram_rdata_a3[59:48];
      sram_rdata_in_3_c2[3] = sram_rdata_a0[83:72];
      sram_rdata_in_3_c2[4] = sram_rdata_a1[95:84];
      sram_rdata_in_3_c2[5] = sram_rdata_a1[83:72];
      sram_rdata_in_3_c2[6] = sram_rdata_a0[59:48];
      sram_rdata_in_3_c2[7] = sram_rdata_a1[71:60];
      sram_rdata_in_3_c2[8] = sram_rdata_a1[59:48];
    end
    2'd3: begin
      sram_rdata_in_0_c2[0] = sram_rdata_a3[95:84];
      sram_rdata_in_0_c2[1] = sram_rdata_a3[83:72];
      sram_rdata_in_0_c2[2] = sram_rdata_a2[95:84];
      sram_rdata_in_0_c2[3] = sram_rdata_a3[71:60];
      sram_rdata_in_0_c2[4] = sram_rdata_a3[59:48];
      sram_rdata_in_0_c2[5] = sram_rdata_a2[71:60];
      sram_rdata_in_0_c2[6] = sram_rdata_a1[95:84];
      sram_rdata_in_0_c2[7] = sram_rdata_a1[83:72];
      sram_rdata_in_0_c2[8] = sram_rdata_a0[95:84];

      sram_rdata_in_1_c2[0] = sram_rdata_a3[83:72];
      sram_rdata_in_1_c2[1] = sram_rdata_a2[95:84];
      sram_rdata_in_1_c2[2] = sram_rdata_a2[83:72];
      sram_rdata_in_1_c2[3] = sram_rdata_a3[59:48];
      sram_rdata_in_1_c2[4] = sram_rdata_a2[71:60];
      sram_rdata_in_1_c2[5] = sram_rdata_a2[59:48];
      sram_rdata_in_1_c2[6] = sram_rdata_a1[83:72];
      sram_rdata_in_1_c2[7] = sram_rdata_a0[95:84];
      sram_rdata_in_1_c2[8] = sram_rdata_a0[83:72];

      sram_rdata_in_2_c2[0] = sram_rdata_a3[71:60];
      sram_rdata_in_2_c2[1] = sram_rdata_a3[59:48];
      sram_rdata_in_2_c2[2] = sram_rdata_a2[71:60];
      sram_rdata_in_2_c2[3] = sram_rdata_a1[95:84];
      sram_rdata_in_2_c2[4] = sram_rdata_a1[83:72];
      sram_rdata_in_2_c2[5] = sram_rdata_a0[95:84];
      sram_rdata_in_2_c2[6] = sram_rdata_a1[71:60];
      sram_rdata_in_2_c2[7] = sram_rdata_a1[59:48];
      sram_rdata_in_2_c2[8] = sram_rdata_a0[71:60];

      sram_rdata_in_3_c2[0] = sram_rdata_a3[59:48];
      sram_rdata_in_3_c2[1] = sram_rdata_a2[71:60];
      sram_rdata_in_3_c2[2] = sram_rdata_a2[59:48];
      sram_rdata_in_3_c2[3] = sram_rdata_a1[83:72];
      sram_rdata_in_3_c2[4] = sram_rdata_a0[95:84];
      sram_rdata_in_3_c2[5] = sram_rdata_a0[83:72];
      sram_rdata_in_3_c2[6] = sram_rdata_a1[59:48];
      sram_rdata_in_3_c2[7] = sram_rdata_a0[71:60];
      sram_rdata_in_3_c2[8] = sram_rdata_a0[59:48];
    end
    default: begin
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c2[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c2[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c2[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c2[i] = 0;
    end
  endcase

// channel (3/7/11) 
always@*
  case(bank_mode_delay)
    2'd0: begin
      sram_rdata_in_0_c3[0] = sram_rdata_a0[47:36];
      sram_rdata_in_0_c3[1] = sram_rdata_a0[35:24];
      sram_rdata_in_0_c3[2] = sram_rdata_a1[47:36];
      sram_rdata_in_0_c3[3] = sram_rdata_a0[23:12];
      sram_rdata_in_0_c3[4] = sram_rdata_a0[11:0];
      sram_rdata_in_0_c3[5] = sram_rdata_a1[23:12];
      sram_rdata_in_0_c3[6] = sram_rdata_a2[47:36];
      sram_rdata_in_0_c3[7] = sram_rdata_a2[35:24];
      sram_rdata_in_0_c3[8] = sram_rdata_a3[47:36];

      sram_rdata_in_1_c3[0] = sram_rdata_a0[35:24];
      sram_rdata_in_1_c3[1] = sram_rdata_a1[47:36];
      sram_rdata_in_1_c3[2] = sram_rdata_a1[35:24];
      sram_rdata_in_1_c3[3] = sram_rdata_a0[11:0];
      sram_rdata_in_1_c3[4] = sram_rdata_a1[23:12];
      sram_rdata_in_1_c3[5] = sram_rdata_a1[11:0];
      sram_rdata_in_1_c3[6] = sram_rdata_a2[35:24];
      sram_rdata_in_1_c3[7] = sram_rdata_a3[47:36];
      sram_rdata_in_1_c3[8] = sram_rdata_a3[35:24];

      sram_rdata_in_2_c3[0] = sram_rdata_a0[23:12];
      sram_rdata_in_2_c3[1] = sram_rdata_a0[11:0];
      sram_rdata_in_2_c3[2] = sram_rdata_a1[23:12];
      sram_rdata_in_2_c3[3] = sram_rdata_a2[47:36];
      sram_rdata_in_2_c3[4] = sram_rdata_a2[35:24];
      sram_rdata_in_2_c3[5] = sram_rdata_a3[47:36];
      sram_rdata_in_2_c3[6] = sram_rdata_a2[23:12];
      sram_rdata_in_2_c3[7] = sram_rdata_a2[11:0];
      sram_rdata_in_2_c3[8] = sram_rdata_a3[23:12];

      sram_rdata_in_3_c3[0] = sram_rdata_a0[11:0];
      sram_rdata_in_3_c3[1] = sram_rdata_a1[23:12];
      sram_rdata_in_3_c3[2] = sram_rdata_a1[11:0];
      sram_rdata_in_3_c3[3] = sram_rdata_a2[35:24];
      sram_rdata_in_3_c3[4] = sram_rdata_a3[47:36];
      sram_rdata_in_3_c3[5] = sram_rdata_a3[35:24];
      sram_rdata_in_3_c3[6] = sram_rdata_a2[11:0];
      sram_rdata_in_3_c3[7] = sram_rdata_a3[23:12];
      sram_rdata_in_3_c3[8] = sram_rdata_a3[11:0];
    end
    2'd1: begin
      sram_rdata_in_0_c3[0] = sram_rdata_a1[47:36];
      sram_rdata_in_0_c3[1] = sram_rdata_a1[35:24];
      sram_rdata_in_0_c3[2] = sram_rdata_a0[47:36];
      sram_rdata_in_0_c3[3] = sram_rdata_a1[23:12];
      sram_rdata_in_0_c3[4] = sram_rdata_a1[11:0];
      sram_rdata_in_0_c3[5] = sram_rdata_a0[23:12];
      sram_rdata_in_0_c3[6] = sram_rdata_a3[47:36];
      sram_rdata_in_0_c3[7] = sram_rdata_a3[35:24];
      sram_rdata_in_0_c3[8] = sram_rdata_a2[47:36];

      sram_rdata_in_1_c3[0] = sram_rdata_a1[35:24];
      sram_rdata_in_1_c3[1] = sram_rdata_a0[47:36];
      sram_rdata_in_1_c3[2] = sram_rdata_a0[35:24];
      sram_rdata_in_1_c3[3] = sram_rdata_a1[11:0];
      sram_rdata_in_1_c3[4] = sram_rdata_a0[23:12];
      sram_rdata_in_1_c3[5] = sram_rdata_a0[11:0];
      sram_rdata_in_1_c3[6] = sram_rdata_a3[35:24];
      sram_rdata_in_1_c3[7] = sram_rdata_a2[47:36];
      sram_rdata_in_1_c3[8] = sram_rdata_a2[35:24];

      sram_rdata_in_2_c3[0] = sram_rdata_a1[23:12];
      sram_rdata_in_2_c3[1] = sram_rdata_a1[11:0];
      sram_rdata_in_2_c3[2] = sram_rdata_a0[23:12];
      sram_rdata_in_2_c3[3] = sram_rdata_a3[47:36];
      sram_rdata_in_2_c3[4] = sram_rdata_a3[35:24];
      sram_rdata_in_2_c3[5] = sram_rdata_a2[47:36];
      sram_rdata_in_2_c3[6] = sram_rdata_a3[23:12];
      sram_rdata_in_2_c3[7] = sram_rdata_a3[11:0];
      sram_rdata_in_2_c3[8] = sram_rdata_a2[23:12];

      sram_rdata_in_3_c3[0] = sram_rdata_a1[11:0];
      sram_rdata_in_3_c3[1] = sram_rdata_a0[23:12];
      sram_rdata_in_3_c3[2] = sram_rdata_a0[11:0];
      sram_rdata_in_3_c3[3] = sram_rdata_a3[35:24];
      sram_rdata_in_3_c3[4] = sram_rdata_a2[47:36];
      sram_rdata_in_3_c3[5] = sram_rdata_a2[35:24];
      sram_rdata_in_3_c3[6] = sram_rdata_a3[11:0];
      sram_rdata_in_3_c3[7] = sram_rdata_a2[23:12];
      sram_rdata_in_3_c3[8] = sram_rdata_a2[11:0];
    end
    2'd2: begin
      sram_rdata_in_0_c3[0] = sram_rdata_a2[47:36];
      sram_rdata_in_0_c3[1] = sram_rdata_a2[35:24];
      sram_rdata_in_0_c3[2] = sram_rdata_a3[47:36];
      sram_rdata_in_0_c3[3] = sram_rdata_a2[23:12];
      sram_rdata_in_0_c3[4] = sram_rdata_a2[11:0];
      sram_rdata_in_0_c3[5] = sram_rdata_a3[23:12];
      sram_rdata_in_0_c3[6] = sram_rdata_a0[47:36];
      sram_rdata_in_0_c3[7] = sram_rdata_a0[35:24];
      sram_rdata_in_0_c3[8] = sram_rdata_a1[47:36];

      sram_rdata_in_1_c3[0] = sram_rdata_a2[35:24];
      sram_rdata_in_1_c3[1] = sram_rdata_a3[47:36];
      sram_rdata_in_1_c3[2] = sram_rdata_a3[35:24];
      sram_rdata_in_1_c3[3] = sram_rdata_a2[11:0];
      sram_rdata_in_1_c3[4] = sram_rdata_a3[23:12];
      sram_rdata_in_1_c3[5] = sram_rdata_a3[11:0];
      sram_rdata_in_1_c3[6] = sram_rdata_a0[35:24];
      sram_rdata_in_1_c3[7] = sram_rdata_a1[47:36];
      sram_rdata_in_1_c3[8] = sram_rdata_a1[35:24];

      sram_rdata_in_2_c3[0] = sram_rdata_a2[23:12];
      sram_rdata_in_2_c3[1] = sram_rdata_a2[11:0];
      sram_rdata_in_2_c3[2] = sram_rdata_a3[23:12];
      sram_rdata_in_2_c3[3] = sram_rdata_a0[47:36];
      sram_rdata_in_2_c3[4] = sram_rdata_a0[35:24];
      sram_rdata_in_2_c3[5] = sram_rdata_a1[47:36];
      sram_rdata_in_2_c3[6] = sram_rdata_a0[23:12];
      sram_rdata_in_2_c3[7] = sram_rdata_a0[11:0];
      sram_rdata_in_2_c3[8] = sram_rdata_a1[23:12];

      sram_rdata_in_3_c3[0] = sram_rdata_a2[11:0];
      sram_rdata_in_3_c3[1] = sram_rdata_a3[23:12];
      sram_rdata_in_3_c3[2] = sram_rdata_a3[11:0];
      sram_rdata_in_3_c3[3] = sram_rdata_a0[35:24];
      sram_rdata_in_3_c3[4] = sram_rdata_a1[47:36];
      sram_rdata_in_3_c3[5] = sram_rdata_a1[35:24];
      sram_rdata_in_3_c3[6] = sram_rdata_a0[11:0];
      sram_rdata_in_3_c3[7] = sram_rdata_a1[23:12];
      sram_rdata_in_3_c3[8] = sram_rdata_a1[11:0];
    end
    2'd3: begin
      sram_rdata_in_0_c3[0] = sram_rdata_a3[47:36];
      sram_rdata_in_0_c3[1] = sram_rdata_a3[35:24];
      sram_rdata_in_0_c3[2] = sram_rdata_a2[47:36];
      sram_rdata_in_0_c3[3] = sram_rdata_a3[23:12];
      sram_rdata_in_0_c3[4] = sram_rdata_a3[11:0];
      sram_rdata_in_0_c3[5] = sram_rdata_a2[23:12];
      sram_rdata_in_0_c3[6] = sram_rdata_a1[47:36];
      sram_rdata_in_0_c3[7] = sram_rdata_a1[35:24];
      sram_rdata_in_0_c3[8] = sram_rdata_a0[47:36];

      sram_rdata_in_1_c3[0] = sram_rdata_a3[35:24];
      sram_rdata_in_1_c3[1] = sram_rdata_a2[47:36];
      sram_rdata_in_1_c3[2] = sram_rdata_a2[35:24];
      sram_rdata_in_1_c3[3] = sram_rdata_a3[11:0];
      sram_rdata_in_1_c3[4] = sram_rdata_a2[23:12];
      sram_rdata_in_1_c3[5] = sram_rdata_a2[11:0];
      sram_rdata_in_1_c3[6] = sram_rdata_a1[35:24];
      sram_rdata_in_1_c3[7] = sram_rdata_a0[47:36];
      sram_rdata_in_1_c3[8] = sram_rdata_a0[35:24];

      sram_rdata_in_2_c3[0] = sram_rdata_a3[23:12];
      sram_rdata_in_2_c3[1] = sram_rdata_a3[11:0];
      sram_rdata_in_2_c3[2] = sram_rdata_a2[23:12];
      sram_rdata_in_2_c3[3] = sram_rdata_a1[47:36];
      sram_rdata_in_2_c3[4] = sram_rdata_a1[35:24];
      sram_rdata_in_2_c3[5] = sram_rdata_a0[47:36];
      sram_rdata_in_2_c3[6] = sram_rdata_a1[23:12];
      sram_rdata_in_2_c3[7] = sram_rdata_a1[11:0];
      sram_rdata_in_2_c3[8] = sram_rdata_a0[23:12];

      sram_rdata_in_3_c3[0] = sram_rdata_a3[11:0];
      sram_rdata_in_3_c3[1] = sram_rdata_a2[23:12];
      sram_rdata_in_3_c3[2] = sram_rdata_a2[11:0];
      sram_rdata_in_3_c3[3] = sram_rdata_a1[35:24];
      sram_rdata_in_3_c3[4] = sram_rdata_a0[47:36];
      sram_rdata_in_3_c3[5] = sram_rdata_a0[35:24];
      sram_rdata_in_3_c3[6] = sram_rdata_a1[11:0];
      sram_rdata_in_3_c3[7] = sram_rdata_a0[23:12];
      sram_rdata_in_3_c3[8] = sram_rdata_a0[11:0];
    end
    default: begin
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c3[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c3[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c3[i] = 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c3[i] = 0;
    end
  endcase

// multiplier input selection (pw)
reg [11:0] sram_rdata_in_b0[0:3];
reg [11:0] sram_rdata_in_b1[0:3];
reg [11:0] sram_rdata_in_b2[0:3];
reg [11:0] sram_rdata_in_b3[0:3];

always@*
  case(conv_cnt_delay_pw % 3'd4)
    3'd0: begin
      sram_rdata_in_b0[0] = sram_rdata_b0[191:180];
      sram_rdata_in_b0[1] = sram_rdata_b0[143:132];
      sram_rdata_in_b0[2] = sram_rdata_b0[95:84];
      sram_rdata_in_b0[3] = sram_rdata_b0[47:36];

      sram_rdata_in_b1[0] = sram_rdata_b0[179:168];
      sram_rdata_in_b1[1] = sram_rdata_b0[131:120];
      sram_rdata_in_b1[2] = sram_rdata_b0[83:72];
      sram_rdata_in_b1[3] = sram_rdata_b0[35:24];

      sram_rdata_in_b2[0] = sram_rdata_b0[167:156];
      sram_rdata_in_b2[1] = sram_rdata_b0[119:108];
      sram_rdata_in_b2[2] = sram_rdata_b0[71:60];
      sram_rdata_in_b2[3] = sram_rdata_b0[23:12];

      sram_rdata_in_b3[0] = sram_rdata_b0[155:144];
      sram_rdata_in_b3[1] = sram_rdata_b0[107:96];
      sram_rdata_in_b3[2] = sram_rdata_b0[59:48];
      sram_rdata_in_b3[3] = sram_rdata_b0[11:0];

    end
    3'd1: begin
      sram_rdata_in_b0[0] = sram_rdata_b1[191:180];
      sram_rdata_in_b0[1] = sram_rdata_b1[143:132];
      sram_rdata_in_b0[2] = sram_rdata_b1[95:84];
      sram_rdata_in_b0[3] = sram_rdata_b1[47:36];

      sram_rdata_in_b1[0] = sram_rdata_b1[179:168];
      sram_rdata_in_b1[1] = sram_rdata_b1[131:120];
      sram_rdata_in_b1[2] = sram_rdata_b1[83:72];
      sram_rdata_in_b1[3] = sram_rdata_b1[35:24];

      sram_rdata_in_b2[0] = sram_rdata_b1[167:156];
      sram_rdata_in_b2[1] = sram_rdata_b1[119:108];
      sram_rdata_in_b2[2] = sram_rdata_b1[71:60];
      sram_rdata_in_b2[3] = sram_rdata_b1[23:12];

      sram_rdata_in_b3[0] = sram_rdata_b1[155:144];
      sram_rdata_in_b3[1] = sram_rdata_b1[107:96];
      sram_rdata_in_b3[2] = sram_rdata_b1[59:48];
      sram_rdata_in_b3[3] = sram_rdata_b1[11:0];
    end
    3'd2: begin
      sram_rdata_in_b0[0] = sram_rdata_b2[191:180];
      sram_rdata_in_b0[1] = sram_rdata_b2[143:132];
      sram_rdata_in_b0[2] = sram_rdata_b2[95:84];
      sram_rdata_in_b0[3] = sram_rdata_b2[47:36];

      sram_rdata_in_b1[0] = sram_rdata_b2[179:168];
      sram_rdata_in_b1[1] = sram_rdata_b2[131:120];
      sram_rdata_in_b1[2] = sram_rdata_b2[83:72];
      sram_rdata_in_b1[3] = sram_rdata_b2[35:24];

      sram_rdata_in_b2[0] = sram_rdata_b2[167:156];
      sram_rdata_in_b2[1] = sram_rdata_b2[119:108];
      sram_rdata_in_b2[2] = sram_rdata_b2[71:60];
      sram_rdata_in_b2[3] = sram_rdata_b2[23:12];

      sram_rdata_in_b3[0] = sram_rdata_b2[155:144];
      sram_rdata_in_b3[1] = sram_rdata_b2[107:96];
      sram_rdata_in_b3[2] = sram_rdata_b2[59:48];
      sram_rdata_in_b3[3] = sram_rdata_b2[11:0];
    end
    3'd3: begin
      sram_rdata_in_b0[0] = sram_rdata_b3[191:180];
      sram_rdata_in_b0[1] = sram_rdata_b3[143:132];
      sram_rdata_in_b0[2] = sram_rdata_b3[95:84];
      sram_rdata_in_b0[3] = sram_rdata_b3[47:36];

      sram_rdata_in_b1[0] = sram_rdata_b3[179:168];
      sram_rdata_in_b1[1] = sram_rdata_b3[131:120];
      sram_rdata_in_b1[2] = sram_rdata_b3[83:72];
      sram_rdata_in_b1[3] = sram_rdata_b3[35:24];

      sram_rdata_in_b2[0] = sram_rdata_b3[167:156];
      sram_rdata_in_b2[1] = sram_rdata_b3[119:108];
      sram_rdata_in_b2[2] = sram_rdata_b3[71:60];
      sram_rdata_in_b2[3] = sram_rdata_b3[23:12];

      sram_rdata_in_b3[0] = sram_rdata_b3[155:144];
      sram_rdata_in_b3[1] = sram_rdata_b3[107:96];
      sram_rdata_in_b3[2] = sram_rdata_b3[59:48];
      sram_rdata_in_b3[3] = sram_rdata_b3[11:0];
    end
    default: begin
      sram_rdata_in_b0[0] = 0;
      sram_rdata_in_b0[1] = 0;
      sram_rdata_in_b0[2] = 0;
      sram_rdata_in_b0[3] = 0;

      sram_rdata_in_b1[0] = 0;
      sram_rdata_in_b1[1] = 0;
      sram_rdata_in_b1[2] = 0;
      sram_rdata_in_b1[3] = 0;

      sram_rdata_in_b2[0] = 0;
      sram_rdata_in_b2[1] = 0;
      sram_rdata_in_b2[2] = 0;
      sram_rdata_in_b2[3] = 0;

      sram_rdata_in_b3[0] = 0;
      sram_rdata_in_b3[1] = 0;
      sram_rdata_in_b3[2] = 0;
      sram_rdata_in_b3[3] = 0;
    end
  endcase


// select input between dw and pw (pipe)
reg [11:0] sram_rdata_in_0_c0_sel [0:8];
reg [11:0] sram_rdata_in_1_c0_sel [0:8];
reg [11:0] sram_rdata_in_2_c0_sel [0:8];
reg [11:0] sram_rdata_in_3_c0_sel [0:8];
reg [11:0] sram_rdata_in_0_c1_sel [0:8];
reg [11:0] sram_rdata_in_1_c1_sel [0:8];
reg [11:0] sram_rdata_in_2_c1_sel [0:8];
reg [11:0] sram_rdata_in_3_c1_sel [0:8];
reg [11:0] sram_rdata_in_0_c2_sel [0:8];
reg [11:0] sram_rdata_in_1_c2_sel [0:8];
reg [11:0] sram_rdata_in_2_c2_sel [0:8];
reg [11:0] sram_rdata_in_3_c2_sel [0:8];
reg [11:0] sram_rdata_in_0_c3_sel [0:8];
reg [11:0] sram_rdata_in_1_c3_sel [0:8];
reg [11:0] sram_rdata_in_2_c3_sel [0:8];
reg [11:0] sram_rdata_in_3_c3_sel [0:8];

always@(posedge clk)
  if(~srst_n) begin
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c0_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c0_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c0_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c0_sel[i] <= 0;

      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c1_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c1_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c1_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c1_sel[i] <= 0;

      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c2_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c2_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c2_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c2_sel[i] <= 0;

      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c3_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c3_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c3_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c3_sel[i] <= 0;
  end

  else
  case(state)
    CONV1_DW: begin
      sram_rdata_in_0_c0_sel[0] <= sram_rdata_in_0_c0[0];
      sram_rdata_in_0_c0_sel[1] <= sram_rdata_in_0_c0[1];
      sram_rdata_in_0_c0_sel[2] <= sram_rdata_in_0_c0[2];
      sram_rdata_in_0_c0_sel[3] <= sram_rdata_in_0_c0[3];
      sram_rdata_in_0_c0_sel[4] <= sram_rdata_in_0_c0[4];
      sram_rdata_in_0_c0_sel[5] <= sram_rdata_in_0_c0[5];
      sram_rdata_in_0_c0_sel[6] <= sram_rdata_in_0_c0[6];
      sram_rdata_in_0_c0_sel[7] <= sram_rdata_in_0_c0[7];
      sram_rdata_in_0_c0_sel[8] <= sram_rdata_in_0_c0[8];


      sram_rdata_in_1_c0_sel[0] <= sram_rdata_in_1_c0[0];
      sram_rdata_in_1_c0_sel[1] <= sram_rdata_in_1_c0[1];
      sram_rdata_in_1_c0_sel[2] <= sram_rdata_in_1_c0[2];
      sram_rdata_in_1_c0_sel[3] <= sram_rdata_in_1_c0[3];
      sram_rdata_in_1_c0_sel[4] <= sram_rdata_in_1_c0[4];
      sram_rdata_in_1_c0_sel[5] <= sram_rdata_in_1_c0[5];
      sram_rdata_in_1_c0_sel[6] <= sram_rdata_in_1_c0[6];
      sram_rdata_in_1_c0_sel[7] <= sram_rdata_in_1_c0[7];
      sram_rdata_in_1_c0_sel[8] <= sram_rdata_in_1_c0[8];


      sram_rdata_in_2_c0_sel[0] <= sram_rdata_in_2_c0[0];
      sram_rdata_in_2_c0_sel[1] <= sram_rdata_in_2_c0[1];
      sram_rdata_in_2_c0_sel[2] <= sram_rdata_in_2_c0[2];
      sram_rdata_in_2_c0_sel[3] <= sram_rdata_in_2_c0[3];
      sram_rdata_in_2_c0_sel[4] <= sram_rdata_in_2_c0[4];
      sram_rdata_in_2_c0_sel[5] <= sram_rdata_in_2_c0[5];
      sram_rdata_in_2_c0_sel[6] <= sram_rdata_in_2_c0[6];
      sram_rdata_in_2_c0_sel[7] <= sram_rdata_in_2_c0[7];
      sram_rdata_in_2_c0_sel[8] <= sram_rdata_in_2_c0[8];


      sram_rdata_in_3_c0_sel[0] <= sram_rdata_in_3_c0[0];
      sram_rdata_in_3_c0_sel[1] <= sram_rdata_in_3_c0[1];
      sram_rdata_in_3_c0_sel[2] <= sram_rdata_in_3_c0[2];
      sram_rdata_in_3_c0_sel[3] <= sram_rdata_in_3_c0[3];
      sram_rdata_in_3_c0_sel[4] <= sram_rdata_in_3_c0[4];
      sram_rdata_in_3_c0_sel[5] <= sram_rdata_in_3_c0[5];
      sram_rdata_in_3_c0_sel[6] <= sram_rdata_in_3_c0[6];
      sram_rdata_in_3_c0_sel[7] <= sram_rdata_in_3_c0[7];
      sram_rdata_in_3_c0_sel[8] <= sram_rdata_in_3_c0[8];


      sram_rdata_in_0_c1_sel[0] <= sram_rdata_in_0_c1[0];
      sram_rdata_in_0_c1_sel[1] <= sram_rdata_in_0_c1[1];
      sram_rdata_in_0_c1_sel[2] <= sram_rdata_in_0_c1[2];
      sram_rdata_in_0_c1_sel[3] <= sram_rdata_in_0_c1[3];
      sram_rdata_in_0_c1_sel[4] <= sram_rdata_in_0_c1[4];
      sram_rdata_in_0_c1_sel[5] <= sram_rdata_in_0_c1[5];
      sram_rdata_in_0_c1_sel[6] <= sram_rdata_in_0_c1[6];
      sram_rdata_in_0_c1_sel[7] <= sram_rdata_in_0_c1[7];
      sram_rdata_in_0_c1_sel[8] <= sram_rdata_in_0_c1[8];


      sram_rdata_in_1_c1_sel[0] <= sram_rdata_in_1_c1[0];
      sram_rdata_in_1_c1_sel[1] <= sram_rdata_in_1_c1[1];
      sram_rdata_in_1_c1_sel[2] <= sram_rdata_in_1_c1[2];
      sram_rdata_in_1_c1_sel[3] <= sram_rdata_in_1_c1[3];
      sram_rdata_in_1_c1_sel[4] <= sram_rdata_in_1_c1[4];
      sram_rdata_in_1_c1_sel[5] <= sram_rdata_in_1_c1[5];
      sram_rdata_in_1_c1_sel[6] <= sram_rdata_in_1_c1[6];
      sram_rdata_in_1_c1_sel[7] <= sram_rdata_in_1_c1[7];
      sram_rdata_in_1_c1_sel[8] <= sram_rdata_in_1_c1[8];


      sram_rdata_in_2_c1_sel[0] <= sram_rdata_in_2_c1[0];
      sram_rdata_in_2_c1_sel[1] <= sram_rdata_in_2_c1[1];
      sram_rdata_in_2_c1_sel[2] <= sram_rdata_in_2_c1[2];
      sram_rdata_in_2_c1_sel[3] <= sram_rdata_in_2_c1[3];
      sram_rdata_in_2_c1_sel[4] <= sram_rdata_in_2_c1[4];
      sram_rdata_in_2_c1_sel[5] <= sram_rdata_in_2_c1[5];
      sram_rdata_in_2_c1_sel[6] <= sram_rdata_in_2_c1[6];
      sram_rdata_in_2_c1_sel[7] <= sram_rdata_in_2_c1[7];
      sram_rdata_in_2_c1_sel[8] <= sram_rdata_in_2_c1[8];


      sram_rdata_in_3_c1_sel[0] <= sram_rdata_in_3_c1[0];
      sram_rdata_in_3_c1_sel[1] <= sram_rdata_in_3_c1[1];
      sram_rdata_in_3_c1_sel[2] <= sram_rdata_in_3_c1[2];
      sram_rdata_in_3_c1_sel[3] <= sram_rdata_in_3_c1[3];
      sram_rdata_in_3_c1_sel[4] <= sram_rdata_in_3_c1[4];
      sram_rdata_in_3_c1_sel[5] <= sram_rdata_in_3_c1[5];
      sram_rdata_in_3_c1_sel[6] <= sram_rdata_in_3_c1[6];
      sram_rdata_in_3_c1_sel[7] <= sram_rdata_in_3_c1[7];
      sram_rdata_in_3_c1_sel[8] <= sram_rdata_in_3_c1[8];


      sram_rdata_in_0_c2_sel[0] <= sram_rdata_in_0_c2[0];
      sram_rdata_in_0_c2_sel[1] <= sram_rdata_in_0_c2[1];
      sram_rdata_in_0_c2_sel[2] <= sram_rdata_in_0_c2[2];
      sram_rdata_in_0_c2_sel[3] <= sram_rdata_in_0_c2[3];
      sram_rdata_in_0_c2_sel[4] <= sram_rdata_in_0_c2[4];
      sram_rdata_in_0_c2_sel[5] <= sram_rdata_in_0_c2[5];
      sram_rdata_in_0_c2_sel[6] <= sram_rdata_in_0_c2[6];
      sram_rdata_in_0_c2_sel[7] <= sram_rdata_in_0_c2[7];
      sram_rdata_in_0_c2_sel[8] <= sram_rdata_in_0_c2[8];


      sram_rdata_in_1_c2_sel[0] <= sram_rdata_in_1_c2[0];
      sram_rdata_in_1_c2_sel[1] <= sram_rdata_in_1_c2[1];
      sram_rdata_in_1_c2_sel[2] <= sram_rdata_in_1_c2[2];
      sram_rdata_in_1_c2_sel[3] <= sram_rdata_in_1_c2[3];
      sram_rdata_in_1_c2_sel[4] <= sram_rdata_in_1_c2[4];
      sram_rdata_in_1_c2_sel[5] <= sram_rdata_in_1_c2[5];
      sram_rdata_in_1_c2_sel[6] <= sram_rdata_in_1_c2[6];
      sram_rdata_in_1_c2_sel[7] <= sram_rdata_in_1_c2[7];
      sram_rdata_in_1_c2_sel[8] <= sram_rdata_in_1_c2[8];



      sram_rdata_in_2_c2_sel[0] <= sram_rdata_in_2_c2[0];
      sram_rdata_in_2_c2_sel[1] <= sram_rdata_in_2_c2[1];
      sram_rdata_in_2_c2_sel[2] <= sram_rdata_in_2_c2[2];
      sram_rdata_in_2_c2_sel[3] <= sram_rdata_in_2_c2[3];
      sram_rdata_in_2_c2_sel[4] <= sram_rdata_in_2_c2[4];
      sram_rdata_in_2_c2_sel[5] <= sram_rdata_in_2_c2[5];
      sram_rdata_in_2_c2_sel[6] <= sram_rdata_in_2_c2[6];
      sram_rdata_in_2_c2_sel[7] <= sram_rdata_in_2_c2[7];
      sram_rdata_in_2_c2_sel[8] <= sram_rdata_in_2_c2[8];


      sram_rdata_in_3_c2_sel[0] <= sram_rdata_in_3_c2[0];
      sram_rdata_in_3_c2_sel[1] <= sram_rdata_in_3_c2[1];
      sram_rdata_in_3_c2_sel[2] <= sram_rdata_in_3_c2[2];
      sram_rdata_in_3_c2_sel[3] <= sram_rdata_in_3_c2[3];
      sram_rdata_in_3_c2_sel[4] <= sram_rdata_in_3_c2[4];
      sram_rdata_in_3_c2_sel[5] <= sram_rdata_in_3_c2[5];
      sram_rdata_in_3_c2_sel[6] <= sram_rdata_in_3_c2[6];
      sram_rdata_in_3_c2_sel[7] <= sram_rdata_in_3_c2[7];
      sram_rdata_in_3_c2_sel[8] <= sram_rdata_in_3_c2[8];


      sram_rdata_in_0_c3_sel[0] <= sram_rdata_in_0_c3[0];
      sram_rdata_in_0_c3_sel[1] <= sram_rdata_in_0_c3[1];
      sram_rdata_in_0_c3_sel[2] <= sram_rdata_in_0_c3[2];
      sram_rdata_in_0_c3_sel[3] <= sram_rdata_in_0_c3[3];
      sram_rdata_in_0_c3_sel[4] <= sram_rdata_in_0_c3[4];
      sram_rdata_in_0_c3_sel[5] <= sram_rdata_in_0_c3[5];
      sram_rdata_in_0_c3_sel[6] <= sram_rdata_in_0_c3[6];
      sram_rdata_in_0_c3_sel[7] <= sram_rdata_in_0_c3[7];
      sram_rdata_in_0_c3_sel[8] <= sram_rdata_in_0_c3[8];


      sram_rdata_in_1_c3_sel[0] <= sram_rdata_in_1_c3[0];
      sram_rdata_in_1_c3_sel[1] <= sram_rdata_in_1_c3[1];
      sram_rdata_in_1_c3_sel[2] <= sram_rdata_in_1_c3[2];
      sram_rdata_in_1_c3_sel[3] <= sram_rdata_in_1_c3[3];
      sram_rdata_in_1_c3_sel[4] <= sram_rdata_in_1_c3[4];
      sram_rdata_in_1_c3_sel[5] <= sram_rdata_in_1_c3[5];
      sram_rdata_in_1_c3_sel[6] <= sram_rdata_in_1_c3[6];
      sram_rdata_in_1_c3_sel[7] <= sram_rdata_in_1_c3[7];
      sram_rdata_in_1_c3_sel[8] <= sram_rdata_in_1_c3[8];


      sram_rdata_in_2_c3_sel[0] <= sram_rdata_in_2_c3[0];
      sram_rdata_in_2_c3_sel[1] <= sram_rdata_in_2_c3[1];
      sram_rdata_in_2_c3_sel[2] <= sram_rdata_in_2_c3[2];
      sram_rdata_in_2_c3_sel[3] <= sram_rdata_in_2_c3[3];
      sram_rdata_in_2_c3_sel[4] <= sram_rdata_in_2_c3[4];
      sram_rdata_in_2_c3_sel[5] <= sram_rdata_in_2_c3[5];
      sram_rdata_in_2_c3_sel[6] <= sram_rdata_in_2_c3[6];
      sram_rdata_in_2_c3_sel[7] <= sram_rdata_in_2_c3[7];
      sram_rdata_in_2_c3_sel[8] <= sram_rdata_in_2_c3[8];

      sram_rdata_in_3_c3_sel[0] <= sram_rdata_in_3_c3[0];
      sram_rdata_in_3_c3_sel[1] <= sram_rdata_in_3_c3[1];
      sram_rdata_in_3_c3_sel[2] <= sram_rdata_in_3_c3[2];
      sram_rdata_in_3_c3_sel[3] <= sram_rdata_in_3_c3[3];
      sram_rdata_in_3_c3_sel[4] <= sram_rdata_in_3_c3[4];
      sram_rdata_in_3_c3_sel[5] <= sram_rdata_in_3_c3[5];
      sram_rdata_in_3_c3_sel[6] <= sram_rdata_in_3_c3[6];
      sram_rdata_in_3_c3_sel[7] <= sram_rdata_in_3_c3[7];
      sram_rdata_in_3_c3_sel[8] <= sram_rdata_in_3_c3[8];

  
    end
    CONV1_PW: begin
      sram_rdata_in_0_c0_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c0_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c0_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c0_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c0_sel[4] <= 0;
      sram_rdata_in_0_c0_sel[5] <= 0;
      sram_rdata_in_0_c0_sel[6] <= 0;
      sram_rdata_in_0_c0_sel[7] <= 0;
      sram_rdata_in_0_c0_sel[8] <= 0;

      sram_rdata_in_1_c0_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c0_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c0_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c0_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c0_sel[4] <= 0;
      sram_rdata_in_1_c0_sel[5] <= 0;
      sram_rdata_in_1_c0_sel[6] <= 0;
      sram_rdata_in_1_c0_sel[7] <= 0;
      sram_rdata_in_1_c0_sel[8] <= 0;

      sram_rdata_in_2_c0_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c0_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c0_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c0_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c0_sel[4] <= 0;
      sram_rdata_in_2_c0_sel[5] <= 0;
      sram_rdata_in_2_c0_sel[6] <= 0;
      sram_rdata_in_2_c0_sel[7] <= 0;
      sram_rdata_in_2_c0_sel[8] <= 0;


      sram_rdata_in_3_c0_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c0_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c0_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c0_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c0_sel[4] <= 0;
      sram_rdata_in_3_c0_sel[5] <= 0;
      sram_rdata_in_3_c0_sel[6] <= 0;
      sram_rdata_in_3_c0_sel[7] <= 0;
      sram_rdata_in_3_c0_sel[8] <= 0;



      sram_rdata_in_0_c1_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c1_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c1_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c1_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c1_sel[4] <= 0;
      sram_rdata_in_0_c1_sel[5] <= 0;
      sram_rdata_in_0_c1_sel[6] <= 0;
      sram_rdata_in_0_c1_sel[7] <= 0;
      sram_rdata_in_0_c1_sel[8] <= 0;


      sram_rdata_in_1_c1_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c1_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c1_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c1_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c1_sel[4] <= 0;
      sram_rdata_in_1_c1_sel[5] <= 0;
      sram_rdata_in_1_c1_sel[6] <= 0;
      sram_rdata_in_1_c1_sel[7] <= 0;
      sram_rdata_in_1_c1_sel[8] <= 0;


      sram_rdata_in_2_c1_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c1_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c1_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c1_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c1_sel[4] <= 0;
      sram_rdata_in_2_c1_sel[5] <= 0;
      sram_rdata_in_2_c1_sel[6] <= 0;
      sram_rdata_in_2_c1_sel[7] <= 0;
      sram_rdata_in_2_c1_sel[8] <= 0;


      sram_rdata_in_3_c1_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c1_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c1_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c1_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c1_sel[4] <= 0;
      sram_rdata_in_3_c1_sel[5] <= 0;
      sram_rdata_in_3_c1_sel[6] <= 0;
      sram_rdata_in_3_c1_sel[7] <= 0;
      sram_rdata_in_3_c1_sel[8] <= 0;


      sram_rdata_in_0_c2_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c2_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c2_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c2_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c2_sel[4] <= 0;
      sram_rdata_in_0_c2_sel[5] <= 0;
      sram_rdata_in_0_c2_sel[6] <= 0;
      sram_rdata_in_0_c2_sel[7] <= 0;
      sram_rdata_in_0_c2_sel[8] <= 0;


      sram_rdata_in_1_c2_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c2_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c2_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c2_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c2_sel[4] <= 0;
      sram_rdata_in_1_c2_sel[5] <= 0;
      sram_rdata_in_1_c2_sel[6] <= 0;
      sram_rdata_in_1_c2_sel[7] <= 0;
      sram_rdata_in_1_c2_sel[8] <= 0;


      sram_rdata_in_2_c2_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c2_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c2_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c2_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c2_sel[4] <= 0;
      sram_rdata_in_2_c2_sel[5] <= 0;
      sram_rdata_in_2_c2_sel[6] <= 0;
      sram_rdata_in_2_c2_sel[7] <= 0;
      sram_rdata_in_2_c2_sel[8] <= 0;


      sram_rdata_in_3_c2_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c2_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c2_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c2_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c2_sel[4] <= 0;
      sram_rdata_in_3_c2_sel[5] <= 0;
      sram_rdata_in_3_c2_sel[6] <= 0;
      sram_rdata_in_3_c2_sel[7] <= 0;
      sram_rdata_in_3_c2_sel[8] <= 0;


      sram_rdata_in_0_c3_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c3_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c3_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c3_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c3_sel[4] <= 0;
      sram_rdata_in_0_c3_sel[5] <= 0;
      sram_rdata_in_0_c3_sel[6] <= 0;
      sram_rdata_in_0_c3_sel[7] <= 0;
      sram_rdata_in_0_c3_sel[8] <= 0;


      sram_rdata_in_1_c3_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c3_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c3_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c3_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c3_sel[4] <= 0;
      sram_rdata_in_1_c3_sel[5] <= 0;
      sram_rdata_in_1_c3_sel[6] <= 0;
      sram_rdata_in_1_c3_sel[7] <= 0;
      sram_rdata_in_1_c3_sel[8] <= 0;


      sram_rdata_in_2_c3_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c3_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c3_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c3_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c3_sel[4] <= 0;
      sram_rdata_in_2_c3_sel[5] <= 0;
      sram_rdata_in_2_c3_sel[6] <= 0;
      sram_rdata_in_2_c3_sel[7] <= 0;
      sram_rdata_in_2_c3_sel[8] <= 0;


      sram_rdata_in_3_c3_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c3_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c3_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c3_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c3_sel[4] <= 0;
      sram_rdata_in_3_c3_sel[5] <= 0;
      sram_rdata_in_3_c3_sel[6] <= 0;
      sram_rdata_in_3_c3_sel[7] <= 0;
      sram_rdata_in_3_c3_sel[8] <= 0;

    end
    CONV2_DW: begin
      sram_rdata_in_0_c0_sel[0] <= sram_rdata_in_0_c0[0];
      sram_rdata_in_0_c0_sel[1] <= sram_rdata_in_0_c0[1];
      sram_rdata_in_0_c0_sel[2] <= sram_rdata_in_0_c0[2];
      sram_rdata_in_0_c0_sel[3] <= sram_rdata_in_0_c0[3];
      sram_rdata_in_0_c0_sel[4] <= sram_rdata_in_0_c0[4];
      sram_rdata_in_0_c0_sel[5] <= sram_rdata_in_0_c0[5];
      sram_rdata_in_0_c0_sel[6] <= sram_rdata_in_0_c0[6];
      sram_rdata_in_0_c0_sel[7] <= sram_rdata_in_0_c0[7];
      sram_rdata_in_0_c0_sel[8] <= sram_rdata_in_0_c0[8];


      sram_rdata_in_1_c0_sel[0] <= sram_rdata_in_1_c0[0];
      sram_rdata_in_1_c0_sel[1] <= sram_rdata_in_1_c0[1];
      sram_rdata_in_1_c0_sel[2] <= sram_rdata_in_1_c0[2];
      sram_rdata_in_1_c0_sel[3] <= sram_rdata_in_1_c0[3];
      sram_rdata_in_1_c0_sel[4] <= sram_rdata_in_1_c0[4];
      sram_rdata_in_1_c0_sel[5] <= sram_rdata_in_1_c0[5];
      sram_rdata_in_1_c0_sel[6] <= sram_rdata_in_1_c0[6];
      sram_rdata_in_1_c0_sel[7] <= sram_rdata_in_1_c0[7];
      sram_rdata_in_1_c0_sel[8] <= sram_rdata_in_1_c0[8];


      sram_rdata_in_2_c0_sel[0] <= sram_rdata_in_2_c0[0];
      sram_rdata_in_2_c0_sel[1] <= sram_rdata_in_2_c0[1];
      sram_rdata_in_2_c0_sel[2] <= sram_rdata_in_2_c0[2];
      sram_rdata_in_2_c0_sel[3] <= sram_rdata_in_2_c0[3];
      sram_rdata_in_2_c0_sel[4] <= sram_rdata_in_2_c0[4];
      sram_rdata_in_2_c0_sel[5] <= sram_rdata_in_2_c0[5];
      sram_rdata_in_2_c0_sel[6] <= sram_rdata_in_2_c0[6];
      sram_rdata_in_2_c0_sel[7] <= sram_rdata_in_2_c0[7];
      sram_rdata_in_2_c0_sel[8] <= sram_rdata_in_2_c0[8];


      sram_rdata_in_3_c0_sel[0] <= sram_rdata_in_3_c0[0];
      sram_rdata_in_3_c0_sel[1] <= sram_rdata_in_3_c0[1];
      sram_rdata_in_3_c0_sel[2] <= sram_rdata_in_3_c0[2];
      sram_rdata_in_3_c0_sel[3] <= sram_rdata_in_3_c0[3];
      sram_rdata_in_3_c0_sel[4] <= sram_rdata_in_3_c0[4];
      sram_rdata_in_3_c0_sel[5] <= sram_rdata_in_3_c0[5];
      sram_rdata_in_3_c0_sel[6] <= sram_rdata_in_3_c0[6];
      sram_rdata_in_3_c0_sel[7] <= sram_rdata_in_3_c0[7];
      sram_rdata_in_3_c0_sel[8] <= sram_rdata_in_3_c0[8];


      sram_rdata_in_0_c1_sel[0] <= sram_rdata_in_0_c1[0];
      sram_rdata_in_0_c1_sel[1] <= sram_rdata_in_0_c1[1];
      sram_rdata_in_0_c1_sel[2] <= sram_rdata_in_0_c1[2];
      sram_rdata_in_0_c1_sel[3] <= sram_rdata_in_0_c1[3];
      sram_rdata_in_0_c1_sel[4] <= sram_rdata_in_0_c1[4];
      sram_rdata_in_0_c1_sel[5] <= sram_rdata_in_0_c1[5];
      sram_rdata_in_0_c1_sel[6] <= sram_rdata_in_0_c1[6];
      sram_rdata_in_0_c1_sel[7] <= sram_rdata_in_0_c1[7];
      sram_rdata_in_0_c1_sel[8] <= sram_rdata_in_0_c1[8];


      sram_rdata_in_1_c1_sel[0] <= sram_rdata_in_1_c1[0];
      sram_rdata_in_1_c1_sel[1] <= sram_rdata_in_1_c1[1];
      sram_rdata_in_1_c1_sel[2] <= sram_rdata_in_1_c1[2];
      sram_rdata_in_1_c1_sel[3] <= sram_rdata_in_1_c1[3];
      sram_rdata_in_1_c1_sel[4] <= sram_rdata_in_1_c1[4];
      sram_rdata_in_1_c1_sel[5] <= sram_rdata_in_1_c1[5];
      sram_rdata_in_1_c1_sel[6] <= sram_rdata_in_1_c1[6];
      sram_rdata_in_1_c1_sel[7] <= sram_rdata_in_1_c1[7];
      sram_rdata_in_1_c1_sel[8] <= sram_rdata_in_1_c1[8];


      sram_rdata_in_2_c1_sel[0] <= sram_rdata_in_2_c1[0];
      sram_rdata_in_2_c1_sel[1] <= sram_rdata_in_2_c1[1];
      sram_rdata_in_2_c1_sel[2] <= sram_rdata_in_2_c1[2];
      sram_rdata_in_2_c1_sel[3] <= sram_rdata_in_2_c1[3];
      sram_rdata_in_2_c1_sel[4] <= sram_rdata_in_2_c1[4];
      sram_rdata_in_2_c1_sel[5] <= sram_rdata_in_2_c1[5];
      sram_rdata_in_2_c1_sel[6] <= sram_rdata_in_2_c1[6];
      sram_rdata_in_2_c1_sel[7] <= sram_rdata_in_2_c1[7];
      sram_rdata_in_2_c1_sel[8] <= sram_rdata_in_2_c1[8];


      sram_rdata_in_3_c1_sel[0] <= sram_rdata_in_3_c1[0];
      sram_rdata_in_3_c1_sel[1] <= sram_rdata_in_3_c1[1];
      sram_rdata_in_3_c1_sel[2] <= sram_rdata_in_3_c1[2];
      sram_rdata_in_3_c1_sel[3] <= sram_rdata_in_3_c1[3];
      sram_rdata_in_3_c1_sel[4] <= sram_rdata_in_3_c1[4];
      sram_rdata_in_3_c1_sel[5] <= sram_rdata_in_3_c1[5];
      sram_rdata_in_3_c1_sel[6] <= sram_rdata_in_3_c1[6];
      sram_rdata_in_3_c1_sel[7] <= sram_rdata_in_3_c1[7];
      sram_rdata_in_3_c1_sel[8] <= sram_rdata_in_3_c1[8];


      sram_rdata_in_0_c2_sel[0] <= sram_rdata_in_0_c2[0];
      sram_rdata_in_0_c2_sel[1] <= sram_rdata_in_0_c2[1];
      sram_rdata_in_0_c2_sel[2] <= sram_rdata_in_0_c2[2];
      sram_rdata_in_0_c2_sel[3] <= sram_rdata_in_0_c2[3];
      sram_rdata_in_0_c2_sel[4] <= sram_rdata_in_0_c2[4];
      sram_rdata_in_0_c2_sel[5] <= sram_rdata_in_0_c2[5];
      sram_rdata_in_0_c2_sel[6] <= sram_rdata_in_0_c2[6];
      sram_rdata_in_0_c2_sel[7] <= sram_rdata_in_0_c2[7];
      sram_rdata_in_0_c2_sel[8] <= sram_rdata_in_0_c2[8];


      sram_rdata_in_1_c2_sel[0] <= sram_rdata_in_1_c2[0];
      sram_rdata_in_1_c2_sel[1] <= sram_rdata_in_1_c2[1];
      sram_rdata_in_1_c2_sel[2] <= sram_rdata_in_1_c2[2];
      sram_rdata_in_1_c2_sel[3] <= sram_rdata_in_1_c2[3];
      sram_rdata_in_1_c2_sel[4] <= sram_rdata_in_1_c2[4];
      sram_rdata_in_1_c2_sel[5] <= sram_rdata_in_1_c2[5];
      sram_rdata_in_1_c2_sel[6] <= sram_rdata_in_1_c2[6];
      sram_rdata_in_1_c2_sel[7] <= sram_rdata_in_1_c2[7];
      sram_rdata_in_1_c2_sel[8] <= sram_rdata_in_1_c2[8];



      sram_rdata_in_2_c2_sel[0] <= sram_rdata_in_2_c2[0];
      sram_rdata_in_2_c2_sel[1] <= sram_rdata_in_2_c2[1];
      sram_rdata_in_2_c2_sel[2] <= sram_rdata_in_2_c2[2];
      sram_rdata_in_2_c2_sel[3] <= sram_rdata_in_2_c2[3];
      sram_rdata_in_2_c2_sel[4] <= sram_rdata_in_2_c2[4];
      sram_rdata_in_2_c2_sel[5] <= sram_rdata_in_2_c2[5];
      sram_rdata_in_2_c2_sel[6] <= sram_rdata_in_2_c2[6];
      sram_rdata_in_2_c2_sel[7] <= sram_rdata_in_2_c2[7];
      sram_rdata_in_2_c2_sel[8] <= sram_rdata_in_2_c2[8];


      sram_rdata_in_3_c2_sel[0] <= sram_rdata_in_3_c2[0];
      sram_rdata_in_3_c2_sel[1] <= sram_rdata_in_3_c2[1];
      sram_rdata_in_3_c2_sel[2] <= sram_rdata_in_3_c2[2];
      sram_rdata_in_3_c2_sel[3] <= sram_rdata_in_3_c2[3];
      sram_rdata_in_3_c2_sel[4] <= sram_rdata_in_3_c2[4];
      sram_rdata_in_3_c2_sel[5] <= sram_rdata_in_3_c2[5];
      sram_rdata_in_3_c2_sel[6] <= sram_rdata_in_3_c2[6];
      sram_rdata_in_3_c2_sel[7] <= sram_rdata_in_3_c2[7];
      sram_rdata_in_3_c2_sel[8] <= sram_rdata_in_3_c2[8];


      sram_rdata_in_0_c3_sel[0] <= sram_rdata_in_0_c3[0];
      sram_rdata_in_0_c3_sel[1] <= sram_rdata_in_0_c3[1];
      sram_rdata_in_0_c3_sel[2] <= sram_rdata_in_0_c3[2];
      sram_rdata_in_0_c3_sel[3] <= sram_rdata_in_0_c3[3];
      sram_rdata_in_0_c3_sel[4] <= sram_rdata_in_0_c3[4];
      sram_rdata_in_0_c3_sel[5] <= sram_rdata_in_0_c3[5];
      sram_rdata_in_0_c3_sel[6] <= sram_rdata_in_0_c3[6];
      sram_rdata_in_0_c3_sel[7] <= sram_rdata_in_0_c3[7];
      sram_rdata_in_0_c3_sel[8] <= sram_rdata_in_0_c3[8];


      sram_rdata_in_1_c3_sel[0] <= sram_rdata_in_1_c3[0];
      sram_rdata_in_1_c3_sel[1] <= sram_rdata_in_1_c3[1];
      sram_rdata_in_1_c3_sel[2] <= sram_rdata_in_1_c3[2];
      sram_rdata_in_1_c3_sel[3] <= sram_rdata_in_1_c3[3];
      sram_rdata_in_1_c3_sel[4] <= sram_rdata_in_1_c3[4];
      sram_rdata_in_1_c3_sel[5] <= sram_rdata_in_1_c3[5];
      sram_rdata_in_1_c3_sel[6] <= sram_rdata_in_1_c3[6];
      sram_rdata_in_1_c3_sel[7] <= sram_rdata_in_1_c3[7];
      sram_rdata_in_1_c3_sel[8] <= sram_rdata_in_1_c3[8];


      sram_rdata_in_2_c3_sel[0] <= sram_rdata_in_2_c3[0];
      sram_rdata_in_2_c3_sel[1] <= sram_rdata_in_2_c3[1];
      sram_rdata_in_2_c3_sel[2] <= sram_rdata_in_2_c3[2];
      sram_rdata_in_2_c3_sel[3] <= sram_rdata_in_2_c3[3];
      sram_rdata_in_2_c3_sel[4] <= sram_rdata_in_2_c3[4];
      sram_rdata_in_2_c3_sel[5] <= sram_rdata_in_2_c3[5];
      sram_rdata_in_2_c3_sel[6] <= sram_rdata_in_2_c3[6];
      sram_rdata_in_2_c3_sel[7] <= sram_rdata_in_2_c3[7];
      sram_rdata_in_2_c3_sel[8] <= sram_rdata_in_2_c3[8];

      sram_rdata_in_3_c3_sel[0] <= sram_rdata_in_3_c3[0];
      sram_rdata_in_3_c3_sel[1] <= sram_rdata_in_3_c3[1];
      sram_rdata_in_3_c3_sel[2] <= sram_rdata_in_3_c3[2];
      sram_rdata_in_3_c3_sel[3] <= sram_rdata_in_3_c3[3];
      sram_rdata_in_3_c3_sel[4] <= sram_rdata_in_3_c3[4];
      sram_rdata_in_3_c3_sel[5] <= sram_rdata_in_3_c3[5];
      sram_rdata_in_3_c3_sel[6] <= sram_rdata_in_3_c3[6];
      sram_rdata_in_3_c3_sel[7] <= sram_rdata_in_3_c3[7];
      sram_rdata_in_3_c3_sel[8] <= sram_rdata_in_3_c3[8];

    end
    CONV2_PW: begin
      sram_rdata_in_0_c0_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c0_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c0_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c0_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c0_sel[4] <= 0;
      sram_rdata_in_0_c0_sel[5] <= 0;
      sram_rdata_in_0_c0_sel[6] <= 0;
      sram_rdata_in_0_c0_sel[7] <= 0;
      sram_rdata_in_0_c0_sel[8] <= 0;

      sram_rdata_in_1_c0_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c0_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c0_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c0_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c0_sel[4] <= 0;
      sram_rdata_in_1_c0_sel[5] <= 0;
      sram_rdata_in_1_c0_sel[6] <= 0;
      sram_rdata_in_1_c0_sel[7] <= 0;
      sram_rdata_in_1_c0_sel[8] <= 0;

      sram_rdata_in_2_c0_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c0_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c0_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c0_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c0_sel[4] <= 0;
      sram_rdata_in_2_c0_sel[5] <= 0;
      sram_rdata_in_2_c0_sel[6] <= 0;
      sram_rdata_in_2_c0_sel[7] <= 0;
      sram_rdata_in_2_c0_sel[8] <= 0;


      sram_rdata_in_3_c0_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c0_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c0_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c0_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c0_sel[4] <= 0;
      sram_rdata_in_3_c0_sel[5] <= 0;
      sram_rdata_in_3_c0_sel[6] <= 0;
      sram_rdata_in_3_c0_sel[7] <= 0;
      sram_rdata_in_3_c0_sel[8] <= 0;



      sram_rdata_in_0_c1_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c1_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c1_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c1_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c1_sel[4] <= 0;
      sram_rdata_in_0_c1_sel[5] <= 0;
      sram_rdata_in_0_c1_sel[6] <= 0;
      sram_rdata_in_0_c1_sel[7] <= 0;
      sram_rdata_in_0_c1_sel[8] <= 0;


      sram_rdata_in_1_c1_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c1_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c1_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c1_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c1_sel[4] <= 0;
      sram_rdata_in_1_c1_sel[5] <= 0;
      sram_rdata_in_1_c1_sel[6] <= 0;
      sram_rdata_in_1_c1_sel[7] <= 0;
      sram_rdata_in_1_c1_sel[8] <= 0;


      sram_rdata_in_2_c1_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c1_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c1_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c1_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c1_sel[4] <= 0;
      sram_rdata_in_2_c1_sel[5] <= 0;
      sram_rdata_in_2_c1_sel[6] <= 0;
      sram_rdata_in_2_c1_sel[7] <= 0;
      sram_rdata_in_2_c1_sel[8] <= 0;


      sram_rdata_in_3_c1_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c1_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c1_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c1_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c1_sel[4] <= 0;
      sram_rdata_in_3_c1_sel[5] <= 0;
      sram_rdata_in_3_c1_sel[6] <= 0;
      sram_rdata_in_3_c1_sel[7] <= 0;
      sram_rdata_in_3_c1_sel[8] <= 0;


      sram_rdata_in_0_c2_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c2_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c2_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c2_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c2_sel[4] <= 0;
      sram_rdata_in_0_c2_sel[5] <= 0;
      sram_rdata_in_0_c2_sel[6] <= 0;
      sram_rdata_in_0_c2_sel[7] <= 0;
      sram_rdata_in_0_c2_sel[8] <= 0;


      sram_rdata_in_1_c2_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c2_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c2_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c2_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c2_sel[4] <= 0;
      sram_rdata_in_1_c2_sel[5] <= 0;
      sram_rdata_in_1_c2_sel[6] <= 0;
      sram_rdata_in_1_c2_sel[7] <= 0;
      sram_rdata_in_1_c2_sel[8] <= 0;


      sram_rdata_in_2_c2_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c2_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c2_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c2_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c2_sel[4] <= 0;
      sram_rdata_in_2_c2_sel[5] <= 0;
      sram_rdata_in_2_c2_sel[6] <= 0;
      sram_rdata_in_2_c2_sel[7] <= 0;
      sram_rdata_in_2_c2_sel[8] <= 0;


      sram_rdata_in_3_c2_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c2_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c2_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c2_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c2_sel[4] <= 0;
      sram_rdata_in_3_c2_sel[5] <= 0;
      sram_rdata_in_3_c2_sel[6] <= 0;
      sram_rdata_in_3_c2_sel[7] <= 0;
      sram_rdata_in_3_c2_sel[8] <= 0;


      sram_rdata_in_0_c3_sel[0] <= sram_rdata_in_b0[0];
      sram_rdata_in_0_c3_sel[1] <= sram_rdata_in_b0[1];
      sram_rdata_in_0_c3_sel[2] <= sram_rdata_in_b0[2];
      sram_rdata_in_0_c3_sel[3] <= sram_rdata_in_b0[3];
      sram_rdata_in_0_c3_sel[4] <= 0;
      sram_rdata_in_0_c3_sel[5] <= 0;
      sram_rdata_in_0_c3_sel[6] <= 0;
      sram_rdata_in_0_c3_sel[7] <= 0;
      sram_rdata_in_0_c3_sel[8] <= 0;


      sram_rdata_in_1_c3_sel[0] <= sram_rdata_in_b1[0];
      sram_rdata_in_1_c3_sel[1] <= sram_rdata_in_b1[1];
      sram_rdata_in_1_c3_sel[2] <= sram_rdata_in_b1[2];
      sram_rdata_in_1_c3_sel[3] <= sram_rdata_in_b1[3];
      sram_rdata_in_1_c3_sel[4] <= 0;
      sram_rdata_in_1_c3_sel[5] <= 0;
      sram_rdata_in_1_c3_sel[6] <= 0;
      sram_rdata_in_1_c3_sel[7] <= 0;
      sram_rdata_in_1_c3_sel[8] <= 0;


      sram_rdata_in_2_c3_sel[0] <= sram_rdata_in_b2[0];
      sram_rdata_in_2_c3_sel[1] <= sram_rdata_in_b2[1];
      sram_rdata_in_2_c3_sel[2] <= sram_rdata_in_b2[2];
      sram_rdata_in_2_c3_sel[3] <= sram_rdata_in_b2[3];
      sram_rdata_in_2_c3_sel[4] <= 0;
      sram_rdata_in_2_c3_sel[5] <= 0;
      sram_rdata_in_2_c3_sel[6] <= 0;
      sram_rdata_in_2_c3_sel[7] <= 0;
      sram_rdata_in_2_c3_sel[8] <= 0;


      sram_rdata_in_3_c3_sel[0] <= sram_rdata_in_b3[0];
      sram_rdata_in_3_c3_sel[1] <= sram_rdata_in_b3[1];
      sram_rdata_in_3_c3_sel[2] <= sram_rdata_in_b3[2];
      sram_rdata_in_3_c3_sel[3] <= sram_rdata_in_b3[3];
      sram_rdata_in_3_c3_sel[4] <= 0;
      sram_rdata_in_3_c3_sel[5] <= 0;
      sram_rdata_in_3_c3_sel[6] <= 0;
      sram_rdata_in_3_c3_sel[7] <= 0;
      sram_rdata_in_3_c3_sel[8] <= 0;
    end
    CONV3: begin
      sram_rdata_in_0_c0_sel[0] <= sram_rdata_in_0_c0[0];
      sram_rdata_in_0_c0_sel[1] <= sram_rdata_in_0_c0[1];
      sram_rdata_in_0_c0_sel[2] <= sram_rdata_in_0_c0[2];
      sram_rdata_in_0_c0_sel[3] <= sram_rdata_in_0_c0[3];
      sram_rdata_in_0_c0_sel[4] <= sram_rdata_in_0_c0[4];
      sram_rdata_in_0_c0_sel[5] <= sram_rdata_in_0_c0[5];
      sram_rdata_in_0_c0_sel[6] <= sram_rdata_in_0_c0[6];
      sram_rdata_in_0_c0_sel[7] <= sram_rdata_in_0_c0[7];
      sram_rdata_in_0_c0_sel[8] <= sram_rdata_in_0_c0[8];


      sram_rdata_in_1_c0_sel[0] <= sram_rdata_in_1_c0[0];
      sram_rdata_in_1_c0_sel[1] <= sram_rdata_in_1_c0[1];
      sram_rdata_in_1_c0_sel[2] <= sram_rdata_in_1_c0[2];
      sram_rdata_in_1_c0_sel[3] <= sram_rdata_in_1_c0[3];
      sram_rdata_in_1_c0_sel[4] <= sram_rdata_in_1_c0[4];
      sram_rdata_in_1_c0_sel[5] <= sram_rdata_in_1_c0[5];
      sram_rdata_in_1_c0_sel[6] <= sram_rdata_in_1_c0[6];
      sram_rdata_in_1_c0_sel[7] <= sram_rdata_in_1_c0[7];
      sram_rdata_in_1_c0_sel[8] <= sram_rdata_in_1_c0[8];


      sram_rdata_in_2_c0_sel[0] <= sram_rdata_in_2_c0[0];
      sram_rdata_in_2_c0_sel[1] <= sram_rdata_in_2_c0[1];
      sram_rdata_in_2_c0_sel[2] <= sram_rdata_in_2_c0[2];
      sram_rdata_in_2_c0_sel[3] <= sram_rdata_in_2_c0[3];
      sram_rdata_in_2_c0_sel[4] <= sram_rdata_in_2_c0[4];
      sram_rdata_in_2_c0_sel[5] <= sram_rdata_in_2_c0[5];
      sram_rdata_in_2_c0_sel[6] <= sram_rdata_in_2_c0[6];
      sram_rdata_in_2_c0_sel[7] <= sram_rdata_in_2_c0[7];
      sram_rdata_in_2_c0_sel[8] <= sram_rdata_in_2_c0[8];


      sram_rdata_in_3_c0_sel[0] <= sram_rdata_in_3_c0[0];
      sram_rdata_in_3_c0_sel[1] <= sram_rdata_in_3_c0[1];
      sram_rdata_in_3_c0_sel[2] <= sram_rdata_in_3_c0[2];
      sram_rdata_in_3_c0_sel[3] <= sram_rdata_in_3_c0[3];
      sram_rdata_in_3_c0_sel[4] <= sram_rdata_in_3_c0[4];
      sram_rdata_in_3_c0_sel[5] <= sram_rdata_in_3_c0[5];
      sram_rdata_in_3_c0_sel[6] <= sram_rdata_in_3_c0[6];
      sram_rdata_in_3_c0_sel[7] <= sram_rdata_in_3_c0[7];
      sram_rdata_in_3_c0_sel[8] <= sram_rdata_in_3_c0[8];


      sram_rdata_in_0_c1_sel[0] <= sram_rdata_in_0_c1[0];
      sram_rdata_in_0_c1_sel[1] <= sram_rdata_in_0_c1[1];
      sram_rdata_in_0_c1_sel[2] <= sram_rdata_in_0_c1[2];
      sram_rdata_in_0_c1_sel[3] <= sram_rdata_in_0_c1[3];
      sram_rdata_in_0_c1_sel[4] <= sram_rdata_in_0_c1[4];
      sram_rdata_in_0_c1_sel[5] <= sram_rdata_in_0_c1[5];
      sram_rdata_in_0_c1_sel[6] <= sram_rdata_in_0_c1[6];
      sram_rdata_in_0_c1_sel[7] <= sram_rdata_in_0_c1[7];
      sram_rdata_in_0_c1_sel[8] <= sram_rdata_in_0_c1[8];


      sram_rdata_in_1_c1_sel[0] <= sram_rdata_in_1_c1[0];
      sram_rdata_in_1_c1_sel[1] <= sram_rdata_in_1_c1[1];
      sram_rdata_in_1_c1_sel[2] <= sram_rdata_in_1_c1[2];
      sram_rdata_in_1_c1_sel[3] <= sram_rdata_in_1_c1[3];
      sram_rdata_in_1_c1_sel[4] <= sram_rdata_in_1_c1[4];
      sram_rdata_in_1_c1_sel[5] <= sram_rdata_in_1_c1[5];
      sram_rdata_in_1_c1_sel[6] <= sram_rdata_in_1_c1[6];
      sram_rdata_in_1_c1_sel[7] <= sram_rdata_in_1_c1[7];
      sram_rdata_in_1_c1_sel[8] <= sram_rdata_in_1_c1[8];


      sram_rdata_in_2_c1_sel[0] <= sram_rdata_in_2_c1[0];
      sram_rdata_in_2_c1_sel[1] <= sram_rdata_in_2_c1[1];
      sram_rdata_in_2_c1_sel[2] <= sram_rdata_in_2_c1[2];
      sram_rdata_in_2_c1_sel[3] <= sram_rdata_in_2_c1[3];
      sram_rdata_in_2_c1_sel[4] <= sram_rdata_in_2_c1[4];
      sram_rdata_in_2_c1_sel[5] <= sram_rdata_in_2_c1[5];
      sram_rdata_in_2_c1_sel[6] <= sram_rdata_in_2_c1[6];
      sram_rdata_in_2_c1_sel[7] <= sram_rdata_in_2_c1[7];
      sram_rdata_in_2_c1_sel[8] <= sram_rdata_in_2_c1[8];


      sram_rdata_in_3_c1_sel[0] <= sram_rdata_in_3_c1[0];
      sram_rdata_in_3_c1_sel[1] <= sram_rdata_in_3_c1[1];
      sram_rdata_in_3_c1_sel[2] <= sram_rdata_in_3_c1[2];
      sram_rdata_in_3_c1_sel[3] <= sram_rdata_in_3_c1[3];
      sram_rdata_in_3_c1_sel[4] <= sram_rdata_in_3_c1[4];
      sram_rdata_in_3_c1_sel[5] <= sram_rdata_in_3_c1[5];
      sram_rdata_in_3_c1_sel[6] <= sram_rdata_in_3_c1[6];
      sram_rdata_in_3_c1_sel[7] <= sram_rdata_in_3_c1[7];
      sram_rdata_in_3_c1_sel[8] <= sram_rdata_in_3_c1[8];


      sram_rdata_in_0_c2_sel[0] <= sram_rdata_in_0_c2[0];
      sram_rdata_in_0_c2_sel[1] <= sram_rdata_in_0_c2[1];
      sram_rdata_in_0_c2_sel[2] <= sram_rdata_in_0_c2[2];
      sram_rdata_in_0_c2_sel[3] <= sram_rdata_in_0_c2[3];
      sram_rdata_in_0_c2_sel[4] <= sram_rdata_in_0_c2[4];
      sram_rdata_in_0_c2_sel[5] <= sram_rdata_in_0_c2[5];
      sram_rdata_in_0_c2_sel[6] <= sram_rdata_in_0_c2[6];
      sram_rdata_in_0_c2_sel[7] <= sram_rdata_in_0_c2[7];
      sram_rdata_in_0_c2_sel[8] <= sram_rdata_in_0_c2[8];


      sram_rdata_in_1_c2_sel[0] <= sram_rdata_in_1_c2[0];
      sram_rdata_in_1_c2_sel[1] <= sram_rdata_in_1_c2[1];
      sram_rdata_in_1_c2_sel[2] <= sram_rdata_in_1_c2[2];
      sram_rdata_in_1_c2_sel[3] <= sram_rdata_in_1_c2[3];
      sram_rdata_in_1_c2_sel[4] <= sram_rdata_in_1_c2[4];
      sram_rdata_in_1_c2_sel[5] <= sram_rdata_in_1_c2[5];
      sram_rdata_in_1_c2_sel[6] <= sram_rdata_in_1_c2[6];
      sram_rdata_in_1_c2_sel[7] <= sram_rdata_in_1_c2[7];
      sram_rdata_in_1_c2_sel[8] <= sram_rdata_in_1_c2[8];



      sram_rdata_in_2_c2_sel[0] <= sram_rdata_in_2_c2[0];
      sram_rdata_in_2_c2_sel[1] <= sram_rdata_in_2_c2[1];
      sram_rdata_in_2_c2_sel[2] <= sram_rdata_in_2_c2[2];
      sram_rdata_in_2_c2_sel[3] <= sram_rdata_in_2_c2[3];
      sram_rdata_in_2_c2_sel[4] <= sram_rdata_in_2_c2[4];
      sram_rdata_in_2_c2_sel[5] <= sram_rdata_in_2_c2[5];
      sram_rdata_in_2_c2_sel[6] <= sram_rdata_in_2_c2[6];
      sram_rdata_in_2_c2_sel[7] <= sram_rdata_in_2_c2[7];
      sram_rdata_in_2_c2_sel[8] <= sram_rdata_in_2_c2[8];


      sram_rdata_in_3_c2_sel[0] <= sram_rdata_in_3_c2[0];
      sram_rdata_in_3_c2_sel[1] <= sram_rdata_in_3_c2[1];
      sram_rdata_in_3_c2_sel[2] <= sram_rdata_in_3_c2[2];
      sram_rdata_in_3_c2_sel[3] <= sram_rdata_in_3_c2[3];
      sram_rdata_in_3_c2_sel[4] <= sram_rdata_in_3_c2[4];
      sram_rdata_in_3_c2_sel[5] <= sram_rdata_in_3_c2[5];
      sram_rdata_in_3_c2_sel[6] <= sram_rdata_in_3_c2[6];
      sram_rdata_in_3_c2_sel[7] <= sram_rdata_in_3_c2[7];
      sram_rdata_in_3_c2_sel[8] <= sram_rdata_in_3_c2[8];


      sram_rdata_in_0_c3_sel[0] <= sram_rdata_in_0_c3[0];
      sram_rdata_in_0_c3_sel[1] <= sram_rdata_in_0_c3[1];
      sram_rdata_in_0_c3_sel[2] <= sram_rdata_in_0_c3[2];
      sram_rdata_in_0_c3_sel[3] <= sram_rdata_in_0_c3[3];
      sram_rdata_in_0_c3_sel[4] <= sram_rdata_in_0_c3[4];
      sram_rdata_in_0_c3_sel[5] <= sram_rdata_in_0_c3[5];
      sram_rdata_in_0_c3_sel[6] <= sram_rdata_in_0_c3[6];
      sram_rdata_in_0_c3_sel[7] <= sram_rdata_in_0_c3[7];
      sram_rdata_in_0_c3_sel[8] <= sram_rdata_in_0_c3[8];


      sram_rdata_in_1_c3_sel[0] <= sram_rdata_in_1_c3[0];
      sram_rdata_in_1_c3_sel[1] <= sram_rdata_in_1_c3[1];
      sram_rdata_in_1_c3_sel[2] <= sram_rdata_in_1_c3[2];
      sram_rdata_in_1_c3_sel[3] <= sram_rdata_in_1_c3[3];
      sram_rdata_in_1_c3_sel[4] <= sram_rdata_in_1_c3[4];
      sram_rdata_in_1_c3_sel[5] <= sram_rdata_in_1_c3[5];
      sram_rdata_in_1_c3_sel[6] <= sram_rdata_in_1_c3[6];
      sram_rdata_in_1_c3_sel[7] <= sram_rdata_in_1_c3[7];
      sram_rdata_in_1_c3_sel[8] <= sram_rdata_in_1_c3[8];


      sram_rdata_in_2_c3_sel[0] <= sram_rdata_in_2_c3[0];
      sram_rdata_in_2_c3_sel[1] <= sram_rdata_in_2_c3[1];
      sram_rdata_in_2_c3_sel[2] <= sram_rdata_in_2_c3[2];
      sram_rdata_in_2_c3_sel[3] <= sram_rdata_in_2_c3[3];
      sram_rdata_in_2_c3_sel[4] <= sram_rdata_in_2_c3[4];
      sram_rdata_in_2_c3_sel[5] <= sram_rdata_in_2_c3[5];
      sram_rdata_in_2_c3_sel[6] <= sram_rdata_in_2_c3[6];
      sram_rdata_in_2_c3_sel[7] <= sram_rdata_in_2_c3[7];
      sram_rdata_in_2_c3_sel[8] <= sram_rdata_in_2_c3[8];

      sram_rdata_in_3_c3_sel[0] <= sram_rdata_in_3_c3[0];
      sram_rdata_in_3_c3_sel[1] <= sram_rdata_in_3_c3[1];
      sram_rdata_in_3_c3_sel[2] <= sram_rdata_in_3_c3[2];
      sram_rdata_in_3_c3_sel[3] <= sram_rdata_in_3_c3[3];
      sram_rdata_in_3_c3_sel[4] <= sram_rdata_in_3_c3[4];
      sram_rdata_in_3_c3_sel[5] <= sram_rdata_in_3_c3[5];
      sram_rdata_in_3_c3_sel[6] <= sram_rdata_in_3_c3[6];
      sram_rdata_in_3_c3_sel[7] <= sram_rdata_in_3_c3[7];
      sram_rdata_in_3_c3_sel[8] <= sram_rdata_in_3_c3[8];

    end
    default: begin
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c0_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c0_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c0_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c0_sel[i] <= 0;

      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c1_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c1_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c1_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c1_sel[i] <= 0;

      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c2_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c2_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c2_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c2_sel[i] <= 0;

      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_0_c3_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_1_c3_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_2_c3_sel[i] <= 0;
      for(i = 0; i < 9; i = i+1)
        sram_rdata_in_3_c3_sel[i] <= 0;
    end
  endcase
   



// ---------------------------------------------------------------------------------convolution input selection---------------------------------------------------------------------//

// ---------------------------------------------------------------------------------convolution multiplier(pipe)---------------------------------------------------------------------//

// channel 0/4/8
reg signed [20:0] mult_result_0_0 [0:8];
reg signed [20:0] mult_result_0_1 [0:8];
reg signed [20:0] mult_result_0_2 [0:8];
reg signed [20:0] mult_result_0_3 [0:8];
always@(posedge clk)
  if(~srst_n) begin
    for(i = 0; i < 9; i = i+1)
      mult_result_0_0[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_0_1[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_0_2[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_0_3[i] <= 0;
  end  
  else begin
    for(i = 0; i < 9; i = i+1)
      mult_result_0_0[i] <= $signed(weight_0_in[i]) * $signed(sram_rdata_in_0_c0_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_0_1[i] <= $signed(weight_0_in[i]) * $signed(sram_rdata_in_1_c0_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_0_2[i] <= $signed(weight_0_in[i]) * $signed(sram_rdata_in_2_c0_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_0_3[i] <= $signed(weight_0_in[i]) * $signed(sram_rdata_in_3_c0_sel[i]);
  end



// channel 1/5/9
reg signed [20:0] mult_result_1_0 [0:8];
reg signed [20:0] mult_result_1_1 [0:8];
reg signed [20:0] mult_result_1_2 [0:8];
reg signed [20:0] mult_result_1_3 [0:8];

always@(posedge clk)
  if(~srst_n) begin
    for(i = 0; i < 9; i = i+1)
      mult_result_1_0[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_1_1[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_1_2[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_1_3[i] <= 0;
  end  
  else begin
    for(i = 0; i < 9; i = i+1)
      mult_result_1_0[i] <= $signed(weight_1_in[i]) * $signed(sram_rdata_in_0_c1_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_1_1[i] <= $signed(weight_1_in[i]) * $signed(sram_rdata_in_1_c1_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_1_2[i] <= $signed(weight_1_in[i]) * $signed(sram_rdata_in_2_c1_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_1_3[i] <= $signed(weight_1_in[i]) * $signed(sram_rdata_in_3_c1_sel[i]);
  end

// channel 2/6/10
reg signed [20:0] mult_result_2_0 [0:8];
reg signed [20:0] mult_result_2_1 [0:8];
reg signed [20:0] mult_result_2_2 [0:8];
reg signed [20:0] mult_result_2_3 [0:8];

always@(posedge clk)
  if(~srst_n) begin
    for(i = 0; i < 9; i = i+1)
      mult_result_2_0[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_2_1[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_2_2[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_2_3[i] <= 0;
  end  
  else begin
    for(i = 0; i < 9; i = i+1)
      mult_result_2_0[i] <= $signed(weight_2_in[i]) * $signed(sram_rdata_in_0_c2_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_2_1[i] <= $signed(weight_2_in[i]) * $signed(sram_rdata_in_1_c2_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_2_2[i] <= $signed(weight_2_in[i]) * $signed(sram_rdata_in_2_c2_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_2_3[i] <= $signed(weight_2_in[i]) * $signed(sram_rdata_in_3_c2_sel[i]);
  end


// channel 3/7/11
reg signed [20:0] mult_result_3_0 [0:8];
reg signed [20:0] mult_result_3_1 [0:8];
reg signed [20:0] mult_result_3_2 [0:8];
reg signed [20:0] mult_result_3_3 [0:8];
always@(posedge clk)
  if(~srst_n) begin
    for(i = 0; i < 9; i = i+1)
      mult_result_3_0[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_3_1[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_3_2[i] <= 0;

    for(i = 0; i < 9; i = i+1)
      mult_result_3_3[i] <= 0;
  end  
  else begin
    for(i = 0; i < 9; i = i+1)
      mult_result_3_0[i] <= $signed(weight_3_in[i]) * $signed(sram_rdata_in_0_c3_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_3_1[i] <= $signed(weight_3_in[i]) * $signed(sram_rdata_in_1_c3_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_3_2[i] <= $signed(weight_3_in[i]) * $signed(sram_rdata_in_2_c3_sel[i]);

    for(i = 0; i < 9; i = i+1)
      mult_result_3_3[i] <= $signed(weight_3_in[i]) * $signed(sram_rdata_in_3_c3_sel[i]);
  end



// ---------------------------------------------------------------------------------convolution multiplier(pipe)---------------------------------------------------------------------//

// ---------------------------------------------------------------------------------convolution adder (phase 1)(pipe)---------------------------------------------------------------------//
// channel 0/4/8
reg signed [20:0] add_result_0_0_p1 [0:4];
reg signed [20:0] add_result_0_1_p1 [0:4];
reg signed [20:0] add_result_0_2_p1 [0:4];
reg signed [20:0] add_result_0_3_p1 [0:4];


always@*  begin
    add_result_0_0_p1[0] = mult_result_0_0[0] + mult_result_0_0[1];
    add_result_0_0_p1[1] = mult_result_0_0[2] + mult_result_0_0[3];
    add_result_0_0_p1[2] = mult_result_0_0[4] + mult_result_0_0[5];
    add_result_0_0_p1[3] = mult_result_0_0[6] + mult_result_0_0[7];
    add_result_0_0_p1[4] = mult_result_0_0[8];

    add_result_0_1_p1[0] = mult_result_0_1[0] + mult_result_0_1[1];
    add_result_0_1_p1[1] = mult_result_0_1[2] + mult_result_0_1[3];
    add_result_0_1_p1[2] = mult_result_0_1[4] + mult_result_0_1[5];
    add_result_0_1_p1[3] = mult_result_0_1[6] + mult_result_0_1[7];
    add_result_0_1_p1[4] = mult_result_0_1[8];

    add_result_0_2_p1[0] = mult_result_0_2[0] + mult_result_0_2[1];
    add_result_0_2_p1[1] = mult_result_0_2[2] + mult_result_0_2[3];
    add_result_0_2_p1[2] = mult_result_0_2[4] + mult_result_0_2[5];
    add_result_0_2_p1[3] = mult_result_0_2[6] + mult_result_0_2[7];
    add_result_0_2_p1[4] = mult_result_0_2[8];

    add_result_0_3_p1[0] = mult_result_0_3[0] + mult_result_0_3[1];
    add_result_0_3_p1[1] = mult_result_0_3[2] + mult_result_0_3[3];
    add_result_0_3_p1[2] = mult_result_0_3[4] + mult_result_0_3[5];
    add_result_0_3_p1[3] = mult_result_0_3[6] + mult_result_0_3[7];
    add_result_0_3_p1[4] = mult_result_0_3[8];
end


// channel 1/5/9
reg signed [20:0] add_result_1_0_p1 [0:4];
reg signed [20:0] add_result_1_1_p1 [0:4];
reg signed [20:0] add_result_1_2_p1 [0:4];
reg signed [20:0] add_result_1_3_p1 [0:4];


always@* begin
    add_result_1_0_p1[0] = mult_result_1_0[0] + mult_result_1_0[1];
    add_result_1_0_p1[1] = mult_result_1_0[2] + mult_result_1_0[3];
    add_result_1_0_p1[2] = mult_result_1_0[4] + mult_result_1_0[5];
    add_result_1_0_p1[3] = mult_result_1_0[6] + mult_result_1_0[7];
    add_result_1_0_p1[4] = mult_result_1_0[8];

    add_result_1_1_p1[0] = mult_result_1_1[0] + mult_result_1_1[1];
    add_result_1_1_p1[1] = mult_result_1_1[2] + mult_result_1_1[3];
    add_result_1_1_p1[2] = mult_result_1_1[4] + mult_result_1_1[5];
    add_result_1_1_p1[3] = mult_result_1_1[6] + mult_result_1_1[7];
    add_result_1_1_p1[4] = mult_result_1_1[8];

    add_result_1_2_p1[0] = mult_result_1_2[0] + mult_result_1_2[1];
    add_result_1_2_p1[1] = mult_result_1_2[2] + mult_result_1_2[3];
    add_result_1_2_p1[2] = mult_result_1_2[4] + mult_result_1_2[5];
    add_result_1_2_p1[3] = mult_result_1_2[6] + mult_result_1_2[7];
    add_result_1_2_p1[4] = mult_result_1_2[8];

    add_result_1_3_p1[0] = mult_result_1_3[0] + mult_result_1_3[1];
    add_result_1_3_p1[1] = mult_result_1_3[2] + mult_result_1_3[3];
    add_result_1_3_p1[2] = mult_result_1_3[4] + mult_result_1_3[5];
    add_result_1_3_p1[3] = mult_result_1_3[6] + mult_result_1_3[7];
    add_result_1_3_p1[4] = mult_result_1_3[8];
end



// channel 2/6/10
reg signed [20:0] add_result_2_0_p1 [0:4];
reg signed [20:0] add_result_2_1_p1 [0:4];
reg signed [20:0] add_result_2_2_p1 [0:4];
reg signed [20:0] add_result_2_3_p1 [0:4];

always@* begin
    add_result_2_0_p1[0] = mult_result_2_0[0] + mult_result_2_0[1];
    add_result_2_0_p1[1] = mult_result_2_0[2] + mult_result_2_0[3];
    add_result_2_0_p1[2] = mult_result_2_0[4] + mult_result_2_0[5];
    add_result_2_0_p1[3] = mult_result_2_0[6] + mult_result_2_0[7];
    add_result_2_0_p1[4] = mult_result_2_0[8];

    add_result_2_1_p1[0] = mult_result_2_1[0] + mult_result_2_1[1];
    add_result_2_1_p1[1] = mult_result_2_1[2] + mult_result_2_1[3];
    add_result_2_1_p1[2] = mult_result_2_1[4] + mult_result_2_1[5];
    add_result_2_1_p1[3] = mult_result_2_1[6] + mult_result_2_1[7];
    add_result_2_1_p1[4] = mult_result_2_1[8];

    add_result_2_2_p1[0] = mult_result_2_2[0] + mult_result_2_2[1];
    add_result_2_2_p1[1] = mult_result_2_2[2] + mult_result_2_2[3];
    add_result_2_2_p1[2] = mult_result_2_2[4] + mult_result_2_2[5];
    add_result_2_2_p1[3] = mult_result_2_2[6] + mult_result_2_2[7];
    add_result_2_2_p1[4] = mult_result_2_2[8];

    add_result_2_3_p1[0] = mult_result_2_3[0] + mult_result_2_3[1];
    add_result_2_3_p1[1] = mult_result_2_3[2] + mult_result_2_3[3];
    add_result_2_3_p1[2] = mult_result_2_3[4] + mult_result_2_3[5];
    add_result_2_3_p1[3] = mult_result_2_3[6] + mult_result_2_3[7];
    add_result_2_3_p1[4] = mult_result_2_3[8];
end


// channel 3/7/11
reg signed [20:0] add_result_3_0_p1 [0:4];
reg signed [20:0] add_result_3_1_p1 [0:4];
reg signed [20:0] add_result_3_2_p1 [0:4];
reg signed [20:0] add_result_3_3_p1 [0:4];


always@* begin
    add_result_3_0_p1[0] = mult_result_3_0[0] + mult_result_3_0[1];
    add_result_3_0_p1[1] = mult_result_3_0[2] + mult_result_3_0[3];
    add_result_3_0_p1[2] = mult_result_3_0[4] + mult_result_3_0[5];
    add_result_3_0_p1[3] = mult_result_3_0[6] + mult_result_3_0[7];
    add_result_3_0_p1[4] = mult_result_3_0[8];

    add_result_3_1_p1[0] = mult_result_3_1[0] + mult_result_3_1[1];
    add_result_3_1_p1[1] = mult_result_3_1[2] + mult_result_3_1[3];
    add_result_3_1_p1[2] = mult_result_3_1[4] + mult_result_3_1[5];
    add_result_3_1_p1[3] = mult_result_3_1[6] + mult_result_3_1[7];
    add_result_3_1_p1[4] = mult_result_3_1[8];

    add_result_3_2_p1[0] = mult_result_3_2[0] + mult_result_3_2[1];
    add_result_3_2_p1[1] = mult_result_3_2[2] + mult_result_3_2[3];
    add_result_3_2_p1[2] = mult_result_3_2[4] + mult_result_3_2[5];
    add_result_3_2_p1[3] = mult_result_3_2[6] + mult_result_3_2[7];
    add_result_3_2_p1[4] = mult_result_3_2[8];

    add_result_3_3_p1[0] = mult_result_3_3[0] + mult_result_3_3[1];
    add_result_3_3_p1[1] = mult_result_3_3[2] + mult_result_3_3[3];
    add_result_3_3_p1[2] = mult_result_3_3[4] + mult_result_3_3[5];
    add_result_3_3_p1[3] = mult_result_3_3[6] + mult_result_3_3[7];
    add_result_3_3_p1[4] = mult_result_3_3[8];
end




// ---------------------------------------------------------------------------------convolution adder (phase 1)(pipe)---------------------------------------------------------------------//

// ---------------------------------------------------------------------------------convolution adder (phase 2)(pipe)---------------------------------------------------------------------//

// channel 0/4/8
reg signed [20:0] add_result_0_0_p2 [0:2];
reg signed [20:0] add_result_0_1_p2 [0:2];
reg signed [20:0] add_result_0_2_p2 [0:2];
reg signed [20:0] add_result_0_3_p2 [0:2];
always@(posedge clk)
  if(~srst_n) begin
    add_result_0_0_p2[0] <= 0;
    add_result_0_0_p2[1] <= 0;
    add_result_0_0_p2[2] <= 0;

    add_result_0_1_p2[0] <= 0;
    add_result_0_1_p2[1] <= 0;
    add_result_0_1_p2[2] <= 0;

    add_result_0_2_p2[0] <= 0;
    add_result_0_2_p2[1] <= 0;
    add_result_0_2_p2[2] <= 0;

    add_result_0_3_p2[0] <= 0;
    add_result_0_3_p2[1] <= 0;
    add_result_0_3_p2[2] <= 0;

  end
  else begin
    add_result_0_0_p2[0] <= add_result_0_0_p1[0] + add_result_0_0_p1[1];
    add_result_0_0_p2[1] <= add_result_0_0_p1[2] + add_result_0_0_p1[3];
    add_result_0_0_p2[2] <= add_result_0_0_p1[4];

    add_result_0_1_p2[0] <= add_result_0_1_p1[0] + add_result_0_1_p1[1];
    add_result_0_1_p2[1] <= add_result_0_1_p1[2] + add_result_0_1_p1[3];
    add_result_0_1_p2[2] <= add_result_0_1_p1[4];

    add_result_0_2_p2[0] <= add_result_0_2_p1[0] + add_result_0_2_p1[1];
    add_result_0_2_p2[1] <= add_result_0_2_p1[2] + add_result_0_2_p1[3];
    add_result_0_2_p2[2] <= add_result_0_2_p1[4];

    add_result_0_3_p2[0] <= add_result_0_3_p1[0] + add_result_0_3_p1[1];
    add_result_0_3_p2[1] <= add_result_0_3_p1[2] + add_result_0_3_p1[3];
    add_result_0_3_p2[2] <= add_result_0_3_p1[4];
end


// channel 1/5/9
reg signed [20:0] add_result_1_0_p2 [0:2];
reg signed [20:0] add_result_1_1_p2 [0:2];
reg signed [20:0] add_result_1_2_p2 [0:2];
reg signed [20:0] add_result_1_3_p2 [0:2];
always@(posedge clk)
  if(~srst_n) begin
    add_result_1_0_p2[0] <= 0;
    add_result_1_0_p2[1] <= 0;
    add_result_1_0_p2[2] <= 0;

    add_result_1_1_p2[0] <= 0;
    add_result_1_1_p2[1] <= 0;
    add_result_1_1_p2[2] <= 0;

    add_result_1_2_p2[0] <= 0;
    add_result_1_2_p2[1] <= 0;
    add_result_1_2_p2[2] <= 0;

    add_result_1_3_p2[0] <= 0;
    add_result_1_3_p2[1] <= 0;
    add_result_1_3_p2[2] <= 0;

  end
  else begin
    add_result_1_0_p2[0] <= add_result_1_0_p1[0] + add_result_1_0_p1[1];
    add_result_1_0_p2[1] <= add_result_1_0_p1[2] + add_result_1_0_p1[3];
    add_result_1_0_p2[2] <= add_result_1_0_p1[4];

    add_result_1_1_p2[0] <= add_result_1_1_p1[0] + add_result_1_1_p1[1];
    add_result_1_1_p2[1] <= add_result_1_1_p1[2] + add_result_1_1_p1[3];
    add_result_1_1_p2[2] <= add_result_1_1_p1[4];

    add_result_1_2_p2[0] <= add_result_1_2_p1[0] + add_result_1_2_p1[1];
    add_result_1_2_p2[1] <= add_result_1_2_p1[2] + add_result_1_2_p1[3];
    add_result_1_2_p2[2] <= add_result_1_2_p1[4];

    add_result_1_3_p2[0] <= add_result_1_3_p1[0] + add_result_1_3_p1[1];
    add_result_1_3_p2[1] <= add_result_1_3_p1[2] + add_result_1_3_p1[3];
    add_result_1_3_p2[2] <= add_result_1_3_p1[4];
end




// channel 2/6/10
reg signed [20:0] add_result_2_0_p2 [0:2];
reg signed [20:0] add_result_2_1_p2 [0:2];
reg signed [20:0] add_result_2_2_p2 [0:2];
reg signed [20:0] add_result_2_3_p2 [0:2];
always@(posedge clk)
  if(~srst_n) begin
    add_result_2_0_p2[0] <= 0;
    add_result_2_0_p2[1] <= 0;
    add_result_2_0_p2[2] <= 0;

    add_result_2_1_p2[0] <= 0;
    add_result_2_1_p2[1] <= 0;
    add_result_2_1_p2[2] <= 0;

    add_result_2_2_p2[0] <= 0;
    add_result_2_2_p2[1] <= 0;
    add_result_2_2_p2[2] <= 0;

    add_result_2_3_p2[0] <= 0;
    add_result_2_3_p2[1] <= 0;
    add_result_2_3_p2[2] <= 0;

  end
  else begin
    add_result_2_0_p2[0] <= add_result_2_0_p1[0] + add_result_2_0_p1[1];
    add_result_2_0_p2[1] <= add_result_2_0_p1[2] + add_result_2_0_p1[3];
    add_result_2_0_p2[2] <= add_result_2_0_p1[4];

    add_result_2_1_p2[0] <= add_result_2_1_p1[0] + add_result_2_1_p1[1];
    add_result_2_1_p2[1] <= add_result_2_1_p1[2] + add_result_2_1_p1[3];
    add_result_2_1_p2[2] <= add_result_2_1_p1[4];

    add_result_2_2_p2[0] <= add_result_2_2_p1[0] + add_result_2_2_p1[1];
    add_result_2_2_p2[1] <= add_result_2_2_p1[2] + add_result_2_2_p1[3];
    add_result_2_2_p2[2] <= add_result_2_2_p1[4];

    add_result_2_3_p2[0] <= add_result_2_3_p1[0] + add_result_2_3_p1[1];
    add_result_2_3_p2[1] <= add_result_2_3_p1[2] + add_result_2_3_p1[3];
    add_result_2_3_p2[2] <= add_result_2_3_p1[4];
end

// channel 3/7/11
reg signed [20:0] add_result_3_0_p2 [0:2];
reg signed [20:0] add_result_3_1_p2 [0:2];
reg signed [20:0] add_result_3_2_p2 [0:2];
reg signed [20:0] add_result_3_3_p2 [0:2];
always@(posedge clk)
  if(~srst_n) begin
    add_result_3_0_p2[0] <= 0;
    add_result_3_0_p2[1] <= 0;
    add_result_3_0_p2[2] <= 0;

    add_result_3_1_p2[0] <= 0;
    add_result_3_1_p2[1] <= 0;
    add_result_3_1_p2[2] <= 0;

    add_result_3_2_p2[0] <= 0;
    add_result_3_2_p2[1] <= 0;
    add_result_3_2_p2[2] <= 0;

    add_result_3_3_p2[0] <= 0;
    add_result_3_3_p2[1] <= 0;
    add_result_3_3_p2[2] <= 0;

  end
  else begin
    add_result_3_0_p2[0] <= add_result_3_0_p1[0] + add_result_3_0_p1[1];
    add_result_3_0_p2[1] <= add_result_3_0_p1[2] + add_result_3_0_p1[3];
    add_result_3_0_p2[2] <= add_result_3_0_p1[4];

    add_result_3_1_p2[0] <= add_result_3_1_p1[0] + add_result_3_1_p1[1];
    add_result_3_1_p2[1] <= add_result_3_1_p1[2] + add_result_3_1_p1[3];
    add_result_3_1_p2[2] <= add_result_3_1_p1[4];

    add_result_3_2_p2[0] <= add_result_3_2_p1[0] + add_result_3_2_p1[1];
    add_result_3_2_p2[1] <= add_result_3_2_p1[2] + add_result_3_2_p1[3];
    add_result_3_2_p2[2] <= add_result_3_2_p1[4];

    add_result_3_3_p2[0] <= add_result_3_3_p1[0] + add_result_3_3_p1[1];
    add_result_3_3_p2[1] <= add_result_3_3_p1[2] + add_result_3_3_p1[3];
    add_result_3_3_p2[2] <= add_result_3_3_p1[4];
end


// ---------------------------------------------------------------------------------convolution adder (phase 2)(pipe)---------------------------------------------------------------------//

// ---------------------------------------------------------------------------------convolution adder (phase 3)(pipe)---------------------------------------------------------------------//
// channel 0/4/8
reg signed [20:0] add_result_0_0_p3 [0:1];
reg signed [20:0] add_result_0_1_p3 [0:1];
reg signed [20:0] add_result_0_2_p3 [0:1];
reg signed [20:0] add_result_0_3_p3 [0:1];



always@* begin
    add_result_0_0_p3[0] = add_result_0_0_p2[0] + add_result_0_0_p2[1];
    add_result_0_0_p3[1] = add_result_0_0_p2[2];

    add_result_0_1_p3[0] = add_result_0_1_p2[0] + add_result_0_1_p2[1];
    add_result_0_1_p3[1] = add_result_0_1_p2[2];

    add_result_0_2_p3[0] = add_result_0_2_p2[0] + add_result_0_2_p2[1];
    add_result_0_2_p3[1] = add_result_0_2_p2[2];

    add_result_0_3_p3[0] = add_result_0_3_p2[0] + add_result_0_3_p2[1];
    add_result_0_3_p3[1] = add_result_0_3_p2[2];
end

// channel 1/5/9
reg signed [20:0] add_result_1_0_p3 [0:1];
reg signed [20:0] add_result_1_1_p3 [0:1];
reg signed [20:0] add_result_1_2_p3 [0:1];
reg signed [20:0] add_result_1_3_p3 [0:1];


always@* begin
    add_result_1_0_p3[0] = add_result_1_0_p2[0] + add_result_1_0_p2[1];
    add_result_1_0_p3[1] = add_result_1_0_p2[2];

    add_result_1_1_p3[0] = add_result_1_1_p2[0] + add_result_1_1_p2[1];
    add_result_1_1_p3[1] = add_result_1_1_p2[2];

    add_result_1_2_p3[0] = add_result_1_2_p2[0] + add_result_1_2_p2[1];
    add_result_1_2_p3[1] = add_result_1_2_p2[2];

    add_result_1_3_p3[0] = add_result_1_3_p2[0] + add_result_1_3_p2[1];
    add_result_1_3_p3[1] = add_result_1_3_p2[2];
end


// channel 2/6/10
reg signed [20:0] add_result_2_0_p3 [0:1];
reg signed [20:0] add_result_2_1_p3 [0:1];
reg signed [20:0] add_result_2_2_p3 [0:1];
reg signed [20:0] add_result_2_3_p3 [0:1];

always@* begin

    add_result_2_0_p3[0] = add_result_2_0_p2[0] + add_result_2_0_p2[1];
    add_result_2_0_p3[1] = add_result_2_0_p2[2];

    add_result_2_1_p3[0] = add_result_2_1_p2[0] + add_result_2_1_p2[1];
    add_result_2_1_p3[1] = add_result_2_1_p2[2];

    add_result_2_2_p3[0] = add_result_2_2_p2[0] + add_result_2_2_p2[1];
    add_result_2_2_p3[1] = add_result_2_2_p2[2];

    add_result_2_3_p3[0] = add_result_2_3_p2[0] + add_result_2_3_p2[1];
    add_result_2_3_p3[1] = add_result_2_3_p2[2];
end




// channel 3/7/11
reg signed [20:0] add_result_3_0_p3 [0:1];
reg signed [20:0] add_result_3_1_p3 [0:1];
reg signed [20:0] add_result_3_2_p3 [0:1];
reg signed [20:0] add_result_3_3_p3 [0:1];



always@* begin
    add_result_3_0_p3[0] = add_result_3_0_p2[0] + add_result_3_0_p2[1];
    add_result_3_0_p3[1] = add_result_3_0_p2[2];

    add_result_3_1_p3[0] = add_result_3_1_p2[0] + add_result_3_1_p2[1];
    add_result_3_1_p3[1] = add_result_3_1_p2[2];

    add_result_3_2_p3[0] = add_result_3_2_p2[0] + add_result_3_2_p2[1];
    add_result_3_2_p3[1] = add_result_3_2_p2[2];

    add_result_3_3_p3[0] = add_result_3_3_p2[0] + add_result_3_3_p2[1];
    add_result_3_3_p3[1] = add_result_3_3_p2[2];
end


// ---------------------------------------------------------------------------------convolution adder (phase 3)(pipe)---------------------------------------------------------------------//

// ---------------------------------------------------------------------------------convolution adder (phase 4)(pipe)---------------------------------------------------------------------//
reg signed [20:0] mult_result_0 [0:3];
reg signed [20:0] mult_result_1 [0:3];
reg signed [20:0] mult_result_2 [0:3];
reg signed [20:0] mult_result_3 [0:3];
always@* begin
  mult_result_0[0] = add_result_0_0_p3[0] + add_result_0_0_p3[1];
  mult_result_0[1] = add_result_0_1_p3[0] + add_result_0_1_p3[1];
  mult_result_0[2] = add_result_0_2_p3[0] + add_result_0_2_p3[1];
  mult_result_0[3] = add_result_0_3_p3[0] + add_result_0_3_p3[1];

  mult_result_1[0] = add_result_1_0_p3[0] + add_result_1_0_p3[1];
  mult_result_1[1] = add_result_1_1_p3[0] + add_result_1_1_p3[1];
  mult_result_1[2] = add_result_1_2_p3[0] + add_result_1_2_p3[1];
  mult_result_1[3] = add_result_1_3_p3[0] + add_result_1_3_p3[1];

  mult_result_2[0] = add_result_2_0_p3[0] + add_result_2_0_p3[1];
  mult_result_2[1] = add_result_2_1_p3[0] + add_result_2_1_p3[1];
  mult_result_2[2] = add_result_2_2_p3[0] + add_result_2_2_p3[1];
  mult_result_2[3] = add_result_2_3_p3[0] + add_result_2_3_p3[1];

  mult_result_3[0] = add_result_3_0_p3[0] + add_result_3_0_p3[1];
  mult_result_3[1] = add_result_3_1_p3[0] + add_result_3_1_p3[1];
  mult_result_3[2] = add_result_3_2_p3[0] + add_result_3_2_p3[1];
  mult_result_3[3] = add_result_3_3_p3[0] + add_result_3_3_p3[1];
end


// ---------------------------------------------------------------------------------convolution adder (phase 4)(pipe)---------------------------------------------------------------------//




// -------------------------------------------------------------------------------add result stage for conv3-----------------------------------------------------------------//
// store conv result
reg signed [20:0] mult_result_c0_3[0:3];
reg signed [20:0] mult_result_c1_3[0:3];
reg signed [20:0] mult_result_c2_3[0:3];
reg signed [20:0] mult_result_c3_3[0:3];
reg signed [20:0] mult_result_c4_3[0:3];
reg signed [20:0] mult_result_c5_3[0:3];
reg signed [20:0] mult_result_c6_3[0:3];
reg signed [20:0] mult_result_c7_3[0:3];
reg signed [20:0] mult_result_c8_3[0:3];
reg signed [20:0] mult_result_c9_3[0:3];
reg signed [20:0] mult_result_c10_3[0:3];
reg signed [20:0] mult_result_c11_3[0:3];

// channel 0
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c0_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3  == 2'd0) begin
      mult_result_c0_3[0] <= mult_result_0[0];
      mult_result_c0_3[1] <= mult_result_0[1];
      mult_result_c0_3[2] <= mult_result_0[2];
      mult_result_c0_3[3] <= mult_result_0[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c0_3[i] <= mult_result_c0_3[i];

// channel 1
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c1_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd0) begin
      mult_result_c1_3[0] <= mult_result_1[0];
      mult_result_c1_3[1] <= mult_result_1[1];
      mult_result_c1_3[2] <= mult_result_1[2];
      mult_result_c1_3[3] <= mult_result_1[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c1_3[i] <= mult_result_c1_3[i];

// channel 2
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c2_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd0)  begin
      mult_result_c2_3[0] <= mult_result_2[0];
      mult_result_c2_3[1] <= mult_result_2[1];
      mult_result_c2_3[2] <= mult_result_2[2];
      mult_result_c2_3[3] <= mult_result_2[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c2_3[i] <= mult_result_c2_3[i];
// channel 3
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c3_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd0) begin
      mult_result_c3_3[0] <= mult_result_3[0];
      mult_result_c3_3[1] <= mult_result_3[1];
      mult_result_c3_3[2] <= mult_result_3[2];
      mult_result_c3_3[3] <= mult_result_3[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c3_3[i] <= mult_result_c3_3[i];

// channel 4
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c4_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd1) begin
      mult_result_c4_3[0] <= mult_result_0[0];
      mult_result_c4_3[1] <= mult_result_0[1];
      mult_result_c4_3[2] <= mult_result_0[2];
      mult_result_c4_3[3] <= mult_result_0[3]; 
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c4_3[i] <= mult_result_c4_3[i];

// channel 5
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c5_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd1) begin
      mult_result_c5_3[0] <= mult_result_1[0];
      mult_result_c5_3[1] <= mult_result_1[1];
      mult_result_c5_3[2] <= mult_result_1[2];
      mult_result_c5_3[3] <= mult_result_1[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c5_3[i] <= mult_result_c5_3[i];

// channel 6
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c6_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd1)  begin
      mult_result_c6_3[0] <= mult_result_2[0];
      mult_result_c6_3[1] <= mult_result_2[1];
      mult_result_c6_3[2] <= mult_result_2[2];
      mult_result_c6_3[3] <= mult_result_2[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c6_3[i] <= mult_result_c6_3[i];

// channel 7
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c7_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd1) begin
      mult_result_c7_3[0] <= mult_result_3[0];
      mult_result_c7_3[1] <= mult_result_3[1];
      mult_result_c7_3[2] <= mult_result_3[2];
      mult_result_c7_3[3] <= mult_result_3[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c7_3[i] <= mult_result_c7_3[i];


// channel 8
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c8_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd2) begin
      mult_result_c8_3[0] <= mult_result_0[0];
      mult_result_c8_3[1] <= mult_result_0[1];
      mult_result_c8_3[2] <= mult_result_0[2];
      mult_result_c8_3[3] <= mult_result_0[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c8_3[i] <= mult_result_c8_3[i];

// channel 9
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c9_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd2) begin
      mult_result_c9_3[0] <= mult_result_1[0];
      mult_result_c9_3[1] <= mult_result_1[1];
      mult_result_c9_3[2] <= mult_result_1[2];
      mult_result_c9_3[3] <= mult_result_1[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c9_3[i] <= mult_result_c9_3[i];

// channel 10
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c10_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd2) begin
      mult_result_c10_3[0] <= mult_result_2[0];
      mult_result_c10_3[1] <= mult_result_2[1];
      mult_result_c10_3[2] <= mult_result_2[2];
      mult_result_c10_3[3] <= mult_result_2[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c10_3[i] <= mult_result_c10_3[i];

// channel 11
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      mult_result_c11_3[i] <= 0;
  else
    if(op_state_3 == CONV && mode_delay_3_3 == 2'd2)  begin
      mult_result_c11_3[0] <= mult_result_3[0];
      mult_result_c11_3[1] <= mult_result_3[1];
      mult_result_c11_3[2] <= mult_result_3[2];
      mult_result_c11_3[3] <= mult_result_3[3];
    end
    else
      for(i = 0; i < 4; i = i+1)
         mult_result_c11_3[i] <= mult_result_c11_3[i];



// add result of 12 channels together (pipe) (phase 1)  
reg signed [23:0] add_result_3_0_1 [0:3];
reg signed [23:0] add_result_3_1_1 [0:3];
reg signed [23:0] add_result_3_2_1 [0:3];
reg signed [23:0] add_result_3_3_1 [0:3];
reg signed [23:0] add_result_3_4_1 [0:3];
reg signed [23:0] add_result_3_5_1 [0:3];

always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_0_1[i] = mult_result_c0_3[i] + mult_result_c1_3[i];

always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_1_1[i] = mult_result_c2_3[i] + mult_result_c3_3[i];

always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_2_1[i] = mult_result_c4_3[i] + mult_result_c5_3[i];

always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_3_1[i] = mult_result_c6_3[i] + mult_result_c7_3[i];

always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_4_1[i] = mult_result_c8_3[i] + mult_result_c9_3[i];

always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_5_1[i] = mult_result_c10_3[i] + mult_result_c11_3[i];




// add result of 12 channels together (phase 2)  
reg signed [23:0] add_result_3_0_2 [0:3];
reg signed [23:0] add_result_3_1_2 [0:3];
reg signed [23:0] add_result_3_2_2 [0:3];
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      add_result_3_0_2[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      add_result_3_0_2[i] <= add_result_3_0_1[i] + add_result_3_1_1[i];

always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      add_result_3_1_2[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      add_result_3_1_2[i] <= add_result_3_2_1[i] + add_result_3_3_1[i];


always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      add_result_3_2_2[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      add_result_3_2_2[i] <= add_result_3_4_1[i] + add_result_3_5_1[i];



// add result of 12 channels together (phase 3) 
reg signed [23:0] add_result_3_0_3 [0:3];
reg signed [23:0] add_result_3_1_3 [0:3];


always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_0_3[i] = add_result_3_0_2[i] + add_result_3_1_2[i];
always@*
  for(i = 0; i < 4; i = i+1)
    add_result_3_1_3[i] = add_result_3_2_2[i];  





// add result of 12 channels together (phase 4) 
reg signed [23:0] add_result_3 [0:3];
always@(posedge clk) 
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
    add_result_3[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      add_result_3[i] <= add_result_3_0_3[i] + add_result_3_1_3[i];






// -------------------------------------------------------------------------------adding result stage for conv3-----------------------------------------------------------------//

// -------------------------------------------------------------------------------adding bias and quantization stage for conv3-----------------------------------------------------------------//
// add bias
reg signed [23:0] bias_add_result_3 [0:3];
reg signed [15:0] shift_bias_in_3;

always@*
  shift_bias_in_3 = bias_0_in << 8;

always@*
  for(i = 0; i < 4; i = i+1)
    bias_add_result_3[i] = add_result_3[i] + shift_bias_in_3;

// RELU (pipe)
reg signed [23:0] relu_result_c3 [0:3];

always@*
  for(i = 0; i < 4; i = i+1)
    if(bias_add_result_3[i][23] == 1'b1)
      relu_result_c3[i] = 0;
    else
      relu_result_c3[i] = bias_add_result_3[i];

// Avarage pooling (pipe) (stage 1)
reg signed [23:0] average_result_3_0;
reg signed [23:0] average_result_3_1;
always@(posedge clk)
  if(~srst_n)
    average_result_3_0 <= 0;
  else
    average_result_3_0 <= relu_result_c3[0] + relu_result_c3[1];

always@(posedge clk)
  if(~srst_n)
    average_result_3_1 <= 0;
  else
    average_result_3_1 <= relu_result_c3[2] + relu_result_c3[3];

// Avarage pooling (pipe) (stage 2)
reg signed [23:0] average_result_3;

always@*
  average_result_3 = (average_result_3_0 + average_result_3_1) >>> 2;




// rounding
reg signed [23:0] round_result_3;
always@*
  round_result_3 = (average_result_3 + 8'sb0100_0000) >>> 7;

// output
reg [11:0] conv_result_c3;

always@*
  if(round_result_3 > 24'sb0000_0000_0000_0111_1111_1111)
    conv_result_c3 = 12'sb0111_1111_1111;
  else if (round_result_3 < 24'sb1111_1111_1111_1000_0000_0000)
    conv_result_c3 = 12'sb1000_0000_0000;
  else
    conv_result_c3 = round_result_3[11:0];

reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b_3; 
// write data
always@*
  sram_wdata_b_3 = {16{conv_result_c3}};


// -------------------------------------------------------------------------------adding bias and quantization stage for conv3-----------------------------------------------------------------//






// -------------------------------------------------------------------------------adding bias and quantization stage (except conv3) ----------------------------------------------------------------//

reg signed [20:0] mult_result_c0 [0:3];
reg signed [20:0] mult_result_c1 [0:3];
reg signed [20:0] mult_result_c2 [0:3];
reg signed [20:0] mult_result_c3 [0:3];

// store conv result 
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1) begin    
      mult_result_c0[i] <= 0;
      mult_result_c1[i] <= 0;
      mult_result_c2[i] <= 0;
      mult_result_c3[i] <= 0;
    end
  else 
    for(i = 0; i < 4; i = i+1) begin
      mult_result_c0[i] <= mult_result_0[i];
      mult_result_c1[i] <= mult_result_1[i];
      mult_result_c2[i] <= mult_result_2[i];
      mult_result_c3[i] <= mult_result_3[i];
    end

// shift bias
reg signed [15:0] shift_bias_0;
reg signed [15:0] shift_bias_1;
reg signed [15:0] shift_bias_2;
reg signed [15:0] shift_bias_3;

always@* begin
  shift_bias_0 = bias_0_in << 8;
  shift_bias_1 = bias_1_in << 8;
  shift_bias_2 = bias_2_in << 8;
  shift_bias_3 = bias_3_in << 8;
end


reg signed [20:0] bias_mult_result_0 [0:3];
reg signed [20:0] bias_mult_result_1 [0:3];
reg signed [20:0] bias_mult_result_2 [0:3];
reg signed [20:0] bias_mult_result_3 [0:3];
//always@*
always@*
  for(i = 0; i < 4; i = i+1) begin
    bias_mult_result_0[i] = mult_result_c0[i] + shift_bias_0;
    bias_mult_result_1[i] = mult_result_c1[i] + shift_bias_1;
    bias_mult_result_2[i] = mult_result_c2[i] + shift_bias_2;
    bias_mult_result_3[i] = mult_result_c3[i] + shift_bias_3;
  end

// RELU (*4) (pipeline)
reg signed [20:0] relu_result_0 [0:3];
reg signed [20:0] relu_result_1 [0:3];
reg signed [20:0] relu_result_2 [0:3];
reg signed [20:0] relu_result_3 [0:3];


always@* begin
    for(i = 0; i < 4; i = i+1)
      if((bias_mult_result_0[i][20] == 1'b1) && ((state == CONV1_PW) || (state== CONV2_PW)))
        relu_result_0[i] = 0;
      else
        relu_result_0[i] = bias_mult_result_0[i];

    for(i = 0; i < 4; i = i+1)
      if((bias_mult_result_1[i][20] == 1'b1) && ((state== CONV1_PW) || (state == CONV2_PW)))
        relu_result_1[i] = 0;
      else
        relu_result_1[i] = bias_mult_result_1[i];

    for(i = 0; i < 4; i = i+1)
      if((bias_mult_result_2[i][20] == 1'b1) && ((state== CONV1_PW) || (state == CONV2_PW)))
        relu_result_2[i] = 0;
      else
        relu_result_2[i] = bias_mult_result_2[i];

    for(i = 0; i < 4; i = i+1)
      if((bias_mult_result_3[i][20] == 1'b1) && ((state== CONV1_PW) || (state== CONV2_PW)))
        relu_result_3[i] = 0;
      else
        relu_result_3[i] = bias_mult_result_3[i];
  end
  

 
// add rounding and shift
reg signed [20:0] round_mult_result_0 [0:3];
reg signed [20:0] round_mult_result_1 [0:3];
reg signed [20:0] round_mult_result_2 [0:3];
reg signed [20:0] round_mult_result_3 [0:3];
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      round_mult_result_0[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      round_mult_result_0[i] <= (relu_result_0[i] + 8'sb0100_0000) >>> 7;
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      round_mult_result_1[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      round_mult_result_1[i] <= (relu_result_1[i] + 8'sb0100_0000) >>> 7;
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      round_mult_result_2[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      round_mult_result_2[i] <= (relu_result_2[i] + 8'sb0100_0000) >>> 7;
always@(posedge clk)
  if(~srst_n)
    for(i = 0; i < 4; i = i+1)
      round_mult_result_3[i] <= 0;
  else
    for(i = 0; i < 4; i = i+1)
      round_mult_result_3[i] <= (relu_result_3[i] + 8'sb0100_0000) >>> 7;



// deal with output 
reg [11:0] conv_result_0[0:3];
reg [11:0] conv_result_1[0:3];
reg [11:0] conv_result_2[0:3];
reg [11:0] conv_result_3[0:3];

always@* begin
  for(i = 0; i < 4; i = i+1)
    if(round_mult_result_0[i] > 21'sb0_0000_0000_0111_1111_1111)
      conv_result_0[i] = 12'sb0111_1111_1111;
    else if (round_mult_result_0[i] < 21'sb1_1111_1111_1000_0000_0000)
      conv_result_0[i] = 12'sb1000_0000_0000;
    else
      conv_result_0[i] = round_mult_result_0[i][11:0];

  for(i = 0; i < 4; i = i+1)
    if(round_mult_result_1[i] > 21'sb0_0000_0000_0111_1111_1111)
      conv_result_1[i] = 12'sb0111_1111_1111;
    else if (round_mult_result_1[i] < 21'sb1_1111_1111_1000_0000_0000)
      conv_result_1[i] = 12'sb1000_0000_0000;
    else
      conv_result_1[i] = round_mult_result_1[i][11:0];

  for(i = 0; i < 4; i = i+1)
    if(round_mult_result_2[i] > 21'sb0_0000_0000_0111_1111_1111)
      conv_result_2[i] = 12'sb0111_1111_1111;
    else if (round_mult_result_2[i] < 21'sb1_1111_1111_1000_0000_0000)
      conv_result_2[i] = 12'sb1000_0000_0000;
    else
      conv_result_2[i] = round_mult_result_2[i][11:0];

  for(i = 0; i < 4; i = i+1)
    if(round_mult_result_3[i] > 21'sb0_0000_0000_0111_1111_1111)
      conv_result_3[i] = 12'sb0111_1111_1111;
    else if (round_mult_result_3[i] < 21'sb1_1111_1111_1000_0000_0000)
      conv_result_3[i] = 12'sb1000_0000_0000;
    else
      conv_result_3[i] = round_mult_result_3[i][11:0];
end


// SRAM B write data
reg [CH_NUM*ACT_PER_ADDR*BW_PER_ACT-1:0] sram_wdata_b_dw; 
// write data
always@*
  sram_wdata_b_dw =    {conv_result_0[0], conv_result_0[1], conv_result_0[2], conv_result_0[3],
                        conv_result_1[0], conv_result_1[1], conv_result_1[2], conv_result_1[3],
                        conv_result_2[0], conv_result_2[1], conv_result_2[2], conv_result_2[3],
                        conv_result_3[0], conv_result_3[1], conv_result_3[2], conv_result_3[3]};


// -------------------------------------------------------------------------------adding bias and quantization stage (except conv3)----------------------------------------------------------------//



// ---------------------------------------------------------------------------------SRAM B write data selection---------------------------------------------------------------------//
// SRAM B write data sel
always@(posedge clk)
  if(~srst_n)
    sram_wdata_b <= 0;
  else
    case(state)
      CONV1_DW: sram_wdata_b <= sram_wdata_b_dw;
      CONV2_DW: sram_wdata_b <= sram_wdata_b_dw;
      CONV3: sram_wdata_b <= sram_wdata_b_3;
      default: sram_wdata_b <= 0;
    endcase
// --------------------------------------------------------------------------------- SRAM B write data selection---------------------------------------------------------------------//

// --------------------------------------------------------------------------------- SRAM A write data selection---------------------------------------------------------------------//
// SRAM A write data
always@(posedge clk)
  if(~srst_n)
    sram_wdata_a <= 0;
  else
    sram_wdata_a <=    {conv_result_0[0], conv_result_0[1], conv_result_0[2], conv_result_0[3],
                       conv_result_1[0], conv_result_1[1], conv_result_1[2], conv_result_1[3],
                       conv_result_2[0], conv_result_2[1], conv_result_2[2], conv_result_2[3],
                       conv_result_3[0], conv_result_3[1], conv_result_3[2], conv_result_3[3]};

// --------------------------------------------------------------------------------- SRAM A write data selection---------------------------------------------------------------------//


// valid sel
always@*
  valid = conv3_valid;


endmodule
