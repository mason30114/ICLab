module ROTATING(
    input clk,
    input srst_n,             
    input [3:0] state,                         
    input sram_data,       
    output reg [11:0] rotate_addr,
    output reg rotate_complete,
    input [5:0] scan_loc_y,
    input [5:0] scan_loc_x,
    output reg [1:0] rotation_type,
    output reg [5:0] loc_y,
    output reg [5:0] loc_x,
    output reg loc_wrong
         
);
parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;

reg [3:0] rotate_cnt, rotate_cnt_tmp;
reg finder;
/*reg sram_data_in;

always@(posedge clk)
  if(~srst_n)
    sram_data_in <= 0;
  else
    sram_data_in <= sram_data;*/

always@(posedge clk)
  if(~srst_n)
    rotate_cnt <= 0;
  else
    if((state == ROTATE) && (rotate_cnt != 4'd15))
      rotate_cnt <= rotate_cnt + 1'b1;
    else
      rotate_cnt <= 0;

// decide rotation of the qr code
always@(posedge clk)
  if(~srst_n)
    rotation_type <= 0;
  else
    if((state == ROTATE) && (rotate_cnt == 4'd15))
      rotation_type <= rotation_type + 1'b1;
    else if (state == SCAN)
      rotation_type <= 0;
    else
      rotation_type <= rotation_type;
     

// decide whether a corner is a finder
always@*
  case(rotate_cnt)
    4'd1: finder = (sram_data == 1'b1);
    4'd2: finder = (sram_data == 1'b1);
    4'd3: finder = (sram_data == 1'b1);
    4'd4: finder = (sram_data == 1'b1);
    4'd5: finder = (sram_data == 1'b1);
    4'd6: finder = (sram_data == 1'b1);
    4'd7: finder = (sram_data == 1'b1);
    4'd8: finder = (sram_data == 1'b1);
    4'd9: finder = (sram_data == 1'b0);
    4'd10: finder = (sram_data == 1'b0);
    4'd11: finder = (sram_data == 1'b0);
    4'd12: finder = (sram_data == 1'b0);
    4'd13: finder = (sram_data == 1'b0);
    4'd14: finder = (sram_data == 1'b1);
    /*6'd15: finder = (sram_data_in == 1'b1);
    6'd16: finder = (sram_data_in == 1'b0);
    6'd17: finder = (sram_data_in == 1'b1);
    6'd18: finder = (sram_data_in == 1'b1);
    6'd19: finder = (sram_data_in == 1'b1);
    6'd20: finder = (sram_data_in == 1'b0);
    6'd21: finder = (sram_data_in == 1'b1);
    6'd22: finder = (sram_data_in == 1'b1);
    6'd23: finder = (sram_data_in == 1'b0);
    6'd24: finder = (sram_data_in == 1'b1);
    6'd25: finder = (sram_data_in == 1'b1);
    6'd26: finder = (sram_data_in == 1'b1);
    6'd27: finder = (sram_data_in == 1'b0);
    6'd28: finder = (sram_data_in == 1'b1);
    6'd29: finder = (sram_data_in == 1'b1);
    6'd30: finder = (sram_data_in == 1'b0);
    6'd31: finder = (sram_data_in == 1'b1);
    6'd32: finder = (sram_data_in == 1'b1);
    6'd33: finder = (sram_data_in == 1'b1);
    6'd34: finder = (sram_data_in == 1'b0);
    6'd35: finder = (sram_data_in == 1'b1);
    6'd36: finder = (sram_data_in == 1'b1);
    6'd37: finder = (sram_data_in == 1'b0);
    6'd38: finder = (sram_data_in == 1'b0);
    6'd39: finder = (sram_data_in == 1'b0);
    6'd40: finder = (sram_data_in == 1'b0);
    6'd41: finder = (sram_data_in == 1'b0);
    6'd42: finder = (sram_data_in == 1'b1);
    6'd43: finder = (sram_data_in == 1'b1);
    6'd44: finder = (sram_data_in == 1'b1);
    6'd45: finder = (sram_data_in == 1'b1);
    6'd46: finder = (sram_data_in == 1'b1);
    6'd47: finder = (sram_data_in == 1'b1);
    6'd48: finder = (sram_data_in == 1'b1);
    6'd49: finder = (sram_data_in == 1'b1);*/
    default: finder = 1;
  endcase

// addr selection
reg [6:0] i;
reg [2:0] j; //, i_tmp, j_tmp;

/*always@*
  if((state == ROTATE) && (j == 3'd6) && finder)
    i_tmp = i + 1'b1;
  else if((state == ROTATE) && (j != 3'd6) && finder)
    i_tmp = i;
  else 
    i_tmp = 0;

always@(posedge clk)
  if(~srst_n)
    i <= 0;
  else
    i <= i_tmp;

always@*
  if((state == ROTATE) && (j != 3'd6) && finder)
    j_tmp = j + 1'b1;
  else if ((state == ROTATE) && (j == 3'd6))
    j_tmp = 0;
  else
    j_tmp = 0;

always@(posedge clk)
  if(~srst_n)
    j <= 0;
  else
    j <= j_tmp;*/

/*always@* begin
  i = rotate_cnt / 3'd7;
  j = rotate_cnt % 3'd7;
end*/

always@*
  case(rotate_cnt)
    4'd0: begin
      i = 7'd0;
      j = 3'd0;
    end
    4'd1: begin
      i = 7'd0;
      j = 3'd1;
    end
    4'd2: begin
      i = 7'd0;
      j = 3'd2;
    end
    4'd3: begin
      i = 7'd0;
      j = 3'd3;
    end
    4'd4: begin
      i = 7'd0;
      j = 3'd4;
    end
    4'd5: begin
      i = 7'd0;
      j = 3'd5;
    end
    4'd6: begin
      i = 7'd0;
      j = 3'd6;
    end
    4'd7: begin
      i = 7'd64;
      j = 3'd0;
    end
    4'd8: begin
      i = 7'd64;
      j = 3'd1;
    end
    4'd9: begin
      i = 7'd64;
      j = 3'd2;
    end
    4'd10: begin
      i = 7'd64;
      j = 3'd3;
    end
    4'd11: begin
      i = 7'd64;
      j = 3'd4;
    end
    4'd12: begin
      i = 7'd64;
      j = 3'd5;
    end
    4'd13: begin
      i = 7'd64;
      j = 3'd6;
    end
    /*4'd14: begin
      i = 3'd2;
      j = 3'd0;
    end
    6'd15: begin
      i = 3'd2;
      j = 3'd1;
    end
    6'd16: begin
      i = 3'd2;
      j = 3'd2;
    end
    6'd17: begin
      i = 3'd2;
      j = 3'd3;
    end
    6'd18: begin
      i = 3'd2;
      j = 3'd4;
    end
    6'd19: begin
      i = 3'd2;
      j = 3'd5;
    end
    6'd20: begin
      i = 3'd2;
      j = 3'd6;
    end
    6'd21: begin
      i = 3'd3;
      j = 3'd0;
    end
    6'd22: begin
      i = 3'd3;
      j = 3'd1;
    end
    6'd23: begin
      i = 3'd3;
      j = 3'd2;
    end
    6'd24: begin
      i = 3'd3;
      j = 3'd3;
    end
    6'd25: begin
      i = 3'd3;
      j = 3'd4;
    end
    6'd26: begin
      i = 3'd3;
      j = 3'd5;
    end
    6'd27: begin
      i = 3'd3;
      j = 3'd6;
    end
    6'd28: begin
      i = 3'd4;
      j = 3'd0;
    end
    6'd29: begin
      i = 3'd4;
      j = 3'd1;
    end
    6'd30: begin
      i = 3'd4;
      j = 3'd2;
    end
    6'd31: begin
      i = 3'd4;
      j = 3'd3;
    end
    6'd32: begin
      i = 3'd4;
      j = 3'd4;
    end
    6'd33: begin
      i = 3'd4;
      j = 3'd5;
    end
    6'd34: begin
      i = 3'd4;
      j = 3'd6;
    end
    6'd35: begin
      i = 3'd5;
      j = 3'd0;
    end
    6'd36: begin
      i = 3'd5;
      j = 3'd1;
    end
    6'd37: begin
      i = 3'd5;
      j = 3'd2;
    end
    6'd38: begin
      i = 3'd5;
      j = 3'd3;
    end
    6'd39: begin
      i = 3'd5;
      j = 3'd4;
    end
    6'd40: begin
      i = 3'd5;
      j = 3'd5;
    end
    6'd41: begin
      i = 3'd5;
      j = 3'd6;
    end
    6'd42: begin
      i = 3'd6;
      j = 3'd0;
    end
    6'd43: begin
      i = 3'd6;
      j = 3'd1;
    end
    6'd44: begin
      i = 3'd6;
      j = 3'd2;
    end
    6'd45: begin
      i = 3'd6;
      j = 3'd3;
    end
    6'd46: begin
      i = 3'd6;
      j = 3'd4;
    end
    6'd47: begin
      i = 3'd6;
      j = 3'd5;
    end
    6'd48: begin
      i = 3'd6;
      j = 3'd6;
    end*/
    default: begin
      i = 7'd0;
      j = 3'd0;
    end
  endcase

// handle corner addr offset
reg [9:0] rotate_off_x, rotate_off_y;
always@*
  case(rotation_type)
    2'd0: begin   
      rotate_off_x = 10'd0;
      rotate_off_y = 10'd0;
    end
    2'd1: begin   
      rotate_off_x = 10'd14;
      rotate_off_y = 10'd0;
    end
    2'd2: begin   
      rotate_off_x = 10'd0;
      rotate_off_y = 10'd896;
    end
    2'd3: begin   
      rotate_off_x = 10'd14;
      rotate_off_y = 10'd896;
    end
    default: begin   
      rotate_off_x = 10'd0;
      rotate_off_y = 10'd0;
    end   
  endcase

/*always@*
  rotate_addr = (scan_loc_y * 7'd64) + scan_loc_x + (i * 7'd64) + j + (rotate_off_y * 7'd64) + rotate_off_x;*/

always@(posedge clk)
  if(~srst_n)
    rotate_addr <= 0;
  else
    rotate_addr <= (scan_loc_y * 7'd64) + scan_loc_x + i + j + (rotate_off_y) + rotate_off_x;

// handle exact qr code location
always@(posedge clk)
  if(~srst_n) begin
    loc_x <= 0;
    loc_y <= 0;
  end
  else
    case(rotation_type)
      2'd0: begin
        loc_x <= scan_loc_x + 5'd20;
        loc_y <= scan_loc_y + 5'd20;
      end
      2'd1: begin
        loc_x <= scan_loc_x;
        loc_y <= scan_loc_y + 5'd20;
      end
      2'd2: begin
        loc_x <= scan_loc_x + 5'd20;
        loc_y <= scan_loc_y;
      end
      2'd3: begin
        loc_x <= scan_loc_x;
        loc_y <= scan_loc_y;
      end
      default: begin
        loc_x <= scan_loc_x;
        loc_y <= scan_loc_y;
      end
    endcase

always@*
  if(!finder)
    rotate_complete = 1'b1;
  else
    rotate_complete = 1'b0;

always@*
  loc_wrong = (rotation_type == 2'd0);


endmodule
