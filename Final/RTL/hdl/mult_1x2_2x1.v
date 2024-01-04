module mult_1x2_2x1 #(
parameter BIT_NUM = 18,
parameter FRAC_NUM = 9
) 
(
  input clk,
  input srst_n,
  input [BIT_NUM-1:0] A_00,
  input [BIT_NUM-1:0] A_01,
  input [BIT_NUM-1:0] B_00,
  input [BIT_NUM-1:0] B_10,
  output reg signed [BIT_NUM-1:0] C
);


// mult phase
reg signed [2*BIT_NUM-1:0] mult [0:1];
always@* begin
  mult[0] = $signed(A_00) * $signed(B_00);
  mult[1] = $signed(A_01) * $signed(B_10); 
end
/*always@(posedge clk)
  if(~srst_n) begin
    mult[0] <= 0;
    mult[1] <= 0;
  end
  else begin
    mult[0] <= $signed(A_00) * $signed(B_00);
    mult[1] <= $signed(A_01) * $signed(B_10);
  end*/

// add phase
reg signed [2*BIT_NUM:0] add;
always@*
  add = mult[0] + mult[1];


// quantization
always@(posedge clk)
  if(~srst_n)  
    C <= 0;
  else
    if(add[2*BIT_NUM])
      C <= add[BIT_NUM+FRAC_NUM-1:FRAC_NUM] + 1'b1;
    else
      C <= add[BIT_NUM+FRAC_NUM-1:FRAC_NUM]; 



endmodule
