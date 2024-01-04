`timescale 10ns/1ns
module kalman_filter_test;
localparam BIT_NUM = 18;
localparam FRAC_NUM = 9;

// ===== waveform dumpping ===== //

initial begin
  $fsdbDumpfile("post_sim.fsdb");
  $fsdbDumpvars("+mda");
end

initial begin

	$dumpfile("postsim.vcd");  
    $dumpvars;
	$sdf_annotate("../innovus/post_layout/CHIP.sdf",CHIP0);

end


// pattern files
reg [500*8-1:0] PATH_Xt;
reg [500*8-1:0] PATH_Yt;
reg [500*8-1:0] PATH_Zt;
reg [500*8-1:0] PATH_Tt;
reg [500*8-1:0] PATH_X;
reg [500*8-1:0] PATH_Y;
reg [500*8-1:0] PATH_Z;
reg [500*8-1:0] PATH_T;
reg [500*8-1:0] PATH_PX;
reg [500*8-1:0] PATH_PY;
reg [500*8-1:0] PATH_PZ;
reg [500*8-1:0] PATH_PT;
reg [500*8-1:0] PATH_X_in;
reg [500*8-1:0] PATH_Y_in;
reg [500*8-1:0] PATH_Z_in;
reg [500*8-1:0] PATH_T_in;
reg [500*8-1:0] PATH_PX_in;
reg [500*8-1:0] PATH_PY_in;
reg [500*8-1:0] PATH_PZ_in;
reg [500*8-1:0] PATH_PT_in;
initial begin
  PATH_Xt = "./data/Zt.dat";
  PATH_Yt = "./data/Zt.dat";
  PATH_Zt = "./data/Zt.dat";
  PATH_Tt = "./data/Zt.dat";
  PATH_X = "./data/X.dat";
  PATH_Y = "./data/X.dat";
  PATH_Z = "./data/X.dat";
  PATH_T = "./data/X.dat";
  PATH_PX = "./data/P.dat";
  PATH_PY = "./data/P.dat";
  PATH_PZ = "./data/P.dat";
  PATH_PT = "./data/P.dat";
  PATH_X_in = "./data/X.dat";
  PATH_PX_in = "./data/P.dat";
  PATH_Y_in = "./data/X.dat";
  PATH_PY_in = "./data/P.dat";
  PATH_Z_in = "./data/X.dat";
  PATH_PZ_in = "./data/P.dat";
  PATH_T_in = "./data/X.dat";
  PATH_PT_in = "./data/P.dat";
end

// clock period
parameter CYCLE = 10;

// control signal
reg clk;
reg srst_n;
always #(CYCLE/2) clk = ~clk; // clock toggles

initial                       // initial state of clk, rst
begin                          
  clk = 0;
  srst_n = 1;
  #(CYCLE); srst_n = 0;
  #(CYCLE); srst_n = 1;
  #1
  #(CYCLE*1000); $finish;
end


// I/O pin def
reg signed [BIT_NUM-1:0] Xt;
reg signed [BIT_NUM-1:0] Yt;
reg signed [BIT_NUM-1:0] Zt;
reg signed [BIT_NUM-1:0] Tt;
reg signed [BIT_NUM-1:0] X_in_00;
reg signed [BIT_NUM-1:0] X_in_10;
reg signed [BIT_NUM-1:0] Y_in_00;
reg signed [BIT_NUM-1:0] Y_in_10;
reg signed [BIT_NUM-1:0] Z_in_00;
reg signed [BIT_NUM-1:0] Z_in_10;
reg signed [BIT_NUM-1:0] T_in_00;
reg signed [BIT_NUM-1:0] T_in_10;
reg signed [BIT_NUM-1:0] PX_in_00;
reg signed [BIT_NUM-1:0] PX_in_01;
reg signed [BIT_NUM-1:0] PX_in_10;
reg signed [BIT_NUM-1:0] PX_in_11;
reg signed [BIT_NUM-1:0] PY_in_00;
reg signed [BIT_NUM-1:0] PY_in_01;
reg signed [BIT_NUM-1:0] PY_in_10;
reg signed [BIT_NUM-1:0] PY_in_11;
reg signed [BIT_NUM-1:0] PZ_in_00;
reg signed [BIT_NUM-1:0] PZ_in_01;
reg signed [BIT_NUM-1:0] PZ_in_10;
reg signed [BIT_NUM-1:0] PZ_in_11;
reg signed [BIT_NUM-1:0] PT_in_00;
reg signed [BIT_NUM-1:0] PT_in_01;
reg signed [BIT_NUM-1:0] PT_in_10;
reg signed [BIT_NUM-1:0] PT_in_11;
reg signed [BIT_NUM-1:0] F_00;
reg signed [BIT_NUM-1:0] F_01;
reg signed [BIT_NUM-1:0] F_10;
reg signed [BIT_NUM-1:0] F_11;
reg signed [BIT_NUM-1:0] Q_00;
reg signed [BIT_NUM-1:0] Q_01;
reg signed [BIT_NUM-1:0] Q_10;
reg signed [BIT_NUM-1:0] Q_11;
reg signed [BIT_NUM-1:0] H_00;
reg signed [BIT_NUM-1:0] H_01;
reg signed [BIT_NUM-1:0] R;
reg enable;
wire signed [BIT_NUM-1:0] K_00;
wire signed [BIT_NUM-1:0] K_10;
wire signed [BIT_NUM-1:0] X_out_00;
wire signed [BIT_NUM-1:0] X_out_10;
wire signed [BIT_NUM-1:0] Y_out_00;
wire signed [BIT_NUM-1:0] Y_out_10;
wire signed [BIT_NUM-1:0] Z_out_00;
wire signed [BIT_NUM-1:0] Z_out_10;
wire signed [BIT_NUM-1:0] T_out_00;
wire signed [BIT_NUM-1:0] T_out_10;
wire signed [BIT_NUM-1:0] PX_out_00;
wire signed [BIT_NUM-1:0] PX_out_01;
wire signed [BIT_NUM-1:0] PX_out_10;
wire signed [BIT_NUM-1:0] PX_out_11;
wire signed [BIT_NUM-1:0] PY_out_00;
wire signed [BIT_NUM-1:0] PY_out_01;
wire signed [BIT_NUM-1:0] PY_out_10;
wire signed [BIT_NUM-1:0] PY_out_11;
wire signed [BIT_NUM-1:0] PZ_out_00;
wire signed [BIT_NUM-1:0] PZ_out_01;
wire signed [BIT_NUM-1:0] PZ_out_10;
wire signed [BIT_NUM-1:0] PZ_out_11;
wire signed [BIT_NUM-1:0] PT_out_00;
wire signed [BIT_NUM-1:0] PT_out_01;
wire signed [BIT_NUM-1:0] PT_out_10;
wire signed [BIT_NUM-1:0] PT_out_11;
wire valid;

/*kalman_filter_top #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) 
Kalman_filter (.clk(clk), .srst_n(srst_n), .Zt(Zt), .X_in_00(X_in_00), .X_in_10(X_in_10), .P_in_00(P_in_00), .P_in_01(P_in_01), .P_in_10(P_in_10), .P_in_11(P_in_11),
                                 .F_00(F_00), .F_01(F_01), .F_10(F_10), .F_11(F_11), .Q_00(Q_00), .Q_01(Q_01), .Q_10(Q_10), .Q_11(Q_11), .H_00(H_00), .H_01(H_01), .enable(enable), 
                                 .X_out_00(X_out_00), .X_out_10(X_out_10), .P_out_00(P_out_00), .P_out_01(P_out_01), .P_out_10(P_out_10), .P_out_11(P_out_11), .valid(valid), .R(R));*/


fourD_kalman_filter CHIP0 (.clk(clk), .srst_n(srst_n), .Xt(Xt), .Yt(Yt), .Zt(Zt), .Tt(Tt), .X_in_00(X_in_00), .X_in_10(X_in_10), .Y_in_00(Y_in_00), .Y_in_10(Y_in_10), .Z_in_00(Z_in_00), .Z_in_10(Z_in_10), .T_in_00(T_in_00), .T_in_10(T_in_10),
 .PX_in_00(PX_in_00), .PX_in_01(PX_in_01), .PX_in_10(PX_in_10), .PX_in_11(PX_in_11), .PY_in_00(PY_in_00), .PY_in_01(PY_in_01), .PY_in_10(PY_in_10), .PY_in_11(PY_in_11),
 .PZ_in_00(PZ_in_00), .PZ_in_01(PZ_in_01), .PZ_in_10(PZ_in_10), .PZ_in_11(PZ_in_11), .PT_in_00(PT_in_00), .PT_in_01(PT_in_01), .PT_in_10(PT_in_10), .PT_in_11(PT_in_11),
 .F_00(F_00), .F_01(F_01), .F_10(F_10), .F_11(F_11), .Q_00(Q_00), .Q_01(Q_01), .Q_10(Q_10), .Q_11(Q_11), .H_00(H_00), .H_01(H_01), .enable(enable), 
 .X_out_00(X_out_00), .X_out_10(X_out_10), .Y_out_00(Y_out_00), .Y_out_10(Y_out_10), .Z_out_00(Z_out_00), .Z_out_10(Z_out_10), .T_out_00(T_out_00), .T_out_10(T_out_10),
 .PX_out_00(PX_out_00), .PX_out_01(PX_out_01), .PX_out_10(PX_out_10), .PX_out_11(PX_out_11), .PY_out_00(PY_out_00), .PY_out_01(PY_out_01), .PY_out_10(PY_out_10), .PY_out_11(PY_out_11),
 .PZ_out_00(PZ_out_00), .PZ_out_01(PZ_out_01), .PZ_out_10(PZ_out_10), .PZ_out_11(PZ_out_11), .PT_out_00(PT_out_00), .PT_out_01(PT_out_01), .PT_out_10(PT_out_10), .PT_out_11(PT_out_11),
 .valid(valid), .R(R));

// Input feeding
integer i, fp_Xt, fp_Yt, fp_Zt, fp_Tt, fp_X_in, fp_PX_in, fp_Y_in, fp_PY_in, fp_Z_in, fp_PZ_in, fp_T_in, fp_PT_in;
integer read_valid_Xt, read_valid_Yt, read_valid_Zt, read_valid_Tt, read_valid_X_in, read_valid_PX_in, read_valid_Y_in, read_valid_PY_in, read_valid_Z_in, read_valid_PZ_in, read_valid_T_in, read_valid_PT_in;
initial begin
  enable = 0; 
  F_00 = 18'sb0_0000_0001_0_0000_0000;
  F_01 = 18'sb0_0000_0001_0_0000_0000;
  F_10 = 0;
  F_11 = 18'sb0_0000_0001_0_0000_0000;
  Q_00 = 18'sb0_0000_0001_0_0000_0000;
  Q_01 = 0;
  Q_10 = 0;
  Q_11 = 18'sb0_0000_0001_0_0000_0000;
  H_00 = 18'sb0_0000_0001_0_0000_0000;
  H_01 = 0;
  R = 18'sb0_0000_0001_0_0000_0000;
  wait(srst_n == 0);
  wait(srst_n == 1);
  //#(CYCLE);
  enable = 1;
  fp_Xt = $fopen(PATH_Xt, "r");
  fp_Yt = $fopen(PATH_Yt, "r");
  fp_Zt = $fopen(PATH_Zt, "r");
  fp_Tt = $fopen(PATH_Tt, "r");
  fp_X_in = $fopen(PATH_X_in, "r");
  fp_Y_in = $fopen(PATH_Y_in, "r");
  fp_Z_in = $fopen(PATH_Z_in, "r");
  fp_T_in = $fopen(PATH_T_in, "r");
  fp_PX_in = $fopen(PATH_PX_in, "r");  
  fp_PY_in = $fopen(PATH_PY_in, "r");  
  fp_PZ_in = $fopen(PATH_PZ_in, "r");  
  fp_PT_in = $fopen(PATH_PT_in, "r");  
  i = 0;
  while (i < 100) begin
    read_valid_Xt = $fscanf(fp_Xt, "%b", Xt);
    read_valid_Yt = $fscanf(fp_Yt, "%b", Yt);
    read_valid_Zt = $fscanf(fp_Zt, "%b", Zt);
    read_valid_Tt = $fscanf(fp_Tt, "%b", Tt);
    read_valid_X_in = $fscanf(fp_X_in, "%b %b", X_in_00, X_in_10);
    read_valid_Y_in = $fscanf(fp_Y_in, "%b %b", Y_in_00, Y_in_10);
    read_valid_Z_in = $fscanf(fp_Z_in, "%b %b", Z_in_00, Z_in_10);
    read_valid_T_in = $fscanf(fp_T_in, "%b %b", T_in_00, T_in_10);
    read_valid_PX_in = $fscanf(fp_PX_in, "%b %b %b %b", PX_in_00, PX_in_01, PX_in_10, PX_in_11);
    read_valid_PY_in = $fscanf(fp_PY_in, "%b %b %b %b", PY_in_00, PY_in_01, PY_in_10, PY_in_11);
    read_valid_PZ_in = $fscanf(fp_PZ_in, "%b %b %b %b", PZ_in_00, PZ_in_01, PZ_in_10, PZ_in_11);
    read_valid_PT_in = $fscanf(fp_PT_in, "%b %b %b %b", PT_in_00, PT_in_01, PT_in_10, PT_in_11);
    i = i+1;
  @(negedge clk);
  end
  $fclose(fp_Xt);
  $fclose(fp_Yt);
  $fclose(fp_Zt);
  $fclose(fp_Tt);
  $fclose(fp_X_in);
  $fclose(fp_Y_in);
  $fclose(fp_Z_in);
  $fclose(fp_T_in);
  $fclose(fp_PX_in);
  $fclose(fp_PY_in);
  $fclose(fp_PZ_in);
  $fclose(fp_PT_in);  
end





// Output comparison
integer j, fp_X, fp_Y, fp_Z, fp_T, fp_PX, fp_PY, fp_PZ, fp_PT, read_valid_X, read_valid_Y, read_valid_Z, read_valid_T, read_valid_PX, read_valid_PY, read_valid_PZ, read_valid_PT;
integer error_X, error_Y, error_Z, error_T, error_PX, error_PY, error_PZ, error_PT;
reg signed [BIT_NUM-1:0] X_out_00_gold;
reg signed [BIT_NUM-1:0] X_out_10_gold;
reg signed [BIT_NUM-1:0] Y_out_00_gold;
reg signed [BIT_NUM-1:0] Y_out_10_gold;
reg signed [BIT_NUM-1:0] Z_out_00_gold;
reg signed [BIT_NUM-1:0] Z_out_10_gold;
reg signed [BIT_NUM-1:0] T_out_00_gold;
reg signed [BIT_NUM-1:0] T_out_10_gold;
reg signed [BIT_NUM-1:0] PX_out_00_gold;
reg signed [BIT_NUM-1:0] PX_out_01_gold;
reg signed [BIT_NUM-1:0] PX_out_10_gold;
reg signed [BIT_NUM-1:0] PX_out_11_gold;
reg signed [BIT_NUM-1:0] PY_out_00_gold;
reg signed [BIT_NUM-1:0] PY_out_01_gold;
reg signed [BIT_NUM-1:0] PY_out_10_gold;
reg signed [BIT_NUM-1:0] PY_out_11_gold;
reg signed [BIT_NUM-1:0] PZ_out_00_gold;
reg signed [BIT_NUM-1:0] PZ_out_01_gold;
reg signed [BIT_NUM-1:0] PZ_out_10_gold;
reg signed [BIT_NUM-1:0] PZ_out_11_gold;
reg signed [BIT_NUM-1:0] PT_out_00_gold;
reg signed [BIT_NUM-1:0] PT_out_01_gold;
reg signed [BIT_NUM-1:0] PT_out_10_gold;
reg signed [BIT_NUM-1:0] PT_out_11_gold;
initial begin
  //wait(valid)
  fp_X = $fopen(PATH_X, "r");
  fp_Y = $fopen(PATH_Y, "r");
  fp_Z = $fopen(PATH_Z, "r");
  fp_T = $fopen(PATH_T, "r");
  fp_PX = $fopen(PATH_PX, "r");  
  fp_PY = $fopen(PATH_PY, "r"); 
  fp_PZ = $fopen(PATH_PZ, "r"); 
  fp_PT = $fopen(PATH_PT, "r"); 
  read_valid_X = $fscanf(fp_X, "%b %b", X_out_00_gold, X_out_10_gold);
  read_valid_Y = $fscanf(fp_Y, "%b %b", Y_out_00_gold, Y_out_10_gold);
  read_valid_Z = $fscanf(fp_Z, "%b %b", Z_out_00_gold, Z_out_10_gold);
  read_valid_T = $fscanf(fp_T, "%b %b", T_out_00_gold, T_out_10_gold);
  read_valid_PX = $fscanf(fp_PX, "%b %b %b %b", PX_out_00_gold, PX_out_01_gold, PX_out_10_gold, PX_out_11_gold);    
  read_valid_PY = $fscanf(fp_PY, "%b %b %b %b", PY_out_00_gold, PY_out_01_gold, PY_out_10_gold, PY_out_11_gold); 
  read_valid_PZ = $fscanf(fp_PZ, "%b %b %b %b", PZ_out_00_gold, PZ_out_01_gold, PZ_out_10_gold, PZ_out_11_gold); 
  read_valid_PT = $fscanf(fp_PT, "%b %b %b %b", PT_out_00_gold, PT_out_01_gold, PT_out_10_gold, PT_out_11_gold); 
  j = 0;
  error_X = 0;
  error_Y = 0;
  error_Z = 0;
  error_T = 0;
  error_PX = 0;
  error_PY = 0;
  error_PZ = 0;
  error_PT = 0;
  wait(valid)  
  while(j < 100) begin
    //wait(valid)
    read_valid_X = $fscanf(fp_X, "%b %b", X_out_00_gold, X_out_10_gold);
    read_valid_Y = $fscanf(fp_Y, "%b %b", Y_out_00_gold, Y_out_10_gold);
    read_valid_Z = $fscanf(fp_Z, "%b %b", Z_out_00_gold, Z_out_10_gold);
    read_valid_T = $fscanf(fp_T, "%b %b", T_out_00_gold, T_out_10_gold);
    read_valid_PX = $fscanf(fp_PX, "%b %b %b %b", PX_out_00_gold, PX_out_01_gold, PX_out_10_gold, PX_out_11_gold); 
    read_valid_PY = $fscanf(fp_PY, "%b %b %b %b", PY_out_00_gold, PY_out_01_gold, PY_out_10_gold, PY_out_11_gold);   
    read_valid_PZ = $fscanf(fp_PZ, "%b %b %b %b", PZ_out_00_gold, PZ_out_01_gold, PZ_out_10_gold, PZ_out_11_gold);   
    read_valid_PT = $fscanf(fp_PT, "%b %b %b %b", PT_out_00_gold, PT_out_01_gold, PT_out_10_gold, PT_out_11_gold);     
    #1 
    $display("simulating pattern %d .......", j+1);
    if((PX_out_00 != PX_out_00_gold) || (PX_out_01 != PX_out_01_gold) || (PX_out_10 != PX_out_10_gold) || (PX_out_11 != PX_out_11_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("  your PX = [[%h, %h], [%h, %h]], golden = [[%h, %h], [%h, %h]]     ", PX_out_00, PX_out_01, PX_out_10, PX_out_11, PX_out_00_gold, PX_out_01_gold, PX_out_10_gold, PX_out_11_gold);        	
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_PX = error_PX + 1;
    end
    if((X_out_00 != X_out_00_gold) || (X_out_10 != X_out_10_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("          your X = [[%h], [%h]], golden = [[%h], [%h]]             ", X_out_00, X_out_10, X_out_00_gold, X_out_10_gold);
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_X = error_X + 1;
    end
    if((PY_out_00 != PY_out_00_gold) || (PY_out_01 != PY_out_01_gold) || (PY_out_10 != PY_out_10_gold) || (PY_out_11 != PY_out_11_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("  your PY = [[%h, %h], [%h, %h]], golden = [[%h, %h], [%h, %h]]     ", PY_out_00, PY_out_01, PY_out_10, PY_out_11, PY_out_00_gold, PY_out_01_gold, PY_out_10_gold, PY_out_11_gold);        	
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_PY = error_PY + 1;
    end
    if((Y_out_00 != Y_out_00_gold) || (Y_out_10 != Y_out_10_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("          your Y = [[%h], [%h]], golden = [[%h], [%h]]             ", Y_out_00, Y_out_10, Y_out_00_gold, Y_out_10_gold);
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_Y = error_Y + 1;
    end
    if((PZ_out_00 != PZ_out_00_gold) || (PZ_out_01 != PZ_out_01_gold) || (PZ_out_10 != PZ_out_10_gold) || (PZ_out_11 != PZ_out_11_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("  your PZ = [[%h, %h], [%h, %h]], golden = [[%h, %h], [%h, %h]]     ", PZ_out_00, PZ_out_01, PZ_out_10, PZ_out_11, PZ_out_00_gold, PZ_out_01_gold, PZ_out_10_gold, PZ_out_11_gold);        	
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_PZ = error_PZ + 1;
    end
    if((Z_out_00 != Z_out_00_gold) || (Z_out_10 != Z_out_10_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("          your Z = [[%h], [%h]], golden = [[%h], [%h]]             ", Z_out_00, Z_out_10, Z_out_00_gold, Z_out_10_gold);
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_Z = error_Z + 1;
    end
    if((PT_out_00 != PT_out_00_gold) || (PT_out_01 != PT_out_01_gold) || (PT_out_10 != PT_out_10_gold) || (PT_out_11 != PT_out_11_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("  your PT = [[%h, %h], [%h, %h]], golden = [[%h, %h], [%h, %h]]     ", PT_out_00, PT_out_01, PT_out_10, PT_out_11, PT_out_00_gold, PT_out_01_gold, PT_out_10_gold, PT_out_11_gold);        	
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_PT = error_PT + 1;
    end
    if((T_out_00 != T_out_00_gold) || (T_out_10 != T_out_10_gold)) begin
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
      $display("X                                                                 X");
      $display("          your T = [[%h], [%h]], golden = [[%h], [%h]]             ", T_out_00, T_out_10, T_out_00_gold, T_out_10_gold);
      $display("X                                                                 X");
      $display("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\n");
      error_T = error_T + 1;
    end
    j = j+1;
  @(posedge clk);
  end
  if((error_PX == 0) && (error_X == 0) && (error_PY == 0) && (error_Y == 0) && (error_PZ == 0) && (error_Z == 0) && (error_PT == 0) && (error_T == 0)) begin
    $display("===================================================================");
    $display("=                                                                 =");
    $display("=       Congratulations!  All patterns'successfully passed!       =");
    $display("=                                                                 =");
    $display("===================================================================");    
  end
  $fclose(fp_X);
  $fclose(fp_Y);
  $fclose(fp_Z);
  $fclose(fp_T);
  $fclose(fp_PX);
  $fclose(fp_PY);
  $fclose(fp_PZ);
  $fclose(fp_PT);
  $finish;
end



endmodule
