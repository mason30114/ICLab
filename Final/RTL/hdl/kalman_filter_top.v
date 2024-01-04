module kalman_filter_top #(
parameter BIT_NUM = 18,
parameter FRAC_NUM = 9
)
(
  input clk,
  input srst_n,
  input signed [BIT_NUM-1:0] Zt,       /// 2
  input signed [BIT_NUM-1:0] X_in_00,
  input signed [BIT_NUM-1:0] X_in_10,
  input signed [BIT_NUM-1:0] P_in_00,
  input signed [BIT_NUM-1:0] P_in_01,
  input signed [BIT_NUM-1:0] P_in_10,
  input signed [BIT_NUM-1:0] P_in_11,
  input signed [BIT_NUM-1:0] F_00,
  input signed [BIT_NUM-1:0] F_01,
  input signed [BIT_NUM-1:0] F_10,
  input signed [BIT_NUM-1:0] F_11,
  input signed [BIT_NUM-1:0] Q_00,
  input signed [BIT_NUM-1:0] Q_01,
  input signed [BIT_NUM-1:0] Q_10,
  input signed [BIT_NUM-1:0] Q_11,
  input signed [BIT_NUM-1:0] H_00,
  input signed [BIT_NUM-1:0] H_01,
  input signed [BIT_NUM-1:0] R,
  input enable,
  output reg signed [BIT_NUM-1:0] X_out_00,
  output reg signed [BIT_NUM-1:0] X_out_10,
  output signed [BIT_NUM-1:0] P_out_00,
  output signed [BIT_NUM-1:0] P_out_01,
  output signed [BIT_NUM-1:0] P_out_10,
  output signed [BIT_NUM-1:0] P_out_11,
  output reg valid
);

wire signed [BIT_NUM-1:0] X_p_00;  /// 6
wire signed [BIT_NUM-1:0] X_p_10;  ///
reg signed [BIT_NUM-1:0] P_p_00;   /// 5
reg signed [BIT_NUM-1:0] P_p_01;   ///
reg signed [BIT_NUM-1:0] P_p_10;   ///
reg signed [BIT_NUM-1:0] P_p_11;   ///
reg signed [BIT_NUM-1:0] K_00;
reg signed [BIT_NUM-1:0] K_10;


// -----------------------------------------------------------------------------------------------Buffer declaration-------------------------------------------------------------------------------------------//

// Zt
reg signed [BIT_NUM-1:0] Zt_delay1, Zt_delay2;

always@(posedge clk)
  if(~srst_n)
    Zt_delay1 <= 0;
  else
    Zt_delay1 <= Zt;

always@(posedge clk)
  if(~srst_n)
    Zt_delay2 <= 0;
  else
    Zt_delay2 <= Zt_delay1;

// Xp
reg signed [BIT_NUM-1:0] X_p_00_delay1, X_p_00_delay2, X_p_00_delay3, X_p_00_delay4, X_p_00_delay5, X_p_00_delay6;
reg signed [BIT_NUM-1:0] X_p_10_delay1, X_p_10_delay2, X_p_10_delay3, X_p_10_delay4, X_p_10_delay5, X_p_10_delay6;

always@(posedge clk)
  if(~srst_n) begin
    X_p_00_delay1 <= 0;
    X_p_10_delay1 <= 0;
  end
  else begin
    X_p_00_delay1 <= X_p_00;
    X_p_10_delay1 <= X_p_10;
  end

always@(posedge clk)
  if(~srst_n) begin
    X_p_00_delay2 <= 0;
    X_p_10_delay2 <= 0;
  end
  else begin
    X_p_00_delay2 <= X_p_00_delay1;
    X_p_10_delay2 <= X_p_10_delay1;
  end

always@(posedge clk)
  if(~srst_n) begin
    X_p_00_delay3 <= 0;
    X_p_10_delay3 <= 0;
  end
  else begin
    X_p_00_delay3 <= X_p_00_delay2;
    X_p_10_delay3 <= X_p_10_delay2;
  end

always@(posedge clk)
  if(~srst_n) begin
    X_p_00_delay4 <= 0;
    X_p_10_delay4 <= 0;
  end
  else begin
    X_p_00_delay4 <= X_p_00_delay3;
    X_p_10_delay4 <= X_p_10_delay3;
  end

always@(posedge clk)
  if(~srst_n) begin
    X_p_00_delay5 <= 0;
    X_p_10_delay5 <= 0;
  end
  else begin
    X_p_00_delay5 <= X_p_00_delay4;
    X_p_10_delay5 <= X_p_10_delay4;
  end

always@(posedge clk)
  if(~srst_n) begin
    X_p_00_delay6 <= 0;
    X_p_10_delay6 <= 0;
  end
  else begin
    X_p_00_delay6 <= X_p_00_delay5;
    X_p_10_delay6 <= X_p_10_delay5;
  end

// Pp
reg signed [BIT_NUM-1:0] P_p_00_delay1, P_p_00_delay2, P_p_00_delay3, P_p_00_delay4, P_p_00_delay5;
reg signed [BIT_NUM-1:0] P_p_01_delay1, P_p_01_delay2, P_p_01_delay3, P_p_01_delay4, P_p_01_delay5;
reg signed [BIT_NUM-1:0] P_p_10_delay1, P_p_10_delay2, P_p_10_delay3, P_p_10_delay4, P_p_10_delay5;
reg signed [BIT_NUM-1:0] P_p_11_delay1, P_p_11_delay2, P_p_11_delay3, P_p_11_delay4, P_p_11_delay5;

always@(posedge clk)
  if(~srst_n) begin
    P_p_00_delay1 <= 0;
    P_p_01_delay1 <= 0;
    P_p_10_delay1 <= 0;
    P_p_11_delay1 <= 0;
  end
  else begin
    P_p_00_delay1 <= P_p_00;
    P_p_01_delay1 <= P_p_01;
    P_p_10_delay1 <= P_p_10;
    P_p_11_delay1 <= P_p_11;
  end

always@(posedge clk)
  if(~srst_n) begin
    P_p_00_delay2 <= 0;
    P_p_01_delay2 <= 0;
    P_p_10_delay2 <= 0;
    P_p_11_delay2 <= 0;
  end
  else begin
    P_p_00_delay2 <= P_p_00_delay1;
    P_p_01_delay2 <= P_p_01_delay1;
    P_p_10_delay2 <= P_p_10_delay1;
    P_p_11_delay2 <= P_p_11_delay1;
  end

always@(posedge clk)
  if(~srst_n) begin
    P_p_00_delay3 <= 0;
    P_p_01_delay3 <= 0;
    P_p_10_delay3 <= 0;
    P_p_11_delay3 <= 0;
  end
  else begin
    P_p_00_delay3 <= P_p_00_delay2;
    P_p_01_delay3 <= P_p_01_delay2;
    P_p_10_delay3 <= P_p_10_delay2;
    P_p_11_delay3 <= P_p_11_delay2;
  end

always@(posedge clk)
  if(~srst_n) begin
    P_p_00_delay4 <= 0;
    P_p_01_delay4 <= 0;
    P_p_10_delay4 <= 0;
    P_p_11_delay4 <= 0;
  end
  else begin
    P_p_00_delay4 <= P_p_00_delay3;
    P_p_01_delay4 <= P_p_01_delay3;
    P_p_10_delay4 <= P_p_10_delay3;
    P_p_11_delay4 <= P_p_11_delay3;
  end

always@(posedge clk)
  if(~srst_n) begin
    P_p_00_delay5 <= 0;
    P_p_01_delay5 <= 0;
    P_p_10_delay5 <= 0;
    P_p_11_delay5 <= 0;
  end
  else begin
    P_p_00_delay5 <= P_p_00_delay4;
    P_p_01_delay5 <= P_p_01_delay4;
    P_p_10_delay5 <= P_p_10_delay4;
    P_p_11_delay5 <= P_p_11_delay4;
  end
// -----------------------------------------------------------------------------------------------Buffer declaration-------------------------------------------------------------------------------------------//



// -------------------------------------------------------------------------------------------X prediction ( cycle)-------------------------------------------------------------------------------------------//

// X_ = np.dot(F, X)
mult_2x2_2x1 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M0(.clk(clk), .srst_n(srst_n), .A_00(F_00), .A_01(F_01), .A_10(F_10), .A_11(F_11), .B_00(X_in_00), .B_10(X_in_10), .C_00(X_p_00), .C_10(X_p_10));

// -------------------------------------------------------------------------------------------X prediction ( cycle)-------------------------------------------------------------------------------------------//









// -------------------------------------------------------------------------------------------P prediction ( cycle)-------------------------------------------------------------------------------------------//

// tmp1 = np.dot(F, P)
wire signed [BIT_NUM-1:0] Pp1_tmp_00;
wire signed [BIT_NUM-1:0] Pp1_tmp_01;
wire signed [BIT_NUM-1:0] Pp1_tmp_10;
wire signed [BIT_NUM-1:0] Pp1_tmp_11;

mult_2x2_2x2 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M1(.clk(clk), .srst_n(srst_n), .A_00(F_00), .A_01(F_01), .A_10(F_10), .A_11(F_11), .B_00(P_in_00), .B_01(P_in_01), .B_10(P_in_10), .B_11(P_in_11), .C_00(Pp1_tmp_00), .C_01(Pp1_tmp_01), .C_10(Pp1_tmp_10), .C_11(Pp1_tmp_11));


// P_ = np.dot(tmp1, Ft) (including transpose)
wire signed [BIT_NUM-1:0] Pp2_tmp_00;
wire signed [BIT_NUM-1:0] Pp2_tmp_01;
wire signed [BIT_NUM-1:0] Pp2_tmp_10;
wire signed [BIT_NUM-1:0] Pp2_tmp_11;

mult_2x2_2x2 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M2(.clk(clk), .srst_n(srst_n), .A_00(Pp1_tmp_00), .A_01(Pp1_tmp_01), .A_10(Pp1_tmp_10), .A_11(Pp1_tmp_11), .B_00(F_00), .B_01(F_10), .B_10(F_01), .B_11(F_11), .C_00(Pp2_tmp_00), .C_01(Pp2_tmp_01), .C_10(Pp2_tmp_10), .C_11(Pp2_tmp_11));

// add Q
always@* begin
  P_p_00 = Pp2_tmp_00 + Q_00;
  P_p_01 = Pp2_tmp_01 + Q_01;
  P_p_10 = Pp2_tmp_10 + Q_10;
  P_p_11 = Pp2_tmp_11 + Q_11;
end


// -------------------------------------------------------------------------------------------P prediction ( cycle)---------------------------------------------------------------------------------------------//







// ------------------------------------------------------------------------------------------- Calculate K ( cycle)---------------------------------------------------------------------------------------------//


// tmp2 = np.dot(H, P_)
wire signed [BIT_NUM-1:0] K1_tmp_00;
wire signed [BIT_NUM-1:0] K1_tmp_01;

mult_1x2_2x2 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M7 (.clk(clk), .srst_n(srst_n), .A_00(H_00), .A_01(H_01), .B_00(P_p_00), .B_01(P_p_01), .B_10(P_p_10), .B_11(P_p_11), .C_00(K1_tmp_00), .C_01(K1_tmp_01));

// tmp3 = np.dot(tmp2, Ht)
wire signed [BIT_NUM-1:0] K2_tmp_00;

mult_1x2_2x1 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M8 (.clk(clk), .srst_n(srst_n), .A_00(K1_tmp_00), .A_01(K1_tmp_01), .B_00(H_00), .B_10(H_01), .C(K2_tmp_00));

// tmp60 = tmp3 + R
reg signed [BIT_NUM-1:0] K3_tmp_00;

always@(posedge clk)
  if(~srst_n)
    K3_tmp_00 <= 0;
  else
    K3_tmp_00 <= K2_tmp_00 + R;

// tmp70 = np.dot(P_, Ht)
wire signed [BIT_NUM-1:0] K4_tmp_00;
wire signed [BIT_NUM-1:0] K4_tmp_10;

mult_2x2_2x1 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M9 (.clk(clk), .srst_n(srst_n), .A_00(P_p_00), .A_01(P_p_01), .A_10(P_p_10), .A_11(P_p_11), .B_00(H_00), .B_10(H_01), .C_00(K4_tmp_00), .C_10(K4_tmp_10));

// K = tmp70 / tmp60
reg signed [BIT_NUM+7:0] K5_tmp_00;
reg signed [BIT_NUM+7:0] K5_tmp_10;

always@(posedge clk)
  if(~srst_n) begin
    K5_tmp_00 <= 0; 
    K5_tmp_10 <= 0;
  end
  else begin
    K5_tmp_00 <= (K4_tmp_00 <<< FRAC_NUM); 
    K5_tmp_10 <= (K4_tmp_10 <<< FRAC_NUM);
  end

reg signed [BIT_NUM+7:0] K5_tmp_00_pipe1;
reg signed [BIT_NUM+7:0] K5_tmp_10_pipe1;

always@(posedge clk)
  if(~srst_n) begin
    K5_tmp_00_pipe1 <= 0; 
    K5_tmp_10_pipe1 <= 0;
  end
  else begin
    K5_tmp_00_pipe1 <= K5_tmp_00; 
    K5_tmp_10_pipe1 <= K5_tmp_10;
  end



always@(posedge clk) 
  if(~srst_n) begin
    K_00 <= 0;
    K_10 <= 0;
  end
  else begin
    K_00 <= K5_tmp_00_pipe1 / K3_tmp_00;
    K_10 <= K5_tmp_10_pipe1 / K3_tmp_00;
  end




// ------------------------------------------------------------------------------------------- Calculate K ( cycle)---------------------------------------------------------------------------------------------//







// ------------------------------------------------------------------------------------------- X modification ( cycle)-------------------------------------------------------------------------------------------//


// tmp4 = Zt - np.dot(H, X_)
wire signed [BIT_NUM-1:0] Xm1_tmp;
reg signed [BIT_NUM-1:0] Xm2_tmp;

mult_1x2_2x1 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M3(.clk(clk), .srst_n(srst_n), .A_00(H_00), .A_01(H_01), .B_00(X_p_00), .B_10(X_p_10), .C(Xm1_tmp));

always@(posedge clk)
  if(~srst_n)
    Xm2_tmp <= 0;
  else
    Xm2_tmp <= Zt_delay2 - Xm1_tmp;

reg signed [BIT_NUM-1:0] Xm2_tmp_pipe1, Xm2_tmp_pipe2, Xm2_tmp_pipe3;

always@(posedge clk)
  if(~srst_n)
    Xm2_tmp_pipe1 <= 0;
  else
    Xm2_tmp_pipe1 <= Xm2_tmp;

always@(posedge clk)
  if(~srst_n)
    Xm2_tmp_pipe2 <= 0;
  else
    Xm2_tmp_pipe2 <= Xm2_tmp_pipe1;

always@(posedge clk)
  if(~srst_n)
    Xm2_tmp_pipe3 <= 0;
  else
    Xm2_tmp_pipe3 <= Xm2_tmp_pipe2;


// X = X_ + np.dot(K, tmp4) 
wire signed [BIT_NUM-1:0] Xm3_tmp_00;
wire signed [BIT_NUM-1:0] Xm3_tmp_10;

mult_2x1_1x1 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M4(.clk(clk), .srst_n(srst_n), .A_00(K_00), .A_10(K_10), .B(Xm2_tmp_pipe3), .C_00(Xm3_tmp_00), .C_10(Xm3_tmp_10));

always@(posedge clk)
  if(~srst_n) begin
    X_out_00 <= 0;
    X_out_10 <= 0;
  end
  else begin
    X_out_00 <= X_p_00_delay6 + Xm3_tmp_00;
    X_out_10 <= X_p_10_delay6 + Xm3_tmp_10;
  end
 

// ------------------------------------------------------------------------------------------- X modification ( cycle)-------------------------------------------------------------------------------------------//




// ------------------------------------------------------------------------------------------- P modification ( cycle)-------------------------------------------------------------------------------------------//

// tmp5 = np.dot(K, H)
wire signed [BIT_NUM-1:0] Pm1_tmp_00;
wire signed [BIT_NUM-1:0] Pm1_tmp_01;
wire signed [BIT_NUM-1:0] Pm1_tmp_10;
wire signed [BIT_NUM-1:0] Pm1_tmp_11; 

mult_2x1_1x2 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M5(.clk(clk), .srst_n(srst_n), .A_00(K_00), .A_10(K_10), .B_00(H_00), .B_01(H_01), .C_00(Pm1_tmp_00), .C_01(Pm1_tmp_01), .C_10(Pm1_tmp_10), .C_11(Pm1_tmp_11));

// tmp6 = I - tmp5
reg signed [BIT_NUM-1:0] Pm2_tmp_00;
reg signed [BIT_NUM-1:0] Pm2_tmp_01;
reg signed [BIT_NUM-1:0] Pm2_tmp_10;
reg signed [BIT_NUM-1:0] Pm2_tmp_11; 

always@* begin
  Pm2_tmp_00 = 18'sb0_0000_0001_0_0000_0000 - Pm1_tmp_00;
  Pm2_tmp_01 = 18'sb0_0000_0000_0_0000_0000 - Pm1_tmp_01;
  Pm2_tmp_10 = 18'sb0_0000_0000_0_0000_0000 - Pm1_tmp_10;
  Pm2_tmp_11 = 18'sb0_0000_0001_0_0000_0000 - Pm1_tmp_11;
end

// P = np.dot(tmp6, P_)

mult_2x2_2x2 #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) M6(.clk(clk), .srst_n(srst_n), .A_00(Pm2_tmp_00), .A_01(Pm2_tmp_01), .A_10(Pm2_tmp_10), .A_11(Pm2_tmp_11), .B_00(P_p_00_delay5), .B_01(P_p_01_delay5), .B_10(P_p_10_delay5), .B_11(P_p_11_delay5), .C_00(P_out_00), .C_01(P_out_01), .C_10(P_out_10), .C_11(P_out_11));


// ------------------------------------------------------------------------------------------- P modification ( cycle)-------------------------------------------------------------------------------------------//




// -------------------------------------------------------------------------------------------------Valid control------------------------------------------------------------------------------------------------//
reg enable_delay1, enable_delay2, enable_delay3, enable_delay4, enable_delay5, enable_delay6, enable_delay7, enable_delay8;

always@(posedge clk)
  if(~srst_n)
    enable_delay1 <= 0;
  else
    enable_delay1 <= enable;    

always@(posedge clk)
  if(~srst_n)
    enable_delay2 <= 0;
  else
    enable_delay2 <= enable_delay1; 

always@(posedge clk)
  if(~srst_n)
    enable_delay3 <= 0;
  else
    enable_delay3 <= enable_delay2; 

always@(posedge clk)
  if(~srst_n)
    enable_delay4 <= 0;
  else
    enable_delay4 <= enable_delay3; 

always@(posedge clk)
  if(~srst_n)
    enable_delay5 <= 0;
  else
    enable_delay5 <= enable_delay4; 

always@(posedge clk)
  if(~srst_n)
    enable_delay6 <= 0;
  else
    enable_delay6 <= enable_delay5; 

always@(posedge clk)
  if(~srst_n)
    enable_delay7 <= 0;
  else
    enable_delay7 <= enable_delay6; 

always@(posedge clk)
  if(~srst_n)
    enable_delay8 <= 0;
  else
    enable_delay8 <= enable_delay7; 
  
always@*
  valid = enable_delay8;


// -------------------------------------------------------------------------------------------------Valid control-----------------------------------------------------------------------------------------------//
endmodule


  
