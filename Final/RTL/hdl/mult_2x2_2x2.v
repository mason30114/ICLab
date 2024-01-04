module mult_2x2_2x2 #(
parameter BIT_NUM = 18,
parameter FRAC_NUM = 9
)
(
  input clk,
  input srst_n,
  input [BIT_NUM-1:0] A_00,
  input [BIT_NUM-1:0] A_01,
  input [BIT_NUM-1:0] A_10,
  input [BIT_NUM-1:0] A_11,
  input [BIT_NUM-1:0] B_00,
  input [BIT_NUM-1:0] B_01,
  input [BIT_NUM-1:0] B_10,
  input [BIT_NUM-1:0] B_11,
  output reg signed [BIT_NUM-1:0] C_00,
  output reg signed [BIT_NUM-1:0] C_01,
  output reg signed [BIT_NUM-1:0] C_10,
  output reg signed [BIT_NUM-1:0] C_11
);


// mult phase
reg signed [2*BIT_NUM-1:0] mult [0:7];
always@* begin
  mult[0] = $signed(A_00) * $signed(B_00);
  mult[1] = $signed(A_01) * $signed(B_10);
  mult[2] = $signed(A_00) * $signed(B_01);
  mult[3] = $signed(A_01) * $signed(B_11);
  mult[4] = $signed(A_10) * $signed(B_00);
  mult[5] = $signed(A_11) * $signed(B_10);
  mult[6] = $signed(A_10) * $signed(B_01);
  mult[7] = $signed(A_11) * $signed(B_11);
end

/*always@(posedge clk)
  if(~srst_n) begin
    mult[0] <= 0;
    mult[1] <= 0;
    mult[2] <= 0;
    mult[3] <= 0;
    mult[4] <= 0;
    mult[5] <= 0;
    mult[6] <= 0;
    mult[7] <= 0;
  end
  else begin
    mult[0] <= $signed(A_00) * $signed(B_00);
    mult[1] <= $signed(A_01) * $signed(B_10);
    mult[2] <= $signed(A_00) * $signed(B_01);
    mult[3] <= $signed(A_01) * $signed(B_11);
    mult[4] <= $signed(A_10) * $signed(B_00);
    mult[5] <= $signed(A_11) * $signed(B_10);
    mult[6] <= $signed(A_10) * $signed(B_01);
    mult[7] <= $signed(A_11) * $signed(B_11);
  end*/

// add phase
reg signed [2*BIT_NUM:0] add [0:3];
always@* begin
  add[0] = mult[0] + mult[1];
  add[1] = mult[2] + mult[3];
  add[2] = mult[4] + mult[5];
  add[3] = mult[6] + mult[7];
end


// quantization
always@(posedge clk) 
  if(~srst_n) begin
    C_00 <= 0;    
    C_01 <= 0;  
    C_10 <= 0; 
    C_11 <= 0; 
  end
  else begin
    if(add[0][2*BIT_NUM])
      C_00 <= add[0][BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;
    else
      C_00 <= add[0][BIT_NUM+FRAC_NUM-1:FRAC_NUM];    
    if(add[1][2*BIT_NUM])
      C_01 <= add[1][BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;
    else
      C_01 <= add[1][BIT_NUM+FRAC_NUM-1:FRAC_NUM];  
    if(add[2][2*BIT_NUM])
      C_10 <= add[2][BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;
    else
      C_10 <= add[2][BIT_NUM+FRAC_NUM-1:FRAC_NUM]; 
    if(add[3][2*BIT_NUM])
      C_11 <= add[3][BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;
    else
      C_11 <= add[3][BIT_NUM+FRAC_NUM-1:FRAC_NUM]; 
  end




endmodule