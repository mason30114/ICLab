//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
 
`timescale 1ns/100ps

module test_enigma_part2;
reg clk;               // clock input
reg srst_n;            // synchronous reset (active low)
reg load;              // load control signal (level sensitive). 0/1: inactive/active
                         // effective in ST_IDLE and ST_LOAD states

reg encrypt;           // encrypt control signal (level sensitive). 0/1: inactive/active
                         // effective in ST_READY state

reg crypt_mode;        // 0: encrypt; 1:decrypt;

reg [2-1:0] table_idx; // table_idx indicates which rotor to be load 
						 // 2'b00: plug board
						 // 2'b01: rotorA
						 // 2'b10: rotorB

reg [6-1:0] code_in;		// When load is active, then code_in is input of rotors. 
							// When encrypy is active, then code_in is input of code words.
							// Note: We only use rotorA in this part.					
wire [6-1:0] code_out, code_out_b;   // encrypted code word (register output)
wire code_valid, code_valid_b;
reg [7:0] a, b;	

integer i, count, fp_r;
parameter CYCLE = 10;
reg [50*8-1:0] PATH_CIPHER, PATH_PLAIN;

`ifdef PAT1 
  localparam test_case = 27;
`elsif PAT2
  localparam test_case = 112;
`endif
initial begin
  if(test_case == 27) begin
    PATH_CIPHER = "./pat/part2_ciphertext1.dat";
    PATH_PLAIN = "./pat/part2_plaintext1.dat";
  end
  else if (test_case == 112) begin
    PATH_CIPHER = "./pat/part2_ciphertext2.dat";
    PATH_PLAIN = "./pat/part2_plaintext2.dat";
  end
end

enigma_part2 enigma(.clk(clk), .srst_n(srst_n), .load(load), .encrypt(encrypt), .table_idx(table_idx), .crypt_mode(crypt_mode),
                      .code_in(code_in), .code_out(code_out), .code_valid(code_valid));

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
  `ifdef EN
  crypt_mode = 1'b0;     // encrypt
  `elsif DE
  crypt_mode = 1'b1;       // decrypt
  `endif

  load = 1'b0;
  table_idx = 2'd3;
  code_in = 6'd0;
  encrypt = 1'b0;

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
    if(code_in != 6'h1a && code_in != 6'h1f)
      count = $fscanf(fp_r, "%s", b);
    $display("rotarA %h", code_in);
    @(negedge clk);
  end
  $fclose(fp_r);
  table_idx = 2'd2;
  fp_r = $fopen("./rotor/rotorB.dat", "r");
  #0.01
  for(i = 0; i < 64; i = i+1) begin
    count = $fscanf(fp_r, "%h", code_in);
    count = $fscanf(fp_r, "%s", a);
    if(code_in != 6'h1a && code_in != 6'h1f)
      count = $fscanf(fp_r, "%s", b);
    $display("rotarB %h", code_in);
    @(negedge clk);
  end
  $fclose(fp_r);
  load = 1'b0;
  table_idx = 2'd3;
  #(CYCLE)
  encrypt = 1'b1;
  if(~crypt_mode)
    fp_r = $fopen(PATH_PLAIN, "r");
  else
    fp_r = $fopen(PATH_CIPHER, "r");
  #0.01
  for(i = 0; i < test_case; i = i+1) begin
    count = $fscanf(fp_r, "%h", code_in);
    count = $fscanf(fp_r, "%s", a);
    if(code_in != 6'h1a)
      count = $fscanf(fp_r, "%s", b);
    $display("encrypt %h", code_in);
    @(negedge clk);
  end
  encrypt = 1'b0;
  $fclose(fp_r);
  #(CYCLE*10000); $finish;
end

integer j, error, fp_l, read_valid;
reg [5:0] Result_Golden;
// output comparason
initial begin
  if(~crypt_mode) begin
    fp_l = $fopen(PATH_CIPHER, "r");
    error = 0;
    wait(code_valid == 1)
    for(j = 0; j < test_case; j = j+1) begin
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
    fp_l = $fopen(PATH_PLAIN, "r");
    error = 0;
    wait(code_valid == 1)
    for(j = 0; j < test_case; j = j+1) begin
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


