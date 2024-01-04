//==================================================================================================
//  Note:          Use only for teaching materials of IC Design Lab, NTHU.
//  Copyright: (c) 2022 Vision Circuits and Systems Lab, NTHU, Taiwan. ALL Rights Reserved.
//==================================================================================================
 
`timescale 1ns/100ps
//`include "display_enigma_code.v"

module test_enigma_part3_display;

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
reg [6-1:0] tmp;							// When encrypy is active, then code_in is input of code words.
							// Note: We only use rotorA in this part.					
wire [6-1:0] code_out, code_out_b;   // encrypted code word (register output)
wire code_valid, code_valid_b;
reg [7:0] a, b;
integer i, count, fp_r;
parameter CYCLE = 10;
reg [50*8-1:0] PATH_CIPHER, PATH_PLAIN;

`ifdef PAT2 
  localparam test_case = 112;
`elsif PAT3
  localparam test_case = 50868;
`endif
initial begin
  if(test_case == 112) begin
    PATH_CIPHER = "./pat/part3_ciphertext2.dat";
    PATH_PLAIN = "./result/plaintext2_ascii.dat";
  end
  else if (test_case == 50868) begin
    PATH_CIPHER = "./pat/part3_ciphertext3.dat";
    PATH_PLAIN = "./result/plaintext3_ascii.dat";
  end
end

enigma_part3 enigma(.clk(clk), .srst_n(srst_n), .load(load), .encrypt(encrypt), .table_idx(table_idx), .crypt_mode(crypt_mode),
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
  /*`ifdef EN
  crypt_mode = 1'b0;     // encrypt
  `elsif DE
  crypt_mode = 1'b1;       // decrypt
  `endif*/
  crypt_mode = 1'b1;
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
  table_idx = 2'd0;
  fp_r = $fopen("./rotor/plug_board_group.dat", "r");
  #0.01
  for(i = 0; i < 16; i = i+1) begin
    count = $fscanf(fp_r, "%h", code_in);
    tmp = code_in;
    $display("plug %h", code_in);
    @(negedge clk);
    count = $fscanf(fp_r, "%h", code_in);
    count = $fscanf(fp_r, "%s", a);
    if(tmp != 6'h1a)
      count = $fscanf(fp_r, "%s", b);
    if(code_in != 6'h1a && code_in != 6'h1f)
      count = $fscanf(fp_r, "%s", b);
    count = $fscanf(fp_r, "%s", a);
    count = $fscanf(fp_r, "%s", a);
    $display("plug %h", code_in);
    @(negedge clk);
  end
  $fclose(fp_r);

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
reg [7:0] ascii_out;
// output comparason
initial begin
  fp_l = $fopen(PATH_PLAIN, "w");
  wait(code_valid == 1);
  @(posedge clk);
  for(j = 0; j < test_case; j = j+1) begin
    case(code_out) 
            6'h00: ascii_out = 8'h61; //'a'
            6'h01: ascii_out = 8'h62; //'b'
	    6'h02: ascii_out = 8'h63; //'c'
	    6'h03: ascii_out = 8'h64; //'d'
	    6'h04: ascii_out = 8'h65; //'e'
	    6'h05: ascii_out = 8'h66; //'f'
	    6'h06: ascii_out = 8'h67; //'g'
	    6'h07: ascii_out = 8'h68; //'h'
	    6'h08: ascii_out = 8'h69; //'i'
	    6'h09: ascii_out = 8'h6a; //'j'
	    6'h0a: ascii_out = 8'h6b; //'k'
	    6'h0b: ascii_out = 8'h6c; //'l'
	    6'h0c: ascii_out = 8'h6d; //'m'
	    6'h0d: ascii_out = 8'h6e; //'n'
	    6'h0e: ascii_out = 8'h6f; //'o'
	    6'h0f: ascii_out = 8'h70; //'p'
	    6'h10: ascii_out = 8'h71; //'q'
	    6'h11: ascii_out = 8'h72; //'r'
	    6'h12: ascii_out = 8'h73; //'s'
	    6'h13: ascii_out = 8'h74; //'t'
	    6'h14: ascii_out = 8'h75; //'u'
	    6'h15: ascii_out = 8'h76; //'v'
	    6'h16: ascii_out = 8'h77; //'w'
	    6'h17: ascii_out = 8'h78; //'x'
	    6'h18: ascii_out = 8'h79; //'y'
	    6'h19: ascii_out = 8'h7a; //'z'
	    6'h1a: ascii_out = 8'h20; //' '
	    6'h1b: ascii_out = 8'h3f; //'?'
	    6'h1c: ascii_out = 8'h2c; //','
	    6'h1d: ascii_out = 8'h2d; //'-'
	    6'h1e: ascii_out = 8'h2e; //'.'
	    6'h1f: ascii_out = 8'h0a; //'\n'(change line)
	    6'h20: ascii_out = 8'h41; //'A'
	    6'h21: ascii_out = 8'h42; //'B'
	    6'h22: ascii_out = 8'h43; //'C'
	    6'h23: ascii_out = 8'h44; //'D'
	    6'h24: ascii_out = 8'h45; //'E'
	    6'h25: ascii_out = 8'h46; //'F'
	    6'h26: ascii_out = 8'h47; //'G'
	    6'h27: ascii_out = 8'h48; //'H'
	    6'h28: ascii_out = 8'h49; //'I'
	    6'h29: ascii_out = 8'h4a; //'J'
	    6'h2a: ascii_out = 8'h4b; //'K'
	    6'h2b: ascii_out = 8'h4c; //'L'
	    6'h2c: ascii_out = 8'h4d; //'M'
	    6'h2d: ascii_out = 8'h4e; //'N'
	    6'h2e: ascii_out = 8'h4f; //'O'
	    6'h2f: ascii_out = 8'h50; //'P'
	    6'h30: ascii_out = 8'h51; //'Q'
	    6'h31: ascii_out = 8'h52; //'R'
	    6'h32: ascii_out = 8'h53; //'S'
	    6'h33: ascii_out = 8'h54; //'T'
	    6'h34: ascii_out = 8'h55; //'U'
	    6'h35: ascii_out = 8'h56; //'V'
	    6'h36: ascii_out = 8'h57; //'W'
	    6'h37: ascii_out = 8'h58; //'X'
	    6'h38: ascii_out = 8'h59; //'Y'
	    6'h39: ascii_out = 8'h5a; //'Z'
	    6'h3a: ascii_out = 8'h3a; //':'
	    6'h3b: ascii_out = 8'h23; //'#'
	    6'h3c: ascii_out = 8'h3b; //';'
	    6'h3d: ascii_out = 8'h5f; //'_'
	    6'h3e: ascii_out = 8'h2b; //'+'
	    6'h3f: ascii_out = 8'h26; //'&'
            default: ascii_out = 8'h26; 
    endcase
    $fwrite(fp_l, "%h\n", ascii_out);
    @(posedge clk);
  end
  $fclose(fp_l);
end


endmodule
