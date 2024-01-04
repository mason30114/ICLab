module fourD_kalman_filter #(
parameter BIT_NUM = 18,
parameter FRAC_NUM = 9
)
(
  input clk,
  input srst_n,
  input signed [BIT_NUM-1:0] Xt,       
  input signed [BIT_NUM-1:0] Yt,  
  input signed [BIT_NUM-1:0] Zt,  
  input signed [BIT_NUM-1:0] Tt,  
  input signed [BIT_NUM-1:0] X_in_00,
  input signed [BIT_NUM-1:0] X_in_10,
  input signed [BIT_NUM-1:0] Y_in_00,
  input signed [BIT_NUM-1:0] Y_in_10,
  input signed [BIT_NUM-1:0] Z_in_00,
  input signed [BIT_NUM-1:0] Z_in_10,
  input signed [BIT_NUM-1:0] T_in_00,
  input signed [BIT_NUM-1:0] T_in_10,
  input signed [BIT_NUM-1:0] PX_in_00,
  input signed [BIT_NUM-1:0] PX_in_01,
  input signed [BIT_NUM-1:0] PX_in_10,
  input signed [BIT_NUM-1:0] PX_in_11,
  input signed [BIT_NUM-1:0] PY_in_00,
  input signed [BIT_NUM-1:0] PY_in_01,
  input signed [BIT_NUM-1:0] PY_in_10,
  input signed [BIT_NUM-1:0] PY_in_11,
  input signed [BIT_NUM-1:0] PZ_in_00,
  input signed [BIT_NUM-1:0] PZ_in_01,
  input signed [BIT_NUM-1:0] PZ_in_10,
  input signed [BIT_NUM-1:0] PZ_in_11,
  input signed [BIT_NUM-1:0] PT_in_00,
  input signed [BIT_NUM-1:0] PT_in_01,
  input signed [BIT_NUM-1:0] PT_in_10,
  input signed [BIT_NUM-1:0] PT_in_11,
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
  output signed [BIT_NUM-1:0] X_out_00,
  output signed [BIT_NUM-1:0] X_out_10,
  output signed [BIT_NUM-1:0] Y_out_00,
  output signed [BIT_NUM-1:0] Y_out_10,
  output signed [BIT_NUM-1:0] Z_out_00,
  output signed [BIT_NUM-1:0] Z_out_10,
  output signed [BIT_NUM-1:0] T_out_00,
  output signed [BIT_NUM-1:0] T_out_10,
  output signed [BIT_NUM-1:0] PX_out_00,
  output signed [BIT_NUM-1:0] PX_out_01,
  output signed [BIT_NUM-1:0] PX_out_10,
  output signed [BIT_NUM-1:0] PX_out_11,
  output signed [BIT_NUM-1:0] PY_out_00,
  output signed [BIT_NUM-1:0] PY_out_01,
  output signed [BIT_NUM-1:0] PY_out_10,
  output signed [BIT_NUM-1:0] PY_out_11,
  output signed [BIT_NUM-1:0] PZ_out_00,
  output signed [BIT_NUM-1:0] PZ_out_01,
  output signed [BIT_NUM-1:0] PZ_out_10,
  output signed [BIT_NUM-1:0] PZ_out_11,
  output signed [BIT_NUM-1:0] PT_out_00,
  output signed [BIT_NUM-1:0] PT_out_01,
  output signed [BIT_NUM-1:0] PT_out_10,
  output signed [BIT_NUM-1:0] PT_out_11,
  output reg valid
);
wire valid_X, valid_Y, valid_Z, valid_T;

kalman_filter_top #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) 
Kalman_filter_X (.clk(clk), .srst_n(srst_n), .Zt(Xt), .X_in_00(X_in_00), .X_in_10(X_in_10), .P_in_00(PX_in_00), .P_in_01(PX_in_01), .P_in_10(PX_in_10), .P_in_11(PX_in_11),
                                 .F_00(F_00), .F_01(F_01), .F_10(F_10), .F_11(F_11), .Q_00(Q_00), .Q_01(Q_01), .Q_10(Q_10), .Q_11(Q_11), .H_00(H_00), .H_01(H_01), .enable(enable), 
                                 .X_out_00(X_out_00), .X_out_10(X_out_10), .P_out_00(PX_out_00), .P_out_01(PX_out_01), .P_out_10(PX_out_10), .P_out_11(PX_out_11), .valid(valid_X), .R(R));


kalman_filter_top #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) 
Kalman_filter_Y (.clk(clk), .srst_n(srst_n), .Zt(Yt), .X_in_00(Y_in_00), .X_in_10(Y_in_10), .P_in_00(PY_in_00), .P_in_01(PY_in_01), .P_in_10(PY_in_10), .P_in_11(PY_in_11),
                                 .F_00(F_00), .F_01(F_01), .F_10(F_10), .F_11(F_11), .Q_00(Q_00), .Q_01(Q_01), .Q_10(Q_10), .Q_11(Q_11), .H_00(H_00), .H_01(H_01), .enable(enable), 
                                 .X_out_00(Y_out_00), .X_out_10(Y_out_10), .P_out_00(PY_out_00), .P_out_01(PY_out_01), .P_out_10(PY_out_10), .P_out_11(PY_out_11), .valid(valid_Y), .R(R));


kalman_filter_top #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) 
Kalman_filter_Z (.clk(clk), .srst_n(srst_n), .Zt(Zt), .X_in_00(Z_in_00), .X_in_10(Z_in_10), .P_in_00(PZ_in_00), .P_in_01(PZ_in_01), .P_in_10(PZ_in_10), .P_in_11(PZ_in_11),
                                 .F_00(F_00), .F_01(F_01), .F_10(F_10), .F_11(F_11), .Q_00(Q_00), .Q_01(Q_01), .Q_10(Q_10), .Q_11(Q_11), .H_00(H_00), .H_01(H_01), .enable(enable), 
                                 .X_out_00(Z_out_00), .X_out_10(Z_out_10), .P_out_00(PZ_out_00), .P_out_01(PZ_out_01), .P_out_10(PZ_out_10), .P_out_11(PZ_out_11), .valid(valid_Z), .R(R));


kalman_filter_top #(.BIT_NUM(BIT_NUM), .FRAC_NUM(FRAC_NUM)) 
Kalman_filter_T (.clk(clk), .srst_n(srst_n), .Zt(Tt), .X_in_00(T_in_00), .X_in_10(T_in_10), .P_in_00(PT_in_00), .P_in_01(PT_in_01), .P_in_10(PT_in_10), .P_in_11(PT_in_11),
                                 .F_00(F_00), .F_01(F_01), .F_10(F_10), .F_11(F_11), .Q_00(Q_00), .Q_01(Q_01), .Q_10(Q_10), .Q_11(Q_11), .H_00(H_00), .H_01(H_01), .enable(enable), 
                                 .X_out_00(T_out_00), .X_out_10(T_out_10), .P_out_00(PT_out_00), .P_out_01(PT_out_01), .P_out_10(PT_out_10), .P_out_11(PT_out_11), .valid(valid_T), .R(R));

always@*
  valid = valid_X && valid_Y && valid_Z && valid_T;



endmodule
