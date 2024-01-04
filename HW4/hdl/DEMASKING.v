module DEMASKING(
    input clk,
    input srst_n,             
    input [3:0] state,                         
    input sram_rdata,
    input [5:0] loc_x,
    input [5:0] loc_y, 
    input [1:0] rotation_type,       
    output reg [11:0] mask_addr,
    output reg [151:0] code_word,
    output reg demask_complete   
);

parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;

// demask process
reg [2:0] mask, mask_tmp, real_mask;
reg [7:0] demask_cnt;
reg [4:0] i, j;//, i_leg, j_leg;
//reg sram_rdata_in;
//reg [11:0] mask_addr;
//reg [151:0] code_word;
/*always@(posedge clk)
  if(~srst_n)
    sram_rdata_in <= 0;
  else
    sram_rdata_in <= sram_rdata;*/

always@(posedge clk)
  if(~srst_n)
    demask_cnt <= 0;
  else
    if((state == DEMASK) && (demask_cnt != 8'd158))
      demask_cnt <= demask_cnt + 1'b1;
    else
      demask_cnt <= 0;

// demask => decode
always@*
  if(demask_cnt == 8'd158)
    demask_complete = 1;
  else
    demask_complete = 0;

// select mask addr 
always@*
  //case(rotation_type)
     //2'd3:
	  case(demask_cnt)
	    8'd0: begin
	      i = 5'd8;
	      j = 5'd2;
	    end
	    8'd1: begin
	      i = 5'd8;
	      j = 5'd3;
	    end
	    8'd2: begin
	      i = 5'd8;
	      j = 5'd4;
	    end
	    8'd3: begin
	      i = 5'd20;
	      j = 5'd20;
	    end
	    8'd4: begin
	      i = 5'd20;
	      j = 5'd19;
	    end   
	    8'd5: begin
	      i = 5'd19;
	      j = 5'd20;
	    end   
	    8'd6: begin
	      i = 5'd19;
	      j = 5'd19;
	    end   
	    8'd7: begin
	      i = 5'd18;
	      j = 5'd20;
	    end   
	    8'd8: begin
	      i = 5'd18;
	      j = 5'd19;
	    end   
	    8'd9: begin
	      i = 5'd17;
	      j = 5'd20;
	    end   
	    8'd10: begin
	      i = 5'd17;
	      j = 5'd19;
	    end   
	    8'd11: begin
	      i = 5'd16;
	      j = 5'd20;
	    end
	    8'd12: begin
	      i = 5'd16;
	      j = 5'd19;
	    end   
	    8'd13: begin
	      i = 5'd15;
	      j = 5'd20;
	    end   
	    8'd14: begin
	      i = 5'd15;
	      j = 5'd19;
	    end   
	    8'd15: begin
	      i = 5'd14;
	      j = 5'd20;
	    end   
	    8'd16: begin
	      i = 5'd14;
	      j = 5'd19;
	    end   
	    8'd17: begin
	      i = 5'd13;
	      j = 5'd20;
	    end   
	    8'd18: begin
	      i = 5'd13;
	      j = 5'd19;
	    end   
	    8'd19: begin
	      i = 5'd12;
	      j = 5'd20;
	    end
	    8'd20: begin
	      i = 5'd12;
	      j = 5'd19;
	    end   
	    8'd21: begin
	      i = 5'd11;
	      j = 5'd20;
	    end   
	    8'd22: begin
	      i = 5'd11;
	      j = 5'd19;
	    end   
	    8'd23: begin
	      i = 5'd10;
	      j = 5'd20;
	    end   
	    8'd24: begin
	      i = 5'd10;
	      j = 5'd19;
	    end   
	    8'd25: begin
	      i = 5'd9;
	      j = 5'd20;
	    end   
	    8'd26: begin
	      i = 5'd9;
	      j = 5'd19;
	    end
	    8'd27: begin
	      i = 5'd9;
	      j = 5'd18;
	    end
	    8'd28: begin
	      i = 5'd9;
	      j = 5'd17;
	    end   
	    8'd29: begin
	      i = 5'd10;
	      j = 5'd18;
	    end   
	    8'd30: begin
	      i = 5'd10;
	      j = 5'd17;
	    end   
	    8'd31: begin
	      i = 5'd11;
	      j = 5'd18;
	    end   
	    8'd32: begin
	      i = 5'd11;
	      j = 5'd17;
	    end   
	    8'd33: begin
	      i = 5'd12;
	      j = 5'd18;
	    end   
	    8'd34: begin
	      i = 5'd12;
	      j = 5'd17;
	    end
	    8'd35: begin
	      i = 5'd13;
	      j = 5'd18;
	    end
	    8'd36: begin
	      i = 5'd13;
	      j = 5'd17;
	    end   
	    8'd37: begin
	      i = 5'd14;
	      j = 5'd18;
	    end   
	    8'd38: begin
	      i = 5'd14;
	      j = 5'd17;
	    end   
	    8'd39: begin
	      i = 5'd15;
	      j = 5'd18;
	    end   
	    8'd40: begin
	      i = 5'd15;
	      j = 5'd17;
	    end   
	    8'd41: begin
	      i = 5'd16;
	      j = 5'd18;
	    end   
	    8'd42: begin
	      i = 5'd16;
	      j = 5'd17;
	    end
	    8'd43: begin
	      i = 5'd17;
	      j = 5'd18;
	    end
	    8'd44: begin
	      i = 5'd17;
	      j = 5'd17;
	    end   
	    8'd45: begin
	      i = 5'd18;
	      j = 5'd18;
	    end   
	    8'd46: begin
	      i = 5'd18;
	      j = 5'd17;
	    end   
	    8'd47: begin
	      i = 5'd19;
	      j = 5'd18;
	    end   
	    8'd48: begin
	      i = 5'd19;
	      j = 5'd17;
	    end   
	    8'd49: begin
	      i = 5'd20;
	      j = 5'd18;
	    end   
	    8'd50: begin
	      i = 5'd20;
	      j = 5'd17;
	    end
	    8'd51: begin
	      i = 5'd20;
	      j = 5'd16;
	    end
	    8'd52: begin
	      i = 5'd20;
	      j = 5'd15;
	    end   
	    8'd53: begin
	      i = 5'd19;
	      j = 5'd16;
	    end   
	    8'd54: begin
	      i = 5'd19;
	      j = 5'd15;
	    end   
	    8'd55: begin
	      i = 5'd18;
	      j = 5'd16;
	    end   
	    8'd56: begin
	      i = 5'd18;
	      j = 5'd15;
	    end   
	    8'd57: begin
	      i = 5'd17;
	      j = 5'd16;
	    end   
	    8'd58: begin
	      i = 5'd17;
	      j = 5'd15;
	    end   
	    8'd59: begin
	      i = 5'd16;
	      j = 5'd16;
	    end
	    8'd60: begin
	      i = 5'd16;
	      j = 5'd15;
	    end   
	    8'd61: begin
	      i = 5'd15;
	      j = 5'd16;
	    end   
	    8'd62: begin
	      i = 5'd15;
	      j = 5'd15;
	    end   
	    8'd63: begin
	      i = 5'd14;
	      j = 5'd16;
	    end   
	    8'd64: begin
	      i = 5'd14;
	      j = 5'd15;
	    end   
	    8'd65: begin
	      i = 5'd13;
	      j = 5'd16;
	    end   
	    8'd66: begin
	      i = 5'd13;
	      j = 5'd15;
	    end   
	    8'd67: begin
	      i = 5'd12;
	      j = 5'd16;
	    end
	    8'd68: begin
	      i = 5'd12;
	      j = 5'd15;
	    end   
	    8'd69: begin
	      i = 5'd11;
	      j = 5'd16;
	    end   
	    8'd70: begin
	      i = 5'd11;
	      j = 5'd15;
	    end   
	    8'd71: begin
	      i = 5'd10;
	      j = 5'd16;
	    end   
	    8'd72: begin
	      i = 5'd10;
	      j = 5'd15;
	    end   
	    8'd73: begin
	      i = 5'd9;
	      j = 5'd16;
	    end   
	    8'd74: begin
	      i = 5'd9;
	      j = 5'd15;
	    end
	    8'd75: begin
	      i = 5'd9;
	      j = 5'd14;
	    end
	    8'd76: begin
	      i = 5'd9;
	      j = 5'd13;
	    end   
	    8'd77: begin
	      i = 5'd10;
	      j = 5'd14;
	    end   
	    8'd78: begin
	      i = 5'd10;
	      j = 5'd13;
	    end   
	    8'd79: begin
	      i = 5'd11;
	      j = 5'd14;
	    end   
	    8'd80: begin
	      i = 5'd11;
	      j = 5'd13;
	    end   
	    8'd81: begin
	      i = 5'd12;
	      j = 5'd14;
	    end   
	    8'd82: begin
	      i = 5'd12;
	      j = 5'd13;
	    end
	    8'd83: begin
	      i = 5'd13;
	      j = 5'd14;
	    end
	    8'd84: begin
	      i = 5'd13;
	      j = 5'd13;
	    end   
	    8'd85: begin
	      i = 5'd14;
	      j = 5'd14;
	    end   
	    8'd86: begin
	      i = 5'd14;
	      j = 5'd13;
	    end   
	    8'd87: begin
	      i = 5'd15;
	      j = 5'd14;
	    end   
	    8'd88: begin
	      i = 5'd15;
	      j = 5'd13;
	    end   
	    8'd89: begin
	      i = 5'd16;
	      j = 5'd14;
	    end   
	    8'd90: begin
	      i = 5'd16;
	      j = 5'd13;
	    end
	    8'd91: begin
	      i = 5'd17;
	      j = 5'd14;
	    end
	    8'd92: begin
	      i = 5'd17;
	      j = 5'd13;
	    end   
	    8'd93: begin
	      i = 5'd18;
	      j = 5'd14;
	    end   
	    8'd94: begin
	      i = 5'd18;
	      j = 5'd13;
	    end   
	    8'd95: begin
	      i = 5'd19;
	      j = 5'd14;
	    end   
	    8'd96: begin
	      i = 5'd19;
	      j = 5'd13;
	    end   
	    8'd97: begin
	      i = 5'd20;
	      j = 5'd14;
	    end   
	    8'd98: begin
	      i = 5'd20;
	      j = 5'd13;
	    end
	    8'd99: begin
	      i = 5'd20;
	      j = 5'd12;
	    end
	    8'd100: begin
	      i = 5'd20;
	      j = 5'd11;
	    end   
	    8'd101: begin
	      i = 5'd19;
	      j = 5'd12;
	    end   
	    8'd102: begin
	      i = 5'd19;
	      j = 5'd11;
	    end   
	    8'd103: begin
	      i = 5'd18;
	      j = 5'd12;
	    end   
	    8'd104: begin
	      i = 5'd18;
	      j = 5'd11;
	    end   
	    8'd105: begin
	      i = 5'd17;
	      j = 5'd12;
	    end   
	    8'd106: begin
	      i = 5'd17;
	      j = 5'd11;
	    end   
	    8'd107: begin
	      i = 5'd16;
	      j = 5'd12;
	    end
	    8'd108: begin
	      i = 5'd16;
	      j = 5'd11;
	    end   
	    8'd109: begin
	      i = 5'd15;
	      j = 5'd12;
	    end   
	    8'd110: begin
	      i = 5'd15;
	      j = 5'd11;
	    end   
	    8'd111: begin
	      i = 5'd14;
	      j = 5'd12;
	    end   
	    8'd112: begin
	      i = 5'd14;
	      j = 5'd11;
	    end   
	    8'd113: begin
	      i = 5'd13;
	      j = 5'd12;
	    end   
	    8'd114: begin
	      i = 5'd13;
	      j = 5'd11;
	    end   
	    8'd115: begin
	      i = 5'd12;
	      j = 5'd12;
	    end
	    8'd116: begin
	      i = 5'd12;
	      j = 5'd11;
	    end   
	    8'd117: begin
	      i = 5'd11;
	      j = 5'd12;
	    end   
	    8'd118: begin
	      i = 5'd11;
	      j = 5'd11;
	    end   
	    8'd119: begin
	      i = 5'd10;
	      j = 5'd12;
	    end   
	    8'd120: begin
	      i = 5'd10;
	      j = 5'd11;
	    end   
	    8'd121: begin
	      i = 5'd9;
	      j = 5'd12;
	    end   
	    8'd122: begin
	      i = 5'd9;
	      j = 5'd11;
	    end
	    8'd123: begin
	      i = 5'd8;
	      j = 5'd12;
	    end   
	    8'd124: begin
	      i = 5'd8;
	      j = 5'd11;
	    end   
	    8'd125: begin
	      i = 5'd7;
	      j = 5'd12;
	    end   
	    8'd126: begin
	      i = 5'd7;
	      j = 5'd11;
	    end
	    8'd127: begin
	      i = 5'd5;
	      j = 5'd12;
	    end   
	    8'd128: begin
	      i = 5'd5;
	      j = 5'd11;
	    end   
	    8'd129: begin
	      i = 5'd4;
	      j = 5'd12;
	    end   
	    8'd130: begin
	      i = 5'd4;
	      j = 5'd11;
	    end
	    8'd131: begin
	      i = 5'd3;
	      j = 5'd12;
	    end   
	    8'd132: begin
	      i = 5'd3;
	      j = 5'd11;
	    end   
	    8'd133: begin
	      i = 5'd2;
	      j = 5'd12;
	    end   
	    8'd134: begin
	      i = 5'd2;
	      j = 5'd11;
	    end
	    8'd135: begin
	      i = 5'd1;
	      j = 5'd12;
	    end   
	    8'd136: begin
	      i = 5'd1;
	      j = 5'd11;
	    end   
	    8'd137: begin
	      i = 5'd0;
	      j = 5'd12;
	    end   
	    8'd138: begin
	      i = 5'd0;
	      j = 5'd11;
	    end
	    8'd139: begin
	      i = 5'd0;
	      j = 5'd10;
	    end   
	    8'd140: begin
	      i = 5'd0;
	      j = 5'd9;
	    end   
	    8'd141: begin
	      i = 5'd1;
	      j = 5'd10;
	    end   
	    8'd142: begin
	      i = 5'd1;
	      j = 5'd9;
	    end
	    8'd143: begin
	      i = 5'd2;
	      j = 5'd10;
	    end   
	    8'd144: begin
	      i = 5'd2;
	      j = 5'd9;
	    end   
	    8'd145: begin
	      i = 5'd3;
	      j = 5'd10;
	    end   
	    8'd146: begin
	      i = 5'd3;
	      j = 5'd9;
	    end
	    8'd147: begin
	      i = 5'd4;
	      j = 5'd10;
	    end   
	    8'd148: begin
	      i = 5'd4;
	      j = 5'd9;
	    end   
	    8'd149: begin
	      i = 5'd5;
	      j = 5'd10;
	    end   
	    8'd150: begin
	      i = 5'd5;
	      j = 5'd9;
	    end
	    8'd151: begin
	      i = 5'd7;
	      j = 5'd10;
	    end   
	    8'd152: begin
	      i = 5'd7;
	      j = 5'd9;
	    end   
	    8'd153: begin
	      i = 5'd8;
	      j = 5'd10;
	    end   
	    8'd154: begin
	      i = 5'd8;
	      j = 5'd9;
	    end
	    /*default: begin
	      i = 5'd0;
	      j = 5'd0;
	    end
	  endcase*/
     /*2'd2:                      //270
	  case(demask_cnt)
	    9'd1: begin
	      i = 5'd2;
	      j = 5'd12;
	    end
	    9'd2: begin
	      i = 5'd3;
	      j = 5'd12;
	    end
	    9'd3: begin
	      i = 5'd4;
	      j = 5'd12;
	    end
	    9'd5: begin
	      i = 5'd20;
	      j = 5'd0;
	    end
	    9'd6: begin
	      i = 5'd19;
	      j = 5'd0;
	    end   
	    9'd7: begin
	      i = 5'd20;
	      j = 5'd1;
	    end   
	    9'd8: begin
	      i = 5'd19;
	      j = 5'd1;
	    end   
	    9'd9: begin
	      i = 5'd20;
	      j = 5'd2;
	    end   
	    9'd10: begin
	      i = 5'd19;
	      j = 5'd2;
	    end   
	    9'd11: begin
	      i = 5'd20;
	      j = 5'd3;
	    end   
	    9'd12: begin
	      i = 5'd19;
	      j = 5'd3;
	    end   
	    9'd13: begin
	      i = 5'd20;
	      j = 5'd4;
	    end
	    9'd14: begin
	      i = 5'd19;
	      j = 5'd4;
	    end   
	    9'd15: begin
	      i = 5'd20;
	      j = 5'd5;
	    end   
	    9'd16: begin
	      i = 5'd19;
	      j = 5'd5;
	    end   
	    9'd17: begin
	      i = 5'd20;
	      j = 5'd6;
	    end   
	    9'd18: begin
	      i = 5'd19;
	      j = 5'd6;
	    end   
	    9'd19: begin
	      i = 5'd20;
	      j = 5'd7;
	    end   
	    9'd20: begin
	      i = 5'd19;
	      j = 5'd7;
	    end   
	    9'd21: begin
	      i = 5'd20;
	      j = 5'd8;
	    end
	    9'd22: begin
	      i = 5'd19;
	      j = 5'd8;
	    end   
	    9'd23: begin
	      i = 5'd20;
	      j = 5'd9;
	    end   
	    9'd24: begin
	      i = 5'd19;
	      j = 5'd9;
	    end   
	    9'd25: begin
	      i = 5'd20;
	      j = 5'd10;
	    end   
	    9'd26: begin
	      i = 5'd19;
	      j = 5'd10;
	    end   
	    9'd27: begin
	      i = 5'd20;
	      j = 5'd11;
	    end   
	    9'd28: begin
	      i = 5'd19;
	      j = 5'd11;
	    end
	    9'd29: begin
	      i = 5'd18;
	      j = 5'd11;
	    end
	    9'd30: begin
	      i = 5'd17;
	      j = 5'd11;
	    end   
	    9'd31: begin
	      i = 5'd18;
	      j = 5'd10;
	    end   
	    9'd32: begin
	      i = 5'd17;
	      j = 5'd10;
	    end   
	    9'd33: begin
	      i = 5'd18;
	      j = 5'd9;
	    end   
	    9'd34: begin
	      i = 5'd17;
	      j = 5'd9;
	    end   
	    9'd35: begin
	      i = 5'd18;
	      j = 5'd8;
	    end   
	    9'd36: begin
	      i = 5'd17;
	      j = 5'd8;
	    end
	    9'd37: begin
	      i = 5'd18;
	      j = 5'd7;
	    end
	    9'd38: begin
	      i = 5'd17;
	      j = 5'd7;
	    end   
	    9'd39: begin
	      i = 5'd18;
	      j = 5'd6;
	    end   
	    9'd40: begin
	      i = 5'd17;
	      j = 5'd6;
	    end   
	    9'd41: begin
	      i = 5'd18;
	      j = 5'd5;
	    end   
	    9'd42: begin
	      i = 5'd17;
	      j = 5'd5;
	    end   
	    9'd43: begin
	      i = 5'd18;
	      j = 5'd4;
	    end   
	    9'd44: begin
	      i = 5'd17;
	      j = 5'd4;
	    end
	    9'd45: begin
	      i = 5'd18;
	      j = 5'd3;
	    end
	    9'd46: begin
	      i = 5'd17;
	      j = 5'd3;
	    end   
	    9'd47: begin
	      i = 5'd18;
	      j = 5'd2;
	    end   
	    9'd48: begin
	      i = 5'd17;
	      j = 5'd2;
	    end   
	    9'd49: begin
	      i = 5'd18;
	      j = 5'd1;
	    end   
	    9'd50: begin
	      i = 5'd17;
	      j = 5'd1;
	    end   
	    9'd51: begin
	      i = 5'd18;
	      j = 5'd0;
	    end   
	    9'd52: begin
	      i = 5'd17;
	      j = 5'd0;
	    end
	    9'd53: begin
	      i = 5'd16;
	      j = 5'd0;
	    end
	    9'd54: begin
	      i = 5'd15;
	      j = 5'd0;
	    end   
	    9'd55: begin
	      i = 5'd16;
	      j = 5'd1;
	    end   
	    9'd56: begin
	      i = 5'd15;
	      j = 5'd1;
	    end   
	    9'd57: begin
	      i = 5'd16;
	      j = 5'd2;
	    end   
	    9'd58: begin
	      i = 5'd15;
	      j = 5'd2;
	    end   
	    9'd59: begin
	      i = 5'd16;
	      j = 5'd3;
	    end   
	    9'd60: begin
	      i = 5'd15;
	      j = 5'd3;
	    end   
	    9'd61: begin
	      i = 5'd16;
	      j = 5'd4;
	    end
	    9'd62: begin
	      i = 5'd15;
	      j = 5'd4;
	    end   
	    9'd63: begin
	      i = 5'd16;
	      j = 5'd5;
	    end   
	    9'd64: begin
	      i = 5'd15;
	      j = 5'd5;
	    end   
	    9'd65: begin
	      i = 5'd16;
	      j = 5'd6;
	    end   
	    9'd66: begin
	      i = 5'd15;
	      j = 5'd6;
	    end   
	    9'd67: begin
	      i = 5'd16;
	      j = 5'd7;
	    end   
	    9'd68: begin
	      i = 5'd15;
	      j = 5'd7;
	    end   
	    9'd69: begin
	      i = 5'd16;
	      j = 5'd8;
	    end
	    9'd70: begin
	      i = 5'd15;
	      j = 5'd8;
	    end   
	    9'd71: begin
	      i = 5'd16;
	      j = 5'd9;
	    end   
	    9'd72: begin
	      i = 5'd15;
	      j = 5'd9;
	    end   
	    9'd73: begin
	      i = 5'd16;
	      j = 5'd10;
	    end   
	    9'd74: begin
	      i = 5'd15;
	      j = 5'd10;
	    end   
	    9'd75: begin
	      i = 5'd16;
	      j = 5'd11;
	    end   
	    9'd76: begin
	      i = 5'd15;
	      j = 5'd11;
	    end
	    9'd77: begin
	      i = 5'd14;
	      j = 5'd11;
	    end
	    9'd78: begin
	      i = 5'd13;
	      j = 5'd11;
	    end   
	    9'd79: begin
	      i = 5'd14;
	      j = 5'd10;
	    end   
	    9'd80: begin
	      i = 5'd13;
	      j = 5'd10;
	    end   
	    9'd81: begin
	      i = 5'd14;
	      j = 5'd9;
	    end   
	    9'd82: begin
	      i = 5'd13;
	      j = 5'd9;
	    end   
	    9'd83: begin
	      i = 5'd14;
	      j = 5'd8;
	    end   
	    9'd84: begin
	      i = 5'd13;
	      j = 5'd8;
	    end
	    9'd85: begin
	      i = 5'd14;
	      j = 5'd7;
	    end
	    9'd86: begin
	      i = 5'd13;
	      j = 5'd7;
	    end   
	    9'd87: begin
	      i = 5'd14;
	      j = 5'd6;
	    end   
	    9'd88: begin
	      i = 5'd13;
	      j = 5'd6;
	    end   
	    9'd89: begin
	      i = 5'd14;
	      j = 5'd5;
	    end   
	    9'd90: begin
	      i = 5'd13;
	      j = 5'd5;
	    end   
	    9'd91: begin
	      i = 5'd14;
	      j = 5'd4;
	    end   
	    9'd92: begin
	      i = 5'd13;
	      j = 5'd4;
	    end
	    9'd93: begin
	      i = 5'd14;
	      j = 5'd3;
	    end
	    9'd94: begin
	      i = 5'd13;
	      j = 5'd3;
	    end   
	    9'd95: begin
	      i = 5'd14;
	      j = 5'd2;
	    end   
	    9'd96: begin
	      i = 5'd13;
	      j = 5'd2;
	    end   
	    9'd97: begin
	      i = 5'd14;
	      j = 5'd1;
	    end   
	    9'd98: begin
	      i = 5'd13;
	      j = 5'd1;
	    end   
	    9'd99: begin
	      i = 5'd14;
	      j = 5'd0;
	    end   
	    9'd100: begin
	      i = 5'd13;
	      j = 5'd0;
	    end
	    9'd101: begin
	      i = 5'd12;
	      j = 5'd0;
	    end
	    9'd102: begin
	      i = 5'd11;
	      j = 5'd0;
	    end   
	    9'd103: begin
	      i = 5'd12;
	      j = 5'd1;
	    end   
	    9'd104: begin
	      i = 5'd11;
	      j = 5'd1;
	    end   
	    9'd105: begin
	      i = 5'd12;
	      j = 5'd2;
	    end   
	    9'd106: begin
	      i = 5'd11;
	      j = 5'd2;
	    end   
	    9'd107: begin
	      i = 5'd12;
	      j = 5'd3;
	    end   
	    9'd108: begin
	      i = 5'd11;
	      j = 5'd3;
	    end   
	    9'd109: begin
	      i = 5'd12;
	      j = 5'd4;
	    end
	    9'd110: begin
	      i = 5'd11;
	      j = 5'd4;
	    end   
	    9'd111: begin
	      i = 5'd12;
	      j = 5'd5;
	    end   
	    9'd112: begin
	      i = 5'd11;
	      j = 5'd5;
	    end   
	    9'd113: begin
	      i = 5'd12;
	      j = 5'd6;
	    end   
	    9'd114: begin
	      i = 5'd11;
	      j = 5'd6;
	    end   
	    9'd115: begin
	      i = 5'd12;
	      j = 5'd7;
	    end   
	    9'd116: begin
	      i = 5'd11;
	      j = 5'd7;
	    end   
	    9'd117: begin
	      i = 5'd12;
	      j = 5'd8;
	    end
	    9'd118: begin
	      i = 5'd11;
	      j = 5'd8;
	    end   
	    9'd119: begin
	      i = 5'd12;
	      j = 5'd9;
	    end   
	    9'd120: begin
	      i = 5'd11;
	      j = 5'd9;
	    end   
	    9'd121: begin
	      i = 5'd12;
	      j = 5'd10;
	    end   
	    9'd122: begin
	      i = 5'd11;
	      j = 5'd10;
	    end   
	    9'd123: begin
	      i = 5'd12;
	      j = 5'd11;
	    end   
	    9'd124: begin
	      i = 5'd11;
	      j = 5'd11;
	    end
	    9'd125: begin
	      i = 5'd12;
	      j = 5'd12;
	    end
	    9'd126: begin
	      i = 5'd11;
	      j = 5'd12;
	    end   
	    9'd127: begin
	      i = 5'd12;
	      j = 5'd13;
	    end   
	    9'd128: begin
	      i = 5'd11;
	      j = 5'd13;
	    end   
	    9'd129: begin
	      i = 5'd12;
	      j = 5'd15;
	    end   
	    9'd130: begin
	      i = 5'd11;
	      j = 5'd15;
	    end   
	    9'd131: begin
	      i = 5'd12;
	      j = 5'd16;
	    end   
	    9'd132: begin
	      i = 5'd11;
	      j = 5'd16;
	    end   
	    9'd133: begin
	      i = 5'd12;
	      j = 5'd17;
	    end
	    9'd134: begin
	      i = 5'd11;
	      j = 5'd17;
	    end   
	    9'd135: begin
	      i = 5'd12;
	      j = 5'd18;
	    end   
	    9'd136: begin
	      i = 5'd11;
	      j = 5'd18;
	    end   
	    9'd137: begin
	      i = 5'd12;
	      j = 5'd19;
	    end   
	    9'd138: begin
	      i = 5'd11;
	      j = 5'd19;
	    end   
	    9'd139: begin
	      i = 5'd12;
	      j = 5'd20;
	    end   
	    9'd140: begin
	      i = 5'd11;
	      j = 5'd20;
	    end   
	    9'd141: begin
	      i = 5'd10;
	      j = 5'd20;
	    end   
	    9'd142: begin
	      i = 5'd9;
	      j = 5'd20;
	    end   
	    9'd143: begin
	      i = 5'd10;
	      j = 5'd19;
	    end   
	    9'd144: begin
	      i = 5'd9;
	      j = 5'd19;
	    end
	    9'd145: begin
	      i = 5'd10;
	      j = 5'd18;
	    end   
	    9'd146: begin
	      i = 5'd9;
	      j = 5'd18;
	    end   
	    9'd147: begin
	      i = 5'd10;
	      j = 5'd17;
	    end   
	    9'd148: begin
	      i = 5'd9;
	      j = 5'd17;
	    end
	    9'd149: begin
	      i = 5'd10;
	      j = 5'd16;
	    end   
	    9'd150: begin
	      i = 5'd9;
	      j = 5'd16;
	    end   
	    9'd151: begin
	      i = 5'd10;
	      j = 5'd15;
	    end   
	    9'd152: begin
	      i = 5'd9;
	      j = 5'd15;
	    end
	    9'd153: begin
	      i = 5'd10;
	      j = 5'd14;
	    end   
	    9'd154: begin
	      i = 5'd9;
	      j = 5'd14;
	    end   
	    9'd155: begin
	      i = 5'd10;
	      j = 5'd13;
	    end   
	    9'd156: begin
	      i = 5'd9;
	      j = 5'd13;
	    end
	    default: begin
	      i = 5'd0;
	      j = 5'd0;
	    end
	  endcase
     2'd1:                      //90
	  case(demask_cnt)
	    9'd1: begin
	      i = 5'd18;
	      j = 5'd8;
	    end
	    9'd2: begin
	      i = 5'd17;
	      j = 5'd8;
	    end
	    9'd3: begin
	      i = 5'd16;
	      j = 5'd8;
	    end
	    9'd5: begin
	      i = 5'd0;
	      j = 5'd20;
	    end
	    9'd6: begin
	      i = 5'd1;
	      j = 5'd20;
	    end   
	    9'd7: begin
	      i = 5'd0;
	      j = 5'd19;
	    end   
	    9'd8: begin
	      i = 5'd1;
	      j = 5'd19;
	    end   
	    9'd9: begin
	      i = 5'd0;
	      j = 5'd18;
	    end   
	    9'd10: begin
	      i = 5'd1;
	      j = 5'd18;
	    end   
	    9'd11: begin
	      i = 5'd0;
	      j = 5'd17;
	    end   
	    9'd12: begin
	      i = 5'd1;
	      j = 5'd17;
	    end   
	    9'd13: begin
	      i = 5'd0;
	      j = 5'd16;
	    end
	    9'd14: begin
	      i = 5'd1;
	      j = 5'd16;
	    end   
	    9'd15: begin
	      i = 5'd0;
	      j = 5'd15;
	    end   
	    9'd16: begin
	      i = 5'd1;
	      j = 5'd15;
	    end   
	    9'd17: begin
	      i = 5'd0;
	      j = 5'd14;
	    end   
	    9'd18: begin
	      i = 5'd1;
	      j = 5'd14;
	    end   
	    9'd19: begin
	      i = 5'd0;
	      j = 5'd13;
	    end   
	    9'd20: begin
	      i = 5'd1;
	      j = 5'd13;
	    end   
	    9'd21: begin
	      i = 5'd0;
	      j = 5'd12;
	    end
	    9'd22: begin
	      i = 5'd1;
	      j = 5'd12;
	    end   
	    9'd23: begin
	      i = 5'd0;
	      j = 5'd11;
	    end   
	    9'd24: begin
	      i = 5'd1;
	      j = 5'd11;
	    end   
	    9'd25: begin
	      i = 5'd0;
	      j = 5'd10;
	    end   
	    9'd26: begin
	      i = 5'd1;
	      j = 5'd10;
	    end   
	    9'd27: begin
	      i = 5'd0;
	      j = 5'd9;
	    end   
	    9'd28: begin
	      i = 5'd1;
	      j = 5'd9;
	    end
	    9'd29: begin
	      i = 5'd2;
	      j = 5'd9;
	    end
	    9'd30: begin
	      i = 5'd3;
	      j = 5'd9;
	    end   
	    9'd31: begin
	      i = 5'd2;
	      j = 5'd10;
	    end   
	    9'd32: begin
	      i = 5'd3;
	      j = 5'd10;
	    end   
	    9'd33: begin
	      i = 5'd2;
	      j = 5'd11;
	    end   
	    9'd34: begin
	      i = 5'd3;
	      j = 5'd11;
	    end   
	    9'd35: begin
	      i = 5'd2;
	      j = 5'd12;
	    end   
	    9'd36: begin
	      i = 5'd3;
	      j = 5'd12;
	    end
	    9'd37: begin
	      i = 5'd2;
	      j = 5'd13;
	    end
	    9'd38: begin
	      i = 5'd3;
	      j = 5'd13;
	    end   
	    9'd39: begin
	      i = 5'd2;
	      j = 5'd14;
	    end   
	    9'd40: begin
	      i = 5'd3;
	      j = 5'd14;
	    end   
	    9'd41: begin
	      i = 5'd2;
	      j = 5'd15;
	    end   
	    9'd42: begin
	      i = 5'd3;
	      j = 5'd15;
	    end   
	    9'd43: begin
	      i = 5'd2;
	      j = 5'd16;
	    end   
	    9'd44: begin
	      i = 5'd3;
	      j = 5'd16;
	    end
	    9'd45: begin
	      i = 5'd2;
	      j = 5'd17;
	    end
	    9'd46: begin
	      i = 5'd3;
	      j = 5'd17;
	    end   
	    9'd47: begin
	      i = 5'd2;
	      j = 5'd18;
	    end   
	    9'd48: begin
	      i = 5'd3;
	      j = 5'd18;
	    end   
	    9'd49: begin
	      i = 5'd2;
	      j = 5'd19;
	    end   
	    9'd50: begin
	      i = 5'd3;
	      j = 5'd19;
	    end   
	    9'd51: begin
	      i = 5'd2;
	      j = 5'd20;
	    end   
	    9'd52: begin
	      i = 5'd3;
	      j = 5'd20;
	    end
	    9'd53: begin
	      i = 5'd4;
	      j = 5'd20;
	    end
	    9'd54: begin
	      i = 5'd5;
	      j = 5'd20;
	    end   
	    9'd55: begin
	      i = 5'd4;
	      j = 5'd19;
	    end   
	    9'd56: begin
	      i = 5'd5;
	      j = 5'd19;
	    end   
	    9'd57: begin
	      i = 5'd4;
	      j = 5'd18;
	    end   
	    9'd58: begin
	      i = 5'd5;
	      j = 5'd18;
	    end   
	    9'd59: begin
	      i = 5'd4;
	      j = 5'd17;
	    end   
	    9'd60: begin
	      i = 5'd5;
	      j = 5'd17;
	    end   
	    9'd61: begin
	      i = 5'd4;
	      j = 5'd16;
	    end
	    9'd62: begin
	      i = 5'd5;
	      j = 5'd16;
	    end   
	    9'd63: begin
	      i = 5'd4;
	      j = 5'd15;
	    end   
	    9'd64: begin
	      i = 5'd5;
	      j = 5'd15;
	    end   
	    9'd65: begin
	      i = 5'd4;
	      j = 5'd14;
	    end   
	    9'd66: begin
	      i = 5'd5;
	      j = 5'd14;
	    end   
	    9'd67: begin
	      i = 5'd4;
	      j = 5'd13;
	    end   
	    9'd68: begin
	      i = 5'd5;
	      j = 5'd13;
	    end   
	    9'd69: begin
	      i = 5'd4;
	      j = 5'd12;
	    end
	    9'd70: begin
	      i = 5'd5;
	      j = 5'd12;
	    end   
	    9'd71: begin
	      i = 5'd4;
	      j = 5'd11;
	    end   
	    9'd72: begin
	      i = 5'd5;
	      j = 5'd11;
	    end   
	    9'd73: begin
	      i = 5'd4;
	      j = 5'd10;
	    end   
	    9'd74: begin
	      i = 5'd5;
	      j = 5'd10;
	    end   
	    9'd75: begin
	      i = 5'd4;
	      j = 5'd9;
	    end   
	    9'd76: begin
	      i = 5'd5;
	      j = 5'd9;
	    end
	    9'd77: begin
	      i = 5'd6;
	      j = 5'd9;
	    end
	    9'd78: begin
	      i = 5'd7;
	      j = 5'd9;
	    end   
	    9'd79: begin
	      i = 5'd6;
	      j = 5'd10;
	    end   
	    9'd80: begin
	      i = 5'd7;
	      j = 5'd10;
	    end   
	    9'd81: begin
	      i = 5'd6;
	      j = 5'd11;
	    end   
	    9'd82: begin
	      i = 5'd7;
	      j = 5'd11;
	    end   
	    9'd83: begin
	      i = 5'd6;
	      j = 5'd12;
	    end   
	    9'd84: begin
	      i = 5'd7;
	      j = 5'd12;
	    end
	    9'd85: begin
	      i = 5'd6;
	      j = 5'd13;
	    end
	    9'd86: begin
	      i = 5'd7;
	      j = 5'd13;
	    end   
	    9'd87: begin
	      i = 5'd6;
	      j = 5'd14;
	    end   
	    9'd88: begin
	      i = 5'd7;
	      j = 5'd14;
	    end   
	    9'd89: begin
	      i = 5'd6;
	      j = 5'd15;
	    end   
	    9'd90: begin
	      i = 5'd7;
	      j = 5'd15;
	    end   
	    9'd91: begin
	      i = 5'd6;
	      j = 5'd16;
	    end   
	    9'd92: begin
	      i = 5'd7;
	      j = 5'd16;
	    end
	    9'd93: begin
	      i = 5'd6;
	      j = 5'd17;
	    end
	    9'd94: begin
	      i = 5'd7;
	      j = 5'd17;
	    end   
	    9'd95: begin
	      i = 5'd6;
	      j = 5'd18;
	    end   
	    9'd96: begin
	      i = 5'd7;
	      j = 5'd18;
	    end   
	    9'd97: begin
	      i = 5'd6;
	      j = 5'd19;
	    end   
	    9'd98: begin
	      i = 5'd7;
	      j = 5'd19;
	    end   
	    9'd99: begin
	      i = 5'd6;
	      j = 5'd20;
	    end   
	    9'd100: begin
	      i = 5'd7;
	      j = 5'd20;
	    end
	    9'd101: begin
	      i = 5'd8;
	      j = 5'd20;
	    end
	    9'd102: begin
	      i = 5'd9;
	      j = 5'd20;
	    end   
	    9'd103: begin
	      i = 5'd8;
	      j = 5'd19;
	    end   
	    9'd104: begin
	      i = 5'd9;
	      j = 5'd19;
	    end   
	    9'd105: begin
	      i = 5'd8;
	      j = 5'd18;
	    end   
	    9'd106: begin
	      i = 5'd9;
	      j = 5'd18;
	    end   
	    9'd107: begin
	      i = 5'd8;
	      j = 5'd17;
	    end   
	    9'd108: begin
	      i = 5'd9;
	      j = 5'd17;
	    end   
	    9'd109: begin
	      i = 5'd8;
	      j = 5'd16;
	    end
	    9'd110: begin
	      i = 5'd9;
	      j = 5'd16;
	    end   
	    9'd111: begin
	      i = 5'd8;
	      j = 5'd15;
	    end   
	    9'd112: begin
	      i = 5'd9;
	      j = 5'd15;
	    end   
	    9'd113: begin
	      i = 5'd8;
	      j = 5'd14;
	    end   
	    9'd114: begin
	      i = 5'd9;
	      j = 5'd14;
	    end   
	    9'd115: begin
	      i = 5'd8;
	      j = 5'd13;
	    end   
	    9'd116: begin
	      i = 5'd9;
	      j = 5'd13;
	    end   
	    9'd117: begin
	      i = 5'd8;
	      j = 5'd12;
	    end
	    9'd118: begin
	      i = 5'd9;
	      j = 5'd12;
	    end   
	    9'd119: begin
	      i = 5'd8;
	      j = 5'd11;
	    end   
	    9'd120: begin
	      i = 5'd9;
	      j = 5'd11;
	    end   
	    9'd121: begin
	      i = 5'd8;
	      j = 5'd10;
	    end   
	    9'd122: begin
	      i = 5'd9;
	      j = 5'd10;
	    end   
	    9'd123: begin
	      i = 5'd8;
	      j = 5'd9;
	    end   
	    9'd124: begin
	      i = 5'd9;
	      j = 5'd9;
	    end
	    9'd125: begin
	      i = 5'd8;
	      j = 5'd8;
	    end
	    9'd126: begin
	      i = 5'd9;
	      j = 5'd8;
	    end   
	    9'd127: begin
	      i = 5'd8;
	      j = 5'd7;
	    end   
	    9'd128: begin
	      i = 5'd9;
	      j = 5'd7;
	    end   
	    9'd129: begin
	      i = 5'd8;
	      j = 5'd5;
	    end   
	    9'd130: begin
	      i = 5'd9;
	      j = 5'd5;
	    end   
	    9'd131: begin
	      i = 5'd8;
	      j = 5'd4;
	    end   
	    9'd132: begin
	      i = 5'd9;
	      j = 5'd4;
	    end   
	    9'd133: begin
	      i = 5'd8;
	      j = 5'd3;
	    end
	    9'd134: begin
	      i = 5'd9;
	      j = 5'd3;
	    end   
	    9'd135: begin
	      i = 5'd8;
	      j = 5'd2;
	    end   
	    9'd136: begin
	      i = 5'd9;
	      j = 5'd2;
	    end   
	    9'd137: begin
	      i = 5'd8;
	      j = 5'd1;
	    end   
	    9'd138: begin
	      i = 5'd9;
	      j = 5'd1;
	    end   
	    9'd139: begin
	      i = 5'd8;
	      j = 5'd0;
	    end   
	    9'd140: begin
	      i = 5'd9;
	      j = 5'd0;
	    end   
	    9'd141: begin
	      i = 5'd10;
	      j = 5'd0;
	    end   
	    9'd142: begin
	      i = 5'd11;
	      j = 5'd0;
	    end   
	    9'd143: begin
	      i = 5'd10;
	      j = 5'd1;
	    end   
	    9'd144: begin
	      i = 5'd11;
	      j = 5'd1;
	    end
	    9'd145: begin
	      i = 5'd10;
	      j = 5'd2;
	    end   
	    9'd146: begin
	      i = 5'd11;
	      j = 5'd2;
	    end   
	    9'd147: begin
	      i = 5'd10;
	      j = 5'd3;
	    end   
	    9'd148: begin
	      i = 5'd11;
	      j = 5'd3;
	    end
	    9'd149: begin
	      i = 5'd10;
	      j = 5'd4;
	    end   
	    9'd150: begin
	      i = 5'd11;
	      j = 5'd4;
	    end   
	    9'd151: begin
	      i = 5'd10;
	      j = 5'd5;
	    end   
	    9'd152: begin
	      i = 5'd11;
	      j = 5'd5;
	    end
	    9'd153: begin
	      i = 5'd10;
	      j = 5'd6;
	    end   
	    9'd154: begin
	      i = 5'd11;
	      j = 5'd6;
	    end   
	    9'd155: begin
	      i = 5'd10;
	      j = 5'd7;
	    end   
	    9'd156: begin
	      i = 5'd11;
	      j = 5'd7;
	    end
	    default: begin
	      i = 5'd0;
	      j = 5'd0;
	    end
	  endcase
     2'd0:
	  case(demask_cnt)
	    9'd1: begin
	      i = 5'd12;
	      j = 5'd18;
	    end
	    9'd2: begin
	      i = 5'd12;
	      j = 5'd17;
	    end
	    9'd3: begin
	      i = 5'd12;
	      j = 5'd16;
	    end
	    9'd5: begin
	      i = 5'd0;
	      j = 5'd0;
	    end
	    9'd6: begin
	      i = 5'd0;
	      j = 5'd1;
	    end   
	    9'd7: begin
	      i = 5'd1;
	      j = 5'd0;
	    end   
	    9'd8: begin
	      i = 5'd1;
	      j = 5'd1;
	    end   
	    9'd9: begin
	      i = 5'd2;
	      j = 5'd0;
	    end   
	    9'd10: begin
	      i = 5'd2;
	      j = 5'd1;
	    end   
	    9'd11: begin
	      i = 5'd3;
	      j = 5'd0;
	    end   
	    9'd12: begin
	      i = 5'd3;
	      j = 5'd1;
	    end   
	    9'd13: begin
	      i = 5'd4;
	      j = 5'd0;
	    end
	    9'd14: begin
	      i = 5'd4;
	      j = 5'd1;
	    end   
	    9'd15: begin
	      i = 5'd5;
	      j = 5'd0;
	    end   
	    9'd16: begin
	      i = 5'd5;
	      j = 5'd1;
	    end   
	    9'd17: begin
	      i = 5'd6;
	      j = 5'd0;
	    end   
	    9'd18: begin
	      i = 5'd6;
	      j = 5'd1;
	    end   
	    9'd19: begin
	      i = 5'd7;
	      j = 5'd0;
	    end   
	    9'd20: begin
	      i = 5'd7;
	      j = 5'd1;
	    end   
	    9'd21: begin
	      i = 5'd8;
	      j = 5'd0;
	    end
	    9'd22: begin
	      i = 5'd8;
	      j = 5'd1;
	    end   
	    9'd23: begin
	      i = 5'd9;
	      j = 5'd0;
	    end   
	    9'd24: begin
	      i = 5'd9;
	      j = 5'd1;
	    end   
	    9'd25: begin
	      i = 5'd10;
	      j = 5'd0;
	    end   
	    9'd26: begin
	      i = 5'd10;
	      j = 5'd1;
	    end   
	    9'd27: begin
	      i = 5'd11;
	      j = 5'd0;
	    end   
	    9'd28: begin
	      i = 5'd11;
	      j = 5'd1;
	    end
	    9'd29: begin
	      i = 5'd11;
	      j = 5'd2;
	    end
	    9'd30: begin
	      i = 5'd11;
	      j = 5'd3;
	    end   
	    9'd31: begin
	      i = 5'd10;
	      j = 5'd2;
	    end   
	    9'd32: begin
	      i = 5'd10;
	      j = 5'd3;
	    end   
	    9'd33: begin
	      i = 5'd9;
	      j = 5'd2;
	    end   
	    9'd34: begin
	      i = 5'd9;
	      j = 5'd3;
	    end   
	    9'd35: begin
	      i = 5'd8;
	      j = 5'd2;
	    end   
	    9'd36: begin
	      i = 5'd8;
	      j = 5'd3;
	    end
	    9'd37: begin
	      i = 5'd7;
	      j = 5'd2;
	    end
	    9'd38: begin
	      i = 5'd7;
	      j = 5'd3;
	    end   
	    9'd39: begin
	      i = 5'd6;
	      j = 5'd2;
	    end   
	    9'd40: begin
	      i = 5'd6;
	      j = 5'd3;
	    end   
	    9'd41: begin
	      i = 5'd5;
	      j = 5'd2;
	    end   
	    9'd42: begin
	      i = 5'd5;
	      j = 5'd3;
	    end   
	    9'd43: begin
	      i = 5'd4;
	      j = 5'd2;
	    end   
	    9'd44: begin
	      i = 5'd4;
	      j = 5'd3;
	    end
	    9'd45: begin
	      i = 5'd3;
	      j = 5'd2;
	    end
	    9'd46: begin
	      i = 5'd3;
	      j = 5'd3;
	    end   
	    9'd47: begin
	      i = 5'd2;
	      j = 5'd2;
	    end   
	    9'd48: begin
	      i = 5'd2;
	      j = 5'd3;
	    end   
	    9'd49: begin
	      i = 5'd1;
	      j = 5'd2;
	    end   
	    9'd50: begin
	      i = 5'd1;
	      j = 5'd3;
	    end   
	    9'd51: begin
	      i = 5'd0;
	      j = 5'd2;
	    end   
	    9'd52: begin
	      i = 5'd0;
	      j = 5'd3;
	    end
	    9'd53: begin
	      i = 5'd0;
	      j = 5'd4;
	    end
	    9'd54: begin
	      i = 5'd0;
	      j = 5'd5;
	    end   
	    9'd55: begin
	      i = 5'd1;
	      j = 5'd4;
	    end   
	    9'd56: begin
	      i = 5'd1;
	      j = 5'd5;
	    end   
	    9'd57: begin
	      i = 5'd2;
	      j = 5'd4;
	    end   
	    9'd58: begin
	      i = 5'd2;
	      j = 5'd5;
	    end   
	    9'd59: begin
	      i = 5'd3;
	      j = 5'd4;
	    end   
	    9'd60: begin
	      i = 5'd3;
	      j = 5'd5;
	    end   
	    9'd61: begin
	      i = 5'd4;
	      j = 5'd4;
	    end
	    9'd62: begin
	      i = 5'd4;
	      j = 5'd5;
	    end   
	    9'd63: begin
	      i = 5'd5;
	      j = 5'd4;
	    end   
	    9'd64: begin
	      i = 5'd5;
	      j = 5'd5;
	    end   
	    9'd65: begin
	      i = 5'd6;
	      j = 5'd4;
	    end   
	    9'd66: begin
	      i = 5'd6;
	      j = 5'd5;
	    end   
	    9'd67: begin
	      i = 5'd7;
	      j = 5'd4;
	    end   
	    9'd68: begin
	      i = 5'd7;
	      j = 5'd5;
	    end   
	    9'd69: begin
	      i = 5'd8;
	      j = 5'd4;
	    end
	    9'd70: begin
	      i = 5'd8;
	      j = 5'd5;
	    end   
	    9'd71: begin
	      i = 5'd9;
	      j = 5'd4;
	    end   
	    9'd72: begin
	      i = 5'd9;
	      j = 5'd5;
	    end   
	    9'd73: begin
	      i = 5'd10;
	      j = 5'd4;
	    end   
	    9'd74: begin
	      i = 5'd10;
	      j = 5'd5;
	    end   
	    9'd75: begin
	      i = 5'd11;
	      j = 5'd4;
	    end   
	    9'd76: begin
	      i = 5'd11;
	      j = 5'd5;
	    end
	    9'd77: begin
	      i = 5'd11;
	      j = 5'd6;
	    end
	    9'd78: begin
	      i = 5'd11;
	      j = 5'd7;
	    end   
	    9'd79: begin
	      i = 5'd10;
	      j = 5'd6;
	    end   
	    9'd80: begin
	      i = 5'd10;
	      j = 5'd7;
	    end   
	    9'd81: begin
	      i = 5'd9;
	      j = 5'd6;
	    end   
	    9'd82: begin
	      i = 5'd9;
	      j = 5'd7;
	    end   
	    9'd83: begin
	      i = 5'd8;
	      j = 5'd6;
	    end   
	    9'd84: begin
	      i = 5'd8;
	      j = 5'd7;
	    end
	    9'd85: begin
	      i = 5'd7;
	      j = 5'd6;
	    end
	    9'd86: begin
	      i = 5'd7;
	      j = 5'd7;
	    end   
	    9'd87: begin
	      i = 5'd6;
	      j = 5'd6;
	    end   
	    9'd88: begin
	      i = 5'd6;
	      j = 5'd7;
	    end   
	    9'd89: begin
	      i = 5'd5;
	      j = 5'd6;
	    end   
	    9'd90: begin
	      i = 5'd5;
	      j = 5'd7;
	    end   
	    9'd91: begin
	      i = 5'd4;
	      j = 5'd6;
	    end   
	    9'd92: begin
	      i = 5'd4;
	      j = 5'd7;
	    end
	    9'd93: begin
	      i = 5'd3;
	      j = 5'd6;
	    end
	    9'd94: begin
	      i = 5'd3;
	      j = 5'd7;
	    end   
	    9'd95: begin
	      i = 5'd2;
	      j = 5'd6;
	    end   
	    9'd96: begin
	      i = 5'd2;
	      j = 5'd7;
	    end   
	    9'd97: begin
	      i = 5'd1;
	      j = 5'd6;
	    end   
	    9'd98: begin
	      i = 5'd1;
	      j = 5'd7;
	    end   
	    9'd99: begin
	      i = 5'd0;
	      j = 5'd6;
	    end   
	    9'd100: begin
	      i = 5'd0;
	      j = 5'd7;
	    end
	    9'd101: begin
	      i = 5'd0;
	      j = 5'd8;
	    end
	    9'd102: begin
	      i = 5'd0;
	      j = 5'd9;
	    end   
	    9'd103: begin
	      i = 5'd1;
	      j = 5'd8;
	    end   
	    9'd104: begin
	      i = 5'd1;
	      j = 5'd9;
	    end   
	    9'd105: begin
	      i = 5'd2;
	      j = 5'd8;
	    end   
	    9'd106: begin
	      i = 5'd2;
	      j = 5'd9;
	    end   
	    9'd107: begin
	      i = 5'd3;
	      j = 5'd8;
	    end   
	    9'd108: begin
	      i = 5'd3;
	      j = 5'd9;
	    end   
	    9'd109: begin
	      i = 5'd4;
	      j = 5'd8;
	    end
	    9'd110: begin
	      i = 5'd4;
	      j = 5'd9;
	    end   
	    9'd111: begin
	      i = 5'd5;
	      j = 5'd8;
	    end   
	    9'd112: begin
	      i = 5'd5;
	      j = 5'd9;
	    end   
	    9'd113: begin
	      i = 5'd6;
	      j = 5'd8;
	    end   
	    9'd114: begin
	      i = 5'd6;
	      j = 5'd9;
	    end   
	    9'd115: begin
	      i = 5'd7;
	      j = 5'd8;
	    end   
	    9'd116: begin
	      i = 5'd7;
	      j = 5'd9;
	    end   
	    9'd117: begin
	      i = 5'd8;
	      j = 5'd8;
	    end
	    9'd118: begin
	      i = 5'd8;
	      j = 5'd9;
	    end   
	    9'd119: begin
	      i = 5'd9;
	      j = 5'd8;
	    end   
	    9'd120: begin
	      i = 5'd9;
	      j = 5'd9;
	    end   
	    9'd121: begin
	      i = 5'd10;
	      j = 5'd8;
	    end   
	    9'd122: begin
	      i = 5'd10;
	      j = 5'd9;
	    end   
	    9'd123: begin
	      i = 5'd11;
	      j = 5'd8;
	    end   
	    9'd124: begin
	      i = 5'd11;
	      j = 5'd9;
	    end
	    9'd125: begin
	      i = 5'd12;
	      j = 5'd8;
	    end   
	    9'd126: begin
	      i = 5'd12;
	      j = 5'd9;
	    end   
	    9'd127: begin
	      i = 5'd13;
	      j = 5'd8;
	    end   
	    9'd128: begin
	      i = 5'd13;
	      j = 5'd9;
	    end
	    9'd129: begin
	      i = 5'd15;
	      j = 5'd8;
	    end   
	    9'd130: begin
	      i = 5'd15;
	      j = 5'd9;
	    end   
	    9'd131: begin
	      i = 5'd16;
	      j = 5'd8;
	    end   
	    9'd132: begin
	      i = 5'd16;
	      j = 5'd9;
	    end
	    9'd133: begin
	      i = 5'd17;
	      j = 5'd8;
	    end   
	    9'd134: begin
	      i = 5'd17;
	      j = 5'd9;
	    end   
	    9'd135: begin
	      i = 5'd18;
	      j = 5'd8;
	    end   
	    9'd136: begin
	      i = 5'd18;
	      j = 5'd9;
	    end
	    9'd137: begin
	      i = 5'd19;
	      j = 5'd8;
	    end   
	    9'd138: begin
	      i = 5'd19;
	      j = 5'd9;
	    end   
	    9'd139: begin
	      i = 5'd20;
	      j = 5'd8;
	    end   
	    9'd140: begin
	      i = 5'd20;
	      j = 5'd9;
	    end
	    9'd141: begin
	      i = 5'd20;
	      j = 5'd10;
	    end   
	    9'd142: begin
	      i = 5'd20;
	      j = 5'd11;
	    end   
	    9'd143: begin
	      i = 5'd19;
	      j = 5'd10;
	    end   
	    9'd144: begin
	      i = 5'd19;
	      j = 5'd11;
	    end
	    9'd145: begin
	      i = 5'd18;
	      j = 5'd10;
	    end   
	    9'd146: begin
	      i = 5'd18;
	      j = 5'd11;
	    end   
	    9'd147: begin
	      i = 5'd17;
	      j = 5'd10;
	    end   
	    9'd148: begin
	      i = 5'd17;
	      j = 5'd11;
	    end
	    9'd149: begin
	      i = 5'd16;
	      j = 5'd10;
	    end   
	    9'd150: begin
	      i = 5'd16;
	      j = 5'd11;
	    end   
	    9'd151: begin
	      i = 5'd15;
	      j = 5'd10;
	    end   
	    9'd152: begin
	      i = 5'd15;
	      j = 5'd11;
	    end
	    9'd153: begin
	      i = 5'd13;
	      j = 5'd10;
	    end   
	    9'd154: begin
	      i = 5'd13;
	      j = 5'd11;
	    end   
	    9'd155: begin
	      i = 5'd12;
	      j = 5'd10;
	    end   
	    9'd156: begin
	      i = 5'd12;
	      j = 5'd11;
	    end
	    default: begin
	      i = 5'd0;
	      j = 5'd0;
	    end
	  endcase*/
    default: begin
      i = 5'd0;
      j = 5'd0;
    end
  endcase


// i, j for comparasion (after reading SRAM)
/*always@(posedge clk)
  if(~srst_n) begin
    i_leg <= 0;
    j_leg <= 0;
  end
  else begin
    /*case(rotation_type)
      2'd3: begin
        i_leg <= i;
        j_leg <= j;
      end
      2'd2: begin
        i_leg <= i;//(5'd20-j);
        j_leg <= j;//i;
      end
      2'd1: begin
        i_leg <= i;//j;
        j_leg <= j;//(5'd20-i);
      end
      2'd0: begin
        i_leg <= i;//(5'd20-i);
        j_leg <= j;//(5'd20-j);
      end
      default: begin
        i_leg <= i;
        j_leg <= j;
      end
    endcase
  end*/
reg [5:0] i_old, j_old, i_old2, j_old2;//, i_old3, j_old3;
reg [11:0] loc_y_mul, i_mul, j_mul;

always@*
    case(rotation_type)
      2'd3:loc_y_mul = loc_y * 7'd64;
      2'd2:loc_y_mul = loc_y * 7'd64;
      2'd1:loc_y_mul = (loc_y-5'd20) * 7'd64;
      2'd0:loc_y_mul = (loc_y-5'd20) * 7'd64;
      default:loc_y_mul = loc_y * 7'd64;
    endcase


always@(posedge clk)
  if(~srst_n)
    i_mul <= 0;
  else
    case(rotation_type)
      2'd3:i_mul <= i_old * 7'd64;
      2'd2:i_mul <= (j_old * 7'd64);
      2'd1:i_mul <= ((5'd20-j_old) * 7'd64);
      2'd0:i_mul <= ((5'd20-i_old) * 7'd64);
      default:i_mul <= i_old * 7'd64;
    endcase

always@(posedge clk)
  if(~srst_n)
    j_mul <= 0;
  else
    case(rotation_type)
      2'd3:j_mul <= j_old;
      2'd2:j_mul <= (5'd20 - i_old);
      2'd1:j_mul <= i_old;
      2'd0:j_mul <= (5'd20-j_old);
      default:j_mul <= j_old;
    endcase

/*always@(posedge clk)
  if(~srst_n)
    i_mul <= 0;
  else
    i_mul <= i_old * 7'd64;*/


// read selected bit in SRAM
/*always@*
  case(rotation_type)
    2'd3: mask_addr = (loc_y * 7'd64) + loc_x + (i_old * 7'd64) + j_old;
    2'd2: mask_addr = (loc_y * 7'd64) + (loc_x-5'd20) + (j_old * 7'd64) + (5'd20 - i_old);
    2'd1: mask_addr = ((loc_y-5'd20) * 7'd64) + loc_x + ((5'd20-j_old) * 7'd64) + i_old;
    2'd0: mask_addr = ((loc_y-5'd20) * 7'd64) + (loc_x-5'd20) + ((5'd20-i_old) * 7'd64) + (5'd20-j_old);
    default: mask_addr = (loc_y * 7'd64) + loc_x + (i_old * 7'd64) + j_old;
  endcase*/
always@(posedge clk)
  if(~srst_n)
    mask_addr <= 0;
  else
    case(rotation_type)
      2'd3: mask_addr <= loc_y_mul + loc_x + i_mul + j_mul;
      2'd2: mask_addr <= loc_y_mul + (loc_x-5'd20) + i_mul + j_mul;
      2'd1: mask_addr <= loc_y_mul + loc_x + i_mul + j_mul;
      2'd0: mask_addr <= loc_y_mul + (loc_x-5'd20) + i_mul + j_mul;
      default: mask_addr <= loc_y_mul + loc_x + i_mul + j_mul;
    endcase

// input mask (cnt == 5: read mask complete)
always@*
  case(demask_cnt)
    8'd3:
      mask_tmp = {sram_rdata, mask[1], mask[0]};
    8'd4:
      mask_tmp = {mask[2], sram_rdata, mask[0]};
    8'd5:
      mask_tmp = {mask[2], mask[1], sram_rdata};
    default:
      mask_tmp = mask;
  endcase


always@(posedge clk)
  if(~srst_n)
    mask <= 0;
  else
    mask <= mask_tmp;

// XOR (convert mask to real mask) at cnt == 5
always@*
  real_mask = mask ^ 3'b101;

// doing demask to data bit
reg demask_result, xor_in;


always@(posedge clk)
  if(~srst_n)
    i_old <= 0;
  else
    i_old <= i;
always@(posedge clk)
  if(~srst_n)
    j_old <= 0;
  else
    j_old <= j;

always@(posedge clk)
  if(~srst_n)
    i_old2 <= 0;
  else
    i_old2 <= i_old;
always@(posedge clk)
  if(~srst_n)
    j_old2 <= 0;
  else
    j_old2 <= j_old;

/*always@(posedge clk)
  if(~srst_n)
    i_old3 <= 0;
  else
    i_old3 <= i_old2;
always@(posedge clk)
  if(~srst_n)
    j_old3 <= 0;
  else
    j_old3 <= j_old2;*/

/*always@*
  case(real_mask)
    3'd0: xor_in = (((i_old2 + j_old2)%2'd2) == 0);
    3'd1: xor_in = ((i_old2%2'd2) == 0);
    3'd2: xor_in = ((j_old2%2'd3) == 0);
    3'd3: xor_in = (((i_old2+j_old2)%2'd3) == 0);
    3'd4: xor_in = ((((i_old2/2'd2) + (j_old2/2'd3)) % 2'd2) == 0);
    3'd5: xor_in = ((((i_old2*j_old2)%2'd2) + ((i_old2*j_old2)%2'd3)) == 0);
    3'd6: xor_in = (((((i_old2*j_old2)%2'd2) + ((i_old2*j_old2)%2'd3))%2'd2) == 0);
    3'd7: xor_in = (((((i_old2*j_old2)%2'd3) + ((i_old2+j_old2)%2'd2))%2'd2) == 0);
    default: xor_in = 0;
  endcase*/

always@(posedge clk)
  if(~srst_n)
    xor_in <= 0;
  else
    case(real_mask)
      3'd0: xor_in <= (((i_old2 + j_old2)%2'd2) == 0);
      3'd1: xor_in <= ((i_old2%2'd2) == 0);
      3'd2: xor_in <= ((j_old2%2'd3) == 0);
      3'd3: xor_in <= (((i_old2+j_old2)%2'd3) == 0);
      3'd4: xor_in <= ((((i_old2/2'd2) + (j_old2/2'd3)) % 2'd2) == 0);
      3'd5: xor_in <= ((((i_old2*j_old2)%2'd2) + ((i_old2*j_old2)%2'd3)) == 0);
      3'd6: xor_in <= (((((i_old2*j_old2)%2'd2) + ((i_old2*j_old2)%2'd3))%2'd2) == 0);
      3'd7: xor_in <= (((((i_old2*j_old2)%2'd3) + ((i_old2+j_old2)%2'd2))%2'd2) == 0);
      default: xor_in <= 0;
    endcase
  
always@*
  demask_result = xor_in ^ sram_rdata;

// save result into array (sequential shift register)
integer k;
always@(posedge clk)
  if(~srst_n)
    code_word <= 0;
  else
    if((demask_cnt >= 8'd6) && (demask_cnt <= 8'd157)) begin
      for(k = 0; k < 151; k = k+1)
        code_word[k+1] <= code_word[k];
      code_word[0] <= demask_result;
    end
    else
      code_word <= code_word;

endmodule
