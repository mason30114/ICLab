module NUM_CALCULATE(
    input clk,
    input srst_n,             
    input [3:0] state,                         
    input sram_rdata,       
    output reg [11:0] num_raddr,
    output reg num_complete,
    output reg [2:0] qr_total
         
);

reg [5:0] i, j;
reg [4:0] num, num_tmp;//, num_delay;
reg [2:0] location, location_tmp;//, location_delay;

parameter IDLE = 4'd0, PRE_SCAN = 4'd1, NUM = 4'd2, SCAN = 4'd3, ROTATE = 4'd4, LOC = 4'd5, DEMASK = 4'd6, DECODE = 4'd7, FINISH = 4'd8;
reg opt_valid;
/*always@(posedge clk)
  if(~srst_n)
    opt_valid <= 0;
  else
    if((state == NUM) && (num == 5'd0))
      opt_valid <= 1;
    else
      opt_valid <= opt_valid;*/
always@*
  if((state == NUM) && (num != 5'd0))
    opt_valid = 1;
  else
    opt_valid = 0;
//always@*
  //num_raddr = (i * 7'd64) + j;
/*always@(posedge clk)
  if(~srst_n)
    num_delay <= 0;
  else
    num_delay <= num;

always@(posedge clk)
  if(~srst_n)
    location_delay <= 0;
  else
    location_delay <= location;*/


always@(posedge clk)
  if(~srst_n)
    num_raddr <= 0;
  else
    num_raddr <= (i * 7'd64) + j;

always@*
  if((state == NUM) && (num != 5'd25) && ((~sram_rdata && opt_valid) || ~opt_valid))
    num_tmp = num + 1'b1;
  else if ((state == NUM) && ((sram_rdata) || (num == 5'd25)) && opt_valid)
    num_tmp = 0;
  else
    num_tmp = num;

always@(posedge clk)
  if(~srst_n)
    num <= 0;
  else
    num <= num_tmp;

always@*
  if((state == NUM) && ((sram_rdata) || (num == 5'd25)) && opt_valid)
    location_tmp = location + 1'b1;
  else
    location_tmp = location;

always@(posedge clk)
  if(~srst_n)
    location <= 0;
  else   
    location <= location_tmp;

always@(posedge clk)
  if(~srst_n)
    qr_total <= 0;
  else
    if((state == NUM) && sram_rdata && opt_valid && ~num_complete)
      qr_total <= qr_total + 1'b1;
    else
      qr_total <= qr_total;

always@*
  if(location == 3'd4)
    num_complete = 1;
  else
    num_complete = 0;


always@*
  case(location)
    3'd0:
      case(num)
        /*6'd0: begin
          i = 6'd14;
          j = 6'd14;
        end  
        6'd1: begin
          i = 6'd14;
          j = 6'd15;
        end 
        6'd2: begin
          i = 6'd14;
          j = 6'd16;
        end 
        6'd3: begin
          i = 6'd14;
          j = 6'd17;
        end 
        6'd4: begin
          i = 6'd14;
          j = 6'd18;
        end 
        6'd5: begin
          i = 6'd14;
          j = 6'd19;
        end 
        6'd6: begin
          i = 6'd14;
          j = 6'd20;
        end 
        6'd7: begin
          i = 6'd14;
          j = 6'd21;
        end 
        6'd8: begin
          i = 6'd14;
          j = 6'd22;
        end 
        6'd9: begin
          i = 6'd14;
          j = 6'd23;
        end 
        6'd10: begin
          i = 6'd14;
          j = 6'd24;
        end 
        6'd11: begin
          i = 6'd14;
          j = 6'd25;
        end 
        6'd12: begin
          i = 6'd14;
          j = 6'd26;
        end 
        6'd13: begin
          i = 6'd14;
          j = 6'd27;
        end 
        6'd14: begin
          i = 6'd14;
          j = 6'd28;
        end
        6'd15: begin
          i = 6'd15;
          j = 6'd28;
        end
        6'd16: begin
          i = 6'd16;
          j = 6'd28;
        end
        6'd17: begin
          i = 6'd17;
          j = 6'd28;
        end
        6'd18: begin
          i = 6'd18;
          j = 6'd28;
        end
        6'd19: begin
          i = 6'd19;
          j = 6'd28;
        end
        6'd20: begin
          i = 6'd20;
          j = 6'd28;
        end
        6'd21: begin
          i = 6'd21;
          j = 6'd28;
        end
        6'd22: begin
          i = 6'd22;
          j = 6'd28;
        end
        6'd23: begin
          i = 6'd23;
          j = 6'd28;
        end
        6'd24: begin
          i = 6'd24;
          j = 6'd28;
        end
        6'd25: begin
          i = 6'd25;
          j = 6'd28;
        end
        6'd26: begin
          i = 6'd26;
          j = 6'd28;
        end
        6'd27: begin
          i = 6'd27;
          j = 6'd28;
        end
        6'd28: begin
          i = 6'd28;
          j = 6'd28;
        end
        6'd29: begin
          i = 6'd28;
          j = 6'd27;
        end
        6'd30: begin
          i = 6'd28;
          j = 6'd26;
        end
        6'd31: begin
          i = 6'd28;
          j = 6'd25;
        end
        6'd32: begin
          i = 6'd28;
          j = 6'd24;
        end
        6'd33: begin
          i = 6'd28;
          j = 6'd23;
        end
        6'd34: begin
          i = 6'd28;
          j = 6'd22;
        end
        6'd35: begin
          i = 6'd28;
          j = 6'd21;
        end
        6'd36: begin
          i = 6'd28;
          j = 6'd20;
        end
        6'd37: begin
          i = 6'd28;
          j = 6'd19;
        end
        6'd38: begin
          i = 6'd28;
          j = 6'd18;
        end
        6'd39: begin
          i = 6'd28;
          j = 6'd17;
        end
        6'd40: begin
          i = 6'd28;
          j = 6'd16;
        end
        6'd41: begin
          i = 6'd28;
          j = 6'd15;
        end
        6'd42: begin
          i = 6'd28;
          j = 6'd14;
        end
        6'd43: begin
          i = 6'd27;
          j = 6'd14;
        end
        6'd44: begin
          i = 6'd26;
          j = 6'd14;
        end
        6'd45: begin
          i = 6'd25;
          j = 6'd14;
        end
        6'd46: begin
          i = 6'd24;
          j = 6'd14;
        end
        6'd47: begin
          i = 6'd23;
          j = 6'd14;
        end
        6'd48: begin
          i = 6'd22;
          j = 6'd14;
        end
        6'd49: begin
          i = 6'd21;
          j = 6'd14;
        end
        6'd50: begin
          i = 6'd20;
          j = 6'd14;
        end
        6'd51: begin
          i = 6'd19;
          j = 6'd14;
        end
        6'd52: begin
          i = 6'd18;
          j = 6'd14;
        end
        6'd53: begin
          i = 6'd17;
          j = 6'd14;
        end
        6'd54: begin
          i = 6'd16;
          j = 6'd14;
        end
        6'd55: begin
          i = 6'd15;
          j = 6'd14;
        end*/
        5'd0: begin
          i = 6'd19;
          j = 6'd19;
        end
        5'd1: begin
          i = 6'd19;
          j = 6'd20;
        end
        5'd2: begin
          i = 6'd19;
          j = 6'd21;
        end
        5'd3: begin
          i = 6'd19;
          j = 6'd22;
        end
        5'd4: begin
          i = 6'd19;
          j = 6'd23;
        end
        5'd5: begin
          i = 6'd20;
          j = 6'd23;
        end
        5'd6: begin
          i = 6'd21;
          j = 6'd23;
        end
        5'd7: begin
          i = 6'd22;
          j = 6'd23;
        end
        5'd8: begin
          i = 6'd23;
          j = 6'd23;
        end
        5'd9: begin
          i = 6'd23;
          j = 6'd22;
        end
        5'd10: begin
          i = 6'd23;
          j = 6'd21;
        end
        5'd11: begin
          i = 6'd23;
          j = 6'd20;
        end
        5'd12: begin
          i = 6'd23;
          j = 6'd19;
        end
        5'd13: begin
          i = 6'd22;
          j = 6'd19;
        end
        5'd14: begin
          i = 6'd21;
          j = 6'd19;
        end
        5'd15: begin
          i = 6'd20;
          j = 6'd19;
        end
        5'd16: begin
          i = 6'd20;
          j = 6'd20;
        end
        5'd17: begin
          i = 6'd20;
          j = 6'd21;
        end
        5'd18: begin
          i = 6'd20;
          j = 6'd22;
        end
        5'd19: begin
          i = 6'd21;
          j = 6'd20;
        end
        5'd20: begin
          i = 6'd21;
          j = 6'd21;
        end
        5'd21: begin
          i = 6'd21;
          j = 6'd22;
        end
        5'd22: begin
          i = 6'd22;
          j = 6'd20;
        end
        5'd23: begin
          i = 6'd22;
          j = 6'd21;
        end
        5'd24: begin
          i = 6'd22;
          j = 6'd22;
        end
        default: begin
          i = 0;
          j = 0;
        end
      endcase
    3'd1:
      case(num)
        /*6'd0: begin
          i = 6'd14;
          j = 6'd35;
        end  
        6'd1: begin
          i = 6'd14;
          j = 6'd36;
        end 
        6'd2: begin
          i = 6'd14;
          j = 6'd37;
        end 
        6'd3: begin
          i = 6'd14;
          j = 6'd38;
        end 
        6'd4: begin
          i = 6'd14;
          j = 6'd39;
        end 
        6'd5: begin
          i = 6'd14;
          j = 6'd40;
        end 
        6'd6: begin
          i = 6'd14;
          j = 6'd41;
        end 
        6'd7: begin
          i = 6'd14;
          j = 6'd42;
        end 
        6'd8: begin
          i = 6'd14;
          j = 6'd43;
        end 
        6'd9: begin
          i = 6'd14;
          j = 6'd44;
        end 
        6'd10: begin
          i = 6'd14;
          j = 6'd45;
        end 
        6'd11: begin
          i = 6'd14;
          j = 6'd46;
        end 
        6'd12: begin
          i = 6'd14;
          j = 6'd47;
        end 
        6'd13: begin
          i = 6'd14;
          j = 6'd48;
        end 
        6'd14: begin
          i = 6'd14;
          j = 6'd49;
        end
        6'd15: begin
          i = 6'd15;
          j = 6'd49;
        end
        6'd16: begin
          i = 6'd16;
          j = 6'd49;
        end
        6'd17: begin
          i = 6'd17;
          j = 6'd49;
        end
        6'd18: begin
          i = 6'd18;
          j = 6'd49;
        end
        6'd19: begin
          i = 6'd19;
          j = 6'd49;
        end
        6'd20: begin
          i = 6'd20;
          j = 6'd49;
        end
        6'd21: begin
          i = 6'd21;
          j = 6'd49;
        end
        6'd22: begin
          i = 6'd22;
          j = 6'd49;
        end
        6'd23: begin
          i = 6'd23;
          j = 6'd49;
        end
        6'd24: begin
          i = 6'd24;
          j = 6'd49;
        end
        6'd25: begin
          i = 6'd25;
          j = 6'd49;
        end
        6'd26: begin
          i = 6'd26;
          j = 6'd49;
        end
        6'd27: begin
          i = 6'd27;
          j = 6'd49;
        end
        6'd28: begin
          i = 6'd28;
          j = 6'd49;
        end
        6'd29: begin
          i = 6'd28;
          j = 6'd48;
        end
        6'd30: begin
          i = 6'd28;
          j = 6'd47;
        end
        6'd31: begin
          i = 6'd28;
          j = 6'd46;
        end
        6'd32: begin
          i = 6'd28;
          j = 6'd45;
        end
        6'd33: begin
          i = 6'd28;
          j = 6'd44;
        end
        6'd34: begin
          i = 6'd28;
          j = 6'd43;
        end
        6'd35: begin
          i = 6'd28;
          j = 6'd42;
        end
        6'd36: begin
          i = 6'd28;
          j = 6'd41;
        end
        6'd37: begin
          i = 6'd28;
          j = 6'd40;
        end
        6'd38: begin
          i = 6'd28;
          j = 6'd39;
        end
        6'd39: begin
          i = 6'd28;
          j = 6'd38;
        end
        6'd40: begin
          i = 6'd28;
          j = 6'd37;
        end
        6'd41: begin
          i = 6'd28;
          j = 6'd36;
        end
        6'd42: begin
          i = 6'd28;
          j = 6'd35;
        end
        6'd43: begin
          i = 6'd27;
          j = 6'd35;
        end
        6'd44: begin
          i = 6'd26;
          j = 6'd35;
        end
        6'd45: begin
          i = 6'd25;
          j = 6'd35;
        end
        6'd46: begin
          i = 6'd24;
          j = 6'd35;
        end
        6'd47: begin
          i = 6'd23;
          j = 6'd14;
        end
        6'd48: begin
          i = 6'd22;
          j = 6'd14;
        end
        6'd49: begin
          i = 6'd21;
          j = 6'd14;
        end
        6'd50: begin
          i = 6'd20;
          j = 6'd14;
        end
        6'd51: begin
          i = 6'd19;
          j = 6'd14;
        end
        6'd52: begin
          i = 6'd18;
          j = 6'd14;
        end
        6'd53: begin
          i = 6'd17;
          j = 6'd14;
        end
        6'd53: begin
          i = 6'd16;
          j = 6'd14;
        end
        6'd55: begin
          i = 6'd15;
          j = 6'd14;
        end*/
        5'd0: begin
          i = 6'd19;
          j = 6'd40;
        end
        5'd1: begin
          i = 6'd19;
          j = 6'd41;
        end
        5'd2: begin
          i = 6'd19;
          j = 6'd42;
        end
        5'd3: begin
          i = 6'd19;
          j = 6'd43;
        end
        5'd4: begin
          i = 6'd19;
          j = 6'd44;
        end
        5'd5: begin
          i = 6'd20;
          j = 6'd44;
        end
        5'd6: begin
          i = 6'd21;
          j = 6'd44;
        end
        5'd7: begin
          i = 6'd22;
          j = 6'd44;
        end
        5'd8: begin
          i = 6'd23;
          j = 6'd44;
        end
        5'd9: begin
          i = 6'd23;
          j = 6'd43;
        end
        5'd10: begin
          i = 6'd23;
          j = 6'd42;
        end
        5'd11: begin
          i = 6'd23;
          j = 6'd41;
        end
        5'd12: begin
          i = 6'd23;
          j = 6'd40;
        end
        5'd13: begin
          i = 6'd22;
          j = 6'd40;
        end
        5'd14: begin
          i = 6'd21;
          j = 6'd40;
        end
        5'd15: begin
          i = 6'd20;
          j = 6'd40;
        end
        5'd16: begin
          i = 6'd20;
          j = 6'd41;
        end
        5'd17: begin
          i = 6'd20;
          j = 6'd42;
        end
        5'd18: begin
          i = 6'd20;
          j = 6'd43;
        end
        5'd19: begin
          i = 6'd21;
          j = 6'd41;
        end
        5'd20: begin
          i = 6'd21;
          j = 6'd42;
        end
        5'd21: begin
          i = 6'd21;
          j = 6'd43;
        end
        5'd22: begin
          i = 6'd22;
          j = 6'd41;
        end
        5'd23: begin
          i = 6'd22;
          j = 6'd42;
        end
        5'd24: begin
          i = 6'd22;
          j = 6'd43;
        end
        default: begin
          i = 0;
          j = 0;
        end
      endcase
    3'd2:
      case(num)
        /*6'd0: begin
          i = 6'd35;
          j = 6'd35;
        end  
        6'd1: begin
          i = 6'd35;
          j = 6'd36;
        end 
        6'd2: begin
          i = 6'd35;
          j = 6'd37;
        end 
        6'd3: begin
          i = 6'd35;
          j = 6'd38;
        end 
        6'd4: begin
          i = 6'd35;
          j = 6'd39;
        end 
        6'd5: begin
          i = 6'd35;
          j = 6'd40;
        end 
        6'd6: begin
          i = 6'd35;
          j = 6'd41;
        end 
        6'd7: begin
          i = 6'd35;
          j = 6'd42;
        end 
        6'd8: begin
          i = 6'd35;
          j = 6'd43;
        end 
        6'd9: begin
          i = 6'd35;
          j = 6'd44;
        end 
        6'd10: begin
          i = 6'd35;
          j = 6'd45;
        end 
        6'd11: begin
          i = 6'd35;
          j = 6'd46;
        end 
        6'd12: begin
          i = 6'd35;
          j = 6'd47;
        end 
        6'd13: begin
          i = 6'd35;
          j = 6'd48;
        end 
        6'd14: begin
          i = 6'd35;
          j = 6'd49;
        end
        6'd15: begin
          i = 6'd36;
          j = 6'd49;
        end
        6'd16: begin
          i = 6'd37;
          j = 6'd49;
        end
        6'd17: begin
          i = 6'd38;
          j = 6'd49;
        end
        6'd18: begin
          i = 6'd39;
          j = 6'd49;
        end
        6'd19: begin
          i = 6'd40;
          j = 6'd49;
        end
        6'd20: begin
          i = 6'd41;
          j = 6'd49;
        end
        6'd21: begin
          i = 6'd42;
          j = 6'd49;
        end
        6'd22: begin
          i = 6'd43;
          j = 6'd49;
        end
        6'd23: begin
          i = 6'd44;
          j = 6'd49;
        end
        6'd24: begin
          i = 6'd45;
          j = 6'd49;
        end
        6'd25: begin
          i = 6'd46;
          j = 6'd49;
        end
        6'd26: begin
          i = 6'd47;
          j = 6'd49;
        end
        6'd27: begin
          i = 6'd48;
          j = 6'd49;
        end
        6'd28: begin
          i = 6'd49;
          j = 6'd49;
        end
        6'd29: begin
          i = 6'd49;
          j = 6'd48;
        end
        6'd30: begin
          i = 6'd49;
          j = 6'd47;
        end
        6'd31: begin
          i = 6'd49;
          j = 6'd46;
        end
        6'd32: begin
          i = 6'd49;
          j = 6'd45;
        end
        6'd33: begin
          i = 6'd49;
          j = 6'd44;
        end
        6'd34: begin
          i = 6'd49;
          j = 6'd43;
        end
        6'd35: begin
          i = 6'd49;
          j = 6'd42;
        end
        6'd36: begin
          i = 6'd49;
          j = 6'd41;
        end
        6'd37: begin
          i = 6'd49;
          j = 6'd40;
        end
        6'd38: begin
          i = 6'd49;
          j = 6'd39;
        end
        6'd39: begin
          i = 6'd49;
          j = 6'd38;
        end
        6'd40: begin
          i = 6'd49;
          j = 6'd37;
        end
        6'd41: begin
          i = 6'd49;
          j = 6'd36;
        end
        6'd42: begin
          i = 6'd49;
          j = 6'd35;
        end
        6'd43: begin
          i = 6'd48;
          j = 6'd35;
        end
        6'd44: begin
          i = 6'd47;
          j = 6'd35;
        end
        6'd45: begin
          i = 6'd46;
          j = 6'd35;
        end
        6'd46: begin
          i = 6'd45;
          j = 6'd35;
        end
        6'd47: begin
          i = 6'd44;
          j = 6'd14;
        end
        6'd48: begin
          i = 6'd43;
          j = 6'd14;
        end
        6'd49: begin
          i = 6'd42;
          j = 6'd14;
        end
        6'd50: begin
          i = 6'd41;
          j = 6'd14;
        end
        6'd51: begin
          i = 6'd40;
          j = 6'd14;
        end
        6'd52: begin
          i = 6'd39;
          j = 6'd14;
        end
        6'd53: begin
          i = 6'd38;
          j = 6'd14;
        end
        6'd53: begin
          i = 6'd37;
          j = 6'd14;
        end
        6'd55: begin
          i = 6'd36;
          j = 6'd14;
        end*/
        5'd0: begin
          i = 6'd40;
          j = 6'd40;
        end
        5'd1: begin
          i = 6'd40;
          j = 6'd41;
        end
        5'd2: begin
          i = 6'd40;
          j = 6'd42;
        end
        5'd3: begin
          i = 6'd40;
          j = 6'd43;
        end
        5'd4: begin
          i = 6'd40;
          j = 6'd44;
        end
        5'd5: begin
          i = 6'd41;
          j = 6'd44;
        end
        5'd6: begin
          i = 6'd42;
          j = 6'd44;
        end
        5'd7: begin
          i = 6'd43;
          j = 6'd44;
        end
        5'd8: begin
          i = 6'd44;
          j = 6'd44;
        end
        5'd9: begin
          i = 6'd44;
          j = 6'd43;
        end
        5'd10: begin
          i = 6'd44;
          j = 6'd42;
        end
        5'd11: begin
          i = 6'd44;
          j = 6'd41;
        end
        5'd12: begin
          i = 6'd44;
          j = 6'd40;
        end
        5'd13: begin
          i = 6'd43;
          j = 6'd40;
        end
        5'd14: begin
          i = 6'd42;
          j = 6'd40;
        end
        5'd15: begin
          i = 6'd41;
          j = 6'd40;
        end
        5'd16: begin
          i = 6'd41;
          j = 6'd41;
        end
        5'd17: begin
          i = 6'd41;
          j = 6'd42;
        end
        5'd18: begin
          i = 6'd41;
          j = 6'd43;
        end
        5'd19: begin
          i = 6'd42;
          j = 6'd41;
        end
        5'd20: begin
          i = 6'd42;
          j = 6'd42;
        end
        5'd21: begin
          i = 6'd42;
          j = 6'd43;
        end
        5'd22: begin
          i = 6'd43;
          j = 6'd41;
        end
        5'd23: begin
          i = 6'd43;
          j = 6'd42;
        end
        5'd24: begin
          i = 6'd43;
          j = 6'd43;
        end
        default: begin
          i = 0;
          j = 0;
        end
      endcase
    3'd3:
      case(num)
        /*6'd0: begin
          i = 6'd35;
          j = 6'd14;
        end  
        6'd1: begin
          i = 6'd35;
          j = 6'd15;
        end 
        6'd2: begin
          i = 6'd35;
          j = 6'd16;
        end 
        6'd3: begin
          i = 6'd35;
          j = 6'd17;
        end 
        6'd4: begin
          i = 6'd35;
          j = 6'd18;
        end 
        6'd5: begin
          i = 6'd35;
          j = 6'd19;
        end 
        6'd6: begin
          i = 6'd35;
          j = 6'd20;
        end 
        6'd7: begin
          i = 6'd35;
          j = 6'd21;
        end 
        6'd8: begin
          i = 6'd35;
          j = 6'd22;
        end 
        6'd9: begin
          i = 6'd35;
          j = 6'd23;
        end 
        6'd10: begin
          i = 6'd35;
          j = 6'd24;
        end 
        6'd11: begin
          i = 6'd35;
          j = 6'd25;
        end 
        6'd12: begin
          i = 6'd35;
          j = 6'd26;
        end 
        6'd13: begin
          i = 6'd35;
          j = 6'd27;
        end 
        6'd14: begin
          i = 6'd35;
          j = 6'd28;
        end
        6'd15: begin
          i = 6'd36;
          j = 6'd28;
        end
        6'd16: begin
          i = 6'd47;
          j = 6'd28;
        end
        6'd17: begin
          i = 6'd38;
          j = 6'd28;
        end
        6'd18: begin
          i = 6'd39;
          j = 6'd28;
        end
        6'd19: begin
          i = 6'd40;
          j = 6'd28;
        end
        6'd20: begin
          i = 6'd41;
          j = 6'd28;
        end
        6'd21: begin
          i = 6'd42;
          j = 6'd28;
        end
        6'd22: begin
          i = 6'd43;
          j = 6'd28;
        end
        6'd23: begin
          i = 6'd44;
          j = 6'd28;
        end
        6'd24: begin
          i = 6'd45;
          j = 6'd28;
        end
        6'd25: begin
          i = 6'd46;
          j = 6'd28;
        end
        6'd26: begin
          i = 6'd47;
          j = 6'd28;
        end
        6'd27: begin
          i = 6'd48;
          j = 6'd28;
        end
        6'd28: begin
          i = 6'd49;
          j = 6'd28;
        end
        6'd29: begin
          i = 6'd49;
          j = 6'd27;
        end
        6'd30: begin
          i = 6'd49;
          j = 6'd26;
        end
        6'd31: begin
          i = 6'd49;
          j = 6'd25;
        end
        6'd32: begin
          i = 6'd49;
          j = 6'd24;
        end
        6'd33: begin
          i = 6'd49;
          j = 6'd23;
        end
        6'd34: begin
          i = 6'd49;
          j = 6'd22;
        end
        6'd35: begin
          i = 6'd49;
          j = 6'd21;
        end
        6'd36: begin
          i = 6'd49;
          j = 6'd20;
        end
        6'd37: begin
          i = 6'd49;
          j = 6'd19;
        end
        6'd38: begin
          i = 6'd49;
          j = 6'd18;
        end
        6'd39: begin
          i = 6'd49;
          j = 6'd17;
        end
        6'd40: begin
          i = 6'd49;
          j = 6'd16;
        end
        6'd41: begin
          i = 6'd49;
          j = 6'd15;
        end
        6'd42: begin
          i = 6'd49;
          j = 6'd14;
        end
        6'd43: begin
          i = 6'd48;
          j = 6'd14;
        end
        6'd44: begin
          i = 6'd47;
          j = 6'd14;
        end
        6'd45: begin
          i = 6'd46;
          j = 6'd14;
        end
        6'd46: begin
          i = 6'd45;
          j = 6'd14;
        end
        6'd47: begin
          i = 6'd44;
          j = 6'd14;
        end
        6'd48: begin
          i = 6'd43;
          j = 6'd14;
        end
        6'd49: begin
          i = 6'd42;
          j = 6'd14;
        end
        6'd50: begin
          i = 6'd41;
          j = 6'd14;
        end
        6'd51: begin
          i = 6'd40;
          j = 6'd14;
        end
        6'd52: begin
          i = 6'd19;
          j = 6'd14;
        end
        6'd53: begin
          i = 6'd38;
          j = 6'd14;
        end
        6'd54: begin
          i = 6'd37;
          j = 6'd14;
        end
        6'd55: begin
          i = 6'd36;
          j = 6'd14;
        end*/
        5'd0: begin
          i = 6'd40;
          j = 6'd19;
        end
        5'd1: begin
          i = 6'd40;
          j = 6'd20;
        end
        5'd2: begin
          i = 6'd40;
          j = 6'd21;
        end
        5'd3: begin
          i = 6'd40;
          j = 6'd22;
        end
        5'd4: begin
          i = 6'd40;
          j = 6'd23;
        end
        5'd5: begin
          i = 6'd41;
          j = 6'd23;
        end
        5'd6: begin
          i = 6'd42;
          j = 6'd23;
        end
        5'd7: begin
          i = 6'd43;
          j = 6'd23;
        end
        5'd8: begin
          i = 6'd44;
          j = 6'd23;
        end
        5'd9: begin
          i = 6'd44;
          j = 6'd22;
        end
        5'd10: begin
          i = 6'd44;
          j = 6'd21;
        end
        5'd11: begin
          i = 6'd44;
          j = 6'd20;
        end
        5'd12: begin
          i = 6'd44;
          j = 6'd19;
        end
        5'd13: begin
          i = 6'd43;
          j = 6'd19;
        end
        5'd14: begin
          i = 6'd42;
          j = 6'd19;
        end
        5'd15: begin
          i = 6'd41;
          j = 6'd19;
        end
        5'd16: begin
          i = 6'd41;
          j = 6'd20;
        end
        5'd17: begin
          i = 6'd41;
          j = 6'd21;
        end
        5'd18: begin
          i = 6'd41;
          j = 6'd22;
        end
        5'd19: begin
          i = 6'd42;
          j = 6'd20;
        end
        5'd20: begin
          i = 6'd42;
          j = 6'd21;
        end
        5'd21: begin
          i = 6'd42;
          j = 6'd22;
        end
        5'd22: begin
          i = 6'd43;
          j = 6'd20;
        end
        5'd23: begin
          i = 6'd43;
          j = 6'd21;
        end
        5'd24: begin
          i = 6'd43;
          j = 6'd22;
        end
        default: begin
          i = 0;
          j = 0;
        end 
      endcase
    default: begin
      i = 0;
      j = 0;
    end
  endcase


endmodule

 
