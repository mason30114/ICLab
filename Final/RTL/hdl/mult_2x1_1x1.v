module mult_2x1_1x1 #(
parameter BIT_NUM = 18,
parameter FRAC_NUM = 9
) 
(
  input clk,
  input srst_n,
  input [BIT_NUM-1:0] A_00,
  input [BIT_NUM-1:0] A_10,
  input [BIT_NUM-1:0] B,

  output reg signed [BIT_NUM-1:0] C_00,
  output reg signed [BIT_NUM-1:0] C_10
);


// mult phase
reg signed [2*BIT_NUM-1:0] mult [0:1];
always@* begin
  mult[0] = $signed(A_00) * $signed(B);
  mult[1] = $signed(A_10) * $signed(B);
end
/*always@(posedge clk)
  if(~srst_n) begin
    mult[0] <= 0;
    mult[1] <= 0;
  end
  else begin
    mult[0] <= $signed(A_00) * $signed(B);
    mult[1] <= $signed(A_10) * $signed(B);
  end*/

always@(posedge clk)
  if(~srst_n) begin
    C_00 <= 0;
    C_10 <= 0;
  end
  else begin
    if(mult[0][2*BIT_NUM-1])
      C_00 <= mult[0][BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;  
    else
      C_00 <= mult[0][BIT_NUM+FRAC_NUM-1:FRAC_NUM];
    if(mult[1][2*BIT_NUM-1])
      C_10 <= mult[1][BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;  
    else
      C_10 <= mult[1][BIT_NUM+FRAC_NUM-1:FRAC_NUM];
  end




endmodule
