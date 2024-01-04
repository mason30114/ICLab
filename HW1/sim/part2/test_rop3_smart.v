`define N 8

module test_rop3_smart;

// clock period
parameter CYCLE = 10;

// I/O def
reg clk, srst_n;
reg [7:0] Mode;
reg [`N-1:0] Bitmap_lut, Bitmap_smart;
wire [`N-1:0] Result_lut, Result_smart;
wire valid;


rop3_smart #(.N(`N)) smart (.clk(clk), .srst_n(srst_n), .Bitmap(Bitmap_smart), .Result(Result_smart), .valid(valid), .Mode(Mode));
rop3_lut16 #(.N(`N)) lut16 (.clk(clk), .srst_n(srst_n), .Bitmap(Bitmap_lut), .Result(Result_lut), .valid(valid), .Mode(Mode));

always #(CYCLE/2) clk = ~clk; // clock toggles

initial                       // initial state of clk, rst
begin                          
  clk = 0;
  srst_n = 1;
  #(CYCLE); srst_n = 0;
  #1;
  #(CYCLE); srst_n = 1;
  #1
  #(CYCLE*100000000); $finish;
end


// input feeding 
integer i, j, k, l;  
reg [`N-1:0] P_in, S_in, D_in;  //scanned pattern
reg [`N-1:0] old_P, old_S, old_D;  //pattern for comparision 
reg [7:0] old_Mode;

initial                       
begin
  P_in = 0;
  S_in = 0;
  D_in = 0;
  Mode = 0;
  wait(srst_n == 0);
  wait(srst_n == 1);
  
  for(i = 1; i <= 15; i = i+1)
  begin
    for(j = 0; j < 2**(`N); j = j+1)
    begin
      for(k = 0; k < 2**(`N); k = k+1)
      begin
        for(l = 0; l < 2**(`N); l = l+1)
        begin
          {old_Mode, old_P, old_S, old_D} = {Mode, P_in, S_in, D_in};
          case(i)
            1: Mode = 8'h00;
            2: Mode = 8'h11;
            3: Mode = 8'h33;
            4: Mode = 8'h44;
            5: Mode = 8'h55;
            6: Mode = 8'h5a;
            7: Mode = 8'h66;
            8: Mode = 8'h88;
            9: Mode = 8'hbb;
            10: Mode = 8'hc0;
            11: Mode = 8'hcc;
            12: Mode = 8'hee;
            13: Mode = 8'hf0;
            14: Mode = 8'hfb;
            15: Mode = 8'hff;
            default: Mode = 8'h00; 
          endcase
          {P_in, S_in, D_in} = {j[`N-1:0], k[`N-1:0], l[`N-1:0]};
          @(negedge clk);
	  Bitmap_lut = P_in;
	  Bitmap_smart = P_in;
	  @(negedge clk);
	  Bitmap_lut = S_in;
	  Bitmap_smart = S_in;
	  @(negedge clk);
	  Bitmap_lut = D_in;
	  Bitmap_smart = D_in;
        end
      end
    end
  end
end

//output comparasion
integer file_out, o_read_valid, w, error;
initial
begin
  w = 0;
  error = 0;
  wait(srst_n == 0);
  wait(srst_n == 1);
  file_out = $fopen("sim_out_part2.csv", "w");
  $fwrite(file_out, "Mode, P, S, D, lut, smart\n");
  // comparasion start
  while(w < ((8**`N) * 15)-1)
  begin
    wait(valid == 1);
    #1;
    $display("simulate function mode %h ...", old_Mode);
    if(Result_lut !== Result_smart)
    begin
      //$display("=======================================================");
      //$display("PATTERN %d IS WRONG!!!!!!!", w+1);
      //display("Mode = %h P = %h S = %h, D = %h lut = %h smart = %h", old_Mode, old_P, old_S, old_D, Result_lut, Result_smart);
      //$display("=======================================================");
      error = error + 1; 
    end
    else
    begin
      //$display("=======================================================");
      //$display("Pattern %d is correct!", w+1);
      $fwrite(file_out, "%h,%h,%h,%h,%h,%h\n" , old_Mode, old_P, old_S, old_D, Result_lut, Result_smart);
      //$display("Mode = %h P = %h S = %h, D = %h lut = %h smart = %h", old_Mode, old_P, old_S, old_D, Result_lut, Result_smart);
      //$display("=======================================================");
    end
    w = w + 1;
    #(CYCLE);
  end
  wait(valid == 1);
  #1;
  $display("simulate function mode %h ...", Mode);
  if(Result_lut !== Result_smart)
  begin
    //$display("=======================================================");
    //$display("PATTERN %d IS WRONG!!!!!!!", w+1);
    //display("Mode = %h P = %h S = %h, D = %h lut = %h smart = %h", old_Mode, old_P, old_S, old_D, Result_lut, Result_smart);
    //$display("=======================================================");
    error = error + 1; 
  end
  else
  begin
    //$display("=======================================================");
    //$display("Pattern %d is correct!", w+1);
    $fwrite(file_out, "%h,%h,%h,%h,%h,%h\n" , Mode, P_in, S_in, D_in, Result_lut, Result_smart);
    //$display("Mode = %h P = %h S = %h, D = %h lut = %h smart = %h", old_Mode, old_P, old_S, old_D, Result_lut, Result_smart);
    //$display("=======================================================");
  end
  w = w + 1;
  #(CYCLE);
  if(error == 0)
  begin
    $display("\n============= Congratulations =============");
    $display("    You can move on to the next part !");
    $display("============= Congratulations =============\n");
  end
  $fclose(file_out);
  $finish;
end
endmodule
  
      
    
 
