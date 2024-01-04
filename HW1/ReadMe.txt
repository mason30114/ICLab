(1) What you observe in Table 1 and how you find out all256 functions for ROP3 in Part 3 ?

There are 3 input patterns, if we use these 3 to do an operation, the result will exactly be corresponding Mode pattern.
Therefore, every Mode repesents a function.

Because 3 inputs gives us 8 possible combinations of sum of minterms, it is exactly the number of bits in Mode.
For example:
8'h00 = 8'b0000_0000, and the result is 0 (0 entry, 3 input are all don't-care).
8'hFF = 8'b1111_1111, and the result is 1 (8 entries, 3 input are all don't-care). 
8'h44 = 8'b0100_0100, and the result is S&~D (2 entries, P&S&~D | ~P&S&~D)
8'hF0 = 8'b1111_0000, and the result is P (4 entries, P&S&D | P&S&~D | P&~S&D | P&~S&~D)
We exprees every Mode in the table as sum of minterm, and find out that the number of 1 in Mode (binary) 
is exactly the number minterms in the corresponding function, and each position represents a minterm.
See the table below:

position0: ~P&~S&~D
position1: ~P&~S&D
position2: ~P&S&~D
position3: ~P&S&D
position4: P&~S&~D
position5: P&~S&D
position6: P&S&~D
position7: P&S&D

Finally, we can just observe Mode patterns and find out all corresponded function.

(2) How you organize your testbench to test your RTL design in Part 2 & Part 3?

Part2:
//Input feeding
Beacuse we need to tranverse the input patterns in {Mode, P, S, D}, we use "for loop".
While we only need to test 15 possible Mode in this part, we use "case" to convert counter i into Mode pattern.
We need 3 cycles to complete the calculation, and Bitmap should represents different inputs in each cycle.
cycle1: P cycle2: S cycle3: D
So in the inner loop, we use @(negedge clk) for 3 times to achieve this.
We need to remember old pattern because of 1 cycle delay from the ROP3 calculation (for comparasion purpose).

//Output comparasion
There are total 8**`N * 15 possible combinations of input pattern, we use "while loop".
As wait == 1, the result of calculation is available, and we continue to do the comparasion from two ROP3.
If the result of calculation is correct, we send the pattern into csv. file.

Part3:
The concept of organazing testbench is almost the same as part2.
The only difference is in input feeding.
Because the counter i is exactly represent Mode pattern, we don't need to use case statement anymore.