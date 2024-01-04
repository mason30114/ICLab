module LOC_CORRECT(
    input clk,
    input srst_n,                                   
    input sram_rdata,  
    input [3:0] state,
    input [5:0] loc_x,
    input [5:0] loc_y,
    output reg [11:0] loc_raddr,
    output reg [5:0] correct_loc_x,
    output reg loc_complete      
);
parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;
reg [3:0] loc_cnt, loc_cnt_tmp;
//reg [11:0] correct_loc_x_tmp;
reg [6:0] i;
reg [2:0] j;
reg finder;
/*reg opt_valid;
always@(posedge clk)
  if(~srst_n)
    opt_valid <= 0;
  else
    opt_valid <= (state == LOC);*/
   
always@(posedge clk)
  if(~srst_n)
    correct_loc_x <= 0;
  else
    if((state == LOC) && ~finder)
      correct_loc_x <= correct_loc_x + 1'b1;
    else if(state == ROTATE)
      correct_loc_x <= loc_x;
    else if((state == LOC) && (loc_cnt == 4'd14))
      correct_loc_x <= correct_loc_x + 4'd6;
    else if(state == SCAN)
      correct_loc_x <= 0;
    else
      correct_loc_x <= correct_loc_x;

always@*
  if((state == LOC) && finder)
    loc_cnt_tmp = loc_cnt + 1'b1;
  else if ((state == LOC) && ~finder)
    loc_cnt_tmp = 0;
  else if(state == SCAN)
    loc_cnt_tmp = 0;
  else
    loc_cnt_tmp = loc_cnt;
    

always@(posedge clk)
  if(~srst_n)
    loc_cnt <= 0;
  else
    loc_cnt <= loc_cnt_tmp;

/*always@*
  loc_raddr = (loc_y * 7'd64) + correct_loc_x + i  + j;*/
always@(posedge clk)
  if(~srst_n)
    loc_raddr <= 0;
  else
    loc_raddr <= (loc_y * 7'd64) + correct_loc_x + i  + j;

/*reg sram_data_in;
always@(posedge clk)
  if(~srst_n)
    sram_data_in <= 0;
  else
    sram_data_in <= sram_rdata;*/

always@*
  case(loc_cnt)
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
    /*4'd13: begin
      i = 3'd1;
      j = 3'd6;
    end
    4'd14: begin
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

/*always@* begin
  i = loc_cnt / 3'd7;
  j = loc_cnt % 3'd7;
end*/


// find the location of finder
always@*
  case(loc_cnt)
    4'd1: finder = (sram_rdata == 1'b1);
    4'd2: finder = (sram_rdata == 1'b1);
    4'd3: finder = (sram_rdata == 1'b1);
    4'd4: finder = (sram_rdata == 1'b1);
    4'd5: finder = (sram_rdata == 1'b1);
    4'd6: finder = (sram_rdata == 1'b1);
    4'd7: finder = (sram_rdata == 1'b1);
    4'd8: finder = (sram_rdata == 1'b1);
    4'd9: finder = (sram_rdata == 1'b0);
    4'd10: finder = (sram_rdata == 1'b0);
    4'd11: finder = (sram_rdata == 1'b0);
    4'd12: finder = (sram_rdata == 1'b0);
    4'd13: finder = (sram_rdata == 1'b0);
    /*4'd14: finder = (sram_data_in == 1'b1);
    6'd15: finder = (sram_data_in == 1'b1);
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

always@*
  if(loc_cnt == 4'd15)
    loc_complete = 1;
  else
    loc_complete = 0;
    





endmodule

