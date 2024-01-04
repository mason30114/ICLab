module SCANNING(
    input clk,
    input srst_n,             
    input [3:0] state,                         
    input sram_rdata,       
    input decode_complete,
    input [5:0] gold_loc_y,
    input [5:0] gold_loc_x,
    input [5:0] x_lower,
    input [5:0] y_lower,
    input [5:0] x_upper,
    input [5:0] y_upper,    
    input [1:0] rotation_type,
    input pre_scan_complete,
    input loc_complete,
    input [2:0] qr_total,
    input [5:0] correct_loc_x,
    output reg [11:0] scan_raddr,
    output reg scan_complete,
    output reg [5:0] loc_y,
    output reg [5:0] loc_x,
    output reg end_of_file
         
);
parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;
reg [11:0] scan_raddr_tmp;
reg [2:0] qr_num;
reg [5:0] pre_loc_x1, pre_loc_y1, pre_loc_x2, pre_loc_y2, pre_loc_x3, pre_loc_y3;
reg [5:0] current_x, current_y, current_x_tmp, current_y_tmp;
always@(posedge clk)
  if(~srst_n) begin
    pre_loc_x1 <= 0;
    pre_loc_y1 <= 0;
  end
  else
    if(decode_complete && (qr_num == 2'd0))
      case(rotation_type)
        2'd3: begin
          pre_loc_x1 <= gold_loc_x;
          pre_loc_y1 <= gold_loc_y;
        end
        2'd2: begin
          pre_loc_x1 <= gold_loc_x - 5'd20;
          pre_loc_y1 <= gold_loc_y;
        end
        2'd1: begin
          pre_loc_x1 <= gold_loc_x;
          pre_loc_y1 <= gold_loc_y - 5'd20;
        end
        2'd0: begin
          pre_loc_x1 <= gold_loc_x - 5'd20;
          pre_loc_y1 <= gold_loc_y - 5'd20;
        end
        default: begin
          pre_loc_x1 <= gold_loc_x;
          pre_loc_y1 <= gold_loc_y;
        end
      endcase
   else begin
     pre_loc_x1 <= pre_loc_x1;
     pre_loc_y1 <= pre_loc_y1;    
   end

always@(posedge clk)
  if(~srst_n) begin
    pre_loc_x2 <= 0;
    pre_loc_y2 <= 0;
  end
  else
    if(decode_complete && (qr_num == 2'd1))
      case(rotation_type)
        2'd3: begin
          pre_loc_x2 <= gold_loc_x;
          pre_loc_y2 <= gold_loc_y;
        end
        2'd2: begin
          pre_loc_x2 <= gold_loc_x - 5'd20;
          pre_loc_y2 <= gold_loc_y;
        end
        2'd1: begin
          pre_loc_x2 <= gold_loc_x;
          pre_loc_y2 <= gold_loc_y - 5'd20;
        end
        2'd0: begin
          pre_loc_x2 <= gold_loc_x - 5'd20;
          pre_loc_y2 <= gold_loc_y - 5'd20;
        end
        default: begin
          pre_loc_x2 <= gold_loc_x;
          pre_loc_y2 <= gold_loc_y;
        end
      endcase
   else begin
     pre_loc_x2 <= pre_loc_x2;
     pre_loc_y2 <= pre_loc_y2;    
   end

always@(posedge clk)
  if(~srst_n) begin
    pre_loc_x3 <= 0;
    pre_loc_y3 <= 0;
  end
  else
    if(decode_complete && (qr_num == 2'd2))
      case(rotation_type)
        2'd3: begin
          pre_loc_x3 <= gold_loc_x;
          pre_loc_y3 <= gold_loc_y;
        end
        2'd2: begin
          pre_loc_x3 <= gold_loc_x - 5'd20;
          pre_loc_y3 <= gold_loc_y;
        end
        2'd1: begin
          pre_loc_x3 <= gold_loc_x;
          pre_loc_y3 <= gold_loc_y - 5'd20;
        end
        2'd0: begin
          pre_loc_x3 <= gold_loc_x - 5'd20;
          pre_loc_y3 <= gold_loc_y - 5'd20;
        end
        default: begin
          pre_loc_x3 <= gold_loc_x;
          pre_loc_y3 <= gold_loc_y;
        end
      endcase
   else begin
     pre_loc_x3 <= pre_loc_x3;
     pre_loc_y3 <= pre_loc_y3;    
   end
    
/*always@*
  if((state == SCAN))
    scan_raddr_tmp = scan_raddr + 1'b1; 
  else
    scan_raddr_tmp = scan_raddr;


always@(posedge clk)
  if(~srst_n)
    scan_raddr <= 0;
  else
    scan_raddr <= scan_raddr_tmp;

reg [5:0] current_x, current_y;
always@* begin
   current_x = (scan_raddr % 64);
   current_y = (scan_raddr / 64);
end*/


always@*
  if((state == SCAN) && (current_x != x_upper))
    if((qr_num == 2'd1) && (current_x == pre_loc_x1) && ((current_y - pre_loc_y1) <= 5'd20) )
      current_x_tmp = current_x +5'd20;
    else if((qr_num == 2'd2) && (((current_x == pre_loc_x1) && ((current_y - pre_loc_y1) <= 5'd20)) || 
                                 ((current_x == pre_loc_x2) && ((current_y - pre_loc_y2) <= 5'd20))))
      current_x_tmp = current_x +5'd20;
    else if((qr_num == 2'd3) && (((current_x == pre_loc_x1) && ((current_y - pre_loc_y1) <= 5'd20)) ||
                                ((current_x == pre_loc_x2) && ((current_y - pre_loc_y2) <= 5'd20)) ||
                                ((current_x == pre_loc_x3) && ((current_y - pre_loc_y3) <= 5'd20))))
      current_x_tmp = current_x +5'd20;
    else
      current_x_tmp = current_x +1'b1;
    /*if((state == SCAN) && (current_x != x_upper) && (qr_num == 2'd1) && (current_x == pre_loc_x1) && ((current_y - pre_loc_y1) <= 5'd20) )
      current_x_tmp = current_x +5'd20;
    else if((state == SCAN) && (current_x != x_upper) && (qr_num == 2'd2) && (((current_x == pre_loc_x1) && ((current_y - pre_loc_y1) <= 5'd20)) || 
                                 ((current_x == pre_loc_x2) && ((current_y - pre_loc_y2) <= 5'd20))))
      current_x_tmp = current_x +5'd20;
    else if((state == SCAN) && (current_x != x_upper) && (qr_num == 2'd3) && (((current_x == pre_loc_x1) && ((current_y - pre_loc_y1) <= 5'd20)) ||
                                ((current_x == pre_loc_x2) && ((current_y - pre_loc_y2) <= 5'd20)) ||
                                ((current_x == pre_loc_x3) && ((current_y - pre_loc_y3) <= 5'd20))))
      current_x_tmp = current_x +5'd20;
    else if ((state == SCAN) && (current_x != x_upper))
      current_x_tmp = current_x +1'b1;*/

  /*if((state == SCAN) && corner_empty[0] && (current_y <= 6'd20) && (current_x <= 6'd20))
    current_x_tmp = 6'd21;
  else if((state == SCAN) && corner_empty[1] && (current_y <= 6'd20) && (current_x >= 6'd21) && (current_x <= 6'd41))
    current_x_tmp = 6'd42;
  else if((state == SCAN) && corner_empty[2] && (current_y <= 6'd20) && (current_x >= 6'd42))
    current_x_tmp = 6'd63;
  else if((state == SCAN) && corner_empty[3] && (current_y >= 6'd21) && (current_y <= 6'd41) && (current_x <= 6'd20))
    current_x_tmp = 6'd21;
  else if((state == SCAN) && corner_empty[4] && (current_y >= 6'd21) && (current_y <= 6'd41) && (current_x >= 6'd21) && (current_x <= 6'd41))
    current_x_tmp = 6'd42;
  else if((state == SCAN) && corner_empty[5] && (current_y >= 6'd21) && (current_y <= 6'd41) && (current_x >= 6'd42))
    current_x_tmp = 6'd63;
  else if((state == SCAN) && corner_empty[6] && (current_y >= 6'd42) && (current_x <= 6'd20))
    current_x_tmp = 6'd21;
  else if((state == SCAN) && corner_empty[7] && (current_y >= 6'd42) && (current_y >= 6'd21) && (current_x <= 6'd41))
    current_x_tmp = 6'd42;
  else if((state == SCAN) && corner_empty[8] && (current_y >= 6'd42) && (current_x >= 6'd42))
    current_x_tmp = 6'd63;*/
  else if((state == SCAN) && (current_x == x_upper))
    current_x_tmp = x_lower;
  /*else if (state == SCAN)
    current_x_tmp = current_x + 1'b1;*/
  else if((state == LOC) && loc_complete)
    current_x_tmp = correct_loc_x;
  else
    current_x_tmp = current_x;
  
always@(posedge clk)
  if(~srst_n)
    current_x <= 0;
  else 
    if(pre_scan_complete)
      current_x <= x_lower;
    else
      current_x <= current_x_tmp;

always@*
  if((state == SCAN) && (current_x == x_upper))
    current_y_tmp = current_y +1'b1;
  /*else if((state == SCAN) && corner_empty[2] && (current_y <= 6'd21) && (current_x >= 6'd43))
    current_y_tmp = 6'd22;
  else if((state == SCAN) && corner_empty[5] && (current_y >= 6'd22) && (current_y <= 6'd42) && (current_x >= 6'd43))
    current_y_tmp = 6'd43;
  else if((state == SCAN) && corner_empty[8] && (current_y >= 6'd43) && (current_x >= 6'd43))
    current_y_tmp = 6'd0;*/
  else
    current_y_tmp = current_y;

always@(posedge clk)
  if(~srst_n)
    current_y <= 0;
  else
    if(pre_scan_complete)
      current_y <= y_lower;
    else
      current_y <= current_y_tmp;

reg [5:0] current_x_old, current_y_old;

always@(posedge clk)
  if(~srst_n)
    current_x_old <= 0;
  else
    current_x_old <= current_x;

always@(posedge clk)
  if(~srst_n)
    current_y_old <= 0;
  else
    current_y_old <= current_y;

/*always@*
  scan_raddr <= current_y * 7'd64 + current_x;*/

always@(posedge clk)
  if(~srst_n)
    scan_raddr <= 0;
  else
    scan_raddr <= current_y * 7'd64 + current_x;



// handle whether start to decode a pattern
always@*
  if((state == SCAN) && sram_rdata)
    if(qr_num == 0)
        scan_complete = 1'b1;
    else if ((qr_num == 2'd1) && (((current_x_old - pre_loc_x1) > 5'd20) || ((current_y_old - pre_loc_y1) > 5'd20) || (current_x_old < pre_loc_x1)))
        scan_complete = 1'b1;
    else if ((qr_num == 2'd2) && (((current_x_old - pre_loc_x1) > 5'd20) || ((current_y_old - pre_loc_y1) > 5'd20) || (current_x_old < pre_loc_x1)) && 
            (((current_x_old - pre_loc_x2) > 5'd20) || ((current_y_old - pre_loc_y2) > 5'd20) || (current_x_old < pre_loc_x2)))
        scan_complete = 1'b1;
    else if ((qr_num == 2'd3) && (((current_x_old - pre_loc_x1) > 5'd20) || ((current_y_old - pre_loc_y1) > 5'd20) || (current_x_old < pre_loc_x1)) && 
            (((current_x_old - pre_loc_x2) > 5'd20) || ((current_y_old - pre_loc_y2) > 5'd20) || (current_x_old < pre_loc_x2)) && 
            (((current_x_old - pre_loc_x3) > 5'd20) || ((current_y_old - pre_loc_y3) > 5'd20) || (current_x_old < pre_loc_x3)))  
        scan_complete = 1'b1;
    else
        scan_complete = 1'b0;
  else
    scan_complete = 1'b0;


// handle loc
always@(posedge clk)
  if(~srst_n) begin
    loc_x <= 0;
    loc_y <= 0;
  end
  else
    if(scan_complete) begin
      loc_x <= current_x_old;
      loc_y <= current_y_old;
    end
    else begin
      loc_x <= loc_x;
      loc_y <= loc_y;
    end

always@(posedge clk)
  if(~srst_n)
    qr_num <= 0;
  else
    if(decode_complete)
      qr_num <= qr_num + 1'b1;
    else   
      qr_num <= qr_num;
      

always@*
  if((qr_num == qr_total) || ((current_x == x_upper) && (current_y == y_upper)))
    end_of_file = 1;
  else
    end_of_file = 0;
endmodule


