//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
 
`timescale 1ns/100ps
`define TEST_CASE 27

module test_enigma_part1;

reg clk;               // clock input
reg srst_n;            // synchronous reset (active low)
reg load;              // load control signal (level sensitive). 0/1: inactive/active
                         // effective in ST_IDLE and ST_LOAD states

reg encrypt_b, encrypt_p;           // encrypt control signal (level sensitive). 0/1: inactive/active
                         // effective in ST_READY state

reg crypt_mode;        // 0: encrypt; 1:decrypt;

reg [2-1:0] table_idx; // table_idx indicates which rotor to be load 
						 // 2'b00: plug board
						 // 2'b01: rotorA
						 // 2'b10: rotorB

reg [6-1:0] code_in;
reg [7:0] a, b;		// When load is active, then code_in is input of rotors. 
							// When encrypy is active, then code_in is input of code words.
							// Note: We only use rotorA in this part.					
wire [6-1:0] code_out_b, code_out_p;   // encrypted code word (register output)
reg [6-1:0] code_out; 
wire code_valid_b, code_valid_p;
reg code_valid;

integer i, count, fp_r, z;
parameter CYCLE = 10;
behavior_model enigma_b(.clk(clk), .srst_n(srst_n), .load(load), .encrypt(encrypt_b), .crypt_mode(crypt_mode), .table_idx(table_idx),
                      .code_in(code_in), .code_out(code_out_b), .code_valid(code_valid_b));
enigma_part1 enigma_p(.clk(clk), .srst_n(srst_n), .load(load), .encrypt(encrypt_p), .crypt_mode(crypt_mode), .table_idx(table_idx),
                      .code_in(code_in), .code_out(code_out_p), .code_valid(code_valid_p));

initial begin
  $fsdbDumpfile("enigma.fsdb");
  $fsdbDumpvars("+mda");
end
// clock toggle
always #(CYCLE/2) clk = ~clk;

// input feeding
initial begin
  clk = 0;
  srst_n = 1;
  crypt_mode = 1'b0;
  load = 1'b0;

  table_idx = 2'd3;
  code_in = 6'd0;
  encrypt_b = 1'b0;
  encrypt_p = 1'b0;
  #(CYCLE) 
  srst_n = 0;
  #(CYCLE)
  srst_n = 1;
  #(CYCLE)
  load = 1'b1;
  table_idx = 2'd1;
  fp_r = $fopen("./rotor/rotorA.dat", "r");
  #0.01
  for(i = 0; i < 64; i = i+1) begin
    count = $fscanf(fp_r, "%h", code_in);
    count = $fscanf(fp_r, "%s", a);
    if(code_in != 6'h1a)
      count = $fscanf(fp_r, "%s", b);
    @(negedge clk);
  end
  load = 1'b0;
  table_idx = 2'd3;
  $fclose(fp_r);
  #(CYCLE)
  `ifdef EN
    encrypt_b = 1'b1;
  `else
    encrypt_p = 1'b1;
  `endif
  fp_r = $fopen("./pat/part1_plaintext1.dat", "r");
  #0.01
  for(i = 0; i < 27; i = i+1) begin
    count = $fscanf(fp_r, "%h", code_in);
    count = $fscanf(fp_r, "%s", a);
    if(code_in != 6'h1a)
      count = $fscanf(fp_r, "%s", b);
    $display("encrypt %h", code_in);
    @(negedge clk);
  end
  `ifdef EN
    encrypt_b = 1'b0;
  `else
    encrypt_p = 1'b0;
  `endif
  $fclose(fp_r);
  #(CYCLE*100000); $finish;
end
always@* begin
  `ifdef EN begin
    code_out = code_out_b;
    code_valid = code_valid_b;
  end
  `else begin
    code_out = code_out_p;
    code_valid = code_valid_p;
  end
  `endif
end
integer j, error, fp_l;
reg [5:0] Result_Golden;
// output comparason
initial begin
  if(~crypt_mode) begin
    fp_l = $fopen("./pat/part1_ciphertext1.dat", "r");
    error = 0;
    wait(code_valid == 1)
    for(j = 0; j < `TEST_CASE; j = j+1) begin
      count = $fscanf(fp_l, "%h", Result_Golden);
      count = $fscanf(fp_l, "%s", a);
      if(Result_Golden != 6'h1a)
        count = $fscanf(fp_l, "%s", b);
      @(posedge clk)
      if(Result_Golden !== code_out) begin
        $display("***********************PATTERN %d IS WRONG!!!!**************************", j);
        $display("Your answer is %h, but the answer is %h", code_out, Result_Golden);
        $display("************************************************************************");
        error = error+1;
      end
      else begin
        $display("***********************Pattern %d is correct**************************", j);
        $display("Your answer is %h, and the answer is %h", code_out, Result_Golden);
        $display("********************************************************************");
      end
    end
    $display("total error = %d", error);  
    if(error == 0) begin
      $display("********************************************************************");
      $display("Congratulations! You can move to the next part!");
      $display("********************************************************************");
    end
    $fclose(fp_l);
  end
  else begin
    fp_l = $fopen("./pat/part1_plaintext1.dat", "r");
    error = 0;
    wait(code_valid == 1)
    for(j = 0; j < `TEST_CASE; j = j+1) begin
      count = $fscanf(fp_l, "%h", Result_Golden);
      count = $fscanf(fp_l, "%s", a);
      if(Result_Golden != 6'h1a)
        count = $fscanf(fp_l, "%s", b);
      @(posedge clk)
      if(Result_Golden !== code_out) begin
        $display("***********************PATTERN %d IS WRONG!!!!**************************", j);
        $display("Your answer is %h, but the answer is %h", code_out, Result_Golden);
        $display("************************************************************************");
        error = error+1;
      end
      else begin
        $display("***********************Pattern %d is correct**************************", j);
        $display("Your answer is %h, and the answer is %h", code_out, Result_Golden);
        $display("********************************************************************");
      end
    end
    $display("total error = %d", error);  
    if(error == 0) begin
      $display("********************************************************************");
      $display("Congratulations! You can move to the next part!");
      $display("********************************************************************");
    end
    $fclose(fp_l);
  end
end



endmodule
