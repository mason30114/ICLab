module PRE_SCANNING(
    input clk,
    input srst_n,             
    input [3:0] state,                         
    input sram_rdata,       
    output reg [11:0] pre_scan_raddr,
    output reg pre_scan_complete,
    output reg [5:0] x_upper,
    output reg [5:0] x_lower,
    output reg [5:0] y_upper,
    output reg [5:0] y_lower
    //output reg [1:0] qr_total,
         
);
reg [5:0] x_upper_tmp, x_lower_tmp, y_upper_tmp, y_lower_tmp;
reg x0_empty, x21_empty, x42_empty, x63_empty, y0_empty, y21_empty, y42_empty, y63_empty;
reg [5:0] i, j, i_tmp, j_tmp;
reg mode;
/*reg qr_0_0, qr_0_21, qr_0_42, qr_0_63;
reg qr_21_0, qr_21_21, qr_21_42, qr_21_63;
reg qr_42_0, qr_42_21, qr_42_42, qr_42_63;
reg qr_63_0, qr_63_21, qr_63_42, qr_63_63;*/

parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;

always@*
  if((state == PRE_SCAN) && (mode == 0) && sram_rdata)     //mode == 0 => x scan
    j_tmp = 0;
  else if ((state == PRE_SCAN) && (mode == 1) && (sram_rdata || (i == 6'd63))) //|| ((state == PRE_SCAN) && (mode == 1) && (i == 6'd63)))
    j_tmp = j + 6'd21;
  else if((state == PRE_SCAN) && (mode == 0) && ~sram_rdata)
    j_tmp = j + 1'b1;
  else
    j_tmp = j;

always@*
  if((state == PRE_SCAN) && (mode == 1) && sram_rdata)     //mode == 1 => y scan
    i_tmp = 0;
  else if ((state == PRE_SCAN) && (mode == 0) && (sram_rdata || (j == 6'd63))) //|| ((state == PRE_SCAN) && (mode == 0) && (j == 6'd63)))
    i_tmp = i + 6'd21;
  else if((state == PRE_SCAN) && (mode == 1) && ~sram_rdata)
    i_tmp = i + 1'b1;
  else
    i_tmp = i;

always@(posedge clk)
  if(~srst_n)
    mode <= 0;
  else
    if((state == PRE_SCAN) && (i == 6'd63) && (sram_rdata || (j == 6'd63)))
      mode <= ~mode;
    else
      mode <= mode;

always@(posedge clk)
  if(~srst_n)
    pre_scan_complete <= 0;
  else
    if((state == PRE_SCAN) && mode && (j == 6'd63) && (sram_rdata || (i == 6'd63)))
      pre_scan_complete <= 1;
    else
      pre_scan_complete <= 0;
    


always@(posedge clk)
  if(~srst_n) begin
    i <= 0;
    j <= 0;
  end
  else begin
    i <= i_tmp;
    j <= j_tmp;
  end

always@*
  pre_scan_raddr = i * 7'd64 + j;

always@(posedge clk)
  if(~srst_n)
    x0_empty <= 1;
  else
    if((state == PRE_SCAN) && (j == 6'd0) && sram_rdata && (mode == 1))
      x0_empty <= 0;
    else
      x0_empty <= x0_empty;

always@(posedge clk)
  if(~srst_n)
    x21_empty <= 1;
  else
    if((state == PRE_SCAN) && (j == 6'd21) && sram_rdata && (mode == 1))
      x21_empty <= 0;
    else
      x21_empty <= x21_empty;

always@(posedge clk)
  if(~srst_n)
    x42_empty <= 1;
  else
    if((state == PRE_SCAN) && (j == 6'd42) && sram_rdata && (mode == 1))
      x42_empty <= 0;
    else
      x42_empty <= x42_empty;

always@(posedge clk)
  if(~srst_n)
    x63_empty <= 1;
  else
    if((state == PRE_SCAN) && (j == 6'd63) && sram_rdata && (mode == 1))
      x63_empty <= 0;
    else
      x63_empty <= x63_empty;

always@(posedge clk)
  if(~srst_n)
    y0_empty <= 1;
  else
    if((state == PRE_SCAN) && (i == 6'd0) && sram_rdata && (mode == 0))
      y0_empty <= 0;
    else
      y0_empty <= y0_empty;

always@(posedge clk)
  if(~srst_n)
    y21_empty <= 1;
  else
    if((state == PRE_SCAN) && (i == 6'd21) && sram_rdata && (mode == 0))
      y21_empty <= 0;
    else
      y21_empty <= y21_empty;

always@(posedge clk)
  if(~srst_n)
    y42_empty <= 1;
  else
    if((state == PRE_SCAN) && (i == 6'd42) && sram_rdata && (mode == 0))
      y42_empty <= 0;
    else
      y42_empty <= y42_empty;

always@(posedge clk)
  if(~srst_n)
    y63_empty <= 1;
  else
    if((state == PRE_SCAN) && (i == 6'd63) && sram_rdata && (mode == 0))
      y63_empty <= 0;
    else
      y63_empty <= y63_empty;

/*always@*
  if(x0_empty && x21_empty && y0_empty && y21_empty)
    corner_empty[0] = 1;
  else
    corner_empty[0] = 0;

always@*
  if(x21_empty && x42_empty && y0_empty && y21_empty)
    corner_empty[1] = 1;
  else
    corner_empty[1] = 0;

always@*
  if(x42_empty && x63_empty && y0_empty && y21_empty)
    corner_empty[2] = 1;
  else
    corner_empty[2] = 0;

always@*
  if(x0_empty && x21_empty && y21_empty && y42_empty)
    corner_empty[3] = 1;
  else
    corner_empty[3] = 0;

always@*
  if(x21_empty && x42_empty && y21_empty && y42_empty)
    corner_empty[4] = 1;
  else
    corner_empty[4] = 0;

always@*
  if(x42_empty && x63_empty && y21_empty && y42_empty)
    corner_empty[5] = 1;
  else
    corner_empty[5] = 0;

always@*
  if(x0_empty && x21_empty && y42_empty && y63_empty)
    corner_empty[6] = 1;
  else
    corner_empty[6] = 0;

always@*
  if(x21_empty && x42_empty && y42_empty && y63_empty)
    corner_empty[7] = 1;
  else
    corner_empty[7] = 0;

always@*
  if(x42_empty && x63_empty && y42_empty && y63_empty)
    corner_empty[8] = 1;
  else
    corner_empty[8] = 0;*/
  

always@*
  if(pre_scan_complete)
    case({x0_empty, x21_empty, x42_empty, x63_empty})
      4'b0000: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b0001: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b0010: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b0011: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd42;
      end
      4'b0100: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b0101: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b0110: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b0111: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd21;
      end
      4'b1000: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b1001: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b1010: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      4'b1011: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd42;
      end
      4'b1100: begin
        x_lower_tmp = 6'd21;
        x_upper_tmp = 6'd63;
      end
      4'b1101: begin
        x_lower_tmp = 6'd21;
        x_upper_tmp = 6'd63;
      end
      4'b1110: begin
        x_lower_tmp = 6'd42;
        x_upper_tmp = 6'd63;
      end
      4'b1111: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
      default: begin
        x_lower_tmp = 6'd0;
        x_upper_tmp = 6'd63;
      end
    endcase
  else begin
    x_lower_tmp = x_lower;
    x_upper_tmp = x_upper;    
  end

always@*
  if(pre_scan_complete)
    case({y0_empty, y21_empty, y42_empty, y63_empty})
      4'b0000: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b0001: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b0010: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b0011: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd42;
      end
      4'b0100: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b0101: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b0110: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b0111: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd21;
      end
      4'b1000: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b1001: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b1010: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      4'b1011: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd42;
      end
      4'b1100: begin
        y_lower_tmp = 6'd21;
        y_upper_tmp = 6'd63;
      end
      4'b1101: begin
        y_lower_tmp = 6'd21;
        y_upper_tmp = 6'd63;
      end
      4'b1110: begin
        y_lower_tmp = 6'd42;
        y_upper_tmp = 6'd63;
      end
      4'b1111: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
      default: begin
        y_lower_tmp = 6'd0;
        y_upper_tmp = 6'd63;
      end
    endcase
  else begin
    y_lower_tmp = y_lower;
    y_upper_tmp = y_upper;    
  end

always@(posedge clk)
  if(~srst_n) begin
    x_lower <= 0;
    y_lower <= 0;
    x_upper <= 0;
    y_upper <= 0;
  end
  else begin
    x_lower <= x_lower_tmp;
    y_lower <= y_lower_tmp;
    x_upper <= x_upper_tmp;
    y_upper <= y_upper_tmp;
  end

/*always@*
  if(~x0_empty && ~y0_empty)
    qr_0_0 = 1;
  else
    qr_0_0 = 0;
always@*
  if(~x21_empty && ~y0_empty)
    qr_21_0 = 1;
  else
    qr_21_0 = 0;
always@*
  if(~x42_empty && ~y0_empty)
    qr_42_0 = 1;
  else
    qr_42_0 = 0;
always@*
  if(~x63_empty && ~y0_empty)
    qr_63_0 = 1;
  else
    qr_63_0 = 0;

always@*
  if(~x0_empty && ~y21_empty)
    qr_0_21 = 1;
  else
    qr_0_21 = 0;
always@*
  if(~x21_empty && ~y21_empty)
    qr_21_21 = 1;
  else
    qr_21_21 = 0;
always@*
  if(~x42_empty && ~y21_empty)
    qr_42_21 = 1;
  else
    qr_42_21 = 0;
always@*
  if(~x63_empty && ~y21_empty)
    qr_63_21 = 1;
  else
    qr_63_21 = 0;
always@*
  if(~x0_empty && ~y42_empty)
    qr_0_42 = 1;
  else
    qr_0_42 = 0;
always@*
  if(~x21_empty && ~y42_empty)
    qr_21_42 = 1;
  else
    qr_21_42 = 0;
always@*
  if(~x42_empty && ~y42_empty)
    qr_42_42 = 1;
  else
    qr_42_42 = 0;
always@*
  if(~x63_empty && ~y42_empty)
    qr_63_42 = 1;
  else
    qr_63_42 = 0;
always@*
  if(~x0_empty && ~y63_empty)
    qr_0_63 = 1;
  else
    qr_0_63 = 0;
always@*
  if(~x21_empty && ~y63_empty)
    qr_21_63 = 1;
  else
    qr_21_63 = 0;
always@*
  if(~x42_empty && ~y63_empty)
    qr_42_63 = 1;
  else
    qr_42_63 = 0;
always@*
  if(~x63_empty && ~y63_empty)
    qr_63_63 = 1;
  else
    qr_63_63 = 0;*/

      
  /*if(pre_scan_complete)
    case({x0_empty, y0_empty, y21_empty, y42_empty, y63_empty})
      5'b00000: qr_num_0 = 4;
      5'b00001: qr_num_0 = 3;
      5'b00010: qr_num_0 = 3;
      5'b00011: qr_num_0 = 2;
      5'b00100: qr_num_0 = 3;
      5'b00101: qr_num_0 = 2;
      5'b00110: qr_num_0 = 2;
      5'b00111: qr_num_0 = 1;
      5'b01000: qr_num_0 = 3;
      5'b01001: qr_num_0 = 2;
      5'b01010: qr_num_0 = 2;
      5'b01011: qr_num_0 = 1;
      5'b01100: qr_num_0 = 2;
      5'b01101: qr_num_0 = 1;
      5'b01110: qr_num_0 = 1;
      5'b01111: qr_num_0 = 0;
      default: qr_num_0 = 0;
    endcase
  else 
    qr_num_0 = 0;

always@*
  if(pre_scan_complete)
    case({x21_empty, y0_empty, y21_empty, y42_empty, y63_empty})
      5'b00000: qr_num_21 = 4;
      5'b00001: qr_num_21 = 3;
      5'b00010: qr_num_21 = 3;
      5'b00011: qr_num_21 = 2;
      5'b00100: qr_num_21 = 3;
      5'b00101: qr_num_21 = 2;
      5'b00110: qr_num_21 = 2;
      5'b00111: qr_num_21 = 1;
      5'b01000: qr_num_21 = 3;
      5'b01001: qr_num_21 = 2;
      5'b01010: qr_num_21 = 2;
      5'b01011: qr_num_21 = 1;
      5'b01100: qr_num_21 = 2;
      5'b01101: qr_num_21 = 1;
      5'b01110: qr_num_21 = 1;
      5'b01111: qr_num_21 = 0;
      default: qr_num_21 = 0;
    endcase
  else 
    qr_num_21 = 0;

always@*
  if(pre_scan_complete)
    case({x42_empty, y0_empty, y21_empty, y42_empty, y63_empty})
      5'b00000: qr_num_42 = 4;
      5'b00001: qr_num_42 = 3;
      5'b00010: qr_num_42 = 3;
      5'b00011: qr_num_42 = 2;
      5'b00100: qr_num_42 = 3;
      5'b00101: qr_num_42 = 2;
      5'b00110: qr_num_42 = 2;
      5'b00111: qr_num_42 = 1;
      5'b01000: qr_num_42 = 3;
      5'b01001: qr_num_42 = 2;
      5'b01010: qr_num_42 = 2;
      5'b01011: qr_num_42 = 1;
      5'b01100: qr_num_42 = 2;
      5'b01101: qr_num_42 = 1;
      5'b01110: qr_num_42 = 1;
      5'b01111: qr_num_42 = 0;
      default: qr_num_42 = 0;
    endcase
  else 
    qr_num_42 = 0;

always@*
  if(pre_scan_complete)
    case({x63_empty, y0_empty, y21_empty, y42_empty, y63_empty})
      5'b00000: qr_num_63 = 4;
      5'b00001: qr_num_63 = 3;
      5'b00010: qr_num_63 = 3;
      5'b00011: qr_num_63 = 2;
      5'b00100: qr_num_63 = 3;
      5'b00101: qr_num_63 = 2;
      5'b00110: qr_num_63 = 2;
      5'b00111: qr_num_63 = 1;
      5'b01000: qr_num_63 = 3;
      5'b01001: qr_num_63 = 2;
      5'b01010: qr_num_63 = 2;
      5'b01011: qr_num_63 = 1;
      5'b01100: qr_num_63 = 2;
      5'b01101: qr_num_63 = 1;
      5'b01110: qr_num_63 = 1;
      5'b01111: qr_num_63 = 0;
      default: qr_num_63 = 0;
    endcase
  else 
    qr_num_63 = 0;*/


/*always@(posedge clk)
  if(~srst_n)
    qr_total <= 0;
  else
    if(pre_scan_complete)
      //if((x63_empty + x63_empty + x63_empty + x63_empty) != ())
      qr_total <= qr_0_0 + qr_0_21 + qr_0_42 + qr_0_63 + qr_21_0 + qr_21_21 + qr_21_42 + qr_21_63 + qr_42_0 + qr_42_21 + qr_42_42 + qr_42_63 + qr_63_0 + qr_63_21 + qr_63_42 + qr_63_63;
    else
      qr_total <= qr_total;*/


endmodule
    
      
