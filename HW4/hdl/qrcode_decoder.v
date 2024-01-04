//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================

module qrcode_decoder(
    input clk,
    input srst_n,             
    input start,                         
    input sram_rdata,       

    output reg [11:0] sram_raddr,
    output [5:0] loc_y,
    output reg [5:0] loc_x,
    output [7:0] decode_text,
    output valid,
    output finish         
);


// FSM
wire demask_complete, decode_complete, scan_complete, rotate_complete, pre_scan_complete;
wire [3:0] state;
parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;
// code_word
wire [151:0] code_word;
wire [11:0] scan_raddr, mask_addr, rotate_addr, loc_raddr, pre_scan_raddr, num_raddr;
wire [5:0] scan_loc_y, scan_loc_x;
wire [1:0] rotation_type;
wire [5:0] correct_loc_x;
wire loc_wrong, loc_complete, num_complete;
wire [5:0] rotate_loc_x;
wire [5:0] x_lower, y_lower, x_upper, y_upper;
wire [2:0] qr_total;
reg start_in;
wire end_of_file;
FSM FSM(.clk(clk), .srst_n(srst_n), .start(start), .demask_complete(demask_complete), .decode_complete(decode_complete), .state(state), .pre_scan_complete(pre_scan_complete), .num_complete(num_complete),
        .scan_complete(scan_complete), .rotate_complete(rotate_complete), .loc_wrong(loc_wrong), .loc_complete(loc_complete), .end_of_file(end_of_file), .finish(finish));

ROTATING ROTATING(.clk(clk), .srst_n(srst_n), .state(state), .sram_data(sram_rdata), .rotate_addr(rotate_addr), .rotate_complete(rotate_complete),
                  .scan_loc_x(scan_loc_x), .scan_loc_y(scan_loc_y), .rotation_type(rotation_type), .loc_x(rotate_loc_x), .loc_y(loc_y), .loc_wrong(loc_wrong));

LOC_CORRECT LOC_CORRECT (.clk(clk), .srst_n(srst_n), .sram_rdata(sram_rdata), .state(state), .loc_x(scan_loc_x), .loc_raddr(loc_raddr), 
                         .correct_loc_x(correct_loc_x), .loc_complete(loc_complete), .loc_y(scan_loc_y));

SCANNING SCANNING(.clk(clk), .srst_n(srst_n), .state(state), .sram_rdata(sram_rdata), .scan_raddr(scan_raddr), .scan_complete(scan_complete), .rotation_type(rotation_type), 
                  .loc_x(scan_loc_x), .loc_y(scan_loc_y), .end_of_file(end_of_file), .decode_complete(decode_complete), .gold_loc_x(loc_x), .gold_loc_y(loc_y), .correct_loc_x(correct_loc_x), 
                  .x_upper(x_upper), .y_upper(y_upper), .x_lower(x_lower), .y_lower(y_lower), .pre_scan_complete(pre_scan_complete), .qr_total(qr_total), .loc_complete(loc_complete));

PRE_SCANNING PRE_SCANNING (.clk(clk), .srst_n(srst_n), .state(state), .sram_rdata(sram_rdata), .pre_scan_raddr(pre_scan_raddr), .pre_scan_complete(pre_scan_complete), 
                           .x_upper(x_upper), .y_upper(y_upper), .x_lower(x_lower), .y_lower(y_lower));

NUM_CALCULATE NUM_CALCULATE (.clk(clk), .srst_n(srst_n), .state(state), .sram_rdata(sram_rdata), .num_raddr(num_raddr), .num_complete(num_complete), .qr_total(qr_total));

DEMASKING DEMASKING(.clk(clk), .srst_n(srst_n), .state(state), .sram_rdata(sram_rdata), .mask_addr(mask_addr), .demask_complete(demask_complete), .code_word(code_word),
                    .loc_x(loc_x), .loc_y(loc_y), .rotation_type(rotation_type));

DECODING DECODING(.clk(clk), .srst_n(srst_n), .state(state), .decode_complete(decode_complete), .code_word(code_word),
              .decode_text(decode_text), .valid(valid));

always@(posedge clk)
  if(~srst_n)
    loc_x <= 0;
  else
    if(state == LOC)
      loc_x <= correct_loc_x;
    else if (state == ROTATE)
      loc_x <= rotate_loc_x;
    else
      loc_x <= loc_x;
// find pattern (handle loc_x, y finish)
/*always@(posedge clk)
  if(~srst_n) begin
    loc_x <= 0;
    loc_y <= 0;
  end
  else begin
    loc_x <= 0;
    loc_y <= 0;
  end*/

/*always@(posedge clk)
  if(~srst_n)
    start_in <= 0;
  else
    start_in <= start;*/


/*always@(posedge clk)
  if(~srst_n)
    finish <= 0;
  else
    if(decode_complete)
      finish <= 1;
    else
      finish <= 0;*/

// handle rotation

// handle sram_addr
always@*
  case(state)
    DEMASK: sram_raddr = mask_addr;
    SCAN: sram_raddr = scan_raddr;
    ROTATE: sram_raddr = rotate_addr;
    PRE_SCAN: sram_raddr = pre_scan_raddr;
    NUM: sram_raddr = num_raddr;
    LOC: sram_raddr = loc_raddr;
    default: sram_raddr = 0;
  endcase
  /*if(state == DEMASK)
    sram_raddr = mask_addr;
  else if (state == SCAN)
    sram_raddr = scan_raddr;
  else if (state == ROTATE)
    sram_raddr = rotate_addr;
  else if (state == PRE_SCAN)
    sram_raddr = pre_scan_raddr;
  else if (state == NUM)
    sram_raddr = num_raddr;
  else if (state == LOC)
    sram_raddr = loc_raddr;
  else */
    //sram_raddr = 0;


endmodule
