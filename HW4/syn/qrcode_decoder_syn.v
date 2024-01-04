/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Ultra(TM) in wire load mode
// Version   : R-2020.09-SP5
// Date      : Mon Nov 14 13:06:46 2022
/////////////////////////////////////////////////////////////


module SNPS_CLOCK_GATE_HIGH_FSM ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7345;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7345) );
  AND2XL main_gate ( .A(net7345), .B(CLK), .Y(ENCLK) );
endmodule


module FSM ( clk, srst_n, start, rotate_complete, scan_complete, 
        demask_complete, decode_complete, loc_wrong, loc_complete, 
        pre_scan_complete, end_of_file, num_complete, state, finish );
  output [3:0] state;
  input clk, srst_n, start, rotate_complete, scan_complete, demask_complete,
         decode_complete, loc_wrong, loc_complete, pre_scan_complete,
         end_of_file, num_complete;
  output finish;
  wire   net7348, net7352, n21, n24, n25, n1, n2, n3, n4, n5, n6, n7, n8, n9,
         n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n22, n23, n26,
         n27, n28, n29, n30;
  wire   [2:0] n_state;

  DFFTRX2 state_reg_1_ ( .D(srst_n), .RN(n_state[1]), .CK(net7352), .Q(
        state[1]), .QN(n30) );
  OAI211X1 U4 ( .A0(loc_wrong), .A1(n27), .B0(n26), .C0(n23), .Y(n28) );
  AOI221X1 U5 ( .A0(end_of_file), .A1(n29), .B0(scan_complete), .B1(n29), .C0(
        n30), .Y(n18) );
  AOI31XL U6 ( .A0(scan_complete), .A1(n11), .A2(n10), .B0(n9), .Y(n12) );
  AOI31X1 U7 ( .A0(state[1]), .A1(decode_complete), .A2(n19), .B0(n29), .Y(n9)
         );
  OAI2BB1X1 U9 ( .A0N(end_of_file), .A1N(n11), .B0(n24), .Y(n25) );
  AOI22XL U10 ( .A0(n18), .A1(n19), .B0(n30), .B1(n1), .Y(n17) );
  INVXL U12 ( .A(pre_scan_complete), .Y(n4) );
  NOR2XL U13 ( .A(n7), .B(n6), .Y(n5) );
  INVXL U14 ( .A(loc_wrong), .Y(n6) );
  NAND2XL U15 ( .A(state[2]), .B(n21), .Y(n7) );
  INVXL U16 ( .A(n21), .Y(n19) );
  OAI211XL U17 ( .A0(state[1]), .A1(n13), .B0(srst_n), .C0(state[3]), .Y(
        net7348) );
  AND2XL U18 ( .A(n28), .B(n24), .Y(n_state[1]) );
  INVXL U19 ( .A(n29), .Y(n8) );
  AOI31XL U20 ( .A0(state[2]), .A1(loc_complete), .A2(n19), .B0(n18), .Y(n26)
         );
  AOI221XL U21 ( .A0(n19), .A1(n17), .B0(n16), .B1(n17), .C0(state[3]), .Y(
        n_state[0]) );
  NOR4XL U22 ( .A(n24), .B(state[1]), .C(state[2]), .D(n19), .Y(finish) );
  NAND2XL U23 ( .A(n19), .B(n29), .Y(n20) );
  NOR2XL U24 ( .A(n30), .B(n20), .Y(n11) );
  INVXL U25 ( .A(end_of_file), .Y(n10) );
  NOR2XL U26 ( .A(n12), .B(state[3]), .Y(n_state[2]) );
  NAND2XL U27 ( .A(n21), .B(n29), .Y(n13) );
  INVXL U28 ( .A(loc_complete), .Y(n14) );
  AOI33XL U29 ( .A0(state[2]), .A1(n19), .A2(n14), .B0(start), .B1(n21), .B2(
        n29), .Y(n15) );
  OAI221XL U30 ( .A0(n8), .A1(num_complete), .B0(n29), .B1(demask_complete), 
        .C0(state[1]), .Y(n16) );
  NAND3BXL U31 ( .AN(n19), .B(state[2]), .C(rotate_complete), .Y(n27) );
  INVXL U32 ( .A(n20), .Y(n22) );
  AOI32XL U33 ( .A0(n22), .A1(n30), .A2(pre_scan_complete), .B0(state[1]), 
        .B1(n21), .Y(n23) );
  SNPS_CLOCK_GATE_HIGH_FSM clk_gate_state_reg ( .CLK(clk), .EN(net7348), 
        .ENCLK(net7352) );
  DFFTRX2 state_reg_3_ ( .D(srst_n), .RN(n25), .CK(net7352), .Q(state[3]), 
        .QN(n24) );
  DFFTRX2 state_reg_0_ ( .D(srst_n), .RN(n_state[0]), .CK(net7352), .Q(
        state[0]), .QN(n21) );
  DFFTRX4 state_reg_2_ ( .D(srst_n), .RN(n_state[2]), .CK(net7352), .Q(
        state[2]), .QN(n29) );
  NOR2BXL U3 ( .AN(n4), .B(n20), .Y(n3) );
  NOR2BXL U8 ( .AN(n15), .B(n3), .Y(n2) );
  OAI2BB1XL U11 ( .A0N(n5), .A1N(rotate_complete), .B0(n2), .Y(n1) );
endmodule


module ROTATING ( clk, srst_n, state, sram_data, rotate_addr, rotate_complete, 
        scan_loc_y, scan_loc_x, rotation_type, loc_y, loc_x, loc_wrong );
  input [3:0] state;
  output [11:0] rotate_addr;
  input [5:0] scan_loc_y;
  input [5:0] scan_loc_x;
  output [1:0] rotation_type;
  output [5:0] loc_y;
  output [5:0] loc_x;
  input clk, srst_n, sram_data;
  output rotate_complete, loc_wrong;
  wire   rotate_cnt_2_, N50, N51, N52, N53, N59, N60, N244, N245, N246, N247,
         N248, N249, N250, N251, N252, N253, N254, N255, N289, N290, N291,
         N292, N295, N296, N297, N298, n17, n32, n36, intadd_0_A_3_,
         intadd_0_A_1_, intadd_0_B_3_, intadd_0_B_2_, intadd_0_B_1_,
         intadd_0_B_0_, intadd_0_CI, intadd_0_SUM_3_, intadd_0_SUM_2_,
         intadd_0_SUM_1_, intadd_0_SUM_0_, intadd_0_n4, intadd_0_n3,
         intadd_0_n2, intadd_0_n1, intadd_1_A_2_, intadd_1_A_1_, intadd_1_B_2_,
         intadd_1_B_0_, intadd_1_CI, intadd_1_SUM_2_, intadd_1_SUM_1_,
         intadd_1_SUM_0_, intadd_1_n3, intadd_1_n2, intadd_1_n1, n1, n2, n3,
         n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n18, n19,
         n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n33, n34,
         n35, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49,
         n500, n520, n530, n54, n55, n56, n57, n58, n590;

  DFFTRXL rotate_cnt_reg_0_ ( .D(n58), .RN(N50), .CK(clk), .Q(n520), .QN(n36)
         );
  DFFTRXL rotate_cnt_reg_1_ ( .D(n58), .RN(N51), .CK(clk), .Q(n56), .QN(n17)
         );
  DFFTRXL rotate_cnt_reg_3_ ( .D(n58), .RN(N53), .CK(clk), .Q(n55), .QN(n32)
         );
  DFFTRXL rotate_cnt_reg_2_ ( .D(n58), .RN(N52), .CK(clk), .Q(rotate_cnt_2_), 
        .QN(n530) );
  DFFTRXL rotation_type_reg_0_ ( .D(n58), .RN(N59), .CK(clk), .Q(
        rotation_type[0]), .QN(n54) );
  DFFTRXL rotation_type_reg_1_ ( .D(n58), .RN(N60), .CK(clk), .Q(
        rotation_type[1]), .QN(n57) );
  DFFTRXL rotate_addr_reg_11_ ( .D(n58), .RN(N255), .CK(clk), .Q(
        rotate_addr[11]) );
  DFFTRXL rotate_addr_reg_10_ ( .D(n58), .RN(N254), .CK(clk), .Q(
        rotate_addr[10]) );
  DFFTRXL rotate_addr_reg_9_ ( .D(n58), .RN(N253), .CK(clk), .Q(rotate_addr[9]) );
  DFFTRXL rotate_addr_reg_8_ ( .D(n58), .RN(N252), .CK(clk), .Q(rotate_addr[8]) );
  DFFTRXL rotate_addr_reg_7_ ( .D(n58), .RN(N251), .CK(clk), .Q(rotate_addr[7]) );
  DFFTRXL rotate_addr_reg_6_ ( .D(n58), .RN(N250), .CK(clk), .Q(rotate_addr[6]) );
  DFFTRXL rotate_addr_reg_5_ ( .D(n58), .RN(N249), .CK(clk), .Q(rotate_addr[5]) );
  DFFTRXL rotate_addr_reg_4_ ( .D(n590), .RN(N248), .CK(clk), .Q(
        rotate_addr[4]) );
  DFFTRXL rotate_addr_reg_3_ ( .D(n590), .RN(N247), .CK(clk), .Q(
        rotate_addr[3]) );
  DFFTRXL rotate_addr_reg_2_ ( .D(n590), .RN(N246), .CK(clk), .Q(
        rotate_addr[2]) );
  DFFTRXL rotate_addr_reg_1_ ( .D(n590), .RN(N245), .CK(clk), .Q(
        rotate_addr[1]) );
  DFFTRXL rotate_addr_reg_0_ ( .D(n590), .RN(N244), .CK(clk), .Q(
        rotate_addr[0]) );
  DFFTRXL loc_y_reg_5_ ( .D(n590), .RN(N298), .CK(clk), .Q(loc_y[5]) );
  DFFTRXL loc_y_reg_4_ ( .D(n590), .RN(N297), .CK(clk), .Q(loc_y[4]) );
  DFFTRXL loc_y_reg_3_ ( .D(n590), .RN(N296), .CK(clk), .Q(loc_y[3]) );
  DFFTRXL loc_x_reg_5_ ( .D(n590), .RN(N292), .CK(clk), .Q(loc_x[5]) );
  DFFTRXL loc_x_reg_4_ ( .D(n590), .RN(N291), .CK(clk), .Q(loc_x[4]) );
  DFFTRXL loc_x_reg_3_ ( .D(n58), .RN(N290), .CK(clk), .Q(loc_x[3]) );
  DFFTRXL loc_x_reg_2_ ( .D(n58), .RN(N289), .CK(clk), .Q(loc_x[2]) );
  DFFTRXL loc_x_reg_1_ ( .D(n58), .RN(scan_loc_x[1]), .CK(clk), .Q(loc_x[1])
         );
  DFFTRXL loc_x_reg_0_ ( .D(n58), .RN(scan_loc_x[0]), .CK(clk), .Q(loc_x[0])
         );
  ADDFX1 intadd_0_U5 ( .A(intadd_0_B_0_), .B(rotation_type[0]), .CI(
        intadd_0_CI), .CO(intadd_0_n4), .S(intadd_0_SUM_0_) );
  ADDFX1 intadd_0_U4 ( .A(intadd_0_B_1_), .B(intadd_0_A_1_), .CI(intadd_0_n4), 
        .CO(intadd_0_n3), .S(intadd_0_SUM_1_) );
  ADDFX1 intadd_0_U3 ( .A(intadd_0_B_2_), .B(scan_loc_x[3]), .CI(intadd_0_n3), 
        .CO(intadd_0_n2), .S(intadd_0_SUM_2_) );
  ADDFX1 intadd_0_U2 ( .A(intadd_0_B_3_), .B(intadd_0_A_3_), .CI(intadd_0_n2), 
        .CO(intadd_0_n1), .S(intadd_0_SUM_3_) );
  ADDFX1 intadd_1_U4 ( .A(intadd_1_B_0_), .B(scan_loc_y[2]), .CI(intadd_1_CI), 
        .CO(intadd_1_n3), .S(intadd_1_SUM_0_) );
  ADDFX1 intadd_1_U3 ( .A(scan_loc_y[3]), .B(intadd_1_A_1_), .CI(intadd_1_n3), 
        .CO(intadd_1_n2), .S(intadd_1_SUM_1_) );
  ADDFX1 intadd_1_U2 ( .A(intadd_1_B_2_), .B(intadd_1_A_2_), .CI(intadd_1_n2), 
        .CO(intadd_1_n1), .S(intadd_1_SUM_2_) );
  DFFTRXL loc_y_reg_2_ ( .D(n590), .RN(N295), .CK(clk), .Q(loc_y[2]) );
  DFFTRXL loc_y_reg_0_ ( .D(n590), .RN(scan_loc_y[0]), .CK(clk), .Q(loc_y[0])
         );
  DFFTRXL loc_y_reg_1_ ( .D(n590), .RN(scan_loc_y[1]), .CK(clk), .Q(loc_y[1])
         );
  OAI32XL U7 ( .A0(n17), .A1(n16), .A2(n20), .B0(n15), .B1(n56), .Y(n18) );
  AOI32XL U8 ( .A0(n47), .A1(rotation_type[1]), .A2(n46), .B0(n45), .B1(n57), 
        .Y(N60) );
  AOI222XL U9 ( .A0(scan_loc_x[4]), .A1(rotation_type[0]), .B0(scan_loc_x[4]), 
        .B1(n8), .C0(n7), .C1(n22), .Y(n9) );
  OAI2BB1XL U10 ( .A0N(n35), .A1N(n6), .B0(n57), .Y(n3) );
  NOR2XL U11 ( .A(n14), .B(n530), .Y(n20) );
  NOR2XL U12 ( .A(scan_loc_x[2]), .B(n21), .Y(intadd_0_B_2_) );
  NAND2XL U13 ( .A(n41), .B(scan_loc_x[0]), .Y(intadd_0_CI) );
  NOR2XL U14 ( .A(rotation_type[0]), .B(scan_loc_x[4]), .Y(n22) );
  AOI22XL U15 ( .A0(n20), .A1(n56), .B0(n530), .B1(n19), .Y(n21) );
  AOI21XL U16 ( .A0(scan_loc_x[1]), .A1(n18), .B0(intadd_0_A_1_), .Y(
        intadd_0_B_0_) );
  AOI21XL U17 ( .A0(scan_loc_x[4]), .A1(rotation_type[0]), .B0(n22), .Y(
        intadd_0_B_3_) );
  NOR2XL U18 ( .A(n22), .B(intadd_0_n1), .Y(n13) );
  NOR2XL U19 ( .A(n37), .B(n38), .Y(intadd_1_CI) );
  NAND2XL U20 ( .A(n55), .B(n520), .Y(n15) );
  NOR2XL U21 ( .A(n55), .B(n520), .Y(n14) );
  INVXL U22 ( .A(n15), .Y(n16) );
  NOR3XL U23 ( .A(n25), .B(n16), .C(n14), .Y(n41) );
  AOI21XL U24 ( .A0(n21), .A1(scan_loc_x[2]), .B0(intadd_0_B_2_), .Y(
        intadd_0_B_1_) );
  XNOR2X1 U25 ( .A(scan_loc_x[3]), .B(n43), .Y(N290) );
  XNOR2X1 U26 ( .A(scan_loc_y[3]), .B(n42), .Y(N296) );
  XNOR2X1 U27 ( .A(scan_loc_y[5]), .B(n3), .Y(N298) );
  XNOR2X1 U28 ( .A(scan_loc_x[5]), .B(n2), .Y(N249) );
  AND2XL U29 ( .A(scan_loc_x[5]), .B(n13), .Y(n39) );
  XNOR2X1 U30 ( .A(scan_loc_y[5]), .B(intadd_1_n1), .Y(n1) );
  OAI222XL U31 ( .A0(sram_data), .A1(n28), .B0(sram_data), .B1(n27), .C0(n27), 
        .C1(n26), .Y(rotate_complete) );
  OAI21XL U32 ( .A0(n32), .A1(sram_data), .B0(n24), .Y(n27) );
  INVXL U33 ( .A(state[2]), .Y(n10) );
  NAND2XL U34 ( .A(n31), .B(n55), .Y(n19) );
  NOR2XL U35 ( .A(scan_loc_x[1]), .B(n18), .Y(intadd_0_A_1_) );
  NOR2XL U36 ( .A(n17), .B(n530), .Y(n25) );
  AOI21XL U37 ( .A0(intadd_0_n1), .A1(n22), .B0(n13), .Y(n2) );
  NAND2XL U38 ( .A(n56), .B(n520), .Y(n500) );
  INVXL U39 ( .A(n9), .Y(N291) );
  INVXL U40 ( .A(intadd_1_SUM_1_), .Y(N253) );
  INVXL U41 ( .A(scan_loc_y[4]), .Y(n35) );
  NAND2XL U42 ( .A(n57), .B(n35), .Y(n34) );
  NAND2XL U43 ( .A(scan_loc_x[2]), .B(n54), .Y(n43) );
  NAND2XL U44 ( .A(scan_loc_y[2]), .B(n57), .Y(n42) );
  NAND2XL U45 ( .A(scan_loc_y[2]), .B(scan_loc_y[3]), .Y(n6) );
  NAND2XL U46 ( .A(scan_loc_x[2]), .B(scan_loc_x[3]), .Y(n7) );
  INVXL U47 ( .A(n7), .Y(n8) );
  OAI21XL U48 ( .A0(scan_loc_x[4]), .A1(n8), .B0(n54), .Y(n4) );
  INVXL U49 ( .A(n6), .Y(n5) );
  OAI222XL U50 ( .A0(n35), .A1(n57), .B0(n35), .B1(n6), .C0(n5), .C1(n34), .Y(
        N297) );
  OR4X1 U51 ( .A(state[3]), .B(state[0]), .C(state[1]), .D(n10), .Y(n48) );
  NOR2XL U52 ( .A(n520), .B(n48), .Y(N50) );
  NAND2XL U53 ( .A(state[0]), .B(state[1]), .Y(n12) );
  NAND2XL U54 ( .A(n25), .B(n16), .Y(n30) );
  NOR2XL U55 ( .A(n30), .B(n48), .Y(n44) );
  INVXL U56 ( .A(n44), .Y(n11) );
  OAI31XL U57 ( .A0(state[3]), .A1(state[2]), .A2(n12), .B0(n11), .Y(n46) );
  NAND2XL U58 ( .A(n44), .B(n54), .Y(n47) );
  OAI21XL U59 ( .A0(n54), .A1(n46), .B0(n47), .Y(N59) );
  INVXL U60 ( .A(intadd_0_SUM_0_), .Y(N245) );
  INVXL U61 ( .A(intadd_0_SUM_1_), .Y(N246) );
  INVXL U62 ( .A(intadd_0_SUM_2_), .Y(N247) );
  INVXL U63 ( .A(intadd_0_SUM_3_), .Y(N248) );
  INVXL U64 ( .A(intadd_1_SUM_0_), .Y(N252) );
  INVXL U65 ( .A(intadd_1_SUM_2_), .Y(N254) );
  NAND2XL U66 ( .A(scan_loc_y[1]), .B(n57), .Y(intadd_1_B_0_) );
  OA21X1 U67 ( .A0(scan_loc_y[1]), .A1(n57), .B0(intadd_1_B_0_), .Y(n37) );
  NOR2XL U68 ( .A(n530), .B(n500), .Y(n49) );
  NOR2XL U69 ( .A(n49), .B(n55), .Y(n29) );
  AOI21XL U70 ( .A0(n25), .A1(n55), .B0(n29), .Y(n40) );
  INVXL U71 ( .A(n500), .Y(n31) );
  INVXL U72 ( .A(scan_loc_x[3]), .Y(intadd_0_A_3_) );
  INVXL U73 ( .A(scan_loc_y[2]), .Y(intadd_1_A_1_) );
  INVXL U74 ( .A(scan_loc_y[3]), .Y(intadd_1_A_2_) );
  NAND2XL U75 ( .A(n17), .B(n36), .Y(n33) );
  NOR2XL U76 ( .A(rotate_cnt_2_), .B(n33), .Y(n23) );
  AOI22XL U77 ( .A0(n36), .A1(n25), .B0(n23), .B1(n55), .Y(n28) );
  INVXL U78 ( .A(n23), .Y(n24) );
  OR2XL U79 ( .A(n25), .B(n32), .Y(n26) );
  NOR3BXL U80 ( .AN(n30), .B(n29), .C(n48), .Y(N53) );
  NOR3BXL U81 ( .AN(n33), .B(n31), .C(n48), .Y(N51) );
  OA21X1 U82 ( .A0(n35), .A1(n57), .B0(n34), .Y(intadd_1_B_2_) );
  AO21XL U83 ( .A0(n38), .A1(n37), .B0(intadd_1_CI), .Y(N251) );
  ADDFX1 U84 ( .A(scan_loc_y[0]), .B(n40), .CI(n39), .CO(n38), .S(N250) );
  OA21X1 U85 ( .A0(n41), .A1(scan_loc_x[0]), .B0(intadd_0_CI), .Y(N244) );
  NOR2XL U86 ( .A(rotation_type[0]), .B(rotation_type[1]), .Y(loc_wrong) );
  OA21X1 U87 ( .A0(scan_loc_y[2]), .A1(n57), .B0(n42), .Y(N295) );
  OA21X1 U88 ( .A0(scan_loc_x[2]), .A1(n54), .B0(n43), .Y(N289) );
  NAND2XL U89 ( .A(n44), .B(rotation_type[0]), .Y(n45) );
  AOI211XL U90 ( .A0(n530), .A1(n500), .B0(n49), .C0(n48), .Y(N52) );
  BUFX2 U4 ( .A(srst_n), .Y(n590) );
  BUFX2 U3 ( .A(srst_n), .Y(n58) );
  XNOR2XL U5 ( .A(scan_loc_x[5]), .B(n4), .Y(N292) );
  XNOR2XL U6 ( .A(n34), .B(n1), .Y(N255) );
endmodule


module SNPS_CLOCK_GATE_HIGH_LOC_CORRECT ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7323;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7323) );
  AND2XL main_gate ( .A(net7323), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_LOC_CORRECT_mydesign_0 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7323;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7323) );
  AND2XL main_gate ( .A(net7323), .B(CLK), .Y(ENCLK) );
endmodule


module LOC_CORRECT ( clk, srst_n, sram_rdata, state, loc_x, loc_y, loc_raddr, 
        correct_loc_x, loc_complete );
  input [3:0] state;
  input [5:0] loc_x;
  input [5:0] loc_y;
  output [11:0] loc_raddr;
  output [5:0] correct_loc_x;
  input clk, srst_n, sram_rdata;
  output loc_complete;
  wire   N57, N58, N59, N60, N61, N62, N103, N104, N105, N106, N107, N108,
         N109, N110, N111, N112, N113, N114, net7329, net7330, net7331,
         net7332, net7333, net7336, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10,
         n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24,
         n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38,
         n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52,
         n53, n54, n55, n56, n570, n580, n590, n600, n610, n620, n63, n64, n65,
         n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79,
         n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n1030, n1040, n1050,
         n1060, n1070, n1080, n1090, n1100, n1110;
  wire   [3:0] loc_cnt;

  DFFTRXL loc_cnt_reg_0_ ( .D(srst_n), .RN(net7333), .CK(net7336), .Q(
        loc_cnt[0]), .QN(n100) );
  DFFTRXL loc_cnt_reg_1_ ( .D(srst_n), .RN(net7332), .CK(net7336), .Q(
        loc_cnt[1]), .QN(n99) );
  DFFTRXL loc_cnt_reg_2_ ( .D(srst_n), .RN(net7331), .CK(net7336), .Q(
        loc_cnt[2]), .QN(n98) );
  DFFTRXL correct_loc_x_reg_0_ ( .D(n1040), .RN(N57), .CK(n1100), .Q(
        correct_loc_x[0]), .QN(n1030) );
  DFFTRXL correct_loc_x_reg_1_ ( .D(n1050), .RN(N58), .CK(n1100), .Q(
        correct_loc_x[1]) );
  DFFTRXL correct_loc_x_reg_2_ ( .D(n1060), .RN(N59), .CK(n1100), .Q(
        correct_loc_x[2]), .QN(n101) );
  DFFTRXL correct_loc_x_reg_3_ ( .D(n1070), .RN(N60), .CK(n1100), .Q(
        correct_loc_x[3]), .QN(n102) );
  DFFTRXL correct_loc_x_reg_4_ ( .D(n1080), .RN(N61), .CK(n1100), .Q(
        correct_loc_x[4]), .QN(n12) );
  DFFTRXL correct_loc_x_reg_5_ ( .D(n1090), .RN(N62), .CK(n1100), .Q(
        correct_loc_x[5]), .QN(n13) );
  DFFTRXL loc_raddr_reg_11_ ( .D(srst_n), .RN(N114), .CK(clk), .Q(
        loc_raddr[11]) );
  DFFTRXL loc_raddr_reg_10_ ( .D(srst_n), .RN(N113), .CK(clk), .Q(
        loc_raddr[10]) );
  DFFTRXL loc_raddr_reg_9_ ( .D(srst_n), .RN(N112), .CK(clk), .Q(loc_raddr[9])
         );
  DFFTRXL loc_raddr_reg_8_ ( .D(srst_n), .RN(N111), .CK(clk), .Q(loc_raddr[8])
         );
  DFFTRXL loc_raddr_reg_7_ ( .D(srst_n), .RN(N110), .CK(clk), .Q(loc_raddr[7])
         );
  DFFTRXL loc_raddr_reg_6_ ( .D(srst_n), .RN(N109), .CK(clk), .Q(loc_raddr[6])
         );
  DFFTRXL loc_raddr_reg_5_ ( .D(srst_n), .RN(N108), .CK(clk), .Q(loc_raddr[5])
         );
  DFFTRXL loc_raddr_reg_4_ ( .D(srst_n), .RN(N107), .CK(clk), .Q(loc_raddr[4])
         );
  DFFTRXL loc_raddr_reg_3_ ( .D(srst_n), .RN(N106), .CK(clk), .Q(loc_raddr[3])
         );
  DFFTRXL loc_raddr_reg_2_ ( .D(srst_n), .RN(N105), .CK(clk), .Q(loc_raddr[2])
         );
  DFFTRXL loc_raddr_reg_1_ ( .D(srst_n), .RN(N104), .CK(clk), .Q(loc_raddr[1])
         );
  DFFTRXL loc_raddr_reg_0_ ( .D(srst_n), .RN(N103), .CK(clk), .Q(loc_raddr[0])
         );
  DFFTRXL loc_cnt_reg_3_ ( .D(srst_n), .RN(net7330), .CK(net7336), .Q(
        loc_cnt[3]), .QN(n97) );
  OAI2BB1XL U4 ( .A0N(n87), .A1N(correct_loc_x[2]), .B0(n70), .Y(N59) );
  OAI2BB1X1 U5 ( .A0N(n87), .A1N(correct_loc_x[4]), .B0(n80), .Y(N61) );
  OAI2BB1X1 U6 ( .A0N(n87), .A1N(correct_loc_x[3]), .B0(n86), .Y(N60) );
  OAI2BB1X1 U7 ( .A0N(n87), .A1N(correct_loc_x[0]), .B0(n590), .Y(N57) );
  NOR2BX1 U8 ( .AN(correct_loc_x[5]), .B(n71), .Y(n94) );
  OR2X1 U10 ( .A(n29), .B(n56), .Y(n83) );
  OAI211X1 U11 ( .A0(loc_cnt[3]), .A1(loc_cnt[0]), .B0(n37), .C0(n36), .Y(n49)
         );
  INVX1 U12 ( .A(srst_n), .Y(n85) );
  OAI21XL U13 ( .A0(loc_cnt[3]), .A1(n23), .B0(n64), .Y(n22) );
  NAND2XL U14 ( .A(loc_cnt[3]), .B(n23), .Y(n20) );
  NAND2BXL U15 ( .AN(n102), .B(n10), .Y(n6) );
  NAND3XL U16 ( .A(correct_loc_x[3]), .B(n8), .C(n1), .Y(n7) );
  OAI21XL U17 ( .A0(n600), .A1(n11), .B0(n66), .Y(n10) );
  INVXL U18 ( .A(n65), .Y(n11) );
  NAND2XL U19 ( .A(n8), .B(n1), .Y(n5) );
  NAND2XL U20 ( .A(n8), .B(n3), .Y(n9) );
  OR2XL U21 ( .A(correct_loc_x[2]), .B(n29), .Y(n65) );
  OR2XL U22 ( .A(correct_loc_x[1]), .B(n29), .Y(n3) );
  NAND2XL U23 ( .A(correct_loc_x[1]), .B(n29), .Y(n600) );
  NOR2XL U24 ( .A(n95), .B(n52), .Y(n56) );
  OR2XL U25 ( .A(n27), .B(n28), .Y(n2) );
  NOR2BXL U26 ( .AN(n17), .B(state[0]), .Y(n84) );
  AOI22XL U27 ( .A0(correct_loc_x[1]), .A1(n44), .B0(n48), .B1(n38), .Y(n46)
         );
  NOR2XL U28 ( .A(n102), .B(n50), .Y(n72) );
  NAND2XL U29 ( .A(correct_loc_x[4]), .B(n72), .Y(n71) );
  AND2XL U30 ( .A(n92), .B(loc_y[1]), .Y(n91) );
  NAND2XL U31 ( .A(loc_cnt[1]), .B(loc_cnt[0]), .Y(n74) );
  NAND2XL U32 ( .A(n53), .B(n52), .Y(n75) );
  AND2XL U33 ( .A(n65), .B(n3), .Y(n1) );
  NOR2XL U34 ( .A(n18), .B(n95), .Y(n29) );
  NAND2XL U35 ( .A(n98), .B(n55), .Y(n23) );
  NOR3XL U36 ( .A(state[1]), .B(state[3]), .C(n14), .Y(n17) );
  INVXL U37 ( .A(state[1]), .Y(n15) );
  AOI22XL U38 ( .A0(correct_loc_x[2]), .A1(n41), .B0(n45), .B1(n40), .Y(n50)
         );
  NOR2XL U39 ( .A(n51), .B(n90), .Y(n89) );
  AOI22XL U40 ( .A0(loc_x[4]), .A1(n84), .B0(n83), .B1(n79), .Y(n80) );
  AOI22XL U41 ( .A0(loc_x[3]), .A1(n84), .B0(n83), .B1(n82), .Y(n86) );
  NOR2XL U42 ( .A(n10), .B(n4), .Y(n81) );
  AOI22XL U43 ( .A0(loc_x[2]), .A1(n84), .B0(n83), .B1(n69), .Y(n70) );
  OAI21XL U44 ( .A0(n9), .A1(n28), .B0(n600), .Y(n67) );
  AOI22XL U45 ( .A0(loc_x[1]), .A1(n84), .B0(n83), .B1(n620), .Y(n63) );
  AOI22XL U46 ( .A0(loc_x[0]), .A1(n84), .B0(n83), .B1(n580), .Y(n590) );
  AND2XL U47 ( .A(n2), .B(n570), .Y(n580) );
  NAND2XL U48 ( .A(srst_n), .B(n87), .Y(n1110) );
  XNOR2X1 U49 ( .A(n44), .B(n43), .Y(N104) );
  XNOR2X1 U50 ( .A(correct_loc_x[1]), .B(n48), .Y(n43) );
  XNOR2X1 U51 ( .A(n47), .B(n46), .Y(N105) );
  XNOR2X1 U52 ( .A(n101), .B(n45), .Y(n47) );
  XNOR2X1 U53 ( .A(correct_loc_x[5]), .B(n71), .Y(N108) );
  XNOR2X1 U54 ( .A(loc_y[5]), .B(n88), .Y(N114) );
  NAND2XL U55 ( .A(correct_loc_x[5]), .B(n87), .Y(n32) );
  NOR2XL U56 ( .A(n85), .B(n63), .Y(n1050) );
  NOR2XL U57 ( .A(n85), .B(n590), .Y(n1040) );
  NOR3XL U58 ( .A(n55), .B(n54), .C(n75), .Y(net7332) );
  NOR2XL U59 ( .A(loc_cnt[0]), .B(n75), .Y(net7333) );
  INVXL U60 ( .A(n27), .Y(n8) );
  NOR4XL U61 ( .A(state[3]), .B(state[2]), .C(n16), .D(n15), .Y(n96) );
  INVXL U62 ( .A(state[2]), .Y(n14) );
  NOR2XL U63 ( .A(n5), .B(n28), .Y(n4) );
  OAI21XL U64 ( .A0(n7), .A1(n28), .B0(n6), .Y(n78) );
  AOI22XL U65 ( .A0(loc_x[5]), .A1(n84), .B0(n83), .B1(n31), .Y(n73) );
  XOR2XL U66 ( .A(n102), .B(n81), .Y(n82) );
  NAND2XL U67 ( .A(n91), .B(loc_y[2]), .Y(n90) );
  NOR2XL U68 ( .A(loc_cnt[1]), .B(loc_cnt[0]), .Y(n55) );
  AOI21XL U69 ( .A0(n50), .A1(n102), .B0(n72), .Y(N106) );
  NOR2XL U70 ( .A(n85), .B(n70), .Y(n1060) );
  INVXL U71 ( .A(state[0]), .Y(n16) );
  NAND2XL U72 ( .A(loc_cnt[1]), .B(loc_cnt[2]), .Y(n37) );
  NOR2XL U73 ( .A(n97), .B(n37), .Y(n19) );
  NAND2XL U74 ( .A(n100), .B(n19), .Y(n18) );
  NAND2XL U75 ( .A(state[0]), .B(n17), .Y(n95) );
  INVXL U76 ( .A(n19), .Y(n64) );
  NOR2XL U77 ( .A(n20), .B(sram_rdata), .Y(n21) );
  NOR2XL U78 ( .A(n22), .B(n21), .Y(n26) );
  INVXL U79 ( .A(n23), .Y(n24) );
  OAI21XL U80 ( .A0(n24), .A1(n97), .B0(sram_rdata), .Y(n25) );
  NAND2XL U81 ( .A(n26), .B(n25), .Y(n52) );
  NOR3X1 U82 ( .A(n84), .B(n96), .C(n83), .Y(n87) );
  INVXL U83 ( .A(n26), .Y(n28) );
  OR2XL U84 ( .A(n1030), .B(n95), .Y(n27) );
  NAND2XL U85 ( .A(correct_loc_x[2]), .B(n29), .Y(n66) );
  NAND2BXL U86 ( .AN(n12), .B(n78), .Y(n30) );
  XOR2XL U87 ( .A(n13), .B(n30), .Y(n31) );
  NAND2XL U88 ( .A(n32), .B(n73), .Y(N62) );
  NAND2XL U89 ( .A(loc_cnt[3]), .B(loc_cnt[0]), .Y(n36) );
  NOR2XL U90 ( .A(loc_cnt[3]), .B(loc_cnt[0]), .Y(n33) );
  NOR2XL U91 ( .A(n33), .B(n98), .Y(n35) );
  NOR2XL U92 ( .A(n97), .B(n74), .Y(n34) );
  AOI211XL U93 ( .A0(n99), .A1(n36), .B0(n35), .C0(n34), .Y(n44) );
  NOR2XL U94 ( .A(n1030), .B(n49), .Y(n48) );
  OR2XL U95 ( .A(correct_loc_x[1]), .B(n44), .Y(n38) );
  INVXL U96 ( .A(n46), .Y(n41) );
  AOI211XL U97 ( .A0(n99), .A1(n100), .B0(n97), .C0(n98), .Y(n42) );
  NOR2XL U98 ( .A(loc_cnt[3]), .B(n74), .Y(n39) );
  AOI211XL U99 ( .A0(n98), .A1(n74), .B0(n42), .C0(n39), .Y(n45) );
  NAND2XL U100 ( .A(n101), .B(n46), .Y(n40) );
  INVXL U101 ( .A(loc_y[3]), .Y(n51) );
  NOR2XL U102 ( .A(n98), .B(n74), .Y(n77) );
  NOR2XL U103 ( .A(n77), .B(loc_cnt[3]), .Y(n76) );
  NOR2XL U104 ( .A(n76), .B(n42), .Y(n93) );
  NAND2XL U105 ( .A(n89), .B(loc_y[4]), .Y(n88) );
  AOI21XL U106 ( .A0(n1030), .A1(n49), .B0(n48), .Y(N103) );
  AOI21XL U107 ( .A0(n90), .A1(n51), .B0(n89), .Y(N112) );
  INVXL U108 ( .A(n95), .Y(n53) );
  INVXL U109 ( .A(n74), .Y(n54) );
  OR2XL U110 ( .A(correct_loc_x[0]), .B(n56), .Y(n570) );
  NAND2XL U111 ( .A(n600), .B(n3), .Y(n610) );
  XOR2XL U112 ( .A(n610), .B(n2), .Y(n620) );
  NOR2XL U113 ( .A(n100), .B(n64), .Y(loc_complete) );
  NAND2XL U114 ( .A(n66), .B(n65), .Y(n68) );
  OA21X1 U115 ( .A0(correct_loc_x[4]), .A1(n72), .B0(n71), .Y(N107) );
  NOR2XL U116 ( .A(n85), .B(n73), .Y(n1090) );
  AOI211XL U117 ( .A0(n98), .A1(n74), .B0(n77), .C0(n75), .Y(net7331) );
  AOI211XL U118 ( .A0(loc_cnt[3]), .A1(n77), .B0(n76), .C0(n75), .Y(net7330)
         );
  XOR2XL U119 ( .A(correct_loc_x[4]), .B(n78), .Y(n79) );
  NOR2XL U120 ( .A(n85), .B(n80), .Y(n1080) );
  NOR2XL U121 ( .A(n85), .B(n86), .Y(n1070) );
  OA21X1 U122 ( .A0(n89), .A1(loc_y[4]), .B0(n88), .Y(N113) );
  OA21X1 U123 ( .A0(n91), .A1(loc_y[2]), .B0(n90), .Y(N111) );
  AOI2BB1XL U124 ( .A0N(n92), .A1N(loc_y[1]), .B0(n91), .Y(N110) );
  ADDFX1 U125 ( .A(loc_y[0]), .B(n94), .CI(n93), .CO(n92), .S(N109) );
  NAND3BXL U126 ( .AN(n96), .B(srst_n), .C(n95), .Y(net7329) );
  SNPS_CLOCK_GATE_HIGH_LOC_CORRECT clk_gate_loc_cnt_reg ( .CLK(clk), .EN(
        net7329), .ENCLK(net7336) );
  SNPS_CLOCK_GATE_HIGH_LOC_CORRECT_mydesign_0 clk_gate_correct_loc_x_reg ( 
        .CLK(clk), .EN(n1110), .ENCLK(n1100) );
  XNOR2XL U3 ( .A(n68), .B(n67), .Y(n69) );
  OAI2BB1XL U9 ( .A0N(n87), .A1N(correct_loc_x[1]), .B0(n63), .Y(N58) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_0 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_10 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_9 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_8 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_7 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_6 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_5 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_4 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_3 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_2 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_1 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7251;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7251) );
  AND2XL main_gate ( .A(net7251), .B(CLK), .Y(ENCLK) );
endmodule


module SCANNING ( clk, srst_n, state, sram_rdata, decode_complete, gold_loc_y, 
        gold_loc_x, x_lower, y_lower, x_upper, y_upper, rotation_type, 
        pre_scan_complete, loc_complete, qr_total, correct_loc_x, scan_raddr, 
        scan_complete, loc_y, loc_x, end_of_file );
  input [3:0] state;
  input [5:0] gold_loc_y;
  input [5:0] gold_loc_x;
  input [5:0] x_lower;
  input [5:0] y_lower;
  input [5:0] x_upper;
  input [5:0] y_upper;
  input [1:0] rotation_type;
  input [2:0] qr_total;
  input [5:0] correct_loc_x;
  output [11:0] scan_raddr;
  output [5:0] loc_y;
  output [5:0] loc_x;
  input clk, srst_n, sram_rdata, decode_complete, pre_scan_complete,
         loc_complete;
  output scan_complete, end_of_file;
  wire   n_Logic0_, N59, N60, N61, N62, N65, N66, N67, N68, N284, N285, N286,
         N287, N288, N289, N294, N295, N296, N297, N298, N299, N305, N306,
         N307, N308, N309, N310, N311, N312, N313, N314, N315, N316, N432,
         N433, net7254, net7257, net7262, net7265, net7268, net7273, net7276,
         net7279, net7284, net7287, net7291, net7294, net7297, net7300,
         net7303, net7308, net7311, net7314, n104, n105, n107, n108, n110,
         n111, n162, n165, n169, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11,
         n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25,
         n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39,
         n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51, n52, n53,
         n54, n55, n56, n57, n58, n590, n600, n610, n620, n63, n64, n650, n660,
         n670, n680, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78, n79,
         n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92, n93,
         n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n106, n109,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146, n147, n148, n149, n150, n151, n152, n153, n154, n155,
         n156, n157, n158, n159, n160, n161, n163, n164, n166, n167, n168,
         n170, n171, n172, n173, n174, n175, n176, n177, n178, n179, n180,
         n181, n182, n183, n184, n185, n186, n187, n188, n189, n190, n191,
         n192, n193, n194, n195, n196, n197, n198, n199, n200, n201, n202,
         n203, n204, n205, n206, n207, n208, n209, n210, n211, n212, n213,
         n214, n215, n216, n217, n218, n219, n220, n221, n222, n223, n224,
         n225, n226, n227, n228, n229, n230, n231, n232, n233, n234, n235,
         n236, n237, n238, n239, n240, n241, n242, n243, n244, n245, n246,
         n247, n248, n249, n250, n251, n252, n253, n254, n255, n256, n257,
         n258, n259, n260, n261, n262, n263, n264, n265, n266, n267, n268,
         n269, n270, n271, n272, n273, n274, n275, n276, n277, n278, n279,
         n280, n281, n282, n283, n2840, n2850, n2860, n2870, n2880, n2890,
         n290, n291, n292, n293, n2940, n2950, n2960, n2970, n2980, n2990,
         n300, n301, n302, n303, n304, n3050, n3060, n3070, n3080, n3090,
         n3100, n3110, n3120, n3130, n3140;
  wire   [5:0] pre_loc_x1;
  wire   [5:0] pre_loc_y1;
  wire   [5:0] pre_loc_x2;
  wire   [5:0] pre_loc_y2;
  wire   [5:0] pre_loc_x3;
  wire   [5:0] pre_loc_y3;

  DFFTRXL current_x_reg_0_ ( .D(n3090), .RN(N284), .CK(net7291), .Q(N305), 
        .QN(n111) );
  DFFTRXL current_x_reg_1_ ( .D(n3120), .RN(N285), .CK(net7291), .Q(N306), 
        .QN(n110) );
  DFFTRXL current_x_reg_2_ ( .D(n3120), .RN(N286), .CK(net7291), .Q(N307), 
        .QN(n107) );
  DFFTRXL current_x_reg_3_ ( .D(n3120), .RN(N287), .CK(net7291), .Q(N308), 
        .QN(n108) );
  DFFTRXL current_x_reg_4_ ( .D(n3120), .RN(N288), .CK(net7291), .Q(N309), 
        .QN(n104) );
  DFFTRXL current_x_reg_5_ ( .D(n3120), .RN(N289), .CK(net7291), .Q(N310), 
        .QN(n105) );
  SMDFFHQX1 current_y_reg_5_ ( .D0(N298), .D1(y_lower[5]), .SI(n_Logic0_), 
        .S0(pre_scan_complete), .SE(n3130), .CK(net7297), .Q(N316) );
  SMDFFHQX1 current_y_reg_4_ ( .D0(N297), .D1(y_lower[4]), .SI(n_Logic0_), 
        .S0(pre_scan_complete), .SE(n3140), .CK(net7297), .Q(N315) );
  SMDFFHQX1 current_y_reg_3_ ( .D0(N296), .D1(y_lower[3]), .SI(n_Logic0_), 
        .S0(pre_scan_complete), .SE(n3140), .CK(net7297), .Q(N314) );
  SMDFFHQX1 current_y_reg_2_ ( .D0(N295), .D1(y_lower[2]), .SI(n_Logic0_), 
        .S0(pre_scan_complete), .SE(n3140), .CK(net7297), .Q(N313) );
  SMDFFHQX1 current_y_reg_1_ ( .D0(N294), .D1(y_lower[1]), .SI(n_Logic0_), 
        .S0(pre_scan_complete), .SE(n3140), .CK(net7297), .Q(N312) );
  DFFTRXL scan_raddr_reg_11_ ( .D(n3120), .RN(N316), .CK(clk), .Q(
        scan_raddr[11]), .QN(n3050) );
  DFFTRXL scan_raddr_reg_10_ ( .D(n3120), .RN(N315), .CK(clk), .Q(
        scan_raddr[10]), .QN(n2960) );
  DFFTRXL scan_raddr_reg_9_ ( .D(n3120), .RN(N314), .CK(clk), .Q(scan_raddr[9]), .QN(n2940) );
  DFFTRXL scan_raddr_reg_8_ ( .D(n3120), .RN(N313), .CK(clk), .Q(scan_raddr[8]), .QN(n291) );
  DFFTRXL scan_raddr_reg_7_ ( .D(n3120), .RN(N312), .CK(clk), .Q(scan_raddr[7]), .QN(n281) );
  DFFTRXL scan_raddr_reg_6_ ( .D(n3120), .RN(N311), .CK(clk), .Q(scan_raddr[6]), .QN(n303) );
  DFFTRXL scan_raddr_reg_5_ ( .D(n3120), .RN(N310), .CK(clk), .Q(scan_raddr[5]) );
  DFFTRXL scan_raddr_reg_4_ ( .D(n3120), .RN(N309), .CK(clk), .Q(scan_raddr[4]), .QN(n2990) );
  DFFTRXL scan_raddr_reg_3_ ( .D(n3120), .RN(N308), .CK(clk), .Q(scan_raddr[3]), .QN(n2970) );
  DFFTRXL scan_raddr_reg_2_ ( .D(n3120), .RN(N307), .CK(clk), .Q(scan_raddr[2]), .QN(n283) );
  DFFTRXL scan_raddr_reg_1_ ( .D(n3120), .RN(N306), .CK(clk), .Q(scan_raddr[1]), .QN(n2890) );
  DFFTRXL scan_raddr_reg_0_ ( .D(n3120), .RN(N305), .CK(clk), .Q(scan_raddr[0]), .QN(n282) );
  DFFTRXL qr_num_reg_1_ ( .D(n3110), .RN(N432), .CK(net7314), .Q(n302), .QN(
        n165) );
  DFFTRXL qr_num_reg_2_ ( .D(n3110), .RN(N433), .CK(net7314), .Q(n304), .QN(
        n162) );
  DFFTRXL pre_loc_y2_reg_5_ ( .D(n3110), .RN(N68), .CK(net7273), .Q(
        pre_loc_y2[5]) );
  DFFTRXL pre_loc_y2_reg_4_ ( .D(n3110), .RN(N67), .CK(net7273), .Q(
        pre_loc_y2[4]), .QN(n292) );
  DFFTRXL pre_loc_y2_reg_3_ ( .D(n3110), .RN(N66), .CK(net7273), .Q(
        pre_loc_y2[3]), .QN(n2880) );
  DFFTRXL pre_loc_y2_reg_2_ ( .D(n3110), .RN(N65), .CK(net7273), .Q(
        pre_loc_y2[2]), .QN(n2860) );
  DFFTRXL pre_loc_x2_reg_5_ ( .D(n3110), .RN(N62), .CK(net7268), .Q(
        pre_loc_x2[5]) );
  DFFTRXL pre_loc_x2_reg_4_ ( .D(n3110), .RN(N61), .CK(net7268), .Q(
        pre_loc_x2[4]) );
  DFFTRXL pre_loc_x2_reg_3_ ( .D(n3110), .RN(N60), .CK(net7268), .Q(
        pre_loc_x2[3]) );
  DFFTRXL pre_loc_x2_reg_2_ ( .D(n3110), .RN(N59), .CK(net7268), .Q(
        pre_loc_x2[2]) );
  DFFTRXL pre_loc_y1_reg_5_ ( .D(n3110), .RN(N68), .CK(net7262), .Q(
        pre_loc_y1[5]) );
  DFFTRXL pre_loc_y1_reg_4_ ( .D(n3110), .RN(N67), .CK(net7262), .Q(
        pre_loc_y1[4]), .QN(n3060) );
  DFFTRXL pre_loc_y1_reg_3_ ( .D(n3110), .RN(N66), .CK(net7262), .Q(
        pre_loc_y1[3]), .QN(n2) );
  DFFTRXL pre_loc_y1_reg_2_ ( .D(n3110), .RN(N65), .CK(net7262), .Q(
        pre_loc_y1[2]), .QN(n1) );
  DFFTRXL pre_loc_y1_reg_1_ ( .D(n3100), .RN(gold_loc_y[1]), .CK(net7262), .Q(
        pre_loc_y1[1]), .QN(n3) );
  DFFTRXL pre_loc_y1_reg_0_ ( .D(n3100), .RN(gold_loc_y[0]), .CK(net7262), .Q(
        pre_loc_y1[0]) );
  DFFTRXL pre_loc_x1_reg_5_ ( .D(n3100), .RN(N62), .CK(net7257), .Q(
        pre_loc_x1[5]) );
  DFFTRXL pre_loc_x1_reg_4_ ( .D(n3100), .RN(N61), .CK(net7257), .Q(
        pre_loc_x1[4]), .QN(n301) );
  DFFTRXL pre_loc_x1_reg_3_ ( .D(n3100), .RN(N60), .CK(net7257), .Q(
        pre_loc_x1[3]) );
  DFFTRXL pre_loc_x1_reg_2_ ( .D(n3100), .RN(N59), .CK(net7257), .Q(
        pre_loc_x1[2]), .QN(n2980) );
  DFFTRXL pre_loc_y3_reg_5_ ( .D(n3100), .RN(N68), .CK(net7284), .Q(
        pre_loc_y3[5]) );
  DFFTRXL pre_loc_y3_reg_4_ ( .D(n3100), .RN(N67), .CK(net7284), .Q(
        pre_loc_y3[4]), .QN(n2950) );
  DFFTRXL pre_loc_y3_reg_3_ ( .D(n3100), .RN(N66), .CK(net7284), .Q(
        pre_loc_y3[3]), .QN(n290) );
  DFFTRXL pre_loc_y3_reg_2_ ( .D(n3100), .RN(N65), .CK(net7284), .Q(
        pre_loc_y3[2]), .QN(n2870) );
  DFFTRXL pre_loc_x3_reg_5_ ( .D(n3100), .RN(N62), .CK(net7279), .Q(
        pre_loc_x3[5]) );
  DFFTRXL pre_loc_x3_reg_4_ ( .D(n3100), .RN(N61), .CK(net7279), .Q(
        pre_loc_x3[4]) );
  DFFTRXL pre_loc_x3_reg_3_ ( .D(n3100), .RN(N60), .CK(net7279), .Q(
        pre_loc_x3[3]) );
  DFFTRXL pre_loc_x3_reg_2_ ( .D(n3100), .RN(N59), .CK(net7279), .Q(
        pre_loc_x3[2]) );
  DFFTRXL loc_x_reg_5_ ( .D(n3100), .RN(scan_raddr[5]), .CK(net7308), .Q(
        loc_x[5]) );
  DFFTRXL loc_x_reg_4_ ( .D(n3090), .RN(scan_raddr[4]), .CK(net7308), .Q(
        loc_x[4]) );
  DFFTRXL loc_x_reg_3_ ( .D(n3090), .RN(scan_raddr[3]), .CK(net7308), .Q(
        loc_x[3]) );
  DFFTRXL loc_x_reg_2_ ( .D(n3090), .RN(scan_raddr[2]), .CK(net7308), .Q(
        loc_x[2]) );
  DFFTRXL loc_x_reg_1_ ( .D(n3090), .RN(scan_raddr[1]), .CK(net7308), .Q(
        loc_x[1]) );
  DFFTRXL loc_x_reg_0_ ( .D(n3090), .RN(scan_raddr[0]), .CK(net7308), .Q(
        loc_x[0]) );
  DFFTRXL loc_y_reg_5_ ( .D(n3090), .RN(scan_raddr[11]), .CK(net7303), .Q(
        loc_y[5]) );
  DFFTRXL loc_y_reg_4_ ( .D(n3090), .RN(scan_raddr[10]), .CK(net7303), .Q(
        loc_y[4]) );
  DFFTRXL loc_y_reg_3_ ( .D(n3090), .RN(scan_raddr[9]), .CK(net7303), .Q(
        loc_y[3]) );
  DFFTRXL loc_y_reg_2_ ( .D(n3090), .RN(scan_raddr[8]), .CK(net7303), .Q(
        loc_y[2]) );
  DFFTRXL loc_y_reg_1_ ( .D(n3090), .RN(scan_raddr[7]), .CK(net7303), .Q(
        loc_y[1]) );
  DFFTRXL loc_y_reg_0_ ( .D(n3090), .RN(scan_raddr[6]), .CK(net7303), .Q(
        loc_y[0]) );
  DFFTRXL qr_num_reg_0_ ( .D(n3110), .RN(n169), .CK(net7314), .Q(n3080), .QN(
        n169) );
  DFFTRXL pre_loc_x3_reg_0_ ( .D(n3110), .RN(gold_loc_x[0]), .CK(net7279), .Q(
        pre_loc_x3[0]), .QN(n300) );
  DFFTRXL pre_loc_x3_reg_1_ ( .D(n3100), .RN(gold_loc_x[1]), .CK(net7279), .Q(
        pre_loc_x3[1]), .QN(n293) );
  DFFTRXL pre_loc_y3_reg_1_ ( .D(n3100), .RN(gold_loc_y[1]), .CK(net7284), .Q(
        pre_loc_y3[1]), .QN(n2850) );
  DFFTRXL pre_loc_y2_reg_1_ ( .D(n3110), .RN(gold_loc_y[1]), .CK(net7273), .Q(
        pre_loc_y2[1]), .QN(n2840) );
  DFFTRXL pre_loc_x1_reg_0_ ( .D(n3100), .RN(gold_loc_x[0]), .CK(net7257), .Q(
        pre_loc_x1[0]) );
  DFFTRXL pre_loc_x1_reg_1_ ( .D(n3100), .RN(gold_loc_x[1]), .CK(net7257), .Q(
        pre_loc_x1[1]) );
  DFFTRXL pre_loc_x2_reg_1_ ( .D(n3110), .RN(gold_loc_x[1]), .CK(net7268), .Q(
        pre_loc_x2[1]) );
  DFFTRXL pre_loc_x2_reg_0_ ( .D(n3110), .RN(gold_loc_x[0]), .CK(net7268), .Q(
        pre_loc_x2[0]) );
  DFFTRXL pre_loc_y3_reg_0_ ( .D(n3100), .RN(gold_loc_y[0]), .CK(net7284), .Q(
        pre_loc_y3[0]) );
  DFFTRXL pre_loc_y2_reg_0_ ( .D(n3110), .RN(gold_loc_y[0]), .CK(net7273), .Q(
        pre_loc_y2[0]) );
  DFFTRXL current_y_reg_0_ ( .D(n3120), .RN(N299), .CK(net7297), .Q(N311), 
        .QN(n3070) );
  AOI222X1 U6 ( .A0(n253), .A1(x_lower[1]), .B0(n252), .B1(correct_loc_x[1]), 
        .C0(n251), .C1(n231), .Y(n232) );
  NOR2BXL U10 ( .AN(pre_loc_y1[0]), .B(scan_raddr[6]), .Y(n96) );
  OAI221XL U11 ( .A0(pre_loc_x2[2]), .A1(n107), .B0(pre_loc_x2[5]), .B1(n105), 
        .C0(n213), .Y(n216) );
  NOR4XL U14 ( .A(n218), .B(n217), .C(n216), .D(n215), .Y(n219) );
  NOR4XL U16 ( .A(n198), .B(n197), .C(n196), .D(n195), .Y(n222) );
  OAI211XL U18 ( .A0(n89), .A1(n88), .B0(n87), .C0(n86), .Y(n90) );
  NOR2BXL U19 ( .AN(n178), .B(n177), .Y(n228) );
  OAI211XL U20 ( .A0(n136), .A1(pre_loc_x1[5]), .B0(n135), .C0(n134), .Y(n137)
         );
  AOI222XL U21 ( .A0(n253), .A1(x_lower[5]), .B0(n252), .B1(correct_loc_x[5]), 
        .C0(n251), .C1(n250), .Y(n254) );
  AOI222X1 U22 ( .A0(n253), .A1(x_lower[4]), .B0(n252), .B1(correct_loc_x[4]), 
        .C0(n251), .C1(n243), .Y(n244) );
  AOI222X1 U23 ( .A0(n253), .A1(x_lower[3]), .B0(n252), .B1(correct_loc_x[3]), 
        .C0(n251), .C1(n239), .Y(n240) );
  AOI222X1 U24 ( .A0(n253), .A1(x_lower[2]), .B0(n252), .B1(correct_loc_x[2]), 
        .C0(n251), .C1(n236), .Y(n237) );
  NAND2BXL U26 ( .AN(scan_complete), .B(n3090), .Y(net7300) );
  AOI211XL U27 ( .A0(n246), .A1(n141), .B0(n273), .C0(n140), .Y(scan_complete)
         );
  OAI21XL U28 ( .A0(n246), .A1(n278), .B0(n3090), .Y(net7254) );
  OAI211X1 U29 ( .A0(scan_raddr[5]), .A1(n33), .B0(n32), .C0(n31), .Y(n34) );
  AOI221X1 U31 ( .A0(pre_loc_x1[2]), .A1(n107), .B0(n2980), .B1(N307), .C0(
        n193), .Y(n194) );
  AOI32X1 U32 ( .A0(n125), .A1(n124), .A2(n123), .B0(n122), .B1(n124), .Y(n138) );
  OAI211X1 U35 ( .A0(n128), .A1(n114), .B0(n113), .C0(n112), .Y(n124) );
  OAI211X1 U36 ( .A0(n49), .A1(n48), .B0(n47), .C0(n46), .Y(n92) );
  NOR2BX1 U37 ( .AN(n187), .B(n186), .Y(n198) );
  NOR2BX1 U38 ( .AN(n168), .B(n167), .Y(n170) );
  OAI211XL U39 ( .A0(n45), .A1(n44), .B0(n43), .C0(n42), .Y(n47) );
  OAI211X1 U40 ( .A0(n109), .A1(n106), .B0(n103), .C0(n102), .Y(n113) );
  OAI211XL U41 ( .A0(scan_raddr[2]), .A1(n120), .B0(n119), .C0(n118), .Y(n123)
         );
  OAI211XL U42 ( .A0(n85), .A1(n84), .B0(n83), .C0(n82), .Y(n87) );
  AOI221X1 U43 ( .A0(n185), .A1(n184), .B0(n183), .B1(n184), .C0(n182), .Y(
        n186) );
  AOI221X1 U44 ( .A0(pre_loc_x3[1]), .A1(n110), .B0(n293), .B1(N306), .C0(n155), .Y(n173) );
  OAI211XL U45 ( .A0(qr_total[2]), .A1(n162), .B0(n269), .C0(n268), .Y(n270)
         );
  AOI221X1 U48 ( .A0(n165), .A1(qr_total[1]), .B0(qr_total[0]), .B1(n169), 
        .C0(n267), .Y(n269) );
  OAI211XL U50 ( .A0(pre_loc_x3[0]), .A1(n282), .B0(n13), .C0(n12), .Y(n14) );
  OAI211XL U51 ( .A0(pre_loc_x1[0]), .A1(n282), .B0(n117), .C0(n116), .Y(n119)
         );
  OAI211XL U52 ( .A0(pre_loc_x2[0]), .A1(n282), .B0(n53), .C0(n52), .Y(n54) );
  NOR2BX1 U53 ( .AN(n12), .B(n13), .Y(n11) );
  OAI2BB1X1 U54 ( .A0N(gold_loc_x[4]), .A1N(n145), .B0(n9), .Y(n10) );
  OAI221X1 U55 ( .A0(pre_loc_x1[0]), .A1(n111), .B0(pre_loc_x1[1]), .B1(n110), 
        .C0(n189), .Y(n196) );
  OAI221X1 U56 ( .A0(pre_loc_x1[3]), .A1(n108), .B0(pre_loc_x1[5]), .B1(n105), 
        .C0(n188), .Y(n197) );
  OAI211XL U57 ( .A0(pre_loc_x3[4]), .A1(n104), .B0(n157), .C0(n156), .Y(n171)
         );
  OAI221X1 U58 ( .A0(n104), .A1(x_upper[4]), .B0(n110), .B1(x_upper[1]), .C0(
        n147), .Y(n150) );
  OAI221X1 U59 ( .A0(n105), .A1(x_upper[5]), .B0(n108), .B1(x_upper[3]), .C0(
        n146), .Y(n151) );
  OAI221X1 U60 ( .A0(n107), .A1(pre_loc_x3[2]), .B0(n108), .B1(pre_loc_x3[3]), 
        .C0(n154), .Y(n155) );
  AOI2BB2XL U61 ( .B0(scan_raddr[5]), .B1(pre_loc_x2[5]), .A0N(pre_loc_x2[5]), 
        .A1N(scan_raddr[5]), .Y(n71) );
  OAI211XL U63 ( .A0(pre_loc_x1[3]), .A1(n2970), .B0(pre_loc_x1[2]), .C0(n283), 
        .Y(n132) );
  AOI221X1 U66 ( .A0(n21), .A1(n20), .B0(n19), .B1(n23), .C0(n18), .Y(n35) );
  XNOR2X1 U67 ( .A(scan_raddr[5]), .B(n127), .Y(n136) );
  AOI22XL U68 ( .A0(n228), .A1(n227), .B0(n226), .B1(n225), .Y(n233) );
  NAND2XL U69 ( .A(n224), .B(n223), .Y(n225) );
  NAND2BXL U70 ( .AN(N311), .B(pre_loc_y1[0]), .Y(n180) );
  AOI221X1 U71 ( .A0(n166), .A1(n164), .B0(n163), .B1(n164), .C0(n161), .Y(
        n167) );
  XNOR2X1 U72 ( .A(pre_loc_x1[2]), .B(n115), .Y(n120) );
  AOI22XL U73 ( .A0(n93), .A1(n92), .B0(n91), .B1(n90), .Y(n139) );
  AOI221X1 U74 ( .A0(n257), .A1(y_upper[3]), .B0(n256), .B1(y_upper[2]), .C0(
        n255), .Y(n265) );
  AOI221X1 U75 ( .A0(n260), .A1(y_upper[4]), .B0(n259), .B1(y_upper[5]), .C0(
        n258), .Y(n264) );
  AOI221X1 U76 ( .A0(n262), .A1(y_upper[1]), .B0(n3070), .B1(y_upper[0]), .C0(
        n261), .Y(n263) );
  NAND2XL U77 ( .A(n165), .B(n169), .Y(n246) );
  NOR2XL U78 ( .A(n235), .B(n110), .Y(n238) );
  INVXL U79 ( .A(n234), .Y(n235) );
  INVXL U80 ( .A(n245), .Y(n253) );
  NOR2XL U81 ( .A(pre_scan_complete), .B(n272), .Y(n252) );
  NOR3XL U82 ( .A(pre_scan_complete), .B(n266), .C(n273), .Y(n251) );
  INVXL U83 ( .A(n3130), .Y(n3100) );
  INVX2 U84 ( .A(n3140), .Y(n3090) );
  XOR2XL U85 ( .A(pre_loc_y1[5]), .B(n192), .Y(n193) );
  XOR2XL U86 ( .A(pre_loc_y2[5]), .B(n211), .Y(n218) );
  XNOR2X1 U87 ( .A(pre_loc_y3[5]), .B(n27), .Y(n29) );
  OAI21XL U88 ( .A0(n302), .A1(n222), .B0(n199), .Y(n223) );
  NOR2XL U89 ( .A(n169), .B(n304), .Y(n199) );
  NAND2XL U90 ( .A(n220), .B(n219), .Y(n221) );
  NAND2BXL U91 ( .AN(n208), .B(n207), .Y(n220) );
  AOI221X1 U92 ( .A0(n205), .A1(n204), .B0(n203), .B1(n204), .C0(n202), .Y(
        n208) );
  XOR2XL U93 ( .A(pre_loc_y3[5]), .B(n176), .Y(n177) );
  XNOR2X1 U94 ( .A(N316), .B(n175), .Y(n176) );
  AOI221X1 U95 ( .A0(n63), .A1(n620), .B0(n610), .B1(n600), .C0(n590), .Y(n74)
         );
  AOI21XL U96 ( .A0(n152), .A1(n266), .B0(pre_scan_complete), .Y(n245) );
  NAND2XL U97 ( .A(n162), .B(decode_complete), .Y(n278) );
  NOR2XL U98 ( .A(n242), .B(n108), .Y(n247) );
  INVXL U99 ( .A(n241), .Y(n242) );
  OAI22XL U100 ( .A0(n165), .A1(n139), .B0(n138), .B1(n137), .Y(n141) );
  NAND2XL U101 ( .A(n271), .B(n270), .Y(end_of_file) );
  NAND2XL U102 ( .A(n3090), .B(n245), .Y(net7294) );
  XNOR2X1 U103 ( .A(gold_loc_x[5]), .B(n10), .Y(N62) );
  XNOR2X1 U104 ( .A(gold_loc_y[4]), .B(n5), .Y(N67) );
  XNOR2X1 U105 ( .A(n162), .B(n4), .Y(N433) );
  NOR2BX1 U106 ( .AN(n246), .B(n4), .Y(N432) );
  INVXL U107 ( .A(n3130), .Y(n3110) );
  INVX2 U108 ( .A(srst_n), .Y(n3140) );
  INVX1 U109 ( .A(srst_n), .Y(n3130) );
  INVXL U110 ( .A(n254), .Y(N289) );
  XOR2XL U111 ( .A(N310), .B(n249), .Y(n250) );
  INVXL U112 ( .A(n244), .Y(N288) );
  INVXL U113 ( .A(n240), .Y(N287) );
  XOR2XL U114 ( .A(N308), .B(n241), .Y(n239) );
  XOR2XL U115 ( .A(N306), .B(n234), .Y(n231) );
  INVXL U116 ( .A(n3130), .Y(n3120) );
  NAND4BXL U117 ( .AN(state[1]), .B(state[2]), .C(n153), .D(loc_complete), .Y(
        n272) );
  NAND2XL U118 ( .A(n162), .B(sram_rdata), .Y(n140) );
  INVXL U119 ( .A(n37), .Y(n26) );
  INVXL U120 ( .A(n77), .Y(n670) );
  OAI22XL U121 ( .A0(pre_loc_y1[1]), .A1(n281), .B0(pre_loc_y1[0]), .B1(n303), 
        .Y(n101) );
  OAI22XL U122 ( .A0(pre_loc_y3[0]), .A1(n303), .B0(pre_loc_y3[1]), .B1(n281), 
        .Y(n41) );
  NAND2BXL U123 ( .AN(n99), .B(n98), .Y(n109) );
  OAI22XL U124 ( .A0(n650), .A1(n64), .B0(pre_loc_x2[4]), .B1(n2990), .Y(n72)
         );
  AOI22XL U125 ( .A0(n30), .A1(pre_loc_x3[5]), .B0(scan_raddr[5]), .B1(n33), 
        .Y(n31) );
  OAI222XL U126 ( .A0(scan_raddr[4]), .A1(n301), .B0(scan_raddr[4]), .B1(n132), 
        .C0(n132), .C1(n301), .Y(n133) );
  OAI21XL U127 ( .A0(n115), .A1(scan_raddr[2]), .B0(n95), .Y(n121) );
  OAI21XL U128 ( .A0(n136), .A1(n133), .B0(pre_loc_x1[5]), .Y(n134) );
  AOI22XL U129 ( .A0(n107), .A1(x_upper[2]), .B0(n111), .B1(x_upper[0]), .Y(
        n148) );
  INVXL U130 ( .A(n223), .Y(n227) );
  INVXL U131 ( .A(n233), .Y(n248) );
  NOR3XL U132 ( .A(n151), .B(n150), .C(n149), .Y(n266) );
  TIELO U133 ( .Y(n_Logic0_) );
  NAND3XL U134 ( .A(pre_loc_x2[2]), .B(n283), .C(n2970), .Y(n50) );
  NAND2BXL U135 ( .AN(decode_complete), .B(n3090), .Y(net7311) );
  NOR2XL U136 ( .A(n165), .B(n169), .Y(n4) );
  OR2XL U137 ( .A(gold_loc_y[2]), .B(gold_loc_y[3]), .Y(n143) );
  INVXL U138 ( .A(rotation_type[1]), .Y(n7) );
  NAND2XL U139 ( .A(n143), .B(n7), .Y(n5) );
  OR2XL U140 ( .A(gold_loc_x[2]), .B(gold_loc_x[3]), .Y(n145) );
  INVXL U141 ( .A(rotation_type[0]), .Y(n9) );
  NAND2XL U142 ( .A(n145), .B(n9), .Y(n6) );
  INVXL U143 ( .A(N314), .Y(n257) );
  INVXL U144 ( .A(N312), .Y(n262) );
  NOR2XL U145 ( .A(n262), .B(n3070), .Y(n277) );
  NAND2XL U146 ( .A(N313), .B(n277), .Y(n276) );
  NOR2XL U147 ( .A(n257), .B(n276), .Y(n275) );
  NAND2XL U148 ( .A(N315), .B(n275), .Y(n274) );
  NAND2XL U149 ( .A(scan_raddr[1]), .B(n293), .Y(n12) );
  AOI22XL U150 ( .A0(pre_loc_x3[0]), .A1(n282), .B0(pre_loc_x3[1]), .B1(n2890), 
        .Y(n13) );
  ADDFX1 U151 ( .A(pre_loc_x3[2]), .B(n283), .CI(n11), .CO(n16), .S(n15) );
  NAND2BXL U152 ( .AN(n15), .B(n14), .Y(n20) );
  NAND2XL U153 ( .A(n2990), .B(pre_loc_x3[4]), .Y(n24) );
  NOR2XL U154 ( .A(pre_loc_x3[4]), .B(n2990), .Y(n22) );
  ADDFX1 U155 ( .A(pre_loc_x3[3]), .B(n2970), .CI(n16), .CO(n17), .S(n21) );
  INVXL U156 ( .A(n17), .Y(n23) );
  NOR2XL U157 ( .A(n23), .B(n19), .Y(n18) );
  AOI21XL U158 ( .A0(n24), .A1(n23), .B0(n22), .Y(n30) );
  NOR2XL U159 ( .A(n30), .B(pre_loc_x3[5]), .Y(n33) );
  NAND2XL U160 ( .A(n2960), .B(pre_loc_y3[4]), .Y(n37) );
  NAND2XL U161 ( .A(pre_loc_y3[2]), .B(n291), .Y(n38) );
  OAI222XL U162 ( .A0(pre_loc_y3[1]), .A1(n25), .B0(pre_loc_y3[1]), .B1(n281), 
        .C0(n281), .C1(n25), .Y(n44) );
  NOR2XL U163 ( .A(n291), .B(pre_loc_y3[2]), .Y(n39) );
  AOI21XL U164 ( .A0(n38), .A1(n44), .B0(n39), .Y(n40) );
  OAI22XL U165 ( .A0(pre_loc_y3[4]), .A1(n2960), .B0(n26), .B1(n49), .Y(n27)
         );
  NOR2XL U166 ( .A(n29), .B(n3050), .Y(n28) );
  AOI211XL U167 ( .A0(n29), .A1(n3050), .B0(n169), .C0(n28), .Y(n32) );
  NOR2XL U168 ( .A(n35), .B(n34), .Y(n93) );
  OR2XL U169 ( .A(pre_loc_y3[4]), .B(n2960), .Y(n36) );
  NAND2XL U170 ( .A(n37), .B(n36), .Y(n48) );
  NAND2BXL U171 ( .AN(n39), .B(n38), .Y(n45) );
  ADDFX1 U172 ( .A(pre_loc_y3[3]), .B(n2940), .CI(n40), .CO(n49), .S(n43) );
  NAND3XL U173 ( .A(n41), .B(n45), .C(n44), .Y(n42) );
  NAND2XL U174 ( .A(n49), .B(n48), .Y(n46) );
  NOR2XL U175 ( .A(pre_loc_x2[4]), .B(n2990), .Y(n57) );
  NAND2XL U176 ( .A(pre_loc_x2[4]), .B(n2990), .Y(n56) );
  OAI21XL U177 ( .A0(n57), .A1(n50), .B0(n56), .Y(n75) );
  OR2XL U178 ( .A(pre_loc_x2[1]), .B(n2890), .Y(n52) );
  AOI22XL U179 ( .A0(pre_loc_x2[0]), .A1(n282), .B0(pre_loc_x2[1]), .B1(n2890), 
        .Y(n53) );
  ADDFX1 U180 ( .A(pre_loc_x2[2]), .B(n283), .CI(n51), .CO(n58), .S(n55) );
  NAND2BXL U181 ( .AN(n55), .B(n54), .Y(n620) );
  INVXL U182 ( .A(n56), .Y(n64) );
  NOR2XL U183 ( .A(n57), .B(n64), .Y(n610) );
  ADDFX1 U184 ( .A(pre_loc_x2[3]), .B(n2970), .CI(n58), .CO(n650), .S(n63) );
  INVXL U185 ( .A(n650), .Y(n600) );
  NOR2XL U186 ( .A(n600), .B(n610), .Y(n590) );
  NAND2XL U187 ( .A(n2960), .B(pre_loc_y2[4]), .Y(n77) );
  NAND2XL U188 ( .A(pre_loc_y2[2]), .B(n291), .Y(n78) );
  OAI222XL U189 ( .A0(pre_loc_y2[1]), .A1(n660), .B0(pre_loc_y2[1]), .B1(n281), 
        .C0(n281), .C1(n660), .Y(n84) );
  NOR2XL U190 ( .A(n291), .B(pre_loc_y2[2]), .Y(n79) );
  AOI21XL U191 ( .A0(n78), .A1(n84), .B0(n79), .Y(n80) );
  OAI22XL U192 ( .A0(pre_loc_y2[4]), .A1(n2960), .B0(n670), .B1(n89), .Y(n680)
         );
  AOI22XL U193 ( .A0(n72), .A1(n71), .B0(n3050), .B1(n70), .Y(n69) );
  AOI211XL U194 ( .A0(pre_loc_x2[5]), .A1(n75), .B0(n74), .C0(n73), .Y(n91) );
  OR2XL U195 ( .A(pre_loc_y2[4]), .B(n2960), .Y(n76) );
  NAND2XL U196 ( .A(n77), .B(n76), .Y(n88) );
  NAND2BXL U197 ( .AN(n79), .B(n78), .Y(n85) );
  ADDFX1 U198 ( .A(pre_loc_y2[3]), .B(n2940), .CI(n80), .CO(n89), .S(n83) );
  OAI22XL U199 ( .A0(pre_loc_y2[0]), .A1(n303), .B0(pre_loc_y2[1]), .B1(n281), 
        .Y(n81) );
  NAND3XL U200 ( .A(n81), .B(n85), .C(n84), .Y(n82) );
  NAND2XL U201 ( .A(n89), .B(n88), .Y(n86) );
  AOI22XL U202 ( .A0(pre_loc_x1[1]), .A1(n2890), .B0(pre_loc_x1[0]), .B1(n282), 
        .Y(n117) );
  OR2XL U203 ( .A(pre_loc_x1[1]), .B(n2890), .Y(n116) );
  NAND2BXL U204 ( .AN(n117), .B(n116), .Y(n115) );
  NAND2XL U205 ( .A(scan_raddr[2]), .B(n115), .Y(n94) );
  NAND2XL U206 ( .A(pre_loc_x1[2]), .B(n94), .Y(n95) );
  NAND2XL U207 ( .A(pre_loc_y1[2]), .B(n291), .Y(n98) );
  OAI222XL U208 ( .A0(pre_loc_y1[1]), .A1(n96), .B0(pre_loc_y1[1]), .B1(n281), 
        .C0(n281), .C1(n96), .Y(n106) );
  NOR2XL U209 ( .A(n291), .B(pre_loc_y1[2]), .Y(n99) );
  AOI21XL U210 ( .A0(n98), .A1(n106), .B0(n99), .Y(n100) );
  NOR2XL U211 ( .A(n3060), .B(scan_raddr[10]), .Y(n129) );
  NAND2XL U212 ( .A(scan_raddr[10]), .B(n3060), .Y(n97) );
  NAND2BXL U213 ( .AN(n129), .B(n97), .Y(n114) );
  ADDFX1 U214 ( .A(pre_loc_y1[3]), .B(n2940), .CI(n100), .CO(n128), .S(n103)
         );
  NAND3XL U215 ( .A(n101), .B(n109), .C(n106), .Y(n102) );
  NAND2XL U216 ( .A(n128), .B(n114), .Y(n112) );
  NAND2XL U217 ( .A(scan_raddr[2]), .B(n120), .Y(n118) );
  ADDFX1 U218 ( .A(pre_loc_x1[3]), .B(n2970), .CI(n121), .CO(n126), .S(n125)
         );
  ADDFX1 U219 ( .A(pre_loc_x1[4]), .B(n2990), .CI(n126), .CO(n127), .S(n122)
         );
  OAI22XL U220 ( .A0(pre_loc_y1[4]), .A1(n2960), .B0(n129), .B1(n128), .Y(n131) );
  NOR2BXL U221 ( .AN(state[0]), .B(state[3]), .Y(n153) );
  NAND3BXL U222 ( .AN(state[2]), .B(n153), .C(state[1]), .Y(n273) );
  NOR2XL U223 ( .A(rotation_type[1]), .B(gold_loc_y[2]), .Y(n279) );
  INVXL U224 ( .A(gold_loc_y[3]), .Y(n142) );
  OAI22XL U225 ( .A0(rotation_type[1]), .A1(n143), .B0(n279), .B1(n142), .Y(
        N66) );
  NOR2XL U226 ( .A(rotation_type[0]), .B(gold_loc_x[2]), .Y(n280) );
  INVXL U227 ( .A(gold_loc_x[3]), .Y(n144) );
  OAI22XL U228 ( .A0(rotation_type[0]), .A1(n145), .B0(n280), .B1(n144), .Y(
        N60) );
  AOI21XL U229 ( .A0(n262), .A1(n3070), .B0(n277), .Y(N294) );
  AOI21XL U230 ( .A0(n257), .A1(n276), .B0(n275), .Y(N296) );
  INVXL U231 ( .A(n273), .Y(n152) );
  AOI22XL U232 ( .A0(n105), .A1(x_upper[5]), .B0(n108), .B1(x_upper[3]), .Y(
        n146) );
  AOI22XL U233 ( .A0(n104), .A1(x_upper[4]), .B0(n110), .B1(x_upper[1]), .Y(
        n147) );
  AOI22XL U234 ( .A0(n107), .A1(pre_loc_x3[2]), .B0(n108), .B1(pre_loc_x3[3]), 
        .Y(n154) );
  OAI22XL U235 ( .A0(pre_loc_x3[0]), .A1(n111), .B0(n105), .B1(pre_loc_x3[5]), 
        .Y(n172) );
  AOI22XL U236 ( .A0(pre_loc_x3[4]), .A1(n104), .B0(pre_loc_x3[5]), .B1(n105), 
        .Y(n157) );
  NAND2BXL U237 ( .AN(n300), .B(n111), .Y(n156) );
  NAND2BXL U238 ( .AN(N311), .B(pre_loc_y3[0]), .Y(n159) );
  XOR2XL U239 ( .A(N311), .B(pre_loc_y3[0]), .Y(n166) );
  ADDFX1 U240 ( .A(N313), .B(n2870), .CI(n158), .CO(n160), .S(n164) );
  ADDFX1 U241 ( .A(N312), .B(n2850), .CI(n159), .CO(n158), .S(n163) );
  ADDFX1 U242 ( .A(N314), .B(n290), .CI(n160), .CO(n174), .S(n161) );
  ADDFX1 U243 ( .A(N315), .B(n2950), .CI(n174), .CO(n175), .S(n168) );
  XOR2XL U244 ( .A(N311), .B(pre_loc_y1[0]), .Y(n185) );
  ADDFX1 U245 ( .A(N313), .B(n1), .CI(n179), .CO(n181), .S(n184) );
  ADDFX1 U246 ( .A(N312), .B(n3), .CI(n180), .CO(n179), .S(n183) );
  ADDFX1 U247 ( .A(N314), .B(n2), .CI(n181), .CO(n190), .S(n182) );
  AOI22XL U248 ( .A0(pre_loc_x1[3]), .A1(n108), .B0(pre_loc_x1[5]), .B1(n105), 
        .Y(n188) );
  AOI22XL U249 ( .A0(pre_loc_x1[0]), .A1(n111), .B0(pre_loc_x1[1]), .B1(n110), 
        .Y(n189) );
  ADDFX1 U250 ( .A(N315), .B(n3060), .CI(n190), .CO(n191), .S(n187) );
  XOR2XL U251 ( .A(N311), .B(pre_loc_y2[0]), .Y(n205) );
  NAND2BXL U252 ( .AN(N311), .B(pre_loc_y2[0]), .Y(n200) );
  ADDFX1 U253 ( .A(N312), .B(n2840), .CI(n200), .CO(n201), .S(n203) );
  ADDFX1 U254 ( .A(N313), .B(n2860), .CI(n201), .CO(n206), .S(n204) );
  ADDFX1 U255 ( .A(N314), .B(n2880), .CI(n206), .CO(n209), .S(n202) );
  ADDFX1 U256 ( .A(N315), .B(n292), .CI(n209), .CO(n210), .S(n207) );
  AOI22XL U257 ( .A0(pre_loc_x2[4]), .A1(n104), .B0(pre_loc_x2[1]), .B1(n110), 
        .Y(n212) );
  AOI22XL U258 ( .A0(pre_loc_x2[2]), .A1(n107), .B0(pre_loc_x2[5]), .B1(n105), 
        .Y(n213) );
  AOI22XL U259 ( .A0(pre_loc_x2[3]), .A1(n108), .B0(pre_loc_x2[0]), .B1(n111), 
        .Y(n214) );
  NAND2BXL U260 ( .AN(n222), .B(n221), .Y(n226) );
  NAND2XL U261 ( .A(n162), .B(n302), .Y(n224) );
  INVXL U262 ( .A(n230), .Y(N284) );
  ADDHX1 U263 ( .A(n233), .B(N305), .CO(n234), .S(n229) );
  INVXL U264 ( .A(n232), .Y(N285) );
  INVXL U265 ( .A(n237), .Y(N286) );
  ADDFX1 U266 ( .A(n248), .B(N307), .CI(n238), .CO(n241), .S(n236) );
  ADDFX1 U267 ( .A(n248), .B(N309), .CI(n247), .CO(n249), .S(n243) );
  INVXL U268 ( .A(N313), .Y(n256) );
  OAI22XL U269 ( .A0(y_upper[2]), .A1(n256), .B0(y_upper[3]), .B1(n257), .Y(
        n255) );
  INVXL U270 ( .A(N315), .Y(n260) );
  INVXL U271 ( .A(N316), .Y(n259) );
  OAI22XL U272 ( .A0(y_upper[5]), .A1(n259), .B0(y_upper[4]), .B1(n260), .Y(
        n258) );
  OAI22XL U273 ( .A0(y_upper[1]), .A1(n262), .B0(n3070), .B1(y_upper[0]), .Y(
        n261) );
  NAND4XL U274 ( .A(n266), .B(n265), .C(n264), .D(n263), .Y(n271) );
  OAI22XL U275 ( .A0(n165), .A1(qr_total[1]), .B0(n169), .B1(qr_total[0]), .Y(
        n267) );
  NAND2XL U276 ( .A(qr_total[2]), .B(n162), .Y(n268) );
  NAND3BXL U277 ( .AN(net7294), .B(n273), .C(n272), .Y(net7287) );
  OA21X1 U278 ( .A0(N315), .A1(n275), .B0(n274), .Y(N297) );
  OA21X1 U279 ( .A0(N313), .A1(n277), .B0(n276), .Y(N295) );
  OAI31X1 U280 ( .A0(n169), .A1(n278), .A2(n302), .B0(n3090), .Y(net7265) );
  OAI31X1 U281 ( .A0(n165), .A1(n3080), .A2(n278), .B0(n3090), .Y(net7276) );
  AO21XL U282 ( .A0(gold_loc_y[2]), .A1(rotation_type[1]), .B0(n279), .Y(N65)
         );
  AO21XL U283 ( .A0(gold_loc_x[2]), .A1(rotation_type[0]), .B0(n280), .Y(N59)
         );
  MX2XL U284 ( .A(n3070), .B(y_lower[0]), .S0(pre_scan_complete), .Y(N299) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_0 clk_gate_pre_loc_x1_reg ( .CLK(clk), 
        .EN(net7254), .ENCLK(net7257) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_10 clk_gate_pre_loc_y1_reg ( .CLK(clk), .EN(net7254), .ENCLK(net7262) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_9 clk_gate_pre_loc_x2_reg ( .CLK(clk), 
        .EN(net7265), .ENCLK(net7268) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_8 clk_gate_pre_loc_y2_reg ( .CLK(clk), 
        .EN(net7265), .ENCLK(net7273) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_7 clk_gate_pre_loc_x3_reg ( .CLK(clk), 
        .EN(net7276), .ENCLK(net7279) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_6 clk_gate_pre_loc_y3_reg ( .CLK(clk), 
        .EN(net7276), .ENCLK(net7284) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_5 clk_gate_current_x_reg ( .CLK(clk), 
        .EN(net7287), .ENCLK(net7291) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_4 clk_gate_current_y_reg ( .CLK(clk), 
        .EN(net7294), .ENCLK(net7297) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_3 clk_gate_loc_y_reg ( .CLK(clk), 
        .EN(net7300), .ENCLK(net7303) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_2 clk_gate_loc_x_reg ( .CLK(clk), 
        .EN(net7300), .ENCLK(net7308) );
  SNPS_CLOCK_GATE_HIGH_SCANNING_mydesign_1 clk_gate_qr_num_reg ( .CLK(clk), 
        .EN(net7311), .ENCLK(net7314) );
  XNOR2XL U3 ( .A(N316), .B(n191), .Y(n192) );
  NOR2BXL U4 ( .AN(n52), .B(n53), .Y(n51) );
  XNOR2XL U5 ( .A(N316), .B(n210), .Y(n211) );
  NOR2BXL U7 ( .AN(pre_loc_y2[0]), .B(scan_raddr[6]), .Y(n660) );
  NOR2BXL U8 ( .AN(pre_loc_y3[0]), .B(scan_raddr[6]), .Y(n25) );
  OAI221XL U9 ( .A0(pre_loc_x2[3]), .A1(n108), .B0(pre_loc_x2[0]), .B1(n111), 
        .C0(n214), .Y(n215) );
  OAI221XL U12 ( .A0(pre_loc_x2[4]), .A1(n104), .B0(pre_loc_x2[1]), .B1(n110), 
        .C0(n212), .Y(n217) );
  XNOR2XL U13 ( .A(pre_loc_y2[5]), .B(n680), .Y(n70) );
  NOR2BXL U15 ( .AN(n24), .B(n22), .Y(n19) );
  OAI221XL U17 ( .A0(pre_loc_x1[4]), .A1(n104), .B0(n301), .B1(N309), .C0(n194), .Y(n195) );
  XNOR2XL U25 ( .A(pre_loc_y1[5]), .B(scan_raddr[11]), .Y(n130) );
  OAI221XL U30 ( .A0(n72), .A1(n71), .B0(n3050), .B1(n70), .C0(n69), .Y(n73)
         );
  NOR4BXL U33 ( .AN(n173), .B(n172), .C(n171), .D(n170), .Y(n178) );
  XNOR2XL U34 ( .A(n131), .B(n130), .Y(n135) );
  OAI221XL U46 ( .A0(n107), .A1(x_upper[2]), .B0(n111), .B1(x_upper[0]), .C0(
        n148), .Y(n149) );
  OAI2BB1XL U47 ( .A0N(gold_loc_y[4]), .A1N(n143), .B0(n7), .Y(n8) );
  AOI222XL U49 ( .A0(n253), .A1(x_lower[0]), .B0(n252), .B1(correct_loc_x[0]), 
        .C0(n251), .C1(n229), .Y(n230) );
  XNOR2XL U62 ( .A(gold_loc_x[4]), .B(n6), .Y(N61) );
  XNOR2XL U64 ( .A(gold_loc_y[5]), .B(n8), .Y(N68) );
  XNOR2XL U65 ( .A(N316), .B(n274), .Y(N298) );
endmodule


module SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_0 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7209;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7209) );
  AND2XL main_gate ( .A(net7209), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_5 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7209;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7209) );
  AND2XL main_gate ( .A(net7209), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_4 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7209;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7209) );
  AND2XL main_gate ( .A(net7209), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_2 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7209;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7209) );
  AND2XL main_gate ( .A(net7209), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_1 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7209;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7209) );
  AND2XL main_gate ( .A(net7209), .B(CLK), .Y(ENCLK) );
endmodule


module PRE_SCANNING ( clk, srst_n, state, sram_rdata, pre_scan_raddr, 
        pre_scan_complete, x_upper, x_lower, y_upper, y_lower );
  input [3:0] state;
  output [11:0] pre_scan_raddr;
  output [5:0] x_upper;
  output [5:0] x_lower;
  output [5:0] y_upper;
  output [5:0] y_lower;
  input clk, srst_n, sram_rdata;
  output pre_scan_complete;
  wire   N86, x0_empty, x21_empty, x42_empty, x63_empty, y0_empty, y21_empty,
         y42_empty, y63_empty, N161, N162, N164, N231, N232, N234, net7164,
         net7215, net7220, net7223, net7226, net7229, net7237, net7242, n9,
         n10, n11, n20, n26, n45, n46, n47, n48, n49, n50, n51, n52, n1, n2,
         n3, n4, n5, n6, n7, n8, n12, n13, n14, n15, n16, n17, n18, n19, n21,
         n22, n23, n24, n25, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n38, n39, n40, n41, n42, n43, n44, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72,
         n79, n80, n81, n82, n83, n84, n85, n860, n87, n88, n89, n90;
  wire   [5:0] j_tmp;
  wire   [5:0] i_tmp;

  DFFTRXL j_reg_0_ ( .D(n87), .RN(j_tmp[0]), .CK(net7226), .Q(
        pre_scan_raddr[0]), .QN(n80) );
  DFFTRXL i_reg_5_ ( .D(n860), .RN(i_tmp[5]), .CK(net7215), .Q(
        pre_scan_raddr[11]) );
  DFFTRXL mode_reg ( .D(n87), .RN(n10), .CK(clk), .Q(n81), .QN(n50) );
  DFFTRXL i_reg_4_ ( .D(n87), .RN(i_tmp[4]), .CK(net7215), .Q(
        pre_scan_raddr[10]) );
  DFFTRXL i_reg_3_ ( .D(n87), .RN(i_tmp[3]), .CK(net7215), .Q(
        pre_scan_raddr[9]), .QN(n83) );
  DFFTRXL i_reg_2_ ( .D(n87), .RN(i_tmp[2]), .CK(net7215), .Q(
        pre_scan_raddr[8]) );
  DFFTRXL i_reg_1_ ( .D(n87), .RN(i_tmp[1]), .CK(net7215), .Q(
        pre_scan_raddr[7]), .QN(n84) );
  DFFTRXL i_reg_0_ ( .D(n87), .RN(i_tmp[0]), .CK(net7215), .Q(
        pre_scan_raddr[6]), .QN(n79) );
  DFFTRXL j_reg_1_ ( .D(n87), .RN(j_tmp[1]), .CK(net7226), .Q(
        pre_scan_raddr[1]), .QN(n82) );
  DFFTRXL j_reg_2_ ( .D(n87), .RN(j_tmp[2]), .CK(net7226), .Q(
        pre_scan_raddr[2]) );
  DFFTRXL j_reg_3_ ( .D(n87), .RN(j_tmp[3]), .CK(net7226), .Q(
        pre_scan_raddr[3]), .QN(n85) );
  DFFTRXL j_reg_4_ ( .D(n87), .RN(j_tmp[4]), .CK(net7226), .Q(
        pre_scan_raddr[4]) );
  DFFTRXL j_reg_5_ ( .D(n87), .RN(j_tmp[5]), .CK(net7226), .Q(
        pre_scan_raddr[5]) );
  DFFTRXL pre_scan_complete_reg ( .D(n87), .RN(N86), .CK(clk), .Q(
        pre_scan_complete) );
  MDFFHQX1 x0_empty_reg ( .D0(n9), .D1(n89), .S0(n26), .CK(net7215), .Q(
        x0_empty) );
  DFFTRXL x_upper_reg_5_ ( .D(n87), .RN(N164), .CK(net7237), .Q(x_upper[5]) );
  DFFTRXL x_upper_reg_3_ ( .D(n87), .RN(N164), .CK(net7237), .Q(x_upper[3]) );
  DFFTRXL x_upper_reg_1_ ( .D(n87), .RN(N164), .CK(net7237), .Q(x_upper[1]) );
  DFFTRXL x_upper_reg_0_ ( .D(n87), .RN(n51), .CK(net7242), .Q(x_upper[4]), 
        .QN(n3) );
  DFFTRXL y_upper_reg_5_ ( .D(n87), .RN(N234), .CK(net7242), .Q(y_upper[5]) );
  DFFTRXL y_upper_reg_4_ ( .D(n87), .RN(n52), .CK(net7242), .Q(y_upper[4]) );
  DFFTRXL y_upper_reg_3_ ( .D(n87), .RN(N234), .CK(net7237), .Q(y_upper[3]) );
  DFFTRXL y_upper_reg_1_ ( .D(n860), .RN(N234), .CK(net7237), .Q(y_upper[1])
         );
  DFFTRXL y_upper_reg_0_ ( .D(n860), .RN(n52), .CK(net7237), .Q(y_upper[2]) );
  DFFTRXL x_lower_reg_5_ ( .D(n860), .RN(N162), .CK(net7237), .Q(x_lower[5])
         );
  DFFTRXL x_lower_reg_3_ ( .D(n860), .RN(N162), .CK(net7237), .Q(x_lower[3])
         );
  DFFTRXL x_lower_reg_2_ ( .D(n860), .RN(N161), .CK(net7237), .Q(x_lower[4])
         );
  DFFTRXL x_lower_reg_1_ ( .D(n860), .RN(N162), .CK(net7242), .Q(x_lower[1])
         );
  DFFTRXL x_lower_reg_0_ ( .D(n860), .RN(N161), .CK(net7242), .Q(x_lower[0])
         );
  DFFTRXL y_lower_reg_5_ ( .D(n860), .RN(N232), .CK(net7242), .Q(y_lower[5])
         );
  DFFTRXL y_lower_reg_3_ ( .D(n860), .RN(N232), .CK(net7242), .Q(y_lower[3])
         );
  DFFTRXL y_lower_reg_1_ ( .D(n860), .RN(N232), .CK(net7242), .Q(y_lower[1])
         );
  DFFTRXL y_lower_reg_0_ ( .D(n860), .RN(N231), .CK(net7242), .Q(y_lower[0]), 
        .QN(n4) );
  MDFFHQX1 y42_empty_reg ( .D0(n45), .D1(n9), .S0(n88), .CK(net7220), .Q(
        y42_empty) );
  MDFFHQX1 y21_empty_reg ( .D0(n46), .D1(n9), .S0(n88), .CK(net7220), .Q(
        y21_empty) );
  MDFFHQX1 x21_empty_reg ( .D0(n49), .D1(n9), .S0(n88), .CK(net7220), .Q(
        x21_empty) );
  MDFFHQX1 y63_empty_reg ( .D0(n9), .D1(n88), .S0(n11), .CK(net7220), .Q(
        y63_empty) );
  MDFFHQX1 y0_empty_reg ( .D0(n47), .D1(n9), .S0(n88), .CK(net7220), .Q(
        y0_empty) );
  MDFFHQX1 x42_empty_reg ( .D0(n9), .D1(n88), .S0(n20), .CK(net7220), .Q(
        x42_empty) );
  MDFFHQX1 x63_empty_reg ( .D0(n48), .D1(n9), .S0(n88), .CK(net7220), .Q(
        x63_empty) );
  AOI31XL U4 ( .A0(n34), .A1(n33), .A2(n69), .B0(n32), .Y(n46) );
  NOR2BXL U5 ( .AN(n31), .B(n65), .Y(j_tmp[2]) );
  NOR2BX1 U6 ( .AN(n41), .B(n65), .Y(j_tmp[4]) );
  NOR2BXL U7 ( .AN(n42), .B(n57), .Y(i_tmp[4]) );
  OAI2BB1X1 U9 ( .A0N(n18), .A1N(n5), .B0(n13), .Y(n10) );
  NOR2XL U10 ( .A(n40), .B(n12), .Y(n43) );
  OAI31X1 U11 ( .A0(n21), .A1(n36), .A2(n39), .B0(x21_empty), .Y(n22) );
  NOR4X1 U12 ( .A(pre_scan_raddr[10]), .B(pre_scan_raddr[6]), .C(
        pre_scan_raddr[8]), .D(n67), .Y(n71) );
  XNOR2XL U13 ( .A(pre_scan_raddr[5]), .B(n60), .Y(n61) );
  BUFX2 U14 ( .A(n62), .Y(n1) );
  CLKAND2X2 U15 ( .A(pre_scan_raddr[3]), .B(n62), .Y(n63) );
  ADDFXL U16 ( .A(pre_scan_raddr[10]), .B(n5), .CI(n55), .CO(n44), .S(n42) );
  CLKAND2X2 U17 ( .A(pre_scan_raddr[9]), .B(n54), .Y(n55) );
  BUFX2 U18 ( .A(n59), .Y(n2) );
  INVXL U19 ( .A(n23), .Y(n59) );
  OR2XL U20 ( .A(n81), .B(n14), .Y(n40) );
  NOR2XL U21 ( .A(n50), .B(n14), .Y(n27) );
  NAND3XL U22 ( .A(pre_scan_raddr[0]), .B(pre_scan_raddr[4]), .C(
        pre_scan_raddr[2]), .Y(n21) );
  INVX2 U23 ( .A(n88), .Y(n860) );
  INVX2 U24 ( .A(n88), .Y(n87) );
  NOR2XL U25 ( .A(n37), .B(n21), .Y(n19) );
  NAND3XL U26 ( .A(pre_scan_raddr[1]), .B(pre_scan_raddr[5]), .C(
        pre_scan_raddr[3]), .Y(n37) );
  NAND2XL U27 ( .A(n8), .B(n7), .Y(n14) );
  NOR2BXL U28 ( .AN(state[0]), .B(state[1]), .Y(n7) );
  NAND2XL U29 ( .A(n72), .B(n34), .Y(n35) );
  INVXL U30 ( .A(n35), .Y(n18) );
  NOR2XL U31 ( .A(n24), .B(n2), .Y(n65) );
  INVXL U32 ( .A(n29), .Y(n48) );
  OAI211XL U33 ( .A0(n37), .A1(n38), .B0(n860), .C0(x42_empty), .Y(n20) );
  OAI211XL U34 ( .A0(n35), .A1(n67), .B0(n860), .C0(y63_empty), .Y(n11) );
  INVXL U35 ( .A(n67), .Y(n33) );
  NAND2XL U36 ( .A(n860), .B(y21_empty), .Y(n32) );
  INVX2 U37 ( .A(srst_n), .Y(n88) );
  OAI211XL U38 ( .A0(n39), .A1(n38), .B0(n860), .C0(x0_empty), .Y(n26) );
  NOR2XL U39 ( .A(pre_scan_raddr[6]), .B(n57), .Y(i_tmp[0]) );
  NOR2XL U40 ( .A(pre_scan_raddr[0]), .B(n65), .Y(j_tmp[0]) );
  XNOR2XL U41 ( .A(pre_scan_raddr[11]), .B(n44), .Y(n53) );
  ADDFXL U42 ( .A(pre_scan_raddr[8]), .B(n58), .CI(n43), .CO(n54), .S(n30) );
  ADDFXL U43 ( .A(pre_scan_raddr[4]), .B(n2), .CI(n63), .CO(n60), .S(n41) );
  ADDFXL U44 ( .A(pre_scan_raddr[2]), .B(n66), .CI(n59), .CO(n62), .S(n31) );
  OAI21XL U45 ( .A0(n18), .A1(sram_rdata), .B0(n27), .Y(n23) );
  BUFX2 U46 ( .A(n43), .Y(n5) );
  NOR2XL U47 ( .A(state[3]), .B(state[2]), .Y(n8) );
  NOR2XL U48 ( .A(n40), .B(n90), .Y(n24) );
  INVXL U49 ( .A(n90), .Y(n25) );
  NAND2XL U50 ( .A(n90), .B(n50), .Y(n67) );
  NAND2XL U51 ( .A(n90), .B(n81), .Y(n36) );
  OAI211XL U52 ( .A0(n28), .A1(n36), .B0(n860), .C0(x63_empty), .Y(n29) );
  OAI31XL U53 ( .A0(n12), .A1(n14), .A2(n35), .B0(n81), .Y(n13) );
  NOR2XL U54 ( .A(x42_empty), .B(n17), .Y(N161) );
  TIEHI U55 ( .Y(n9) );
  INVXL U56 ( .A(n3), .Y(x_upper[2]) );
  INVXL U57 ( .A(n3), .Y(x_upper[0]) );
  BUFX2 U58 ( .A(y_upper[2]), .Y(y_upper[0]) );
  BUFX2 U59 ( .A(x_lower[4]), .Y(x_lower[2]) );
  INVXL U60 ( .A(n4), .Y(y_lower[2]) );
  INVXL U61 ( .A(n4), .Y(y_lower[4]) );
  AND3XL U62 ( .A(pre_scan_raddr[11]), .B(pre_scan_raddr[9]), .C(
        pre_scan_raddr[7]), .Y(n72) );
  NAND2XL U63 ( .A(pre_scan_raddr[10]), .B(pre_scan_raddr[8]), .Y(n6) );
  NOR2XL U64 ( .A(n79), .B(n6), .Y(n34) );
  NOR2XL U65 ( .A(n19), .B(sram_rdata), .Y(n12) );
  INVX1 U66 ( .A(srst_n), .Y(n89) );
  INVXL U67 ( .A(n27), .Y(n15) );
  NAND3BXL U68 ( .AN(n5), .B(n860), .C(n15), .Y(net7164) );
  INVXL U69 ( .A(y0_empty), .Y(n68) );
  NAND4XL U70 ( .A(y21_empty), .B(y42_empty), .C(y63_empty), .D(n68), .Y(N234)
         );
  NAND2XL U71 ( .A(y0_empty), .B(y21_empty), .Y(n16) );
  NOR2XL U72 ( .A(y42_empty), .B(n16), .Y(N231) );
  NAND4BXL U73 ( .AN(x0_empty), .B(x21_empty), .C(x42_empty), .D(x63_empty), 
        .Y(N164) );
  NAND2XL U74 ( .A(x0_empty), .B(x21_empty), .Y(n17) );
  INVXL U75 ( .A(y42_empty), .Y(n70) );
  NOR3XL U76 ( .A(y63_empty), .B(n70), .C(n16), .Y(N232) );
  NOR3BXL U77 ( .AN(x42_empty), .B(x63_empty), .C(n17), .Y(N162) );
  INVXL U78 ( .A(n19), .Y(n28) );
  NOR2XL U79 ( .A(n23), .B(n28), .Y(N86) );
  OR3XL U80 ( .A(pre_scan_raddr[1]), .B(pre_scan_raddr[5]), .C(
        pre_scan_raddr[3]), .Y(n39) );
  NOR2XL U81 ( .A(n89), .B(n22), .Y(n49) );
  AND2XL U82 ( .A(pre_scan_raddr[6]), .B(pre_scan_raddr[7]), .Y(n58) );
  NOR2XL U83 ( .A(n80), .B(n82), .Y(n66) );
  NOR3XL U84 ( .A(pre_scan_raddr[11]), .B(pre_scan_raddr[9]), .C(
        pre_scan_raddr[7]), .Y(n69) );
  OR4X1 U85 ( .A(pre_scan_raddr[0]), .B(pre_scan_raddr[4]), .C(
        pre_scan_raddr[2]), .D(n36), .Y(n38) );
  NAND3BXL U86 ( .AN(n2), .B(n860), .C(n40), .Y(net7223) );
  NOR2XL U87 ( .A(n53), .B(n57), .Y(i_tmp[5]) );
  INVXL U88 ( .A(n54), .Y(n56) );
  AOI211XL U89 ( .A0(n83), .A1(n56), .B0(n55), .C0(n57), .Y(i_tmp[3]) );
  AOI211XL U90 ( .A0(n79), .A1(n84), .B0(n58), .C0(n57), .Y(i_tmp[1]) );
  NOR2XL U91 ( .A(n65), .B(n61), .Y(j_tmp[5]) );
  INVXL U92 ( .A(n1), .Y(n64) );
  AOI211XL U93 ( .A0(n64), .A1(n85), .B0(n65), .C0(n63), .Y(j_tmp[3]) );
  AOI211XL U94 ( .A0(n80), .A1(n82), .B0(n66), .C0(n65), .Y(j_tmp[1]) );
  OR2XL U95 ( .A(pre_scan_complete), .B(n89), .Y(net7229) );
  NAND3BXL U96 ( .AN(y21_empty), .B(y42_empty), .C(y63_empty), .Y(n52) );
  NAND3BXL U97 ( .AN(x21_empty), .B(x42_empty), .C(x63_empty), .Y(n51) );
  AOI211XL U98 ( .A0(n69), .A1(n71), .B0(n89), .C0(n68), .Y(n47) );
  AOI211XL U99 ( .A0(n72), .A1(n71), .B0(n89), .C0(n70), .Y(n45) );
  SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_0 clk_gate_i_reg ( .CLK(clk), 
        .EN(net7164), .ENCLK(net7215) );
  SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_5 clk_gate_x21_empty_reg ( .CLK(
        clk), .EN(net7164), .ENCLK(net7220) );
  SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_4 clk_gate_j_reg ( .CLK(clk), 
        .EN(net7223), .ENCLK(net7226) );
  SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_2 clk_gate_y_upper_reg ( .CLK(clk), .EN(net7229), .ENCLK(net7237) );
  SNPS_CLOCK_GATE_HIGH_PRE_SCANNING_mydesign_1 clk_gate_x_lower_reg ( .CLK(clk), .EN(net7229), .ENCLK(net7242) );
  AOI21X1 U3 ( .A0(n27), .A1(n25), .B0(n5), .Y(n57) );
  BUFX2 U8 ( .A(sram_rdata), .Y(n90) );
  NOR2BXL U100 ( .AN(n30), .B(n57), .Y(i_tmp[2]) );
endmodule


module SNPS_CLOCK_GATE_HIGH_NUM_CALCULATE_mydesign_0 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7140;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7140) );
  AND2XL main_gate ( .A(net7140), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_NUM_CALCULATE_mydesign_2 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7140;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7140) );
  AND2XL main_gate ( .A(net7140), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_NUM_CALCULATE_mydesign_1 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7140;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7140) );
  AND2XL main_gate ( .A(net7140), .B(CLK), .Y(ENCLK) );
endmodule


module NUM_CALCULATE ( clk, srst_n, state, sram_rdata, num_raddr, num_complete, 
        qr_total );
  input [3:0] state;
  output [11:0] num_raddr;
  output [2:0] qr_total;
  input clk, srst_n, sram_rdata;
  output num_complete;
  wire   N113, N114, N115, N117, N118, N119, N120, N121, N123, N124, N139,
         N140, N144, N145, net7143, net7144, net7145, net7146, net7147,
         net7148, net7151, net7154, net7157, net7160, net7163, n66, n77, n78,
         n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16,
         n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30,
         n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44,
         n45, n46, n47, n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58,
         n59, n60, n61, n62, n63, n64, n65, n67, n68, n71, n72, n73, n74, n75,
         n76, n79, n80;
  wire   [4:0] num;
  wire   [2:0] location;

  DFFTRXL num_reg_0_ ( .D(srst_n), .RN(net7148), .CK(net7151), .Q(num[0]), 
        .QN(n71) );
  DFFTRXL num_reg_1_ ( .D(srst_n), .RN(net7147), .CK(net7151), .Q(num[1]), 
        .QN(n73) );
  DFFTRXL num_reg_4_ ( .D(srst_n), .RN(net7144), .CK(net7151), .Q(num[4]), 
        .QN(n75) );
  DFFTRXL location_reg_0_ ( .D(n80), .RN(n77), .CK(net7157), .Q(location[0]), 
        .QN(n77) );
  DFFTRXL qr_total_reg_0_ ( .D(n80), .RN(n78), .CK(net7163), .Q(qr_total[0]), 
        .QN(n78) );
  DFFTRXL num_reg_2_ ( .D(n80), .RN(net7146), .CK(net7151), .Q(num[2]), .QN(
        n72) );
  DFFTRXL num_reg_3_ ( .D(n80), .RN(net7145), .CK(net7151), .Q(num[3]), .QN(
        n79) );
  DFFTRXL location_reg_2_ ( .D(n80), .RN(N140), .CK(net7157), .Q(location[2]), 
        .QN(n76) );
  DFFTRXL location_reg_1_ ( .D(n80), .RN(N139), .CK(net7157), .Q(n74), .QN(n66) );
  DFFTRXL qr_total_reg_2_ ( .D(n80), .RN(N145), .CK(net7163), .Q(qr_total[2])
         );
  DFFTRXL qr_total_reg_1_ ( .D(n80), .RN(N144), .CK(net7163), .Q(qr_total[1])
         );
  DFFTRXL num_raddr_reg_9_ ( .D(n80), .RN(N124), .CK(clk), .Q(num_raddr[9]) );
  DFFTRXL num_raddr_reg_3_ ( .D(n80), .RN(N118), .CK(clk), .Q(num_raddr[3]) );
  DFFTRXL num_raddr_reg_6_ ( .D(n80), .RN(N119), .CK(clk), .Q(num_raddr[6]) );
  DFFTRXL num_raddr_reg_8_ ( .D(n80), .RN(N121), .CK(clk), .Q(num_raddr[8]) );
  DFFTRXL num_raddr_reg_10_ ( .D(n80), .RN(N123), .CK(clk), .Q(num_raddr[10])
         );
  DFFTRXL num_raddr_reg_0_ ( .D(n80), .RN(N113), .CK(clk), .Q(num_raddr[0]) );
  DFFTRXL num_raddr_reg_1_ ( .D(n80), .RN(N114), .CK(clk), .Q(num_raddr[1]) );
  DFFTRXL num_raddr_reg_2_ ( .D(n80), .RN(N115), .CK(clk), .Q(num_raddr[2]) );
  DFFTRXL num_raddr_reg_7_ ( .D(n80), .RN(N120), .CK(clk), .Q(num_raddr[7]) );
  DFFTRXL num_raddr_reg_4_ ( .D(n80), .RN(N117), .CK(clk), .Q(num_raddr[4]) );
  OAI31XL U3 ( .A0(n63), .A1(n62), .A2(n61), .B0(n66), .Y(n65) );
  OAI32XL U5 ( .A0(n71), .A1(num[2]), .A2(n73), .B0(num[0]), .B1(n35), .Y(n16)
         );
  OAI2BB1XL U7 ( .A0N(n45), .A1N(n44), .B0(n46), .Y(n53) );
  AOI221X1 U10 ( .A0(num[4]), .A1(n56), .B0(n75), .B1(n54), .C0(n55), .Y(
        net7144) );
  AOI222XL U11 ( .A0(n14), .A1(n25), .B0(n13), .B1(n44), .C0(n45), .C1(num[2]), 
        .Y(n15) );
  OAI211XL U12 ( .A0(n20), .A1(n6), .B0(n64), .C0(n5), .Y(n10) );
  OAI211XL U13 ( .A0(N139), .A1(n40), .B0(n75), .C0(n39), .Y(n41) );
  OAI211XL U14 ( .A0(num[3]), .A1(n44), .B0(n12), .C0(n58), .Y(n14) );
  NAND2BXL U15 ( .AN(n53), .B(sram_rdata), .Y(n51) );
  OAI21XL U17 ( .A0(num_complete), .A1(n51), .B0(n80), .Y(net7160) );
  NAND2BXL U18 ( .AN(net7154), .B(n55), .Y(net7143) );
  AOI221X1 U19 ( .A0(N139), .A1(n26), .B0(n25), .B1(n24), .C0(n38), .Y(n27) );
  XNOR2X1 U20 ( .A(qr_total[2]), .B(n68), .Y(N145) );
  XNOR2X1 U21 ( .A(n1), .B(n76), .Y(N140) );
  NOR3BXL U22 ( .AN(n57), .B(n47), .C(n55), .Y(net7146) );
  BUFX3 U23 ( .A(srst_n), .Y(n80) );
  NAND2XL U24 ( .A(n47), .B(n49), .Y(n18) );
  OAI222XL U25 ( .A0(n20), .A1(n17), .B0(n29), .B1(n16), .C0(n23), .C1(n18), 
        .Y(n26) );
  NOR4BXL U26 ( .AN(state[1]), .B(state[0]), .C(state[2]), .D(state[3]), .Y(
        n46) );
  NOR2XL U27 ( .A(n74), .B(n2), .Y(N123) );
  NOR3BXL U28 ( .AN(n49), .B(n48), .C(n55), .Y(net7147) );
  BUFX2 U29 ( .A(num_raddr[9]), .Y(num_raddr[11]) );
  BUFX2 U30 ( .A(num_raddr[3]), .Y(num_raddr[5]) );
  NAND2XL U31 ( .A(qr_total[0]), .B(qr_total[1]), .Y(n68) );
  NOR2XL U32 ( .A(n66), .B(n77), .Y(n1) );
  NOR2XL U33 ( .A(location[0]), .B(n74), .Y(n50) );
  NOR2XL U34 ( .A(n1), .B(n50), .Y(N139) );
  NAND2XL U35 ( .A(num[3]), .B(num[4]), .Y(n43) );
  NAND2XL U36 ( .A(n71), .B(n72), .Y(n28) );
  NOR2XL U37 ( .A(num[1]), .B(n28), .Y(n44) );
  OAI21XL U38 ( .A0(n43), .A1(n44), .B0(n76), .Y(n2) );
  NOR2XL U39 ( .A(N139), .B(n2), .Y(N117) );
  INVXL U40 ( .A(N139), .Y(n25) );
  NOR2XL U41 ( .A(n25), .B(n2), .Y(N118) );
  NOR2XL U42 ( .A(n66), .B(n2), .Y(N124) );
  NOR2XL U43 ( .A(num[3]), .B(num[4]), .Y(n45) );
  INVXL U44 ( .A(n45), .Y(n20) );
  NAND2XL U45 ( .A(num[0]), .B(num[2]), .Y(n60) );
  INVXL U46 ( .A(n60), .Y(n67) );
  NAND2XL U47 ( .A(n67), .B(n73), .Y(n3) );
  NAND2XL U48 ( .A(num[1]), .B(num[2]), .Y(n8) );
  INVXL U49 ( .A(n8), .Y(n4) );
  NAND2XL U50 ( .A(n4), .B(n71), .Y(n59) );
  NAND2XL U51 ( .A(n3), .B(n59), .Y(n6) );
  NOR2XL U52 ( .A(n79), .B(num[4]), .Y(n13) );
  NAND2XL U53 ( .A(n13), .B(n8), .Y(n64) );
  NOR2XL U54 ( .A(n75), .B(num[3]), .Y(n62) );
  NAND2XL U55 ( .A(n62), .B(n4), .Y(n5) );
  INVXL U56 ( .A(n62), .Y(n29) );
  NOR2XL U57 ( .A(n73), .B(n71), .Y(n48) );
  NOR2XL U58 ( .A(num[2]), .B(n48), .Y(n47) );
  INVXL U59 ( .A(n13), .Y(n23) );
  INVXL U60 ( .A(n6), .Y(n7) );
  OAI222XL U61 ( .A0(n8), .A1(n20), .B0(n29), .B1(n47), .C0(n23), .C1(n7), .Y(
        n9) );
  NAND2XL U62 ( .A(num[4]), .B(n44), .Y(n58) );
  NOR2XL U63 ( .A(n79), .B(n58), .Y(n38) );
  NOR2XL U64 ( .A(location[2]), .B(n11), .Y(N120) );
  NAND2XL U65 ( .A(n13), .B(n72), .Y(n12) );
  NOR2XL U66 ( .A(location[2]), .B(n15), .Y(N115) );
  NOR2XL U67 ( .A(n73), .B(num[2]), .Y(n22) );
  INVXL U68 ( .A(n22), .Y(n17) );
  NAND2XL U69 ( .A(num[2]), .B(n73), .Y(n34) );
  NAND2XL U70 ( .A(n17), .B(n34), .Y(n35) );
  NAND2XL U71 ( .A(n73), .B(n71), .Y(n49) );
  AOI33XL U72 ( .A0(num[1]), .A1(n71), .A2(n72), .B0(num[0]), .B1(num[2]), 
        .B2(n73), .Y(n21) );
  INVXL U73 ( .A(n18), .Y(n19) );
  OAI222XL U74 ( .A0(n23), .A1(n22), .B0(n29), .B1(n21), .C0(n20), .C1(n19), 
        .Y(n24) );
  NOR2XL U75 ( .A(location[2]), .B(n27), .Y(N114) );
  NAND2XL U76 ( .A(n28), .B(n35), .Y(n30) );
  AO22XL U77 ( .A0(n75), .A1(n67), .B0(n30), .B1(n62), .Y(n32) );
  OAI22XL U78 ( .A0(n67), .A1(num[4]), .B0(n30), .B1(n29), .Y(n31) );
  NOR2XL U79 ( .A(location[2]), .B(n33), .Y(N119) );
  MX2XL U80 ( .A(n35), .B(n34), .S0(n71), .Y(n36) );
  AOI22XL U81 ( .A0(N139), .A1(n38), .B0(n62), .B1(n37), .Y(n42) );
  NAND2XL U82 ( .A(num[0]), .B(n72), .Y(n40) );
  NAND2XL U83 ( .A(N139), .B(n40), .Y(n39) );
  AOI21XL U84 ( .A0(n42), .A1(n41), .B0(location[2]), .Y(N113) );
  OR4X1 U85 ( .A(n71), .B(n43), .C(num[1]), .D(num[2]), .Y(n52) );
  NAND3X1 U86 ( .A(n52), .B(n46), .C(n51), .Y(n55) );
  NOR2XL U87 ( .A(num[0]), .B(n55), .Y(net7148) );
  NAND2XL U88 ( .A(num[2]), .B(n48), .Y(n57) );
  OAI211X1 U89 ( .A0(n53), .A1(n52), .B0(n80), .C0(n51), .Y(net7154) );
  NOR2XL U90 ( .A(n79), .B(n57), .Y(n56) );
  INVXL U91 ( .A(n56), .Y(n54) );
  AOI211XL U92 ( .A0(n79), .A1(n57), .B0(n56), .C0(n55), .Y(net7145) );
  INVXL U93 ( .A(n58), .Y(n63) );
  AOI21XL U94 ( .A0(n60), .A1(n59), .B0(num[4]), .Y(n61) );
  OA21X1 U95 ( .A0(qr_total[0]), .A1(qr_total[1]), .B0(n68), .Y(N144) );
  SNPS_CLOCK_GATE_HIGH_NUM_CALCULATE_mydesign_0 clk_gate_num_reg ( .CLK(clk), 
        .EN(net7143), .ENCLK(net7151) );
  SNPS_CLOCK_GATE_HIGH_NUM_CALCULATE_mydesign_2 clk_gate_location_reg ( .CLK(
        clk), .EN(net7154), .ENCLK(net7157) );
  SNPS_CLOCK_GATE_HIGH_NUM_CALCULATE_mydesign_1 clk_gate_qr_total_reg ( .CLK(
        clk), .EN(net7160), .ENCLK(net7163) );
  XNOR2XL U4 ( .A(n36), .B(N139), .Y(n37) );
  NOR2BXL U6 ( .AN(n50), .B(n76), .Y(num_complete) );
  AOI221XL U8 ( .A0(n66), .A1(n10), .B0(n74), .B1(n9), .C0(n38), .Y(n11) );
  OAI32XL U9 ( .A0(n66), .A1(n38), .A2(n32), .B0(n31), .B1(n74), .Y(n33) );
  AOI221XL U16 ( .A0(n67), .A1(n65), .B0(n64), .B1(n65), .C0(location[2]), .Y(
        N121) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_0 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_15 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_14 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_13 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_12 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_11 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_10 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_9 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_8 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_7 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_6 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_5 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_4 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_3 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_2 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_1 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   net7049;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(net7049) );
  AND2XL main_gate ( .A(net7049), .B(CLK), .Y(ENCLK) );
endmodule


module DEMASKING ( clk, srst_n, state, sram_rdata, loc_x, loc_y, rotation_type, 
        mask_addr, code_word, demask_complete );
  input [3:0] state;
  input [5:0] loc_x;
  input [5:0] loc_y;
  input [1:0] rotation_type;
  output [11:0] mask_addr;
  output [151:0] code_word;
  input clk, srst_n, sram_rdata;
  output demask_complete;
  wire   N191, N192, N193, N194, N195, N196, N197, N198, N1492, N1499, N1537,
         N1538, N1540, N1541, N1542, N1543, N1544, N1545, N1546, N1547, N1548,
         N1583, N1584, N1585, N1586, N1587, N1588, N1589, N1590, N1591, N1673,
         xor_in, N1735, N1783, demask_result, net7052, net7056, net7061,
         net7066, net7071, net7076, net7081, net7086, net7091, net7096,
         net7101, net7106, net7111, net7116, net7121, net7126, net7131, n38,
         n55, n58, n61, n64, n348, n370, n389, n391, n392, n393, n394, n395,
         n396, n397, n398, n399, n400, n401, n402, intadd_2_A_9_,
         intadd_2_A_8_, intadd_2_A_7_, intadd_2_A_6_, intadd_2_B_9_,
         intadd_2_B_8_, intadd_2_B_7_, intadd_2_B_6_, intadd_2_B_5_,
         intadd_2_CI, intadd_2_SUM_1_, intadd_2_n10, intadd_2_n9, intadd_2_n8,
         intadd_2_n7, intadd_2_n6, intadd_2_n5, intadd_2_n4, intadd_2_n3,
         intadd_2_n2, intadd_2_n1, intadd_3_CI, intadd_3_SUM_3_,
         intadd_3_SUM_2_, intadd_3_SUM_1_, intadd_3_SUM_0_, intadd_3_n4,
         intadd_3_n3, intadd_3_n2, intadd_3_n1, n1, n2, n3, n4, n5, n6, n7, n8,
         n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22,
         n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33, n34, n35, n36,
         n37, n39, n40, n41, n42, n43, n44, n45, n46, n47, n48, n49, n50, n51,
         n52, n53, n54, n56, n57, n59, n60, n62, n63, n65, n66, n67, n68, n69,
         n70, n71, n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83,
         n84, n85, n86, n87, n88, n89, n90, n91, n92, n93, n94, n95, n96, n97,
         n98, n99, n100, n101, n102, n103, n104, n105, n106, n107, n108, n109,
         n110, n111, n112, n113, n114, n115, n116, n117, n118, n119, n120,
         n121, n122, n123, n124, n125, n126, n127, n128, n129, n130, n131,
         n132, n133, n134, n135, n136, n137, n138, n139, n140, n141, n142,
         n143, n144, n145, n146, n147, n148, n149, n150, n151, n152, n153,
         n154, n155, n156, n157, n158, n159, n160, n161, n162, n163, n164,
         n165, n166, n167, n168, n169, n170, n171, n172, n173, n174, n175,
         n176, n177, n178, n179, n180, n181, n182, n183, n184, n185, n186,
         n187, n188, n189, n190, n1910, n1920, n1930, n1940, n1950, n1960,
         n1970, n1980, n199, n200, n201, n202, n203, n204, n205, n206, n207,
         n208, n209, n210, n211, n212, n213, n214, n215, n216, n217, n218,
         n219, n220, n221, n222, n223, n224, n225, n226, n227, n228, n229,
         n230, n231, n232, n233, n234, n235, n236, n237, n238, n239, n240,
         n241, n242, n243, n244, n245, n246, n247, n248, n249, n250, n251,
         n252, n253, n254, n255, n256, n257, n258, n259, n260, n261, n262,
         n263, n264, n265, n266, n267, n268, n269, n270, n271, n272, n273,
         n274, n275, n276, n277, n278, n279, n280, n281, n282, n283, n284,
         n285, n286, n287, n288, n289, n290, n291, n292, n293, n294, n295,
         n296, n297, n298, n299, n300, n301, n302, n303, n304, n305, n306,
         n307, n308, n309, n310, n311, n312, n313, n314, n315, n316, n317,
         n318, n319, n320, n321, n322, n323, n324, n325, n326, n327, n328,
         n329, n330, n331, n332, n333, n334, n335, n336, n337, n338, n339,
         n340, n341, n342, n343, n344, n345, n346, n347, n349, n350, n351,
         n352, n353, n354, n355, n356, n357, n358, n359, n360, n361, n362,
         n363, n364, n365, n366, n367, n368, n369, n371, n372, n373, n374,
         n375, n376, n377, n378, n379, n380, n381, n382, n383, n384, n385,
         n386, n387, n388, n390, n403, n404, n405, n406, n407, n408, n409,
         n410, n411, n413, n414, n416, n417, n418, n419, n420, n421, n422,
         n423, n424, n425, n426, n427, n428, n429, n430, n431, n432, n433,
         n434, n435, n436, n437, n438, n439, n440, n441, n442, n443, n444,
         n445, n446, n447, n448, n449, n450, n451, n452, n453, n454, n455,
         n456, n457, n458, n459, n460, n461, n462, n463, n464, n466, n467,
         n468, n469, n470, n471, n472, n473, n474, n475, n476, n477, n478,
         n479, n480, n481, n482, n483, n484, n485, n486, n487, n488, n489,
         n490, n491, n492, n493, n494, n495, n496, n497, n498, n499, n500,
         n501, n502, n503, n504, n505, n506, n507, n508, n509, n510, n511,
         n512, n513, n514, n515, n516, n517, n518, n519, n520, n521, n522,
         n523, n524, n525, n526, n527, n528, n529, n530, n531, n532, n533,
         n534, n535, n536, n537, n538, n539, n540, n541, n542, n543, n544,
         n545, n546, n547, n548, n549, n550, n551, n552, n553, n554, n555,
         n556, n557, n558, n559, n560, n561, n562, n563, n564, n565, n566,
         n567, n568, n569, n570, n571, n572, n573, n574, n575, n576, n578,
         n579, n580, n581, n582, n583, n584, n585, n586, n587, n588, n589,
         n590, n591, n592, n593;
  wire   [7:0] demask_cnt;
  wire   [4:0] i;
  wire   [4:0] j;
  wire   [4:1] i_old;
  wire   [4:1] j_old;
  wire   [11:6] i_mul;
  wire   [11:0] j_mul;
  wire   [2:0] mask;
  wire   [4:0] i_old2;
  wire   [4:0] j_old2;

  DFFTRXL demask_cnt_reg_1_ ( .D(n587), .RN(N192), .CK(clk), .Q(demask_cnt[1]), 
        .QN(n564) );
  DFFTRXL demask_cnt_reg_2_ ( .D(n587), .RN(N193), .CK(clk), .Q(demask_cnt[2]), 
        .QN(n566) );
  DFFTRXL demask_cnt_reg_4_ ( .D(n587), .RN(N195), .CK(clk), .Q(demask_cnt[4]), 
        .QN(n561) );
  DFFTRXL demask_cnt_reg_5_ ( .D(n587), .RN(N196), .CK(clk), .Q(demask_cnt[5]), 
        .QN(n568) );
  DFFTRXL demask_cnt_reg_6_ ( .D(n587), .RN(N197), .CK(clk), .Q(demask_cnt[6]), 
        .QN(n562) );
  DFFTRXL demask_cnt_reg_7_ ( .D(n587), .RN(N198), .CK(clk), .Q(demask_cnt[7]), 
        .QN(n563) );
  SMDFFHQX1 mask_addr_reg_11_ ( .D0(N1591), .D1(N1548), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[11]) );
  SMDFFHQX1 mask_addr_reg_10_ ( .D0(N1590), .D1(N1547), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[10]) );
  SMDFFHQX1 mask_addr_reg_9_ ( .D0(N1589), .D1(N1546), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[9]) );
  SMDFFHQX1 mask_addr_reg_8_ ( .D0(N1588), .D1(N1545), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[8]) );
  SMDFFHQX1 mask_addr_reg_7_ ( .D0(N1587), .D1(N1544), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[7]) );
  SMDFFHQX1 mask_addr_reg_6_ ( .D0(N1586), .D1(N1543), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[6]) );
  SMDFFHQX1 mask_addr_reg_5_ ( .D0(N1585), .D1(N1542), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[5]) );
  SMDFFHQX1 mask_addr_reg_4_ ( .D0(N1584), .D1(N1541), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[4]) );
  SMDFFHQX1 mask_addr_reg_3_ ( .D0(N1583), .D1(N1540), .SI(N1735), .S0(n589), 
        .SE(n588), .CK(clk), .Q(mask_addr[3]) );
  DFFTRXL mask_addr_reg_2_ ( .D(n586), .RN(N1673), .CK(clk), .Q(mask_addr[2])
         );
  DFFTRXL mask_addr_reg_1_ ( .D(n586), .RN(N1538), .CK(clk), .Q(mask_addr[1])
         );
  DFFTRXL mask_addr_reg_0_ ( .D(n586), .RN(N1537), .CK(clk), .Q(mask_addr[0])
         );
  DFFTRXL mask_reg_2_ ( .D(n586), .RN(n392), .CK(clk), .Q(mask[2]), .QN(n16)
         );
  DFFTRXL mask_reg_0_ ( .D(n586), .RN(n389), .CK(clk), .Q(mask[0]), .QN(n9) );
  DFFTRXL i_old_reg_4_ ( .D(n586), .RN(i[4]), .CK(clk), .Q(i_old[4]) );
  DFFTRXL i_old_reg_3_ ( .D(n586), .RN(i[3]), .CK(clk), .Q(i_old[3]) );
  DFFTRXL i_old_reg_2_ ( .D(n586), .RN(i[2]), .CK(clk), .Q(i_old[2]), .QN(n572) );
  DFFTRXL i_old_reg_1_ ( .D(n586), .RN(i[1]), .CK(clk), .Q(i_old[1]) );
  DFFTRXL i_old_reg_0_ ( .D(n586), .RN(i[0]), .CK(clk), .Q(N1492) );
  DFFTRXL j_old_reg_4_ ( .D(n586), .RN(j[4]), .CK(clk), .Q(j_old[4]), .QN(n573) );
  DFFTRXL j_old_reg_3_ ( .D(n586), .RN(j[3]), .CK(clk), .Q(j_old[3]), .QN(n38)
         );
  DFFTRXL j_old_reg_2_ ( .D(n586), .RN(j[2]), .CK(clk), .Q(j_old[2]) );
  DFFTRXL j_old_reg_1_ ( .D(n586), .RN(j[1]), .CK(clk), .Q(j_old[1]), .QN(n61)
         );
  DFFTRXL j_old_reg_0_ ( .D(n586), .RN(j[0]), .CK(clk), .Q(N1499), .QN(n58) );
  SMDFFHQX1 i_mul_reg_6_ ( .D0(N1492), .D1(N1499), .SI(N1735), .S0(n64), .SE(
        n588), .CK(clk), .Q(i_mul[6]) );
  SMDFFHQX1 j_mul_reg_0_ ( .D0(N1499), .D1(N1492), .SI(N1735), .S0(n64), .SE(
        n588), .CK(clk), .Q(j_mul[0]) );
  DFFTRXL i_mul_reg_7_ ( .D(n586), .RN(n402), .CK(clk), .Q(i_mul[7]) );
  DFFTRXL j_mul_reg_1_ ( .D(n586), .RN(n401), .CK(clk), .Q(j_mul[1]) );
  DFFTRXL i_mul_reg_8_ ( .D(n586), .RN(n400), .CK(clk), .Q(i_mul[8]) );
  DFFTRXL j_mul_reg_2_ ( .D(n586), .RN(n399), .CK(clk), .Q(j_mul[2]) );
  DFFTRXL i_mul_reg_9_ ( .D(n585), .RN(n398), .CK(clk), .Q(i_mul[9]) );
  DFFTRXL j_mul_reg_3_ ( .D(n585), .RN(n397), .CK(clk), .Q(j_mul[3]) );
  DFFTRXL i_mul_reg_11_ ( .D(n585), .RN(n396), .CK(clk), .Q(i_mul[11]) );
  SMDFFHQX1 j_mul_reg_6_ ( .D0(N1735), .D1(n578), .SI(N1735), .S0(n395), .SE(
        n55), .CK(clk), .Q(j_mul[6]) );
  SMDFFHQX1 j_mul_reg_11_ ( .D0(N1735), .D1(n578), .SI(N1735), .S0(n395), .SE(
        n55), .CK(clk), .Q(j_mul[11]) );
  SMDFFHQX1 j_mul_reg_10_ ( .D0(N1735), .D1(n578), .SI(N1735), .S0(n395), .SE(
        n55), .CK(clk), .Q(j_mul[10]) );
  SMDFFHQX1 j_mul_reg_9_ ( .D0(N1735), .D1(n578), .SI(N1735), .S0(n395), .SE(
        n55), .CK(clk), .Q(j_mul[9]) );
  SMDFFHQX1 j_mul_reg_8_ ( .D0(N1735), .D1(n578), .SI(N1735), .S0(n395), .SE(
        n55), .CK(clk), .Q(j_mul[8]) );
  SMDFFHQX1 j_mul_reg_7_ ( .D0(N1735), .D1(n578), .SI(N1735), .S0(n395), .SE(
        n55), .CK(clk), .Q(j_mul[7]) );
  DFFTRXL j_mul_reg_5_ ( .D(n585), .RN(n395), .CK(clk), .Q(j_mul[5]) );
  DFFTRXL i_mul_reg_10_ ( .D(n585), .RN(n394), .CK(clk), .Q(i_mul[10]) );
  DFFTRXL j_mul_reg_4_ ( .D(n585), .RN(n393), .CK(clk), .Q(j_mul[4]) );
  DFFTRXL i_old2_reg_3_ ( .D(n585), .RN(i_old[3]), .CK(clk), .Q(n13), .QN(n575) );
  DFFTRXL j_old2_reg_4_ ( .D(n585), .RN(j_old[4]), .CK(clk), .Q(j_old2[4]), 
        .QN(n348) );
  DFFTRXL j_old2_reg_0_ ( .D(n585), .RN(N1499), .CK(clk), .Q(j_old2[0]), .QN(
        n370) );
  DFFTRXL xor_in_reg ( .D(n585), .RN(N1783), .CK(clk), .Q(xor_in) );
  DFFTRXL code_word_reg_0_ ( .D(n585), .RN(demask_result), .CK(net7131), .Q(
        code_word[0]) );
  DFFTRXL code_word_reg_1_ ( .D(n585), .RN(code_word[0]), .CK(net7131), .Q(
        code_word[1]) );
  DFFTRXL code_word_reg_2_ ( .D(n585), .RN(code_word[1]), .CK(net7131), .Q(
        code_word[2]) );
  DFFTRXL code_word_reg_3_ ( .D(n584), .RN(code_word[2]), .CK(net7131), .Q(
        code_word[3]) );
  DFFTRXL code_word_reg_4_ ( .D(n584), .RN(code_word[3]), .CK(net7131), .Q(
        code_word[4]) );
  DFFTRXL code_word_reg_5_ ( .D(n584), .RN(code_word[4]), .CK(net7131), .Q(
        code_word[5]) );
  DFFTRXL code_word_reg_6_ ( .D(n584), .RN(code_word[5]), .CK(net7131), .Q(
        code_word[6]) );
  DFFTRXL code_word_reg_7_ ( .D(n584), .RN(code_word[6]), .CK(net7131), .Q(
        code_word[7]) );
  DFFTRXL code_word_reg_8_ ( .D(n584), .RN(code_word[7]), .CK(net7131), .Q(
        code_word[8]) );
  DFFTRXL code_word_reg_9_ ( .D(n584), .RN(code_word[8]), .CK(net7126), .Q(
        code_word[9]) );
  DFFTRXL code_word_reg_10_ ( .D(n584), .RN(code_word[9]), .CK(net7126), .Q(
        code_word[10]) );
  DFFTRXL code_word_reg_11_ ( .D(n584), .RN(code_word[10]), .CK(net7126), .Q(
        code_word[11]) );
  DFFTRXL code_word_reg_12_ ( .D(n584), .RN(code_word[11]), .CK(net7126), .Q(
        code_word[12]) );
  DFFTRXL code_word_reg_13_ ( .D(n584), .RN(code_word[12]), .CK(net7126), .Q(
        code_word[13]) );
  DFFTRXL code_word_reg_14_ ( .D(n584), .RN(code_word[13]), .CK(net7126), .Q(
        code_word[14]) );
  DFFTRXL code_word_reg_15_ ( .D(n584), .RN(code_word[14]), .CK(net7126), .Q(
        code_word[15]) );
  DFFTRXL code_word_reg_16_ ( .D(n584), .RN(code_word[15]), .CK(net7126), .Q(
        code_word[16]) );
  DFFTRXL code_word_reg_17_ ( .D(n584), .RN(code_word[16]), .CK(net7126), .Q(
        code_word[17]) );
  DFFTRXL code_word_reg_18_ ( .D(n584), .RN(code_word[17]), .CK(net7121), .Q(
        code_word[18]) );
  DFFTRXL code_word_reg_19_ ( .D(n584), .RN(code_word[18]), .CK(net7121), .Q(
        code_word[19]) );
  DFFTRXL code_word_reg_20_ ( .D(n584), .RN(code_word[19]), .CK(net7121), .Q(
        code_word[20]) );
  DFFTRXL code_word_reg_21_ ( .D(n584), .RN(code_word[20]), .CK(net7121), .Q(
        code_word[21]) );
  DFFTRXL code_word_reg_22_ ( .D(n584), .RN(code_word[21]), .CK(net7121), .Q(
        code_word[22]) );
  DFFTRXL code_word_reg_23_ ( .D(n583), .RN(code_word[22]), .CK(net7121), .Q(
        code_word[23]) );
  DFFTRXL code_word_reg_24_ ( .D(n583), .RN(code_word[23]), .CK(net7121), .Q(
        code_word[24]) );
  DFFTRXL code_word_reg_25_ ( .D(n583), .RN(code_word[24]), .CK(net7121), .Q(
        code_word[25]) );
  DFFTRXL code_word_reg_26_ ( .D(n583), .RN(code_word[25]), .CK(net7121), .Q(
        code_word[26]) );
  DFFTRXL code_word_reg_27_ ( .D(n583), .RN(code_word[26]), .CK(net7116), .Q(
        code_word[27]) );
  DFFTRXL code_word_reg_28_ ( .D(n583), .RN(code_word[27]), .CK(net7116), .Q(
        code_word[28]) );
  DFFTRXL code_word_reg_29_ ( .D(n583), .RN(code_word[28]), .CK(net7116), .Q(
        code_word[29]) );
  DFFTRXL code_word_reg_30_ ( .D(n583), .RN(code_word[29]), .CK(net7116), .Q(
        code_word[30]) );
  DFFTRXL code_word_reg_31_ ( .D(n583), .RN(code_word[30]), .CK(net7116), .Q(
        code_word[31]) );
  DFFTRXL code_word_reg_32_ ( .D(n583), .RN(code_word[31]), .CK(net7116), .Q(
        code_word[32]) );
  DFFTRXL code_word_reg_33_ ( .D(n583), .RN(code_word[32]), .CK(net7116), .Q(
        code_word[33]) );
  DFFTRXL code_word_reg_34_ ( .D(n583), .RN(code_word[33]), .CK(net7116), .Q(
        code_word[34]) );
  DFFTRXL code_word_reg_35_ ( .D(n583), .RN(code_word[34]), .CK(net7116), .Q(
        code_word[35]) );
  DFFTRXL code_word_reg_36_ ( .D(n583), .RN(code_word[35]), .CK(net7111), .Q(
        code_word[36]) );
  DFFTRXL code_word_reg_37_ ( .D(n583), .RN(code_word[36]), .CK(net7111), .Q(
        code_word[37]) );
  DFFTRXL code_word_reg_38_ ( .D(n583), .RN(code_word[37]), .CK(net7111), .Q(
        code_word[38]) );
  DFFTRXL code_word_reg_39_ ( .D(n583), .RN(code_word[38]), .CK(net7111), .Q(
        code_word[39]) );
  DFFTRXL code_word_reg_40_ ( .D(n583), .RN(code_word[39]), .CK(net7111), .Q(
        code_word[40]) );
  DFFTRXL code_word_reg_41_ ( .D(n583), .RN(code_word[40]), .CK(net7111), .Q(
        code_word[41]) );
  DFFTRXL code_word_reg_42_ ( .D(n583), .RN(code_word[41]), .CK(net7111), .Q(
        code_word[42]) );
  DFFTRXL code_word_reg_43_ ( .D(n582), .RN(code_word[42]), .CK(net7111), .Q(
        code_word[43]) );
  DFFTRXL code_word_reg_44_ ( .D(n582), .RN(code_word[43]), .CK(net7111), .Q(
        code_word[44]) );
  DFFTRXL code_word_reg_45_ ( .D(n582), .RN(code_word[44]), .CK(net7106), .Q(
        code_word[45]) );
  DFFTRXL code_word_reg_46_ ( .D(n582), .RN(code_word[45]), .CK(net7106), .Q(
        code_word[46]) );
  DFFTRXL code_word_reg_47_ ( .D(n582), .RN(code_word[46]), .CK(net7106), .Q(
        code_word[47]) );
  DFFTRXL code_word_reg_48_ ( .D(n582), .RN(code_word[47]), .CK(net7106), .Q(
        code_word[48]) );
  DFFTRXL code_word_reg_49_ ( .D(n582), .RN(code_word[48]), .CK(net7106), .Q(
        code_word[49]) );
  DFFTRXL code_word_reg_50_ ( .D(n582), .RN(code_word[49]), .CK(net7106), .Q(
        code_word[50]) );
  DFFTRXL code_word_reg_51_ ( .D(n582), .RN(code_word[50]), .CK(net7106), .Q(
        code_word[51]) );
  DFFTRXL code_word_reg_52_ ( .D(n582), .RN(code_word[51]), .CK(net7106), .Q(
        code_word[52]) );
  DFFTRXL code_word_reg_53_ ( .D(n582), .RN(code_word[52]), .CK(net7106), .Q(
        code_word[53]) );
  DFFTRXL code_word_reg_54_ ( .D(n580), .RN(code_word[53]), .CK(net7101), .Q(
        code_word[54]) );
  DFFTRXL code_word_reg_55_ ( .D(n578), .RN(code_word[54]), .CK(net7101), .Q(
        code_word[55]) );
  DFFTRXL code_word_reg_56_ ( .D(n578), .RN(code_word[55]), .CK(net7101), .Q(
        code_word[56]) );
  DFFTRXL code_word_reg_57_ ( .D(n578), .RN(code_word[56]), .CK(net7101), .Q(
        code_word[57]) );
  DFFTRXL code_word_reg_58_ ( .D(n579), .RN(code_word[57]), .CK(net7101), .Q(
        code_word[58]) );
  DFFTRXL code_word_reg_59_ ( .D(n578), .RN(code_word[58]), .CK(net7101), .Q(
        code_word[59]) );
  DFFTRXL code_word_reg_60_ ( .D(n579), .RN(code_word[59]), .CK(net7101), .Q(
        code_word[60]) );
  DFFTRXL code_word_reg_61_ ( .D(n578), .RN(code_word[60]), .CK(net7101), .Q(
        code_word[61]) );
  DFFTRXL code_word_reg_62_ ( .D(n578), .RN(code_word[61]), .CK(net7101), .Q(
        code_word[62]) );
  DFFTRXL code_word_reg_63_ ( .D(n578), .RN(code_word[62]), .CK(net7096), .Q(
        code_word[63]) );
  DFFTRXL code_word_reg_64_ ( .D(n578), .RN(code_word[63]), .CK(net7096), .Q(
        code_word[64]) );
  DFFTRXL code_word_reg_65_ ( .D(n578), .RN(code_word[64]), .CK(net7096), .Q(
        code_word[65]) );
  DFFTRXL code_word_reg_66_ ( .D(n579), .RN(code_word[65]), .CK(net7096), .Q(
        code_word[66]) );
  DFFTRXL code_word_reg_67_ ( .D(n579), .RN(code_word[66]), .CK(net7096), .Q(
        code_word[67]) );
  DFFTRXL code_word_reg_68_ ( .D(n579), .RN(code_word[67]), .CK(net7096), .Q(
        code_word[68]) );
  DFFTRXL code_word_reg_69_ ( .D(n579), .RN(code_word[68]), .CK(net7096), .Q(
        code_word[69]) );
  DFFTRXL code_word_reg_70_ ( .D(n579), .RN(code_word[69]), .CK(net7096), .Q(
        code_word[70]) );
  DFFTRXL code_word_reg_71_ ( .D(n579), .RN(code_word[70]), .CK(net7096), .Q(
        code_word[71]) );
  DFFTRXL code_word_reg_72_ ( .D(n579), .RN(code_word[71]), .CK(net7091), .Q(
        code_word[72]) );
  DFFTRXL code_word_reg_73_ ( .D(n579), .RN(code_word[72]), .CK(net7091), .Q(
        code_word[73]) );
  DFFTRXL code_word_reg_74_ ( .D(n579), .RN(code_word[73]), .CK(net7091), .Q(
        code_word[74]) );
  DFFTRXL code_word_reg_75_ ( .D(n579), .RN(code_word[74]), .CK(net7091), .Q(
        code_word[75]) );
  DFFTRXL code_word_reg_76_ ( .D(n579), .RN(code_word[75]), .CK(net7091), .Q(
        code_word[76]) );
  DFFTRXL code_word_reg_77_ ( .D(n579), .RN(code_word[76]), .CK(net7091), .Q(
        code_word[77]) );
  DFFTRXL code_word_reg_78_ ( .D(n579), .RN(code_word[77]), .CK(net7091), .Q(
        code_word[78]) );
  DFFTRXL code_word_reg_79_ ( .D(n579), .RN(code_word[78]), .CK(net7091), .Q(
        code_word[79]) );
  DFFTRXL code_word_reg_80_ ( .D(n579), .RN(code_word[79]), .CK(net7091), .Q(
        code_word[80]) );
  DFFTRXL code_word_reg_81_ ( .D(n579), .RN(code_word[80]), .CK(net7091), .Q(
        code_word[81]) );
  DFFTRXL code_word_reg_82_ ( .D(n579), .RN(code_word[81]), .CK(net7086), .Q(
        code_word[82]) );
  DFFTRXL code_word_reg_83_ ( .D(n579), .RN(code_word[82]), .CK(net7086), .Q(
        code_word[83]) );
  DFFTRXL code_word_reg_84_ ( .D(n580), .RN(code_word[83]), .CK(net7086), .Q(
        code_word[84]) );
  DFFTRXL code_word_reg_85_ ( .D(n580), .RN(code_word[84]), .CK(net7086), .Q(
        code_word[85]) );
  DFFTRXL code_word_reg_86_ ( .D(n580), .RN(code_word[85]), .CK(net7086), .Q(
        code_word[86]) );
  DFFTRXL code_word_reg_87_ ( .D(n580), .RN(code_word[86]), .CK(net7086), .Q(
        code_word[87]) );
  DFFTRXL code_word_reg_88_ ( .D(n580), .RN(code_word[87]), .CK(net7086), .Q(
        code_word[88]) );
  DFFTRXL code_word_reg_89_ ( .D(n580), .RN(code_word[88]), .CK(net7086), .Q(
        code_word[89]) );
  DFFTRXL code_word_reg_90_ ( .D(n580), .RN(code_word[89]), .CK(net7086), .Q(
        code_word[90]) );
  DFFTRXL code_word_reg_91_ ( .D(n580), .RN(code_word[90]), .CK(net7086), .Q(
        code_word[91]) );
  DFFTRXL code_word_reg_92_ ( .D(n580), .RN(code_word[91]), .CK(net7081), .Q(
        code_word[92]) );
  DFFTRXL code_word_reg_93_ ( .D(n580), .RN(code_word[92]), .CK(net7081), .Q(
        code_word[93]) );
  DFFTRXL code_word_reg_94_ ( .D(n580), .RN(code_word[93]), .CK(net7081), .Q(
        code_word[94]) );
  DFFTRXL code_word_reg_95_ ( .D(n580), .RN(code_word[94]), .CK(net7081), .Q(
        code_word[95]) );
  DFFTRXL code_word_reg_96_ ( .D(n580), .RN(code_word[95]), .CK(net7081), .Q(
        code_word[96]) );
  DFFTRXL code_word_reg_97_ ( .D(n580), .RN(code_word[96]), .CK(net7081), .Q(
        code_word[97]) );
  DFFTRXL code_word_reg_98_ ( .D(n580), .RN(code_word[97]), .CK(net7081), .Q(
        code_word[98]) );
  DFFTRXL code_word_reg_99_ ( .D(n580), .RN(code_word[98]), .CK(net7081), .Q(
        code_word[99]) );
  DFFTRXL code_word_reg_100_ ( .D(n580), .RN(code_word[99]), .CK(net7081), .Q(
        code_word[100]) );
  DFFTRXL code_word_reg_101_ ( .D(n580), .RN(code_word[100]), .CK(net7081), 
        .Q(code_word[101]) );
  DFFTRXL code_word_reg_102_ ( .D(n582), .RN(code_word[101]), .CK(net7076), 
        .Q(code_word[102]) );
  DFFTRXL code_word_reg_103_ ( .D(n580), .RN(code_word[102]), .CK(net7076), 
        .Q(code_word[103]) );
  DFFTRXL code_word_reg_104_ ( .D(n578), .RN(code_word[103]), .CK(net7076), 
        .Q(code_word[104]) );
  DFFTRXL code_word_reg_105_ ( .D(n578), .RN(code_word[104]), .CK(net7076), 
        .Q(code_word[105]) );
  DFFTRXL code_word_reg_106_ ( .D(n578), .RN(code_word[105]), .CK(net7076), 
        .Q(code_word[106]) );
  DFFTRXL code_word_reg_107_ ( .D(srst_n), .RN(code_word[106]), .CK(net7076), 
        .Q(code_word[107]) );
  DFFTRXL code_word_reg_108_ ( .D(srst_n), .RN(code_word[107]), .CK(net7076), 
        .Q(code_word[108]) );
  DFFTRXL code_word_reg_109_ ( .D(srst_n), .RN(code_word[108]), .CK(net7076), 
        .Q(code_word[109]) );
  DFFTRXL code_word_reg_110_ ( .D(srst_n), .RN(code_word[109]), .CK(net7076), 
        .Q(code_word[110]) );
  DFFTRXL code_word_reg_111_ ( .D(n587), .RN(code_word[110]), .CK(net7076), 
        .Q(code_word[111]) );
  DFFTRXL code_word_reg_112_ ( .D(n587), .RN(code_word[111]), .CK(net7071), 
        .Q(code_word[112]) );
  DFFTRXL code_word_reg_113_ ( .D(n587), .RN(code_word[112]), .CK(net7071), 
        .Q(code_word[113]) );
  DFFTRXL code_word_reg_114_ ( .D(n587), .RN(code_word[113]), .CK(net7071), 
        .Q(code_word[114]) );
  DFFTRXL code_word_reg_115_ ( .D(n587), .RN(code_word[114]), .CK(net7071), 
        .Q(code_word[115]) );
  DFFTRXL code_word_reg_116_ ( .D(n587), .RN(code_word[115]), .CK(net7071), 
        .Q(code_word[116]) );
  DFFTRXL code_word_reg_117_ ( .D(n587), .RN(code_word[116]), .CK(net7071), 
        .Q(code_word[117]) );
  DFFTRXL code_word_reg_118_ ( .D(n587), .RN(code_word[117]), .CK(net7071), 
        .Q(code_word[118]) );
  DFFTRXL code_word_reg_119_ ( .D(n587), .RN(code_word[118]), .CK(net7071), 
        .Q(code_word[119]) );
  DFFTRXL code_word_reg_120_ ( .D(n587), .RN(code_word[119]), .CK(net7071), 
        .Q(code_word[120]) );
  DFFTRXL code_word_reg_121_ ( .D(n587), .RN(code_word[120]), .CK(net7071), 
        .Q(code_word[121]) );
  DFFTRXL code_word_reg_122_ ( .D(n587), .RN(code_word[121]), .CK(net7066), 
        .Q(code_word[122]) );
  DFFTRXL code_word_reg_123_ ( .D(n587), .RN(code_word[122]), .CK(net7066), 
        .Q(code_word[123]) );
  DFFTRXL code_word_reg_124_ ( .D(n581), .RN(code_word[123]), .CK(net7066), 
        .Q(code_word[124]) );
  DFFTRXL code_word_reg_125_ ( .D(n581), .RN(code_word[124]), .CK(net7066), 
        .Q(code_word[125]) );
  DFFTRXL code_word_reg_126_ ( .D(n581), .RN(code_word[125]), .CK(net7066), 
        .Q(code_word[126]) );
  DFFTRXL code_word_reg_127_ ( .D(n581), .RN(code_word[126]), .CK(net7066), 
        .Q(code_word[127]) );
  DFFTRXL code_word_reg_128_ ( .D(n581), .RN(code_word[127]), .CK(net7066), 
        .Q(code_word[128]) );
  DFFTRXL code_word_reg_129_ ( .D(n581), .RN(code_word[128]), .CK(net7066), 
        .Q(code_word[129]) );
  DFFTRXL code_word_reg_130_ ( .D(n581), .RN(code_word[129]), .CK(net7066), 
        .Q(code_word[130]) );
  DFFTRXL code_word_reg_131_ ( .D(n581), .RN(code_word[130]), .CK(net7066), 
        .Q(code_word[131]) );
  DFFTRXL code_word_reg_132_ ( .D(n581), .RN(code_word[131]), .CK(net7061), 
        .Q(code_word[132]) );
  DFFTRXL code_word_reg_133_ ( .D(n581), .RN(code_word[132]), .CK(net7061), 
        .Q(code_word[133]) );
  DFFTRXL code_word_reg_134_ ( .D(n581), .RN(code_word[133]), .CK(net7061), 
        .Q(code_word[134]) );
  DFFTRXL code_word_reg_135_ ( .D(n581), .RN(code_word[134]), .CK(net7061), 
        .Q(code_word[135]) );
  DFFTRXL code_word_reg_136_ ( .D(n581), .RN(code_word[135]), .CK(net7061), 
        .Q(code_word[136]) );
  DFFTRXL code_word_reg_137_ ( .D(n581), .RN(code_word[136]), .CK(net7061), 
        .Q(code_word[137]) );
  DFFTRXL code_word_reg_138_ ( .D(n581), .RN(code_word[137]), .CK(net7061), 
        .Q(code_word[138]) );
  DFFTRXL code_word_reg_139_ ( .D(n581), .RN(code_word[138]), .CK(net7061), 
        .Q(code_word[139]) );
  DFFTRXL code_word_reg_140_ ( .D(n581), .RN(code_word[139]), .CK(net7061), 
        .Q(code_word[140]) );
  DFFTRXL code_word_reg_141_ ( .D(n581), .RN(code_word[140]), .CK(net7061), 
        .Q(code_word[141]) );
  DFFTRXL code_word_reg_142_ ( .D(n581), .RN(code_word[141]), .CK(net7056), 
        .Q(code_word[142]) );
  DFFTRXL code_word_reg_143_ ( .D(n581), .RN(code_word[142]), .CK(net7056), 
        .Q(code_word[143]) );
  DFFTRXL code_word_reg_144_ ( .D(n582), .RN(code_word[143]), .CK(net7056), 
        .Q(code_word[144]) );
  DFFTRXL code_word_reg_145_ ( .D(n582), .RN(code_word[144]), .CK(net7056), 
        .Q(code_word[145]) );
  DFFTRXL code_word_reg_146_ ( .D(n582), .RN(code_word[145]), .CK(net7056), 
        .Q(code_word[146]) );
  DFFTRXL code_word_reg_147_ ( .D(n582), .RN(code_word[146]), .CK(net7056), 
        .Q(code_word[147]) );
  DFFTRXL code_word_reg_148_ ( .D(n582), .RN(code_word[147]), .CK(net7056), 
        .Q(code_word[148]) );
  DFFTRXL code_word_reg_149_ ( .D(n582), .RN(code_word[148]), .CK(net7056), 
        .Q(code_word[149]) );
  DFFTRXL code_word_reg_150_ ( .D(n582), .RN(code_word[149]), .CK(net7056), 
        .Q(code_word[150]) );
  DFFTRXL code_word_reg_151_ ( .D(n582), .RN(code_word[150]), .CK(net7056), 
        .Q(code_word[151]) );
  ADDFX1 intadd_2_U11 ( .A(j_mul[1]), .B(loc_x[1]), .CI(intadd_2_CI), .CO(
        intadd_2_n10), .S(N1538) );
  ADDFX1 intadd_2_U10 ( .A(j_mul[2]), .B(loc_x[2]), .CI(intadd_2_n10), .CO(
        intadd_2_n9), .S(intadd_2_SUM_1_) );
  ADDFX1 intadd_2_U9 ( .A(j_mul[3]), .B(loc_x[3]), .CI(intadd_2_n9), .CO(
        intadd_2_n8), .S(N1540) );
  ADDFX1 intadd_2_U8 ( .A(j_mul[4]), .B(loc_x[4]), .CI(intadd_2_n8), .CO(
        intadd_2_n7), .S(N1541) );
  ADDFX1 intadd_2_U7 ( .A(j_mul[5]), .B(loc_x[5]), .CI(intadd_2_n7), .CO(
        intadd_2_n6), .S(N1542) );
  ADDFX1 intadd_2_U6 ( .A(intadd_2_B_5_), .B(j_mul[6]), .CI(intadd_2_n6), .CO(
        intadd_2_n5), .S(N1543) );
  ADDFX1 intadd_2_U5 ( .A(intadd_2_B_6_), .B(intadd_2_A_6_), .CI(intadd_2_n5), 
        .CO(intadd_2_n4), .S(N1544) );
  ADDFX1 intadd_2_U4 ( .A(intadd_2_B_7_), .B(intadd_2_A_7_), .CI(intadd_2_n4), 
        .CO(intadd_2_n3), .S(N1545) );
  ADDFX1 intadd_2_U3 ( .A(intadd_2_B_8_), .B(intadd_2_A_8_), .CI(intadd_2_n3), 
        .CO(intadd_2_n2), .S(N1546) );
  ADDFX1 intadd_2_U2 ( .A(intadd_2_B_9_), .B(intadd_2_A_9_), .CI(intadd_2_n2), 
        .CO(intadd_2_n1), .S(N1547) );
  DFFTRXL demask_cnt_reg_0_ ( .D(n578), .RN(N191), .CK(clk), .Q(demask_cnt[0]), 
        .QN(n569) );
  DFFTRXL demask_cnt_reg_3_ ( .D(n587), .RN(N194), .CK(clk), .Q(demask_cnt[3]), 
        .QN(n567) );
  DFFTRXL i_old2_reg_1_ ( .D(n585), .RN(i_old[1]), .CK(clk), .Q(i_old2[1]), 
        .QN(n35) );
  DFFTRXL j_old2_reg_2_ ( .D(n585), .RN(j_old[2]), .CK(clk), .Q(j_old2[2]), 
        .QN(n36) );
  DFFTRXL j_old2_reg_3_ ( .D(n585), .RN(j_old[3]), .CK(clk), .Q(j_old2[3]), 
        .QN(n570) );
  DFFTRXL mask_reg_1_ ( .D(n586), .RN(n391), .CK(clk), .Q(mask[1]), .QN(n574)
         );
  DFFTRXL i_old2_reg_2_ ( .D(n585), .RN(i_old[2]), .CK(clk), .Q(i_old2[2]), 
        .QN(n37) );
  DFFTRX1 i_old2_reg_4_ ( .D(n585), .RN(i_old[4]), .CK(clk), .Q(i_old2[4]), 
        .QN(n576) );
  NOR4X1 U5 ( .A(n152), .B(n170), .C(n151), .D(n150), .Y(n167) );
  NOR2BXL U13 ( .AN(n442), .B(n441), .Y(n426) );
  OAI221XL U15 ( .A0(n271), .A1(n114), .B0(n278), .B1(n114), .C0(n269), .Y(
        n115) );
  AOI31XL U16 ( .A0(n267), .A1(n251), .A2(n148), .B0(n133), .Y(n57) );
  OAI2BB1XL U18 ( .A0N(loc_y[4]), .A1N(n509), .B0(n216), .Y(n40) );
  AOI32XL U19 ( .A0(demask_cnt[2]), .A1(demask_cnt[1]), .A2(n243), .B0(n242), 
        .B1(n564), .Y(n245) );
  NOR4XL U20 ( .A(n561), .B(n563), .C(n273), .D(demask_cnt[3]), .Y(n163) );
  OAI211XL U21 ( .A0(n206), .A1(n282), .B0(n1950), .C0(n1940), .Y(n285) );
  NOR4XL U23 ( .A(n282), .B(n567), .C(n56), .D(n138), .Y(demask_complete) );
  AOI31XL U24 ( .A0(n556), .A1(n555), .A2(n573), .B0(n395), .Y(n557) );
  NOR4XL U25 ( .A(n250), .B(n1910), .C(n127), .D(n126), .Y(n165) );
  OAI211XL U26 ( .A0(n289), .A1(n516), .B0(n288), .C0(n287), .Y(i[1]) );
  NOR2XL U27 ( .A(n575), .B(n571), .Y(n325) );
  OAI31XL U28 ( .A0(n477), .A1(n571), .A2(n476), .B0(n475), .Y(n499) );
  NOR2BXL U30 ( .AN(i_old2[4]), .B(n36), .Y(n350) );
  OAI211XL U31 ( .A0(n4), .A1(n18), .B0(n447), .C0(n446), .Y(n452) );
  NOR2BXL U33 ( .AN(n466), .B(n34), .Y(n32) );
  NOR2XL U34 ( .A(n3), .B(n425), .Y(n435) );
  OAI2BB1X1 U35 ( .A0N(n48), .A1N(N1547), .B0(n47), .Y(N1590) );
  OAI2BB1X1 U36 ( .A0N(N1546), .A1N(n51), .B0(n48), .Y(N1589) );
  OAI2BB1X1 U37 ( .A0N(n52), .A1N(N1545), .B0(n51), .Y(N1588) );
  OAI2BB1X1 U38 ( .A0N(N1544), .A1N(n50), .B0(n52), .Y(N1587) );
  NOR4BX1 U39 ( .AN(n286), .B(n285), .C(n284), .D(n283), .Y(n287) );
  OAI2BB1X1 U40 ( .A0N(n49), .A1N(N1543), .B0(n50), .Y(N1586) );
  AOI31X1 U41 ( .A0(demask_cnt[3]), .A1(n199), .A2(n200), .B0(n166), .Y(n258)
         );
  OAI211XL U42 ( .A0(n254), .A1(n262), .B0(n253), .C0(n252), .Y(i[4]) );
  OAI211XL U43 ( .A0(n291), .A1(n257), .B0(n165), .C0(n164), .Y(n166) );
  XOR2XL U45 ( .A(n374), .B(n367), .Y(n418) );
  XOR2XL U46 ( .A(n414), .B(n413), .Y(n430) );
  NOR4X1 U47 ( .A(n129), .B(n106), .C(n105), .D(n104), .Y(n236) );
  OAI211XL U48 ( .A0(demask_cnt[0]), .A1(n257), .B0(n256), .C0(n255), .Y(n260)
         );
  OAI211XL U49 ( .A0(n262), .A1(n189), .B0(n188), .C0(n187), .Y(n190) );
  NOR4X1 U50 ( .A(n235), .B(n234), .C(n233), .D(n232), .Y(n252) );
  NOR4XL U51 ( .A(n73), .B(n95), .C(n224), .D(n54), .Y(n72) );
  AOI31XL U52 ( .A0(n503), .A1(n502), .A2(n370), .B0(n501), .Y(n504) );
  AOI31X1 U53 ( .A0(demask_cnt[6]), .A1(demask_cnt[2]), .A2(n186), .B0(n185), 
        .Y(n187) );
  OAI211XL U54 ( .A0(n516), .A1(n142), .B0(n103), .C0(n102), .Y(n104) );
  NOR4X1 U55 ( .A(n249), .B(n96), .C(n91), .D(n90), .Y(n256) );
  AOI32XL U56 ( .A0(n231), .A1(n230), .A2(n229), .B0(n228), .B1(n230), .Y(n232) );
  OAI211XL U57 ( .A0(n291), .A1(n244), .B0(n131), .C0(n294), .Y(n152) );
  OAI211XL U58 ( .A0(n125), .A1(n262), .B0(n124), .C0(n286), .Y(n126) );
  OAI211XL U59 ( .A0(n87), .A1(n281), .B0(n86), .C0(n85), .Y(n96) );
  OAI211XL U60 ( .A0(n229), .A1(n262), .B0(n97), .C0(n66), .Y(n91) );
  NOR4X1 U61 ( .A(n69), .B(n130), .C(n68), .D(n67), .Y(n102) );
  OAI211XL U62 ( .A0(n206), .A1(n273), .B0(n205), .C0(n204), .Y(n207) );
  OAI211XL U63 ( .A0(n259), .A1(n138), .B0(n135), .C0(n134), .Y(n208) );
  OAI31XL U64 ( .A0(demask_cnt[0]), .A1(n184), .A2(n261), .B0(n76), .Y(n250)
         );
  AOI32XL U65 ( .A0(n109), .A1(n57), .A2(n117), .B0(n262), .B1(n57), .Y(n59)
         );
  OAI211XL U66 ( .A0(n282), .A1(n281), .B0(n280), .C0(n279), .Y(n283) );
  OAI211XL U67 ( .A0(n184), .A1(n183), .B0(n182), .C0(n181), .Y(n185) );
  OAI211XL U68 ( .A0(n259), .A1(n291), .B0(n146), .C0(n145), .Y(n170) );
  OAI211XL U69 ( .A0(n553), .A1(n559), .B0(n552), .C0(n551), .Y(n394) );
  OAI211XL U70 ( .A0(n560), .A1(n559), .B0(n558), .C0(n557), .Y(n393) );
  AOI221X1 U71 ( .A0(demask_cnt[7]), .A1(n524), .B0(n563), .B1(n523), .C0(n522), .Y(N198) );
  OAI211XL U72 ( .A0(n38), .A1(n560), .B0(n542), .C0(n541), .Y(n398) );
  OAI211XL U73 ( .A0(n538), .A1(n553), .B0(n534), .C0(n533), .Y(n400) );
  OAI211XL U74 ( .A0(n61), .A1(n560), .B0(n527), .C0(n526), .Y(n402) );
  OAI211XL U75 ( .A0(demask_cnt[5]), .A1(n520), .B0(n518), .C0(n218), .Y(n219)
         );
  OAI211XL U76 ( .A0(n38), .A1(n547), .B0(n546), .C0(n545), .Y(n397) );
  OAI211XL U77 ( .A0(n137), .A1(n568), .B0(n136), .C0(n183), .Y(n140) );
  NOR2BX1 U78 ( .AN(n175), .B(n522), .Y(N192) );
  OAI211XL U79 ( .A0(n538), .A1(n560), .B0(n537), .C0(n536), .Y(n399) );
  OAI211XL U80 ( .A0(n61), .A1(n547), .B0(n530), .C0(n529), .Y(n401) );
  AOI32XL U81 ( .A0(n117), .A1(n92), .A2(n229), .B0(n184), .B1(n92), .Y(n67)
         );
  OAI211XL U82 ( .A0(n262), .A1(n100), .B0(n83), .C0(n82), .Y(n249) );
  OAI211XL U83 ( .A0(n564), .A1(n567), .B0(demask_cnt[0]), .C0(n199), .Y(n89)
         );
  OAI211XL U84 ( .A0(n62), .A1(n228), .B0(n294), .C0(n293), .Y(n224) );
  AOI31X1 U85 ( .A0(n169), .A1(n562), .A2(n566), .B0(n168), .Y(n212) );
  OAI211X1 U86 ( .A0(n246), .A1(n563), .B0(n245), .C0(n244), .Y(n247) );
  OAI211XL U87 ( .A0(demask_cnt[4]), .A1(n264), .B0(n263), .C0(n290), .Y(n265)
         );
  OAI211XL U88 ( .A0(n184), .A1(n240), .B0(n158), .C0(n154), .Y(n157) );
  OAI211XL U89 ( .A0(demask_cnt[0]), .A1(n122), .B0(n121), .C0(n213), .Y(n127)
         );
  OAI211XL U90 ( .A0(n262), .A1(n178), .B0(n255), .C0(n263), .Y(n1920) );
  OAI211XL U91 ( .A0(n61), .A1(n58), .B0(n554), .C0(n532), .Y(n526) );
  OAI22XL U92 ( .A0(n553), .A1(n221), .B0(n560), .B1(n220), .Y(n395) );
  OAI211XL U93 ( .A0(demask_cnt[3]), .A1(n515), .B0(n517), .C0(n218), .Y(n217)
         );
  OAI211XL U94 ( .A0(n61), .A1(n58), .B0(n556), .C0(n532), .Y(n529) );
  OAI211XL U95 ( .A0(demask_cnt[1]), .A1(demask_cnt[0]), .B0(n203), .C0(n81), 
        .Y(n82) );
  OAI211XL U96 ( .A0(n271), .A1(n270), .B0(n269), .C0(n268), .Y(n134) );
  OAI211XL U97 ( .A0(n271), .A1(n270), .B0(n278), .C0(n200), .Y(n145) );
  OAI211XL U98 ( .A0(n561), .A1(n567), .B0(n1930), .C0(n563), .Y(n149) );
  AND2XL U99 ( .A(n328), .B(n327), .Y(n2) );
  NOR2BXL U100 ( .AN(j_old2[2]), .B(n570), .Y(n468) );
  AND2XL U101 ( .A(j_old2[4]), .B(i_old2[0]), .Y(n326) );
  INVX1 U102 ( .A(srst_n), .Y(n239) );
  INVXL U103 ( .A(j_old2[4]), .Y(n368) );
  XOR3XL U104 ( .A(n354), .B(n352), .C(n353), .Y(n1) );
  XOR2XL U105 ( .A(n328), .B(n327), .Y(n338) );
  AO21XL U106 ( .A0(n430), .A1(n427), .B0(n426), .Y(n3) );
  NOR2BX1 U107 ( .AN(j_old2[0]), .B(n576), .Y(n328) );
  NOR2XL U109 ( .A(n359), .B(n1), .Y(n5) );
  AOI21XL U110 ( .A0(n386), .A1(n384), .B0(n388), .Y(n6) );
  AOI21XL U111 ( .A0(n386), .A1(n384), .B0(n388), .Y(n417) );
  NOR2XL U112 ( .A(n386), .B(n383), .Y(n7) );
  OR2XL U115 ( .A(n407), .B(n418), .Y(n390) );
  OR2XL U116 ( .A(n418), .B(n6), .Y(n419) );
  OAI21XL U117 ( .A0(n488), .A1(n489), .B0(n487), .Y(n491) );
  NOR2XL U118 ( .A(demask_cnt[5]), .B(demask_cnt[6]), .Y(n246) );
  NAND2XL U119 ( .A(n246), .B(demask_cnt[2]), .Y(n282) );
  ADDHX1 U120 ( .A(n330), .B(n329), .CO(n354), .S(n342) );
  XOR2XL U121 ( .A(n376), .B(n592), .Y(n386) );
  XOR2XL U122 ( .A(n441), .B(n440), .Y(n445) );
  XNOR2X1 U123 ( .A(n494), .B(n495), .Y(n498) );
  XNOR2X1 U124 ( .A(n496), .B(n495), .Y(n497) );
  OAI21XL U125 ( .A0(intadd_3_SUM_0_), .A1(n493), .B0(n492), .Y(n495) );
  NOR2XL U126 ( .A(demask_cnt[1]), .B(demask_cnt[0]), .Y(n269) );
  NOR2XL U127 ( .A(n564), .B(demask_cnt[0]), .Y(n174) );
  NAND2BXL U128 ( .AN(loc_y[2]), .B(n508), .Y(n509) );
  OR2XL U129 ( .A(mask[2]), .B(n29), .Y(n14) );
  XOR2XL U130 ( .A(n464), .B(n461), .Y(n462) );
  NAND2XL U131 ( .A(mask[1]), .B(n463), .Y(n31) );
  NOR2XL U132 ( .A(demask_cnt[3]), .B(n143), .Y(n267) );
  AND2XL U133 ( .A(i_mul[6]), .B(loc_y[0]), .Y(intadd_2_B_6_) );
  AND2XL U134 ( .A(n378), .B(n377), .Y(n19) );
  NOR2XL U135 ( .A(n356), .B(n355), .Y(n375) );
  ADDHX1 U136 ( .A(n319), .B(n318), .CO(n339), .S(n309) );
  OR2XL U138 ( .A(n359), .B(n1), .Y(n333) );
  XOR2XL U139 ( .A(n418), .B(n6), .Y(n422) );
  XOR2XL U140 ( .A(n336), .B(n323), .Y(n429) );
  AOI21XL U141 ( .A0(intadd_3_SUM_1_), .A1(n485), .B0(n484), .Y(n489) );
  AND2XL U142 ( .A(n298), .B(n297), .Y(n448) );
  XOR2XL U143 ( .A(n314), .B(n311), .Y(n442) );
  XOR2XL U144 ( .A(intadd_3_SUM_1_), .B(n489), .Y(n493) );
  OAI21XL U145 ( .A0(mask[1]), .A1(n33), .B0(mask[0]), .Y(n29) );
  NOR2XL U146 ( .A(n28), .B(n15), .Y(n25) );
  OR2XL U147 ( .A(mask[1]), .B(intadd_3_CI), .Y(n15) );
  XOR2XL U148 ( .A(n17), .B(n460), .Y(n461) );
  AND2XL U149 ( .A(mask[2]), .B(n11), .Y(n8) );
  NOR3XL U150 ( .A(mask[2]), .B(n30), .C(n29), .Y(n26) );
  INVXL U151 ( .A(n33), .Y(n30) );
  NAND2XL U152 ( .A(n566), .B(n246), .Y(n273) );
  NAND2XL U153 ( .A(n16), .B(n9), .Y(n28) );
  NAND2XL U154 ( .A(n564), .B(demask_cnt[0]), .Y(n291) );
  AND2XL U155 ( .A(j_mul[0]), .B(loc_x[0]), .Y(intadd_2_CI) );
  OR2XL U156 ( .A(N1544), .B(n50), .Y(n52) );
  AO21XL U157 ( .A0(loc_y[2]), .A1(rotation_type[1]), .B0(n511), .Y(n512) );
  OR2XL U158 ( .A(N1545), .B(n52), .Y(n51) );
  OAI22XL U159 ( .A0(rotation_type[1]), .A1(n509), .B0(n511), .B1(n508), .Y(
        n510) );
  OR2XL U160 ( .A(N1546), .B(n51), .Y(n48) );
  XNOR2X1 U161 ( .A(i_mul[11]), .B(intadd_2_n1), .Y(n42) );
  OR2XL U162 ( .A(N1547), .B(n48), .Y(n47) );
  NOR4XL U163 ( .A(demask_complete), .B(state[0]), .C(state[3]), .D(n53), .Y(
        n218) );
  INVXL U164 ( .A(n588), .Y(n581) );
  INVXL U165 ( .A(n588), .Y(n579) );
  INVXL U166 ( .A(n588), .Y(n580) );
  INVXL U167 ( .A(n588), .Y(n582) );
  INVXL U168 ( .A(n588), .Y(n583) );
  INVXL U169 ( .A(n588), .Y(n584) );
  AOI31X1 U170 ( .A0(n554), .A1(n555), .A2(n573), .B0(n396), .Y(n551) );
  INVXL U171 ( .A(n588), .Y(n585) );
  NOR4BX1 U172 ( .AN(n124), .B(n77), .C(n250), .D(n234), .Y(n93) );
  INVXL U173 ( .A(n588), .Y(n586) );
  AOI2BB1XL U174 ( .A0N(i_mul[6]), .A1N(loc_y[0]), .B0(intadd_2_B_6_), .Y(
        intadd_2_B_5_) );
  INVXL U175 ( .A(n215), .Y(n589) );
  XNOR2X1 U177 ( .A(n43), .B(n42), .Y(n45) );
  XNOR2X1 U178 ( .A(n41), .B(n40), .Y(n43) );
  XNOR2X1 U179 ( .A(N1548), .B(n47), .Y(N1591) );
  AOI221X1 U180 ( .A0(demask_cnt[6]), .A1(n519), .B0(n562), .B1(n518), .C0(
        n522), .Y(N197) );
  XNOR2X1 U181 ( .A(n305), .B(n301), .Y(n450) );
  INVXL U182 ( .A(n450), .Y(n18) );
  MXI2XL U183 ( .A(n507), .B(n506), .S0(mask[1]), .Y(n11) );
  NOR2XL U184 ( .A(n26), .B(n8), .Y(n12) );
  INVXL U185 ( .A(n448), .Y(n17) );
  XOR2XL U186 ( .A(n442), .B(n443), .Y(n449) );
  AOI2BB1XL U187 ( .A0N(n17), .A1N(n18), .B0(n449), .Y(n455) );
  NAND2BXL U188 ( .AN(n19), .B(n381), .Y(n385) );
  ADDFXL U190 ( .A(n339), .B(n338), .CI(n337), .CO(n344), .S(n320) );
  INVXL U191 ( .A(j_old2[3]), .Y(n347) );
  OAI2BB1XL U192 ( .A0N(n462), .A1N(n24), .B0(n12), .Y(n22) );
  NAND2XL U193 ( .A(state[2]), .B(state[1]), .Y(n53) );
  OAI21XL U194 ( .A0(n27), .A1(n10), .B0(n20), .Y(N1783) );
  NOR2XL U195 ( .A(n22), .B(n21), .Y(n20) );
  NOR2XL U196 ( .A(n14), .B(n23), .Y(n21) );
  XNOR2XL U197 ( .A(n439), .B(n467), .Y(n23) );
  INVXL U198 ( .A(n467), .Y(n34) );
  NOR2BXL U199 ( .AN(n25), .B(n467), .Y(n24) );
  OR2XL U200 ( .A(n28), .B(n32), .Y(n27) );
  INVXL U201 ( .A(sram_rdata), .Y(n46) );
  ADDFXL U202 ( .A(n326), .B(n325), .CI(n324), .CO(n341), .S(n337) );
  ADDHXL U203 ( .A(n307), .B(n306), .CO(n315), .S(n299) );
  ADDFXL U204 ( .A(n332), .B(n331), .CI(n2), .CO(n352), .S(n340) );
  ADDFXL U205 ( .A(n354), .B(n353), .CI(n352), .CO(n355), .S(n358) );
  ADDFXL U206 ( .A(n342), .B(n341), .CI(n340), .CO(n359), .S(n343) );
  NOR2XL U207 ( .A(n348), .B(n576), .Y(n378) );
  NOR2XL U208 ( .A(n368), .B(n575), .Y(n372) );
  OAI21XL U209 ( .A0(n456), .A1(n457), .B0(n459), .Y(n451) );
  INVXL U210 ( .A(n588), .Y(n587) );
  NOR2XL U211 ( .A(n370), .B(n565), .Y(intadd_3_CI) );
  INVXL U212 ( .A(intadd_3_CI), .Y(n439) );
  NOR2XL U213 ( .A(n576), .B(n347), .Y(n371) );
  INVXL U215 ( .A(intadd_3_SUM_1_), .Y(n486) );
  NOR2XL U216 ( .A(n570), .B(j_old2[4]), .Y(n472) );
  NOR2XL U217 ( .A(n472), .B(n471), .Y(n476) );
  NAND2XL U218 ( .A(n240), .B(n222), .Y(n80) );
  NOR2XL U219 ( .A(n241), .B(n240), .Y(n242) );
  NAND2XL U220 ( .A(n532), .B(j_old[2]), .Y(n539) );
  NOR2XL U221 ( .A(n567), .B(n56), .Y(n243) );
  NOR2XL U222 ( .A(demask_cnt[3]), .B(n132), .Y(n201) );
  NAND2XL U223 ( .A(n174), .B(n179), .Y(n99) );
  INVXL U224 ( .A(n267), .Y(n240) );
  NOR2XL U225 ( .A(n282), .B(n240), .Y(n176) );
  INVXL U226 ( .A(n525), .Y(n554) );
  NAND2XL U227 ( .A(n184), .B(n159), .Y(n155) );
  INVXL U228 ( .A(n516), .Y(n200) );
  OAI22XL U229 ( .A0(n274), .A1(n273), .B0(n272), .B1(n291), .Y(n284) );
  NOR2XL U230 ( .A(n148), .B(n257), .Y(n60) );
  OAI22XL U231 ( .A0(n200), .A1(n244), .B0(n101), .B1(n147), .Y(n94) );
  NAND2XL U232 ( .A(n267), .B(n79), .Y(n244) );
  AOI22XL U233 ( .A0(n556), .A1(n543), .B0(i_old[3]), .B1(n554), .Y(n546) );
  INVXL U234 ( .A(n549), .Y(n560) );
  INVXL U235 ( .A(n170), .Y(n211) );
  NAND2XL U236 ( .A(demask_cnt[5]), .B(n520), .Y(n518) );
  NOR2XL U237 ( .A(demask_cnt[0]), .B(n522), .Y(N191) );
  TIELO U238 ( .Y(N1735) );
  INVXL U239 ( .A(loc_y[3]), .Y(n508) );
  INVXL U240 ( .A(rotation_type[1]), .Y(n216) );
  NAND2XL U241 ( .A(n509), .B(n216), .Y(n39) );
  NOR2XL U242 ( .A(intadd_2_SUM_1_), .B(N1540), .Y(n513) );
  INVXL U243 ( .A(N1541), .Y(n238) );
  NOR2XL U244 ( .A(n513), .B(n238), .Y(n237) );
  OR2XL U245 ( .A(n237), .B(N1542), .Y(n49) );
  OR2XL U246 ( .A(N1543), .B(n49), .Y(n50) );
  NAND2XL U247 ( .A(demask_cnt[4]), .B(demask_cnt[7]), .Y(n56) );
  INVXL U248 ( .A(n174), .Y(n138) );
  NAND2XL U249 ( .A(n138), .B(n291), .Y(n175) );
  INVXL U250 ( .A(n218), .Y(n522) );
  INVXL U251 ( .A(rotation_type[0]), .Y(n215) );
  NOR2XL U252 ( .A(n562), .B(demask_cnt[5]), .Y(n81) );
  INVXL U253 ( .A(n81), .Y(n87) );
  NAND2XL U254 ( .A(n561), .B(n563), .Y(n143) );
  NAND2XL U255 ( .A(n267), .B(n269), .Y(n117) );
  NOR2XL U256 ( .A(demask_cnt[7]), .B(n561), .Y(n271) );
  NAND2XL U257 ( .A(demask_cnt[3]), .B(n271), .Y(n101) );
  INVXL U258 ( .A(n101), .Y(n203) );
  NAND2XL U259 ( .A(n174), .B(n203), .Y(n109) );
  NAND2XL U260 ( .A(n562), .B(demask_cnt[5]), .Y(n223) );
  NOR2XL U261 ( .A(n566), .B(n223), .Y(n226) );
  INVXL U262 ( .A(n226), .Y(n184) );
  NOR2XL U263 ( .A(n138), .B(n240), .Y(n248) );
  INVXL U264 ( .A(n248), .Y(n137) );
  NAND2XL U265 ( .A(n566), .B(n81), .Y(n171) );
  OAI222XL U266 ( .A0(n87), .A1(n117), .B0(n109), .B1(n184), .C0(n137), .C1(
        n171), .Y(n73) );
  NAND2XL U267 ( .A(n271), .B(n567), .Y(n261) );
  INVXL U268 ( .A(n261), .Y(n179) );
  NAND2XL U269 ( .A(n269), .B(n179), .Y(n84) );
  INVXL U270 ( .A(n84), .Y(n116) );
  NAND2XL U271 ( .A(demask_cnt[3]), .B(n563), .Y(n178) );
  NOR2XL U272 ( .A(demask_cnt[4]), .B(n178), .Y(n270) );
  NAND2XL U273 ( .A(n174), .B(n270), .Y(n136) );
  INVXL U274 ( .A(n136), .Y(n110) );
  NOR2XL U275 ( .A(n116), .B(n110), .Y(n231) );
  NOR2XL U276 ( .A(n568), .B(n562), .Y(n521) );
  NAND2XL U277 ( .A(demask_cnt[2]), .B(n521), .Y(n262) );
  NAND2XL U278 ( .A(n566), .B(n521), .Y(n147) );
  OAI22XL U279 ( .A0(n231), .A1(n262), .B0(n261), .B1(n147), .Y(n95) );
  INVXL U280 ( .A(n269), .Y(n148) );
  NAND2XL U281 ( .A(n179), .B(n148), .Y(n62) );
  INVXL U282 ( .A(n223), .Y(n75) );
  NAND2XL U283 ( .A(n566), .B(n75), .Y(n228) );
  NAND2XL U284 ( .A(n269), .B(n176), .Y(n294) );
  INVXL U285 ( .A(n273), .Y(n79) );
  NAND2XL U286 ( .A(demask_cnt[1]), .B(demask_cnt[0]), .Y(n516) );
  OR2XL U287 ( .A(n244), .B(n516), .Y(n293) );
  INVXL U288 ( .A(n163), .Y(n255) );
  OAI22XL U289 ( .A0(n184), .A1(n84), .B0(n516), .B1(n255), .Y(n54) );
  NOR2XL U290 ( .A(demask_cnt[4]), .B(n563), .Y(n88) );
  NAND2XL U291 ( .A(n88), .B(n79), .Y(n122) );
  NOR2XL U292 ( .A(demask_cnt[3]), .B(n122), .Y(n177) );
  NAND2XL U293 ( .A(n79), .B(n243), .Y(n257) );
  INVXL U294 ( .A(n147), .Y(n251) );
  INVXL U295 ( .A(n282), .Y(n153) );
  NAND4XL U296 ( .A(n567), .B(n153), .C(demask_cnt[4]), .D(demask_cnt[7]), .Y(
        n154) );
  INVXL U297 ( .A(n154), .Y(n133) );
  AOI211XL U298 ( .A0(n177), .A1(n569), .B0(n60), .C0(n59), .Y(n71) );
  NAND2XL U299 ( .A(demask_cnt[0]), .B(n203), .Y(n229) );
  INVXL U300 ( .A(n171), .Y(n278) );
  NOR2XL U301 ( .A(n101), .B(n148), .Y(n275) );
  NAND2XL U302 ( .A(demask_cnt[0]), .B(n179), .Y(n78) );
  OAI22XL U303 ( .A0(n87), .A1(n62), .B0(n147), .B1(n78), .Y(n65) );
  NAND2XL U304 ( .A(demask_cnt[2]), .B(n81), .Y(n159) );
  NAND2XL U305 ( .A(demask_cnt[0]), .B(n270), .Y(n222) );
  OAI22XL U306 ( .A0(n159), .A1(n84), .B0(n262), .B1(n222), .Y(n63) );
  AOI211XL U307 ( .A0(n278), .A1(n275), .B0(n65), .C0(n63), .Y(n97) );
  INVXL U308 ( .A(n291), .Y(n1930) );
  NAND2XL U309 ( .A(n1930), .B(n177), .Y(n66) );
  INVXL U310 ( .A(n91), .Y(n70) );
  NAND2XL U311 ( .A(demask_cnt[0]), .B(n267), .Y(n100) );
  AOI21XL U312 ( .A0(n137), .A1(n100), .B0(n223), .Y(n69) );
  INVXL U313 ( .A(n246), .Y(n241) );
  OAI222XL U314 ( .A0(n136), .A1(n282), .B0(n84), .B1(n241), .C0(n273), .C1(
        n99), .Y(n130) );
  NAND2XL U315 ( .A(n269), .B(n270), .Y(n128) );
  OAI22XL U316 ( .A0(n171), .A1(n100), .B0(n228), .B1(n128), .Y(n68) );
  OA22X1 U317 ( .A0(n282), .A1(n222), .B0(n273), .B1(n78), .Y(n92) );
  NAND4XL U318 ( .A(n72), .B(n71), .C(n70), .D(n102), .Y(i[2]) );
  AND2XL U319 ( .A(n270), .B(n569), .Y(n227) );
  INVXL U320 ( .A(n159), .Y(n268) );
  NAND2XL U321 ( .A(n248), .B(n268), .Y(n181) );
  INVXL U322 ( .A(n181), .Y(n74) );
  AOI211XL U323 ( .A0(n278), .A1(n227), .B0(n74), .C0(n73), .Y(n124) );
  NOR2XL U324 ( .A(n564), .B(n244), .Y(n77) );
  INVXL U325 ( .A(n109), .Y(n169) );
  INVXL U326 ( .A(n228), .Y(n276) );
  AOI22XL U327 ( .A0(n75), .A1(n275), .B0(n169), .B1(n276), .Y(n76) );
  INVXL U328 ( .A(n176), .Y(n290) );
  OAI22XL U329 ( .A0(n569), .A1(n290), .B0(n273), .B1(n222), .Y(n234) );
  INVXL U330 ( .A(n78), .Y(n225) );
  NAND2XL U331 ( .A(n203), .B(n79), .Y(n142) );
  NOR2XL U332 ( .A(n291), .B(n142), .Y(n168) );
  AOI21XL U333 ( .A0(n225), .A1(n153), .B0(n168), .Y(n103) );
  AOI22XL U334 ( .A0(n268), .A1(n275), .B0(n251), .B1(n80), .Y(n83) );
  NAND2XL U335 ( .A(n270), .B(n200), .Y(n281) );
  INVXL U336 ( .A(n262), .Y(n120) );
  AOI22XL U337 ( .A0(n268), .A1(n270), .B0(n120), .B1(n225), .Y(n86) );
  OA22X1 U338 ( .A0(n171), .A1(n84), .B0(n147), .B1(n229), .Y(n85) );
  NAND2XL U339 ( .A(n153), .B(n88), .Y(n132) );
  INVXL U340 ( .A(n201), .Y(n272) );
  INVXL U341 ( .A(n122), .Y(n199) );
  OAI21XL U342 ( .A0(n569), .A1(n272), .B0(n89), .Y(n90) );
  NAND4XL U343 ( .A(n93), .B(n92), .C(n103), .D(n256), .Y(j[2]) );
  NAND2BXL U344 ( .AN(n275), .B(n99), .Y(n98) );
  INVXL U345 ( .A(n257), .Y(n114) );
  AOI22XL U346 ( .A0(n120), .A1(n98), .B0(n114), .B1(n175), .Y(n107) );
  OAI22XL U347 ( .A0(demask_cnt[0]), .A1(n142), .B0(n282), .B1(n99), .Y(n129)
         );
  NAND2XL U348 ( .A(n270), .B(n1930), .Y(n1970) );
  OAI22XL U349 ( .A0(n117), .A1(n228), .B0(n171), .B1(n1970), .Y(n106) );
  OAI22XL U350 ( .A0(n282), .A1(n101), .B0(n159), .B1(n100), .Y(n105) );
  NAND4XL U351 ( .A(n108), .B(n124), .C(n107), .D(n236), .Y(i[3]) );
  OAI22XL U352 ( .A0(n282), .A1(n109), .B0(n148), .B1(n255), .Y(n113) );
  OAI21XL U353 ( .A0(n271), .A1(n270), .B0(n174), .Y(n111) );
  NOR2XL U354 ( .A(n248), .B(n110), .Y(n173) );
  OAI22XL U355 ( .A0(n111), .A1(n159), .B0(n173), .B1(n184), .Y(n112) );
  NOR2XL U356 ( .A(n113), .B(n112), .Y(n288) );
  INVXL U357 ( .A(n115), .Y(n119) );
  NAND2XL U358 ( .A(n117), .B(n128), .Y(n277) );
  NOR2XL U359 ( .A(n116), .B(n277), .Y(n125) );
  OAI22XL U360 ( .A0(n125), .A1(n228), .B0(n117), .B1(n147), .Y(n118) );
  AOI211XL U361 ( .A0(n174), .A1(n163), .B0(n119), .C0(n118), .Y(n188) );
  NAND2XL U362 ( .A(n120), .B(n563), .Y(n264) );
  OAI22XL U363 ( .A0(n138), .A1(n264), .B0(n148), .B1(n272), .Y(n1910) );
  NAND2XL U364 ( .A(n275), .B(n120), .Y(n121) );
  AOI211XL U365 ( .A0(n567), .A1(n561), .B0(demask_cnt[7]), .C0(n147), .Y(n123) );
  NAND2XL U366 ( .A(n174), .B(n123), .Y(n213) );
  AOI22XL U367 ( .A0(n174), .A1(n201), .B0(n269), .B1(n123), .Y(n286) );
  OAI222XL U368 ( .A0(n290), .A1(n138), .B0(n128), .B1(n241), .C0(n136), .C1(
        n273), .Y(n233) );
  NOR3XL U369 ( .A(n233), .B(n130), .C(n129), .Y(n131) );
  NOR2XL U370 ( .A(n567), .B(n132), .Y(n162) );
  NOR2XL U371 ( .A(n133), .B(n162), .Y(n259) );
  AOI22XL U372 ( .A0(n153), .A1(n275), .B0(n226), .B1(n277), .Y(n135) );
  NAND2XL U373 ( .A(n174), .B(n271), .Y(n183) );
  OAI22XL U374 ( .A0(n259), .A1(n148), .B0(n257), .B1(n138), .Y(n139) );
  NAND4XL U375 ( .A(n288), .B(n188), .C(n165), .D(n141), .Y(j[0]) );
  OAI21XL U376 ( .A0(n228), .A1(n143), .B0(n142), .Y(n144) );
  NAND2XL U377 ( .A(n200), .B(n144), .Y(n146) );
  NAND2XL U378 ( .A(n271), .B(n1930), .Y(n1960) );
  NAND2XL U379 ( .A(n267), .B(n1930), .Y(n180) );
  OAI22XL U380 ( .A0(n171), .A1(n1960), .B0(n147), .B1(n180), .Y(n151) );
  OAI22XL U381 ( .A0(n149), .A1(n228), .B0(n148), .B1(n244), .Y(n150) );
  AOI22XL U382 ( .A0(n153), .A1(n203), .B0(n271), .B1(n268), .Y(n158) );
  INVXL U383 ( .A(n281), .Y(n156) );
  AOI22XL U384 ( .A0(n200), .A1(n157), .B0(n156), .B1(n155), .Y(n182) );
  NOR2XL U385 ( .A(n158), .B(n291), .Y(n161) );
  AND2XL U386 ( .A(n1970), .B(n180), .Y(n172) );
  OAI22XL U387 ( .A0(n172), .A1(n184), .B0(n159), .B1(n1970), .Y(n160) );
  AOI211XL U388 ( .A0(n200), .A1(n162), .B0(n161), .C0(n160), .Y(n280) );
  NAND2XL U389 ( .A(demask_cnt[0]), .B(n163), .Y(n164) );
  NAND4XL U390 ( .A(n167), .B(n182), .C(n280), .D(n258), .Y(j[1]) );
  AOI21XL U391 ( .A0(n173), .A1(n172), .B0(n171), .Y(n209) );
  OAI22XL U392 ( .A0(n174), .A1(n1930), .B0(n270), .B1(n179), .Y(n206) );
  AOI22XL U393 ( .A0(n200), .A1(n177), .B0(n176), .B1(n175), .Y(n1950) );
  NAND2XL U394 ( .A(n226), .B(n271), .Y(n263) );
  NAND2XL U395 ( .A(n179), .B(n1930), .Y(n189) );
  INVXL U396 ( .A(n180), .Y(n186) );
  AOI211XL U397 ( .A0(n1930), .A1(n1920), .B0(n1910), .C0(n190), .Y(n1940) );
  NAND2XL U398 ( .A(n1970), .B(n1960), .Y(n1980) );
  AOI22XL U399 ( .A0(n269), .A1(n199), .B0(n251), .B1(n1980), .Y(n205) );
  OAI22XL U400 ( .A0(n228), .A1(n291), .B0(n262), .B1(n516), .Y(n202) );
  AOI22XL U401 ( .A0(n203), .A1(n202), .B0(n201), .B1(n200), .Y(n204) );
  NAND4XL U402 ( .A(n213), .B(n212), .C(n211), .D(n210), .Y(i[0]) );
  INVXL U403 ( .A(intadd_2_SUM_1_), .Y(n214) );
  AOI22XL U404 ( .A0(intadd_2_SUM_1_), .A1(n215), .B0(n589), .B1(n214), .Y(
        N1673) );
  NOR2XL U405 ( .A(n216), .B(n589), .Y(n549) );
  NAND2XL U406 ( .A(n216), .B(n589), .Y(n525) );
  NAND2XL U407 ( .A(n560), .B(n525), .Y(n64) );
  NAND2XL U408 ( .A(rotation_type[1]), .B(n589), .Y(n547) );
  INVXL U409 ( .A(n547), .Y(n55) );
  NAND2XL U410 ( .A(n216), .B(n215), .Y(n553) );
  NOR2XL U411 ( .A(N1492), .B(i_old[1]), .Y(n531) );
  NOR2XL U412 ( .A(n531), .B(n572), .Y(n540) );
  NOR2XL U413 ( .A(i_old[3]), .B(n540), .Y(n548) );
  NAND2BXL U414 ( .AN(n548), .B(i_old[4]), .Y(n220) );
  NAND2XL U415 ( .A(n61), .B(n58), .Y(n532) );
  NAND2XL U416 ( .A(n38), .B(n539), .Y(n550) );
  NAND2XL U417 ( .A(j_old[4]), .B(n550), .Y(n221) );
  OAI22XL U418 ( .A0(n553), .A1(n220), .B0(n525), .B1(n221), .Y(n396) );
  NOR2XL U419 ( .A(n566), .B(n516), .Y(n515) );
  NAND2XL U420 ( .A(demask_cnt[3]), .B(n515), .Y(n517) );
  INVXL U421 ( .A(n217), .Y(N194) );
  NOR2XL U422 ( .A(n561), .B(n517), .Y(n520) );
  INVXL U423 ( .A(n219), .Y(N196) );
  NOR2XL U424 ( .A(n223), .B(n222), .Y(n235) );
  NAND2XL U425 ( .A(n252), .B(n236), .Y(j[4]) );
  AOI21XL U426 ( .A0(n513), .A1(n238), .B0(n237), .Y(N1584) );
  INVX2 U428 ( .A(n239), .Y(n578) );
  NAND2X2 U429 ( .A(n578), .B(n247), .Y(net7052) );
  NOR2XL U430 ( .A(n248), .B(n277), .Y(n254) );
  AOI211XL U431 ( .A0(n270), .A1(n251), .B0(n250), .C0(n249), .Y(n253) );
  NAND3BXL U432 ( .AN(n260), .B(n259), .C(n258), .Y(j[3]) );
  AOI21XL U433 ( .A0(n282), .A1(n262), .B0(n261), .Y(n266) );
  AOI211XL U434 ( .A0(n268), .A1(n267), .B0(n266), .C0(n265), .Y(n289) );
  OAI21XL U435 ( .A0(n271), .A1(n270), .B0(n269), .Y(n274) );
  AOI22XL U436 ( .A0(n278), .A1(n277), .B0(n276), .B1(n275), .Y(n279) );
  NOR2XL U437 ( .A(n291), .B(n290), .Y(n292) );
  MX2XL U438 ( .A(mask[0]), .B(sram_rdata), .S0(n292), .Y(n389) );
  MX2XL U439 ( .A(sram_rdata), .B(mask[2]), .S0(n293), .Y(n392) );
  MX2XL U440 ( .A(sram_rdata), .B(mask[1]), .S0(n294), .Y(n391) );
  AOI21XL U441 ( .A0(n370), .A1(n565), .B0(intadd_3_CI), .Y(n490) );
  INVXL U442 ( .A(n490), .Y(n463) );
  NOR2XL U444 ( .A(n370), .B(n35), .Y(n296) );
  AND2XL U445 ( .A(i_old2[0]), .B(j_old2[1]), .Y(n295) );
  NAND2XL U446 ( .A(n296), .B(n295), .Y(n298) );
  OR2XL U447 ( .A(n296), .B(n295), .Y(n297) );
  INVXL U448 ( .A(n298), .Y(n305) );
  NOR2XL U449 ( .A(n565), .B(n36), .Y(n300) );
  NOR2XL U450 ( .A(n370), .B(n37), .Y(n307) );
  NOR2XL U451 ( .A(n35), .B(n571), .Y(n306) );
  NAND2XL U452 ( .A(n300), .B(n299), .Y(n302) );
  OR2XL U453 ( .A(n300), .B(n299), .Y(n304) );
  NAND2XL U454 ( .A(n302), .B(n304), .Y(n301) );
  INVXL U455 ( .A(n302), .Y(n303) );
  AOI21XL U456 ( .A0(n305), .A1(n304), .B0(n303), .Y(n314) );
  NOR2XL U457 ( .A(n370), .B(n575), .Y(n319) );
  NOR2XL U458 ( .A(n565), .B(n347), .Y(n318) );
  NOR2XL U459 ( .A(n37), .B(n571), .Y(n317) );
  NOR2XL U460 ( .A(n35), .B(n36), .Y(n316) );
  NAND2XL U461 ( .A(n309), .B(n308), .Y(n312) );
  NOR2XL U462 ( .A(n309), .B(n308), .Y(n313) );
  INVXL U463 ( .A(n313), .Y(n310) );
  NAND2XL U464 ( .A(n312), .B(n310), .Y(n311) );
  OA21X1 U465 ( .A0(n314), .A1(n313), .B0(n312), .Y(n336) );
  ADDFX1 U466 ( .A(n317), .B(n316), .CI(n315), .CO(n321), .S(n308) );
  NOR2XL U467 ( .A(n37), .B(n36), .Y(n324) );
  NAND2XL U468 ( .A(n321), .B(n320), .Y(n334) );
  NOR2XL U469 ( .A(n321), .B(n320), .Y(n335) );
  INVXL U470 ( .A(n335), .Y(n322) );
  NAND2XL U471 ( .A(n334), .B(n322), .Y(n323) );
  NOR2XL U472 ( .A(n442), .B(n429), .Y(n437) );
  NOR2XL U473 ( .A(n368), .B(n35), .Y(n330) );
  NOR2XL U474 ( .A(n37), .B(n347), .Y(n329) );
  NOR2XL U475 ( .A(n575), .B(n36), .Y(n332) );
  NOR2XL U476 ( .A(n576), .B(n571), .Y(n331) );
  NOR2XL U477 ( .A(n575), .B(n570), .Y(n349) );
  NAND2XL U478 ( .A(n359), .B(n1), .Y(n361) );
  NAND2XL U479 ( .A(n361), .B(n333), .Y(n346) );
  OAI21XL U480 ( .A0(n336), .A1(n335), .B0(n334), .Y(n366) );
  INVXL U481 ( .A(n366), .Y(n414) );
  NOR2XL U482 ( .A(n344), .B(n343), .Y(n360) );
  NAND2XL U483 ( .A(n344), .B(n343), .Y(n362) );
  OAI21XL U485 ( .A0(n414), .A1(n360), .B0(n591), .Y(n345) );
  NAND2XL U486 ( .A(n356), .B(n355), .Y(n373) );
  INVXL U487 ( .A(n375), .Y(n357) );
  NAND2XL U488 ( .A(n373), .B(n357), .Y(n367) );
  NOR2XL U489 ( .A(n359), .B(n358), .Y(n363) );
  NOR2XL U490 ( .A(n5), .B(n360), .Y(n365) );
  OAI21XL U491 ( .A0(n363), .A1(n362), .B0(n361), .Y(n364) );
  AND2XL U492 ( .A(n407), .B(n418), .Y(n406) );
  ADDFX1 U493 ( .A(n372), .B(n371), .CI(n369), .CO(n377), .S(n356) );
  XOR2XL U494 ( .A(n378), .B(n377), .Y(n376) );
  INVXL U495 ( .A(n418), .Y(n382) );
  INVXL U496 ( .A(n378), .Y(n380) );
  NAND2BXL U497 ( .AN(n380), .B(n379), .Y(n381) );
  NOR2XL U498 ( .A(n382), .B(n385), .Y(n384) );
  INVXL U499 ( .A(n385), .Y(n383) );
  NOR2XL U500 ( .A(n386), .B(n383), .Y(n388) );
  NOR2XL U501 ( .A(n418), .B(n385), .Y(n387) );
  NAND2XL U502 ( .A(n387), .B(n386), .Y(n404) );
  NAND2XL U503 ( .A(n390), .B(n7), .Y(n403) );
  NAND2XL U504 ( .A(n404), .B(n403), .Y(n405) );
  AOI21XL U505 ( .A0(n406), .A1(n417), .B0(n405), .Y(n408) );
  NOR2XL U507 ( .A(n407), .B(n593), .Y(n410) );
  INVXL U508 ( .A(n407), .Y(n409) );
  NOR2XL U509 ( .A(n409), .B(n408), .Y(n423) );
  NOR2XL U510 ( .A(n423), .B(n410), .Y(n428) );
  INVXL U511 ( .A(n360), .Y(n411) );
  NAND2XL U512 ( .A(n591), .B(n411), .Y(n413) );
  AND2XL U513 ( .A(n430), .B(n428), .Y(n431) );
  INVXL U514 ( .A(n431), .Y(n424) );
  NAND2XL U515 ( .A(n418), .B(n6), .Y(n416) );
  NOR2XL U516 ( .A(n416), .B(n593), .Y(n421) );
  NOR2XL U517 ( .A(n419), .B(n423), .Y(n420) );
  AOI211XL U518 ( .A0(n423), .A1(n422), .B0(n421), .C0(n420), .Y(n433) );
  INVXL U519 ( .A(n433), .Y(n425) );
  AOI22XL U520 ( .A0(n428), .A1(n424), .B0(n430), .B1(n425), .Y(n436) );
  INVXL U521 ( .A(n428), .Y(n427) );
  INVXL U522 ( .A(n429), .Y(n441) );
  NOR2XL U523 ( .A(n429), .B(n430), .Y(n434) );
  AOI21XL U524 ( .A0(n430), .A1(n429), .B0(n428), .Y(n432) );
  OAI22XL U525 ( .A0(n434), .A1(n433), .B0(n432), .B1(n431), .Y(n440) );
  INVXL U526 ( .A(n4), .Y(n438) );
  AOI22XL U527 ( .A0(n439), .A1(n17), .B0(n18), .B1(n438), .Y(n454) );
  NAND2XL U528 ( .A(n442), .B(n445), .Y(n444) );
  INVXL U530 ( .A(n456), .Y(n446) );
  NAND2XL U531 ( .A(n450), .B(n446), .Y(n453) );
  NAND2XL U532 ( .A(intadd_3_CI), .B(n448), .Y(n447) );
  AOI21XL U533 ( .A0(n450), .A1(n4), .B0(n455), .Y(n457) );
  NAND2XL U534 ( .A(n17), .B(n18), .Y(n459) );
  AOI22XL U535 ( .A0(n454), .A1(n453), .B0(n452), .B1(n451), .Y(n464) );
  INVXL U536 ( .A(n455), .Y(n458) );
  OAI22XL U537 ( .A0(n459), .A1(n458), .B0(n457), .B1(n456), .Y(n460) );
  NAND2XL U538 ( .A(mask[1]), .B(n490), .Y(n466) );
  XNOR2XL U539 ( .A(intadd_3_CI), .B(n464), .Y(n467) );
  NOR2XL U540 ( .A(j_old2[2]), .B(n368), .Y(n469) );
  AOI211XL U541 ( .A0(n368), .A1(n570), .B0(n469), .C0(n468), .Y(n477) );
  NOR2XL U542 ( .A(j_old2[3]), .B(n348), .Y(n470) );
  INVXL U543 ( .A(n476), .Y(n473) );
  NOR2XL U544 ( .A(j_old2[1]), .B(n473), .Y(n474) );
  AOI21XL U545 ( .A0(n477), .A1(j_old2[1]), .B0(n474), .Y(n502) );
  NAND2XL U546 ( .A(n571), .B(n477), .Y(n475) );
  NAND2XL U547 ( .A(j_old2[0]), .B(n499), .Y(n500) );
  NAND2XL U548 ( .A(n502), .B(n500), .Y(n478) );
  XOR2XL U549 ( .A(i_old2[1]), .B(n478), .Y(n479) );
  NAND2XL U550 ( .A(mask[0]), .B(j_old2[0]), .Y(n480) );
  AOI22XL U551 ( .A0(n565), .A1(n480), .B0(mask[0]), .B1(intadd_3_CI), .Y(n507) );
  NAND2XL U552 ( .A(intadd_3_SUM_2_), .B(intadd_3_n1), .Y(n481) );
  NOR2XL U553 ( .A(intadd_3_SUM_2_), .B(intadd_3_n1), .Y(n483) );
  NOR2XL U554 ( .A(intadd_3_SUM_3_), .B(n481), .Y(n482) );
  AOI211XL U555 ( .A0(intadd_3_SUM_3_), .A1(n481), .B0(n483), .C0(n482), .Y(
        n485) );
  OR2XL U556 ( .A(n486), .B(n485), .Y(n488) );
  AO21XL U557 ( .A0(intadd_3_SUM_3_), .A1(n483), .B0(n482), .Y(n484) );
  NAND2XL U558 ( .A(n486), .B(n485), .Y(n487) );
  INVXL U559 ( .A(n491), .Y(n494) );
  AOI21XL U560 ( .A0(intadd_3_SUM_0_), .A1(n491), .B0(n490), .Y(n492) );
  NAND2XL U561 ( .A(n494), .B(n493), .Y(n496) );
  MX2XL U562 ( .A(n498), .B(n497), .S0(intadd_3_SUM_0_), .Y(n505) );
  INVXL U563 ( .A(n499), .Y(n503) );
  INVXL U564 ( .A(n500), .Y(n501) );
  MX2XL U565 ( .A(n505), .B(n504), .S0(mask[0]), .Y(n506) );
  NOR2XL U566 ( .A(rotation_type[1]), .B(loc_y[2]), .Y(n511) );
  ADDFX1 U567 ( .A(j_mul[9]), .B(i_mul[9]), .CI(n510), .CO(intadd_2_B_9_), .S(
        intadd_2_A_8_) );
  ADDFX1 U568 ( .A(j_mul[8]), .B(i_mul[8]), .CI(n512), .CO(intadd_2_B_8_), .S(
        intadd_2_A_7_) );
  ADDFX1 U569 ( .A(loc_y[1]), .B(j_mul[7]), .CI(i_mul[7]), .CO(intadd_2_B_7_), 
        .S(intadd_2_A_6_) );
  AOI2BB1XL U570 ( .A0N(j_mul[0]), .A1N(loc_x[0]), .B0(intadd_2_CI), .Y(N1537)
         );
  AO21XL U571 ( .A0(N1540), .A1(intadd_2_SUM_1_), .B0(n513), .Y(N1583) );
  ADDFX1 U572 ( .A(j_mul[10]), .B(i_mul[10]), .CI(n514), .CO(n41), .S(
        intadd_2_A_9_) );
  AOI211XL U573 ( .A0(n566), .A1(n516), .B0(n515), .C0(n522), .Y(N193) );
  AOI211XL U574 ( .A0(n561), .A1(n517), .B0(n520), .C0(n522), .Y(N195) );
  INVXL U575 ( .A(n518), .Y(n519) );
  NAND2XL U576 ( .A(n521), .B(n520), .Y(n523) );
  INVXL U577 ( .A(n523), .Y(n524) );
  INVXL U578 ( .A(n553), .Y(n556) );
  AOI21XL U579 ( .A0(i_old[1]), .A1(N1492), .B0(n531), .Y(n528) );
  AOI22XL U580 ( .A0(n556), .A1(n528), .B0(i_old[1]), .B1(n55), .Y(n527) );
  AOI22XL U581 ( .A0(i_old[1]), .A1(n554), .B0(n549), .B1(n528), .Y(n530) );
  AOI21XL U582 ( .A0(n531), .A1(n572), .B0(n540), .Y(n538) );
  AOI22XL U583 ( .A0(i_old[2]), .A1(n55), .B0(n549), .B1(j_old[2]), .Y(n534)
         );
  OAI21XL U584 ( .A0(n532), .A1(j_old[2]), .B0(n539), .Y(n535) );
  NAND2XL U585 ( .A(n554), .B(n535), .Y(n533) );
  AOI22XL U586 ( .A0(i_old[2]), .A1(n554), .B0(n55), .B1(j_old[2]), .Y(n537)
         );
  NAND2XL U587 ( .A(n556), .B(n535), .Y(n536) );
  XOR2XL U588 ( .A(n38), .B(n539), .Y(n543) );
  AOI22XL U589 ( .A0(i_old[3]), .A1(n55), .B0(n554), .B1(n543), .Y(n542) );
  AOI21XL U590 ( .A0(n540), .A1(i_old[3]), .B0(n548), .Y(n544) );
  NAND2XL U591 ( .A(n556), .B(n544), .Y(n541) );
  NAND2XL U592 ( .A(n544), .B(n549), .Y(n545) );
  NAND2BXL U593 ( .AN(i_old[4]), .B(n548), .Y(n559) );
  AOI22XL U594 ( .A0(n55), .A1(i_old[4]), .B0(n549), .B1(j_old[4]), .Y(n552)
         );
  INVXL U595 ( .A(n550), .Y(n555) );
  AOI22XL U596 ( .A0(n55), .A1(j_old[4]), .B0(n554), .B1(i_old[4]), .Y(n558)
         );
  ADDFX1 U597 ( .A(j_old2[3]), .B(n13), .CI(intadd_3_n3), .CO(intadd_3_n2), 
        .S(intadd_3_SUM_2_) );
  ADDFX1 U598 ( .A(j_old2[2]), .B(i_old2[2]), .CI(intadd_3_n4), .CO(
        intadd_3_n3), .S(intadd_3_SUM_1_) );
  ADDFX1 U599 ( .A(intadd_3_CI), .B(j_old2[1]), .CI(i_old2[1]), .CO(
        intadd_3_n4), .S(intadd_3_SUM_0_) );
  ADDFX1 U600 ( .A(j_old2[4]), .B(i_old2[4]), .CI(intadd_3_n2), .CO(
        intadd_3_n1), .S(intadd_3_SUM_3_) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_0 clk_gate_code_word_reg ( .CLK(clk), 
        .EN(net7052), .ENCLK(net7056) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_15 clk_gate_code_word_reg_0 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7061) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_14 clk_gate_code_word_reg_1 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7066) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_13 clk_gate_code_word_reg_2 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7071) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_12 clk_gate_code_word_reg_3 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7076) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_11 clk_gate_code_word_reg_4 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7081) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_10 clk_gate_code_word_reg_5 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7086) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_9 clk_gate_code_word_reg_6 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7091) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_8 clk_gate_code_word_reg_7 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7096) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_7 clk_gate_code_word_reg_8 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7101) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_6 clk_gate_code_word_reg_9 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7106) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_5 clk_gate_code_word_reg_10 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7111) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_4 clk_gate_code_word_reg_11 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7116) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_3 clk_gate_code_word_reg_12 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7121) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_2 clk_gate_code_word_reg_13 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7126) );
  SNPS_CLOCK_GATE_HIGH_DEMASKING_mydesign_1 clk_gate_code_word_reg_14 ( .CLK(
        clk), .EN(net7052), .ENCLK(net7131) );
  DFFTRXL j_old2_reg_1_ ( .D(n585), .RN(j_old[1]), .CK(clk), .Q(j_old2[1]), 
        .QN(n571) );
  DFFTRXL i_old2_reg_0_ ( .D(n585), .RN(N1492), .CK(clk), .Q(i_old2[0]), .QN(
        n565) );
  INVX1 U9 ( .A(srst_n), .Y(n588) );
  NOR2XL U3 ( .A(n348), .B(n37), .Y(n351) );
  ADDFX1 U4 ( .A(n351), .B(n350), .CI(n349), .CO(n369), .S(n353) );
  NOR2BXL U6 ( .AN(i_old2[1]), .B(n570), .Y(n327) );
  AOI21XL U7 ( .A0(n366), .A1(n365), .B0(n364), .Y(n374) );
  XNOR2XL U8 ( .A(j_old2[2]), .B(n470), .Y(n471) );
  XNOR2XL U10 ( .A(n346), .B(n345), .Y(n407) );
  MXI2XL U11 ( .A(n445), .B(n444), .S0(n590), .Y(n456) );
  NOR2BXL U12 ( .AN(n574), .B(n479), .Y(n33) );
  AOI221XL U14 ( .A0(n227), .A1(n226), .B0(n225), .B1(n226), .C0(n224), .Y(
        n230) );
  XNOR2XL U17 ( .A(loc_y[4]), .B(n39), .Y(n514) );
  AND2XL U22 ( .A(n31), .B(n34), .Y(n10) );
  NOR4XL U29 ( .A(n152), .B(n208), .C(n140), .D(n139), .Y(n141) );
  NOR4XL U32 ( .A(n209), .B(n285), .C(n208), .D(n207), .Y(n210) );
  NOR4BXL U44 ( .AN(n97), .B(n96), .C(n95), .D(n94), .Y(n108) );
  XNOR2XL U108 ( .A(j_mul[11]), .B(loc_y[5]), .Y(n44) );
  XNOR2XL U113 ( .A(xor_in), .B(n46), .Y(demask_result) );
  OAI2BB1XL U114 ( .A0N(N1542), .A1N(n237), .B0(n49), .Y(N1585) );
  XNOR2XL U137 ( .A(n45), .B(n44), .Y(N1548) );
  OAI22XL U176 ( .A0(n437), .A1(n436), .B0(n435), .B1(n440), .Y(n590) );
  OAI22XL U189 ( .A0(n437), .A1(n436), .B0(n435), .B1(n440), .Y(n443) );
  NAND2XL U214 ( .A(n344), .B(n343), .Y(n591) );
  OAI21XL U427 ( .A0(n375), .A1(n374), .B0(n373), .Y(n592) );
  OAI21XL U443 ( .A0(n375), .A1(n374), .B0(n373), .Y(n379) );
  AO21XL U484 ( .A0(n406), .A1(n417), .B0(n405), .Y(n593) );
  CLKXOR2X1 U506 ( .A(n442), .B(n590), .Y(n4) );
endmodule


module DECODING ( clk, srst_n, state, decode_complete, decode_text, valid, 
        code_word_144_, code_word_143_, code_word_142_, code_word_141_, 
        code_word_140_, code_word_139_, code_word_138_, code_word_137_, 
        code_word_136_, code_word_135_, code_word_134_, code_word_133_, 
        code_word_132_, code_word_131_, code_word_130_, code_word_129_, 
        code_word_128_, code_word_127_, code_word_126_, code_word_125_, 
        code_word_124_, code_word_123_, code_word_122_, code_word_121_, 
        code_word_120_, code_word_119_, code_word_118_, code_word_117_, 
        code_word_116_, code_word_115_, code_word_114_, code_word_113_, 
        code_word_112_, code_word_111_, code_word_110_, code_word_109_, 
        code_word_108_, code_word_107_, code_word_106_, code_word_105_, 
        code_word_104_, code_word_103_, code_word_102_, code_word_101_, 
        code_word_100_, code_word_99_, code_word_98_, code_word_97_, 
        code_word_96_, code_word_95_, code_word_94_, code_word_93_, 
        code_word_92_, code_word_91_, code_word_90_, code_word_89_, 
        code_word_88_, code_word_87_, code_word_86_, code_word_85_, 
        code_word_84_, code_word_83_, code_word_82_, code_word_81_, 
        code_word_80_, code_word_79_, code_word_78_, code_word_77_, 
        code_word_76_, code_word_75_, code_word_74_, code_word_73_, 
        code_word_72_, code_word_71_, code_word_70_, code_word_69_, 
        code_word_68_, code_word_67_, code_word_66_, code_word_65_, 
        code_word_64_, code_word_63_, code_word_62_, code_word_61_, 
        code_word_60_, code_word_59_, code_word_58_, code_word_57_, 
        code_word_56_, code_word_55_, code_word_54_, code_word_53_, 
        code_word_52_, code_word_51_, code_word_50_, code_word_49_, 
        code_word_48_, code_word_47_, code_word_46_, code_word_45_, 
        code_word_44_, code_word_43_, code_word_42_, code_word_41_, 
        code_word_40_, code_word_39_, code_word_38_, code_word_37_, 
        code_word_36_, code_word_35_, code_word_34_, code_word_33_, 
        code_word_32_, code_word_31_, code_word_30_, code_word_29_, 
        code_word_28_, code_word_27_, code_word_26_, code_word_25_, 
        code_word_24_, code_word_23_, code_word_22_, code_word_21_, 
        code_word_20_, code_word_19_, code_word_18_, code_word_17_, 
        code_word_16_, code_word_15_, code_word_14_, code_word_13_, 
        code_word_12_, code_word_11_, code_word_10_, code_word_9_, 
        code_word_8_, code_word_7_, code_word_6_, code_word_5_, code_word_4_, 
        code_word_3_, code_word_2_, code_word_1_, code_word_0_ );
  input [3:0] state;
  output [7:0] decode_text;
  input clk, srst_n, code_word_144_, code_word_143_, code_word_142_,
         code_word_141_, code_word_140_, code_word_139_, code_word_138_,
         code_word_137_, code_word_136_, code_word_135_, code_word_134_,
         code_word_133_, code_word_132_, code_word_131_, code_word_130_,
         code_word_129_, code_word_128_, code_word_127_, code_word_126_,
         code_word_125_, code_word_124_, code_word_123_, code_word_122_,
         code_word_121_, code_word_120_, code_word_119_, code_word_118_,
         code_word_117_, code_word_116_, code_word_115_, code_word_114_,
         code_word_113_, code_word_112_, code_word_111_, code_word_110_,
         code_word_109_, code_word_108_, code_word_107_, code_word_106_,
         code_word_105_, code_word_104_, code_word_103_, code_word_102_,
         code_word_101_, code_word_100_, code_word_99_, code_word_98_,
         code_word_97_, code_word_96_, code_word_95_, code_word_94_,
         code_word_93_, code_word_92_, code_word_91_, code_word_90_,
         code_word_89_, code_word_88_, code_word_87_, code_word_86_,
         code_word_85_, code_word_84_, code_word_83_, code_word_82_,
         code_word_81_, code_word_80_, code_word_79_, code_word_78_,
         code_word_77_, code_word_76_, code_word_75_, code_word_74_,
         code_word_73_, code_word_72_, code_word_71_, code_word_70_,
         code_word_69_, code_word_68_, code_word_67_, code_word_66_,
         code_word_65_, code_word_64_, code_word_63_, code_word_62_,
         code_word_61_, code_word_60_, code_word_59_, code_word_58_,
         code_word_57_, code_word_56_, code_word_55_, code_word_54_,
         code_word_53_, code_word_52_, code_word_51_, code_word_50_,
         code_word_49_, code_word_48_, code_word_47_, code_word_46_,
         code_word_45_, code_word_44_, code_word_43_, code_word_42_,
         code_word_41_, code_word_40_, code_word_39_, code_word_38_,
         code_word_37_, code_word_36_, code_word_35_, code_word_34_,
         code_word_33_, code_word_32_, code_word_31_, code_word_30_,
         code_word_29_, code_word_28_, code_word_27_, code_word_26_,
         code_word_25_, code_word_24_, code_word_23_, code_word_22_,
         code_word_21_, code_word_20_, code_word_19_, code_word_18_,
         code_word_17_, code_word_16_, code_word_15_, code_word_14_,
         code_word_13_, code_word_12_, code_word_11_, code_word_10_,
         code_word_9_, code_word_8_, code_word_7_, code_word_6_, code_word_5_,
         code_word_4_, code_word_3_, code_word_2_, code_word_1_, code_word_0_;
  output decode_complete, valid;
  wire   n116, n117, n118, n119, n120, n121, n122, n123, n124, n1, n2, n3, n4,
         n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19,
         n20, n21, n22, n23, n24, n25, n26, n27, n28, n29, n30, n31, n32, n33,
         n34, n35, n36, n37, n38, n39, n40, n41, n42, n43, n44, n45, n46, n47,
         n48, n49, n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61,
         n62, n63, n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75,
         n76, n77, n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89,
         n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100, n101, n102,
         n103, n104, n105, n106, n107, n108, n109, n110, n111, n112, n113,
         n114, n115, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n140, n141, n142, n143, n144,
         n145, n146;
  wire   [4:0] decode_cnt;
  wire   [4:0] decode_cnt_tmp;

  DFFTRXL decode_cnt_reg_4_ ( .D(srst_n), .RN(decode_cnt_tmp[4]), .CK(clk), 
        .Q(decode_cnt[4]) );
  DFFTRXL decode_cnt_reg_3_ ( .D(srst_n), .RN(decode_cnt_tmp[3]), .CK(clk), 
        .Q(decode_cnt[3]), .QN(n145) );
  DFFTRXL decode_cnt_reg_2_ ( .D(srst_n), .RN(decode_cnt_tmp[2]), .CK(clk), 
        .Q(decode_cnt[2]), .QN(n146) );
  DFFTRXL decode_cnt_reg_1_ ( .D(srst_n), .RN(decode_cnt_tmp[1]), .CK(clk), 
        .Q(decode_cnt[1]), .QN(n144) );
  DFFTRXL decode_cnt_reg_0_ ( .D(srst_n), .RN(decode_cnt_tmp[0]), .CK(clk), 
        .Q(decode_cnt[0]), .QN(n143) );
  DFFTRXL valid_reg ( .D(n124), .RN(srst_n), .CK(clk), .Q(valid) );
  DFFTRXL decode_text_reg_7_ ( .D(srst_n), .RN(n123), .CK(clk), .Q(
        decode_text[7]) );
  DFFTRXL decode_text_reg_6_ ( .D(srst_n), .RN(n122), .CK(clk), .Q(
        decode_text[6]) );
  DFFTRXL decode_text_reg_5_ ( .D(srst_n), .RN(n121), .CK(clk), .Q(
        decode_text[5]) );
  DFFTRXL decode_text_reg_4_ ( .D(srst_n), .RN(n120), .CK(clk), .Q(
        decode_text[4]) );
  DFFTRXL decode_text_reg_3_ ( .D(srst_n), .RN(n119), .CK(clk), .Q(
        decode_text[3]) );
  DFFTRXL decode_text_reg_2_ ( .D(srst_n), .RN(n118), .CK(clk), .Q(
        decode_text[2]) );
  DFFTRXL decode_text_reg_1_ ( .D(srst_n), .RN(n117), .CK(clk), .Q(
        decode_text[1]) );
  DFFTRXL decode_text_reg_0_ ( .D(srst_n), .RN(n116), .CK(clk), .Q(
        decode_text[0]) );
  OAI211XL U3 ( .A0(code_word_142_), .A1(n130), .B0(n126), .C0(n125), .Y(n127)
         );
  OAI211XL U4 ( .A0(decode_cnt[2]), .A1(n131), .B0(code_word_142_), .C0(n130), 
        .Y(n132) );
  NOR2BX1 U6 ( .AN(n96), .B(n1), .Y(n104) );
  NOR2BX1 U8 ( .AN(n124), .B(n137), .Y(decode_complete) );
  AOI222XL U10 ( .A0(n85), .A1(n108), .B0(code_word_11_), .B1(n104), .C0(n84), 
        .C1(n102), .Y(n86) );
  AOI222XL U11 ( .A0(n63), .A1(n108), .B0(n104), .B1(code_word_10_), .C0(n62), 
        .C1(n102), .Y(n64) );
  AOI222XL U12 ( .A0(n74), .A1(n108), .B0(n104), .B1(code_word_9_), .C0(n73), 
        .C1(n102), .Y(n75) );
  OAI211XL U13 ( .A0(decode_cnt[3]), .A1(n115), .B0(code_word_143_), .C0(n114), 
        .Y(n125) );
  AOI222XL U14 ( .A0(n105), .A1(n108), .B0(n104), .B1(code_word_8_), .C0(n103), 
        .C1(n102), .Y(n106) );
  AOI221X1 U17 ( .A0(n139), .A1(n138), .B0(n146), .B1(n138), .C0(n140), .Y(
        decode_cnt_tmp[2]) );
  AOI221X1 U18 ( .A0(decode_cnt[3]), .A1(n142), .B0(n145), .B1(n141), .C0(n140), .Y(decode_cnt_tmp[3]) );
  NAND2XL U19 ( .A(decode_cnt[2]), .B(n143), .Y(n3) );
  AOI22XL U20 ( .A0(n97), .A1(code_word_28_), .B0(n96), .B1(code_word_68_), 
        .Y(n29) );
  AOI22XL U21 ( .A0(n92), .A1(code_word_118_), .B0(n91), .B1(code_word_126_), 
        .Y(n12) );
  AOI22XL U22 ( .A0(n142), .A1(code_word_80_), .B0(n95), .B1(code_word_104_), 
        .Y(n99) );
  AOI22XL U23 ( .A0(n97), .A1(code_word_98_), .B0(n96), .B1(code_word_138_), 
        .Y(n58) );
  AOI22XL U24 ( .A0(n142), .A1(code_word_19_), .B0(n95), .B1(code_word_43_), 
        .Y(n77) );
  NOR2XL U25 ( .A(decode_cnt[3]), .B(decode_cnt[4]), .Y(n102) );
  AOI22XL U26 ( .A0(n108), .A1(n26), .B0(n102), .B1(n25), .Y(n27) );
  NAND2XL U27 ( .A(n124), .B(n137), .Y(n140) );
  NAND2XL U28 ( .A(n28), .B(n27), .Y(n117) );
  NAND2XL U29 ( .A(n143), .B(n146), .Y(n2) );
  NOR2XL U30 ( .A(decode_cnt[1]), .B(n2), .Y(n96) );
  NAND2XL U31 ( .A(decode_cnt[4]), .B(n145), .Y(n1) );
  NAND2XL U32 ( .A(decode_cnt[0]), .B(n144), .Y(n4) );
  NOR2XL U33 ( .A(decode_cnt[2]), .B(n4), .Y(n91) );
  AOI22XL U34 ( .A0(n104), .A1(code_word_6_), .B0(n50), .B1(code_word_2_), .Y(
        n16) );
  NOR2XL U35 ( .A(decode_cnt[4]), .B(n145), .Y(n108) );
  NOR2XL U36 ( .A(n144), .B(n2), .Y(n92) );
  AOI22XL U37 ( .A0(n92), .A1(code_word_54_), .B0(n91), .B1(code_word_62_), 
        .Y(n8) );
  NOR2XL U38 ( .A(n143), .B(n144), .Y(n139) );
  NAND2XL U39 ( .A(n139), .B(n146), .Y(n138) );
  INVXL U40 ( .A(n138), .Y(n94) );
  NOR2XL U41 ( .A(n144), .B(n3), .Y(n93) );
  AOI22XL U42 ( .A0(n94), .A1(code_word_46_), .B0(n93), .B1(code_word_22_), 
        .Y(n7) );
  NAND2XL U43 ( .A(decode_cnt[2]), .B(n139), .Y(n141) );
  INVXL U44 ( .A(n141), .Y(n142) );
  NOR2XL U45 ( .A(decode_cnt[1]), .B(n3), .Y(n95) );
  AOI22XL U46 ( .A0(n142), .A1(code_word_14_), .B0(n95), .B1(code_word_38_), 
        .Y(n6) );
  NOR2XL U47 ( .A(n4), .B(n146), .Y(n97) );
  AOI22XL U48 ( .A0(n97), .A1(code_word_30_), .B0(n96), .B1(code_word_70_), 
        .Y(n5) );
  NAND4XL U49 ( .A(n8), .B(n7), .C(n6), .D(n5), .Y(n14) );
  AOI22XL U50 ( .A0(n94), .A1(code_word_110_), .B0(n93), .B1(code_word_86_), 
        .Y(n11) );
  AOI22XL U51 ( .A0(n142), .A1(code_word_78_), .B0(n95), .B1(code_word_102_), 
        .Y(n10) );
  AOI22XL U52 ( .A0(n97), .A1(code_word_94_), .B0(n96), .B1(code_word_134_), 
        .Y(n9) );
  NAND4XL U53 ( .A(n12), .B(n11), .C(n10), .D(n9), .Y(n13) );
  AOI22XL U54 ( .A0(n108), .A1(n14), .B0(n102), .B1(n13), .Y(n15) );
  NAND2XL U55 ( .A(n16), .B(n15), .Y(n118) );
  AOI22XL U56 ( .A0(n104), .A1(code_word_5_), .B0(n50), .B1(code_word_1_), .Y(
        n28) );
  AOI22XL U57 ( .A0(n92), .A1(code_word_53_), .B0(n91), .B1(code_word_61_), 
        .Y(n20) );
  AOI22XL U58 ( .A0(n94), .A1(code_word_45_), .B0(n93), .B1(code_word_21_), 
        .Y(n19) );
  AOI22XL U59 ( .A0(n142), .A1(code_word_13_), .B0(n95), .B1(code_word_37_), 
        .Y(n18) );
  AOI22XL U60 ( .A0(n97), .A1(code_word_29_), .B0(n96), .B1(code_word_69_), 
        .Y(n17) );
  NAND4XL U61 ( .A(n20), .B(n19), .C(n18), .D(n17), .Y(n26) );
  AOI22XL U62 ( .A0(n92), .A1(code_word_117_), .B0(n91), .B1(code_word_125_), 
        .Y(n24) );
  AOI22XL U63 ( .A0(n94), .A1(code_word_109_), .B0(n93), .B1(code_word_85_), 
        .Y(n23) );
  AOI22XL U64 ( .A0(n142), .A1(code_word_77_), .B0(n95), .B1(code_word_101_), 
        .Y(n22) );
  AOI22XL U65 ( .A0(n97), .A1(code_word_93_), .B0(n96), .B1(code_word_133_), 
        .Y(n21) );
  NAND4XL U66 ( .A(n24), .B(n23), .C(n22), .D(n21), .Y(n25) );
  AOI22XL U67 ( .A0(n104), .A1(code_word_4_), .B0(n50), .B1(code_word_0_), .Y(
        n40) );
  AOI22XL U68 ( .A0(n92), .A1(code_word_52_), .B0(n91), .B1(code_word_60_), 
        .Y(n32) );
  AOI22XL U69 ( .A0(n94), .A1(code_word_44_), .B0(n93), .B1(code_word_20_), 
        .Y(n31) );
  AOI22XL U70 ( .A0(n142), .A1(code_word_12_), .B0(n95), .B1(code_word_36_), 
        .Y(n30) );
  NAND4XL U71 ( .A(n32), .B(n31), .C(n30), .D(n29), .Y(n38) );
  AOI22XL U72 ( .A0(n92), .A1(code_word_116_), .B0(n91), .B1(code_word_124_), 
        .Y(n36) );
  AOI22XL U73 ( .A0(n94), .A1(code_word_108_), .B0(n93), .B1(code_word_84_), 
        .Y(n35) );
  AOI22XL U74 ( .A0(n142), .A1(code_word_76_), .B0(n95), .B1(code_word_100_), 
        .Y(n34) );
  AOI22XL U75 ( .A0(n97), .A1(code_word_92_), .B0(n96), .B1(code_word_132_), 
        .Y(n33) );
  NAND4XL U76 ( .A(n36), .B(n35), .C(n34), .D(n33), .Y(n37) );
  AOI22XL U77 ( .A0(n108), .A1(n38), .B0(n102), .B1(n37), .Y(n39) );
  NAND2XL U78 ( .A(n40), .B(n39), .Y(n116) );
  AOI22XL U79 ( .A0(n92), .A1(code_word_55_), .B0(n91), .B1(code_word_63_), 
        .Y(n44) );
  AOI22XL U80 ( .A0(n94), .A1(code_word_47_), .B0(n93), .B1(code_word_23_), 
        .Y(n43) );
  AOI22XL U81 ( .A0(n142), .A1(code_word_15_), .B0(n95), .B1(code_word_39_), 
        .Y(n42) );
  AOI22XL U82 ( .A0(n97), .A1(code_word_31_), .B0(n96), .B1(code_word_71_), 
        .Y(n41) );
  NAND4XL U83 ( .A(n44), .B(n43), .C(n42), .D(n41), .Y(n45) );
  AOI22XL U84 ( .A0(n108), .A1(n45), .B0(n104), .B1(code_word_7_), .Y(n53) );
  AOI22XL U85 ( .A0(n92), .A1(code_word_119_), .B0(n91), .B1(code_word_127_), 
        .Y(n49) );
  AOI22XL U86 ( .A0(n94), .A1(code_word_111_), .B0(n93), .B1(code_word_87_), 
        .Y(n48) );
  AOI22XL U87 ( .A0(n142), .A1(code_word_79_), .B0(n95), .B1(code_word_103_), 
        .Y(n47) );
  AOI22XL U88 ( .A0(n97), .A1(code_word_95_), .B0(n96), .B1(code_word_135_), 
        .Y(n46) );
  NAND4XL U89 ( .A(n49), .B(n48), .C(n47), .D(n46), .Y(n51) );
  AOI22XL U90 ( .A0(n102), .A1(n51), .B0(n50), .B1(code_word_3_), .Y(n52) );
  NAND2XL U91 ( .A(n53), .B(n52), .Y(n119) );
  AOI22XL U92 ( .A0(n92), .A1(code_word_58_), .B0(n91), .B1(code_word_66_), 
        .Y(n57) );
  AOI22XL U93 ( .A0(n94), .A1(code_word_50_), .B0(n93), .B1(code_word_26_), 
        .Y(n56) );
  AOI22XL U94 ( .A0(n142), .A1(code_word_18_), .B0(n95), .B1(code_word_42_), 
        .Y(n55) );
  AOI22XL U95 ( .A0(n97), .A1(code_word_34_), .B0(n96), .B1(code_word_74_), 
        .Y(n54) );
  NAND4XL U96 ( .A(n57), .B(n56), .C(n55), .D(n54), .Y(n63) );
  AOI22XL U97 ( .A0(n92), .A1(code_word_122_), .B0(n91), .B1(code_word_130_), 
        .Y(n61) );
  AOI22XL U98 ( .A0(n94), .A1(code_word_114_), .B0(n93), .B1(code_word_90_), 
        .Y(n60) );
  AOI22XL U99 ( .A0(n142), .A1(code_word_82_), .B0(n95), .B1(code_word_106_), 
        .Y(n59) );
  NAND4XL U100 ( .A(n61), .B(n60), .C(n59), .D(n58), .Y(n62) );
  INVXL U101 ( .A(n64), .Y(n122) );
  AOI22XL U102 ( .A0(n92), .A1(code_word_57_), .B0(n91), .B1(code_word_65_), 
        .Y(n68) );
  AOI22XL U103 ( .A0(n94), .A1(code_word_49_), .B0(n93), .B1(code_word_25_), 
        .Y(n67) );
  AOI22XL U104 ( .A0(n142), .A1(code_word_17_), .B0(n95), .B1(code_word_41_), 
        .Y(n66) );
  AOI22XL U105 ( .A0(n97), .A1(code_word_33_), .B0(n96), .B1(code_word_73_), 
        .Y(n65) );
  NAND4XL U106 ( .A(n68), .B(n67), .C(n66), .D(n65), .Y(n74) );
  AOI22XL U107 ( .A0(n92), .A1(code_word_121_), .B0(n91), .B1(code_word_129_), 
        .Y(n72) );
  AOI22XL U108 ( .A0(n94), .A1(code_word_113_), .B0(n93), .B1(code_word_89_), 
        .Y(n71) );
  AOI22XL U109 ( .A0(n142), .A1(code_word_81_), .B0(n95), .B1(code_word_105_), 
        .Y(n70) );
  AOI22XL U110 ( .A0(n97), .A1(code_word_97_), .B0(n96), .B1(code_word_137_), 
        .Y(n69) );
  NAND4XL U111 ( .A(n72), .B(n71), .C(n70), .D(n69), .Y(n73) );
  INVXL U112 ( .A(n75), .Y(n121) );
  AOI22XL U113 ( .A0(n92), .A1(code_word_59_), .B0(n91), .B1(code_word_67_), 
        .Y(n79) );
  AOI22XL U114 ( .A0(n94), .A1(code_word_51_), .B0(n93), .B1(code_word_27_), 
        .Y(n78) );
  AOI22XL U115 ( .A0(n97), .A1(code_word_35_), .B0(n96), .B1(code_word_75_), 
        .Y(n76) );
  NAND4XL U116 ( .A(n79), .B(n78), .C(n77), .D(n76), .Y(n85) );
  AOI22XL U117 ( .A0(n92), .A1(code_word_123_), .B0(n91), .B1(code_word_131_), 
        .Y(n83) );
  AOI22XL U118 ( .A0(n94), .A1(code_word_115_), .B0(n93), .B1(code_word_91_), 
        .Y(n82) );
  AOI22XL U119 ( .A0(n142), .A1(code_word_83_), .B0(n95), .B1(code_word_107_), 
        .Y(n81) );
  AOI22XL U120 ( .A0(n97), .A1(code_word_99_), .B0(n96), .B1(code_word_139_), 
        .Y(n80) );
  NAND4XL U121 ( .A(n83), .B(n82), .C(n81), .D(n80), .Y(n84) );
  INVXL U122 ( .A(n86), .Y(n123) );
  AOI22XL U123 ( .A0(n92), .A1(code_word_56_), .B0(n91), .B1(code_word_64_), 
        .Y(n90) );
  AOI22XL U124 ( .A0(n94), .A1(code_word_48_), .B0(n93), .B1(code_word_24_), 
        .Y(n89) );
  AOI22XL U125 ( .A0(n142), .A1(code_word_16_), .B0(n95), .B1(code_word_40_), 
        .Y(n88) );
  AOI22XL U126 ( .A0(n97), .A1(code_word_32_), .B0(n96), .B1(code_word_72_), 
        .Y(n87) );
  NAND4XL U127 ( .A(n90), .B(n89), .C(n88), .D(n87), .Y(n105) );
  AOI22XL U128 ( .A0(n92), .A1(code_word_120_), .B0(n91), .B1(code_word_128_), 
        .Y(n101) );
  AOI22XL U129 ( .A0(n94), .A1(code_word_112_), .B0(n93), .B1(code_word_88_), 
        .Y(n100) );
  AOI22XL U130 ( .A0(n97), .A1(code_word_96_), .B0(n96), .B1(code_word_136_), 
        .Y(n98) );
  NAND4XL U131 ( .A(n101), .B(n100), .C(n99), .D(n98), .Y(n103) );
  INVXL U132 ( .A(n106), .Y(n120) );
  NAND3XL U133 ( .A(state[1]), .B(state[2]), .C(state[0]), .Y(n107) );
  NOR2XL U134 ( .A(state[3]), .B(n107), .Y(n124) );
  NAND2XL U135 ( .A(decode_cnt[3]), .B(n142), .Y(n109) );
  AOI22XL U136 ( .A0(decode_cnt[4]), .A1(n109), .B0(n142), .B1(n108), .Y(n136)
         );
  OR2XL U137 ( .A(code_word_140_), .B(code_word_141_), .Y(n131) );
  NOR2XL U138 ( .A(n131), .B(code_word_142_), .Y(n110) );
  INVXL U139 ( .A(n110), .Y(n115) );
  NOR2XL U140 ( .A(n145), .B(n115), .Y(n135) );
  OAI22XL U141 ( .A0(decode_cnt[0]), .A1(code_word_140_), .B0(decode_cnt[2]), 
        .B1(n115), .Y(n128) );
  NAND2XL U142 ( .A(decode_cnt[2]), .B(n131), .Y(n130) );
  INVXL U143 ( .A(n129), .Y(n113) );
  NOR2XL U144 ( .A(decode_cnt[3]), .B(n110), .Y(n111) );
  NOR2XL U145 ( .A(n111), .B(code_word_143_), .Y(n112) );
  AOI22XL U146 ( .A0(code_word_140_), .A1(n113), .B0(n112), .B1(n134), .Y(n126) );
  NAND2XL U147 ( .A(decode_cnt[3]), .B(n115), .Y(n114) );
  AOI211XL U148 ( .A0(decode_cnt[0]), .A1(n129), .B0(n128), .C0(n127), .Y(n133) );
  NOR2XL U149 ( .A(n136), .B(n140), .Y(decode_cnt_tmp[4]) );
  NOR2XL U150 ( .A(decode_cnt[0]), .B(n140), .Y(decode_cnt_tmp[0]) );
  XNOR2XL U5 ( .A(decode_cnt[1]), .B(code_word_141_), .Y(n129) );
  XNOR2XL U7 ( .A(decode_cnt[4]), .B(code_word_144_), .Y(n134) );
  NOR2BXL U9 ( .AN(n91), .B(n1), .Y(n50) );
  OAI211XL U15 ( .A0(n135), .A1(n134), .B0(n133), .C0(n132), .Y(n137) );
  AOI221XL U16 ( .A0(decode_cnt[1]), .A1(decode_cnt[0]), .B0(n144), .B1(n143), 
        .C0(n140), .Y(decode_cnt_tmp[1]) );
endmodule


module SNPS_CLOCK_GATE_HIGH_qrcode_decoder_mydesign_0 ( CLK, EN, ENCLK );
  input CLK, EN;
  output ENCLK;
  wire   n1;

  TLATNXL latch ( .D(EN), .GN(CLK), .Q(n1) );
  AND2XL main_gate ( .A(n1), .B(CLK), .Y(ENCLK) );
endmodule


module qrcode_decoder ( clk, srst_n, start, sram_rdata, sram_raddr, loc_y, 
        loc_x, decode_text, valid, finish );
  output [11:0] sram_raddr;
  output [5:0] loc_y;
  output [5:0] loc_x;
  output [7:0] decode_text;
  input clk, srst_n, start, sram_rdata;
  output valid, finish;
  wire   demask_complete, decode_complete, pre_scan_complete, num_complete,
         scan_complete, rotate_complete, loc_wrong, loc_complete, end_of_file,
         code_word_151_, code_word_150_, code_word_149_, code_word_148_,
         code_word_147_, code_word_146_, code_word_145_, code_word_144_,
         code_word_143_, code_word_142_, code_word_141_, code_word_140_,
         code_word_139_, code_word_138_, code_word_137_, code_word_136_,
         code_word_135_, code_word_134_, code_word_133_, code_word_132_,
         code_word_131_, code_word_130_, code_word_129_, code_word_128_,
         code_word_127_, code_word_126_, code_word_125_, code_word_124_,
         code_word_123_, code_word_122_, code_word_121_, code_word_120_,
         code_word_119_, code_word_118_, code_word_117_, code_word_116_,
         code_word_115_, code_word_114_, code_word_113_, code_word_112_,
         code_word_111_, code_word_110_, code_word_109_, code_word_108_,
         code_word_107_, code_word_106_, code_word_105_, code_word_104_,
         code_word_103_, code_word_102_, code_word_101_, code_word_100_,
         code_word_99_, code_word_98_, code_word_97_, code_word_96_,
         code_word_95_, code_word_94_, code_word_93_, code_word_92_,
         code_word_91_, code_word_90_, code_word_89_, code_word_88_,
         code_word_87_, code_word_86_, code_word_85_, code_word_84_,
         code_word_83_, code_word_82_, code_word_81_, code_word_80_,
         code_word_79_, code_word_78_, code_word_77_, code_word_76_,
         code_word_75_, code_word_74_, code_word_73_, code_word_72_,
         code_word_71_, code_word_70_, code_word_69_, code_word_68_,
         code_word_67_, code_word_66_, code_word_65_, code_word_64_,
         code_word_63_, code_word_62_, code_word_61_, code_word_60_,
         code_word_59_, code_word_58_, code_word_57_, code_word_56_,
         code_word_55_, code_word_54_, code_word_53_, code_word_52_,
         code_word_51_, code_word_50_, code_word_49_, code_word_48_,
         code_word_47_, code_word_46_, code_word_45_, code_word_44_,
         code_word_43_, code_word_42_, code_word_41_, code_word_40_,
         code_word_39_, code_word_38_, code_word_37_, code_word_36_,
         code_word_35_, code_word_34_, code_word_33_, code_word_32_,
         code_word_31_, code_word_30_, code_word_29_, code_word_28_,
         code_word_27_, code_word_26_, code_word_25_, code_word_24_,
         code_word_23_, code_word_22_, code_word_21_, code_word_20_,
         code_word_19_, code_word_18_, code_word_17_, code_word_16_,
         code_word_15_, code_word_14_, code_word_13_, code_word_12_,
         code_word_11_, code_word_10_, code_word_9_, code_word_8_,
         code_word_7_, code_word_6_, code_word_5_, code_word_4_, code_word_3_,
         code_word_2_, code_word_1_, code_word_0_, N19, N20, N21, N22, N23,
         N24, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
         n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n129, n130, n131, n132, n133, n134, n135, n136;
  wire   [3:0] state;
  wire   [11:0] rotate_addr;
  wire   [5:0] scan_loc_x;
  wire   [5:0] scan_loc_y;
  wire   [1:0] rotation_type;
  wire   [5:0] rotate_loc_x;
  wire   [11:0] loc_raddr;
  wire   [5:0] correct_loc_x;
  wire   [11:0] scan_raddr;
  wire   [5:0] x_upper;
  wire   [5:0] y_upper;
  wire   [5:0] x_lower;
  wire   [5:0] y_lower;
  wire   [2:0] qr_total;
  wire   [11:0] pre_scan_raddr;
  wire   [11:0] num_raddr;
  wire   [11:0] mask_addr;

  DFFTRXL loc_x_reg_3_ ( .D(n131), .RN(N22), .CK(n134), .Q(loc_x[3]), .QN(n125) );
  DFFTRXL loc_x_reg_4_ ( .D(n132), .RN(N23), .CK(n134), .Q(loc_x[4]), .QN(n120) );
  DFFTRXL loc_x_reg_5_ ( .D(n133), .RN(N24), .CK(n134), .Q(loc_x[5]), .QN(n121) );
  DFFTRXL loc_x_reg_0_ ( .D(n128), .RN(N19), .CK(n134), .Q(loc_x[0]), .QN(n124) );
  DFFTRXL loc_x_reg_2_ ( .D(n130), .RN(N21), .CK(n134), .Q(loc_x[2]), .QN(n123) );
  DFFTRXL loc_x_reg_1_ ( .D(n129), .RN(N20), .CK(n134), .Q(loc_x[1]), .QN(n122) );
  INVX1 U72 ( .A(n77), .Y(n115) );
  BUFX2 U73 ( .A(n112), .Y(n52) );
  NOR4XL U74 ( .A(state[2]), .B(state[3]), .C(n75), .D(n74), .Y(n112) );
  INVXL U77 ( .A(state[2]), .Y(n54) );
  NAND2XL U79 ( .A(state[0]), .B(n58), .Y(n77) );
  INVXL U80 ( .A(state[0]), .Y(n74) );
  NAND2X1 U81 ( .A(state[0]), .B(srst_n), .Y(n71) );
  NAND2XL U82 ( .A(srst_n), .B(n74), .Y(n69) );
  NAND2XL U83 ( .A(n127), .B(n73), .Y(n135) );
  OAI22XL U84 ( .A0(n62), .A1(n71), .B0(n61), .B1(n69), .Y(n129) );
  OAI22XL U85 ( .A0(n64), .A1(n71), .B0(n63), .B1(n69), .Y(n130) );
  OAI22XL U86 ( .A0(n60), .A1(n71), .B0(n59), .B1(n69), .Y(n128) );
  OAI22XL U87 ( .A0(n68), .A1(n71), .B0(n67), .B1(n69), .Y(n133) );
  OAI22XL U88 ( .A0(n66), .A1(n71), .B0(n65), .B1(n69), .Y(n132) );
  OAI22XL U89 ( .A0(n72), .A1(n71), .B0(n70), .B1(n69), .Y(n131) );
  INVXL U90 ( .A(n58), .Y(n73) );
  INVXL U91 ( .A(n76), .Y(n55) );
  BUFX2 U92 ( .A(n77), .Y(n56) );
  BUFX2 U93 ( .A(n76), .Y(n57) );
  OAI222XL U94 ( .A0(n63), .A1(n57), .B0(n123), .B1(n53), .C0(n64), .C1(n56), 
        .Y(N21) );
  OAI222XL U95 ( .A0(n59), .A1(n57), .B0(n124), .B1(n53), .C0(n60), .C1(n56), 
        .Y(N19) );
  OAI222XL U96 ( .A0(n70), .A1(n57), .B0(n125), .B1(n53), .C0(n72), .C1(n56), 
        .Y(N22) );
  OAI222XL U97 ( .A0(n65), .A1(n57), .B0(n120), .B1(n58), .C0(n66), .C1(n56), 
        .Y(N23) );
  OAI222XL U98 ( .A0(n61), .A1(n57), .B0(n122), .B1(n58), .C0(n62), .C1(n56), 
        .Y(N20) );
  OAI222XL U99 ( .A0(n67), .A1(n57), .B0(n121), .B1(n53), .C0(n68), .C1(n56), 
        .Y(N24) );
  INVXL U100 ( .A(rotate_loc_x[2]), .Y(n63) );
  BUFX3 U101 ( .A(srst_n), .Y(n126) );
  INVXL U102 ( .A(rotate_loc_x[5]), .Y(n67) );
  NAND2XL U103 ( .A(n74), .B(n58), .Y(n76) );
  INVXL U104 ( .A(correct_loc_x[5]), .Y(n68) );
  INVXL U105 ( .A(rotate_loc_x[1]), .Y(n61) );
  INVXL U106 ( .A(correct_loc_x[1]), .Y(n62) );
  INVXL U107 ( .A(rotate_loc_x[4]), .Y(n65) );
  INVXL U108 ( .A(correct_loc_x[4]), .Y(n66) );
  INVXL U109 ( .A(rotate_loc_x[3]), .Y(n70) );
  INVXL U110 ( .A(correct_loc_x[3]), .Y(n72) );
  INVXL U111 ( .A(rotate_loc_x[0]), .Y(n59) );
  INVXL U112 ( .A(correct_loc_x[0]), .Y(n60) );
  INVXL U113 ( .A(correct_loc_x[2]), .Y(n64) );
  AOI22XL U116 ( .A0(n52), .A1(scan_raddr[0]), .B0(n111), .B1(
        pre_scan_raddr[0]), .Y(n80) );
  AOI22XL U119 ( .A0(n114), .A1(num_raddr[0]), .B0(n113), .B1(mask_addr[0]), 
        .Y(n79) );
  INVXL U120 ( .A(n76), .Y(n116) );
  AOI22XL U121 ( .A0(n116), .A1(rotate_addr[0]), .B0(n115), .B1(loc_raddr[0]), 
        .Y(n78) );
  NAND3XL U122 ( .A(n80), .B(n79), .C(n78), .Y(sram_raddr[0]) );
  AOI22XL U123 ( .A0(n52), .A1(scan_raddr[1]), .B0(n111), .B1(
        pre_scan_raddr[1]), .Y(n83) );
  AOI22XL U124 ( .A0(n114), .A1(num_raddr[1]), .B0(n113), .B1(mask_addr[1]), 
        .Y(n82) );
  AOI22XL U125 ( .A0(n116), .A1(rotate_addr[1]), .B0(n115), .B1(loc_raddr[1]), 
        .Y(n81) );
  NAND3XL U126 ( .A(n83), .B(n82), .C(n81), .Y(sram_raddr[1]) );
  AOI22XL U127 ( .A0(n52), .A1(scan_raddr[2]), .B0(n111), .B1(
        pre_scan_raddr[2]), .Y(n86) );
  AOI22XL U128 ( .A0(n114), .A1(num_raddr[2]), .B0(n113), .B1(mask_addr[2]), 
        .Y(n85) );
  AOI22XL U129 ( .A0(n116), .A1(rotate_addr[2]), .B0(n115), .B1(loc_raddr[2]), 
        .Y(n84) );
  NAND3XL U130 ( .A(n86), .B(n85), .C(n84), .Y(sram_raddr[2]) );
  AOI22XL U131 ( .A0(n52), .A1(scan_raddr[3]), .B0(n111), .B1(
        pre_scan_raddr[3]), .Y(n89) );
  AOI22XL U132 ( .A0(n114), .A1(num_raddr[3]), .B0(n113), .B1(mask_addr[3]), 
        .Y(n88) );
  AOI22XL U133 ( .A0(n116), .A1(rotate_addr[3]), .B0(n115), .B1(loc_raddr[3]), 
        .Y(n87) );
  NAND3XL U134 ( .A(n89), .B(n88), .C(n87), .Y(sram_raddr[3]) );
  AOI22XL U135 ( .A0(n52), .A1(scan_raddr[4]), .B0(n111), .B1(
        pre_scan_raddr[4]), .Y(n92) );
  AOI22XL U136 ( .A0(n114), .A1(num_raddr[4]), .B0(n113), .B1(mask_addr[4]), 
        .Y(n91) );
  AOI22XL U137 ( .A0(n116), .A1(rotate_addr[4]), .B0(n115), .B1(loc_raddr[4]), 
        .Y(n90) );
  NAND3XL U138 ( .A(n92), .B(n91), .C(n90), .Y(sram_raddr[4]) );
  AOI22XL U139 ( .A0(n52), .A1(scan_raddr[5]), .B0(n111), .B1(
        pre_scan_raddr[5]), .Y(n95) );
  AOI22XL U140 ( .A0(n114), .A1(num_raddr[5]), .B0(n113), .B1(mask_addr[5]), 
        .Y(n94) );
  AOI22XL U141 ( .A0(n116), .A1(rotate_addr[5]), .B0(n115), .B1(loc_raddr[5]), 
        .Y(n93) );
  NAND3XL U142 ( .A(n95), .B(n94), .C(n93), .Y(sram_raddr[5]) );
  AOI22XL U143 ( .A0(n52), .A1(scan_raddr[6]), .B0(n111), .B1(
        pre_scan_raddr[6]), .Y(n98) );
  AOI22XL U144 ( .A0(n114), .A1(num_raddr[6]), .B0(n113), .B1(mask_addr[6]), 
        .Y(n97) );
  AOI22XL U145 ( .A0(n55), .A1(rotate_addr[6]), .B0(n115), .B1(loc_raddr[6]), 
        .Y(n96) );
  NAND3XL U146 ( .A(n98), .B(n97), .C(n96), .Y(sram_raddr[6]) );
  AOI22XL U147 ( .A0(n52), .A1(scan_raddr[7]), .B0(n111), .B1(
        pre_scan_raddr[7]), .Y(n101) );
  AOI22XL U148 ( .A0(n114), .A1(num_raddr[7]), .B0(n113), .B1(mask_addr[7]), 
        .Y(n100) );
  AOI22XL U149 ( .A0(n55), .A1(rotate_addr[7]), .B0(n115), .B1(loc_raddr[7]), 
        .Y(n99) );
  NAND3XL U150 ( .A(n101), .B(n100), .C(n99), .Y(sram_raddr[7]) );
  AOI22XL U151 ( .A0(n52), .A1(scan_raddr[8]), .B0(n111), .B1(
        pre_scan_raddr[8]), .Y(n104) );
  AOI22XL U152 ( .A0(n114), .A1(num_raddr[8]), .B0(n113), .B1(mask_addr[8]), 
        .Y(n103) );
  AOI22XL U153 ( .A0(n55), .A1(rotate_addr[8]), .B0(n115), .B1(loc_raddr[8]), 
        .Y(n102) );
  NAND3XL U154 ( .A(n104), .B(n103), .C(n102), .Y(sram_raddr[8]) );
  AOI22XL U155 ( .A0(n52), .A1(scan_raddr[9]), .B0(n111), .B1(
        pre_scan_raddr[9]), .Y(n107) );
  AOI22XL U156 ( .A0(n114), .A1(num_raddr[9]), .B0(n113), .B1(mask_addr[9]), 
        .Y(n106) );
  AOI22XL U157 ( .A0(n55), .A1(rotate_addr[9]), .B0(n115), .B1(loc_raddr[9]), 
        .Y(n105) );
  NAND3XL U158 ( .A(n107), .B(n106), .C(n105), .Y(sram_raddr[9]) );
  AOI22XL U159 ( .A0(n52), .A1(scan_raddr[10]), .B0(n111), .B1(
        pre_scan_raddr[10]), .Y(n110) );
  AOI22XL U160 ( .A0(n114), .A1(num_raddr[10]), .B0(n113), .B1(mask_addr[10]), 
        .Y(n109) );
  AOI22XL U161 ( .A0(n55), .A1(rotate_addr[10]), .B0(n115), .B1(loc_raddr[10]), 
        .Y(n108) );
  NAND3XL U162 ( .A(n110), .B(n109), .C(n108), .Y(sram_raddr[10]) );
  AOI22XL U163 ( .A0(n52), .A1(scan_raddr[11]), .B0(n111), .B1(
        pre_scan_raddr[11]), .Y(n119) );
  AOI22XL U164 ( .A0(n114), .A1(num_raddr[11]), .B0(n113), .B1(mask_addr[11]), 
        .Y(n118) );
  AOI22XL U165 ( .A0(n55), .A1(rotate_addr[11]), .B0(n115), .B1(loc_raddr[11]), 
        .Y(n117) );
  NAND3XL U166 ( .A(n119), .B(n118), .C(n117), .Y(sram_raddr[11]) );
  FSM FSM ( .clk(clk), .srst_n(n127), .start(start), .rotate_complete(
        rotate_complete), .scan_complete(scan_complete), .demask_complete(
        demask_complete), .decode_complete(decode_complete), .loc_wrong(
        loc_wrong), .loc_complete(loc_complete), .pre_scan_complete(
        pre_scan_complete), .end_of_file(end_of_file), .num_complete(
        num_complete), .state(state), .finish(finish) );
  ROTATING ROTATING ( .clk(clk), .srst_n(srst_n), .state(state), .sram_data(
        n136), .rotate_addr(rotate_addr), .rotate_complete(rotate_complete), 
        .scan_loc_y(scan_loc_y), .scan_loc_x(scan_loc_x), .rotation_type(
        rotation_type), .loc_y(loc_y), .loc_x(rotate_loc_x), .loc_wrong(
        loc_wrong) );
  LOC_CORRECT LOC_CORRECT ( .clk(clk), .srst_n(n126), .sram_rdata(sram_rdata), 
        .state(state), .loc_x(scan_loc_x), .loc_y(scan_loc_y), .loc_raddr(
        loc_raddr), .correct_loc_x(correct_loc_x), .loc_complete(loc_complete)
         );
  SCANNING SCANNING ( .clk(clk), .srst_n(srst_n), .state(state), .sram_rdata(
        sram_rdata), .decode_complete(decode_complete), .gold_loc_y(loc_y), 
        .gold_loc_x(loc_x), .x_lower(x_lower), .y_lower(y_lower), .x_upper(
        x_upper), .y_upper(y_upper), .rotation_type(rotation_type), 
        .pre_scan_complete(pre_scan_complete), .loc_complete(loc_complete), 
        .qr_total(qr_total), .correct_loc_x(correct_loc_x), .scan_raddr(
        scan_raddr), .scan_complete(scan_complete), .loc_y(scan_loc_y), 
        .loc_x(scan_loc_x), .end_of_file(end_of_file) );
  PRE_SCANNING PRE_SCANNING ( .clk(clk), .srst_n(srst_n), .state(state), 
        .sram_rdata(sram_rdata), .pre_scan_raddr(pre_scan_raddr), 
        .pre_scan_complete(pre_scan_complete), .x_upper(x_upper), .x_lower(
        x_lower), .y_upper(y_upper), .y_lower(y_lower) );
  NUM_CALCULATE NUM_CALCULATE ( .clk(clk), .srst_n(srst_n), .state(state), 
        .sram_rdata(sram_rdata), .num_raddr(num_raddr), .num_complete(
        num_complete), .qr_total(qr_total) );
  DEMASKING DEMASKING ( .clk(clk), .srst_n(srst_n), .state(state), 
        .sram_rdata(n136), .loc_x(loc_x), .loc_y(loc_y), .rotation_type(
        rotation_type), .mask_addr(mask_addr), .code_word({code_word_151_, 
        code_word_150_, code_word_149_, code_word_148_, code_word_147_, 
        code_word_146_, code_word_145_, code_word_144_, code_word_143_, 
        code_word_142_, code_word_141_, code_word_140_, code_word_139_, 
        code_word_138_, code_word_137_, code_word_136_, code_word_135_, 
        code_word_134_, code_word_133_, code_word_132_, code_word_131_, 
        code_word_130_, code_word_129_, code_word_128_, code_word_127_, 
        code_word_126_, code_word_125_, code_word_124_, code_word_123_, 
        code_word_122_, code_word_121_, code_word_120_, code_word_119_, 
        code_word_118_, code_word_117_, code_word_116_, code_word_115_, 
        code_word_114_, code_word_113_, code_word_112_, code_word_111_, 
        code_word_110_, code_word_109_, code_word_108_, code_word_107_, 
        code_word_106_, code_word_105_, code_word_104_, code_word_103_, 
        code_word_102_, code_word_101_, code_word_100_, code_word_99_, 
        code_word_98_, code_word_97_, code_word_96_, code_word_95_, 
        code_word_94_, code_word_93_, code_word_92_, code_word_91_, 
        code_word_90_, code_word_89_, code_word_88_, code_word_87_, 
        code_word_86_, code_word_85_, code_word_84_, code_word_83_, 
        code_word_82_, code_word_81_, code_word_80_, code_word_79_, 
        code_word_78_, code_word_77_, code_word_76_, code_word_75_, 
        code_word_74_, code_word_73_, code_word_72_, code_word_71_, 
        code_word_70_, code_word_69_, code_word_68_, code_word_67_, 
        code_word_66_, code_word_65_, code_word_64_, code_word_63_, 
        code_word_62_, code_word_61_, code_word_60_, code_word_59_, 
        code_word_58_, code_word_57_, code_word_56_, code_word_55_, 
        code_word_54_, code_word_53_, code_word_52_, code_word_51_, 
        code_word_50_, code_word_49_, code_word_48_, code_word_47_, 
        code_word_46_, code_word_45_, code_word_44_, code_word_43_, 
        code_word_42_, code_word_41_, code_word_40_, code_word_39_, 
        code_word_38_, code_word_37_, code_word_36_, code_word_35_, 
        code_word_34_, code_word_33_, code_word_32_, code_word_31_, 
        code_word_30_, code_word_29_, code_word_28_, code_word_27_, 
        code_word_26_, code_word_25_, code_word_24_, code_word_23_, 
        code_word_22_, code_word_21_, code_word_20_, code_word_19_, 
        code_word_18_, code_word_17_, code_word_16_, code_word_15_, 
        code_word_14_, code_word_13_, code_word_12_, code_word_11_, 
        code_word_10_, code_word_9_, code_word_8_, code_word_7_, code_word_6_, 
        code_word_5_, code_word_4_, code_word_3_, code_word_2_, code_word_1_, 
        code_word_0_}), .demask_complete(demask_complete) );
  DECODING DECODING ( .clk(clk), .srst_n(n127), .state(state), 
        .decode_complete(decode_complete), .decode_text(decode_text), .valid(
        valid), .code_word_144_(code_word_144_), .code_word_143_(
        code_word_143_), .code_word_142_(code_word_142_), .code_word_141_(
        code_word_141_), .code_word_140_(code_word_140_), .code_word_139_(
        code_word_139_), .code_word_138_(code_word_138_), .code_word_137_(
        code_word_137_), .code_word_136_(code_word_136_), .code_word_135_(
        code_word_135_), .code_word_134_(code_word_134_), .code_word_133_(
        code_word_133_), .code_word_132_(code_word_132_), .code_word_131_(
        code_word_131_), .code_word_130_(code_word_130_), .code_word_129_(
        code_word_129_), .code_word_128_(code_word_128_), .code_word_127_(
        code_word_127_), .code_word_126_(code_word_126_), .code_word_125_(
        code_word_125_), .code_word_124_(code_word_124_), .code_word_123_(
        code_word_123_), .code_word_122_(code_word_122_), .code_word_121_(
        code_word_121_), .code_word_120_(code_word_120_), .code_word_119_(
        code_word_119_), .code_word_118_(code_word_118_), .code_word_117_(
        code_word_117_), .code_word_116_(code_word_116_), .code_word_115_(
        code_word_115_), .code_word_114_(code_word_114_), .code_word_113_(
        code_word_113_), .code_word_112_(code_word_112_), .code_word_111_(
        code_word_111_), .code_word_110_(code_word_110_), .code_word_109_(
        code_word_109_), .code_word_108_(code_word_108_), .code_word_107_(
        code_word_107_), .code_word_106_(code_word_106_), .code_word_105_(
        code_word_105_), .code_word_104_(code_word_104_), .code_word_103_(
        code_word_103_), .code_word_102_(code_word_102_), .code_word_101_(
        code_word_101_), .code_word_100_(code_word_100_), .code_word_99_(
        code_word_99_), .code_word_98_(code_word_98_), .code_word_97_(
        code_word_97_), .code_word_96_(code_word_96_), .code_word_95_(
        code_word_95_), .code_word_94_(code_word_94_), .code_word_93_(
        code_word_93_), .code_word_92_(code_word_92_), .code_word_91_(
        code_word_91_), .code_word_90_(code_word_90_), .code_word_89_(
        code_word_89_), .code_word_88_(code_word_88_), .code_word_87_(
        code_word_87_), .code_word_86_(code_word_86_), .code_word_85_(
        code_word_85_), .code_word_84_(code_word_84_), .code_word_83_(
        code_word_83_), .code_word_82_(code_word_82_), .code_word_81_(
        code_word_81_), .code_word_80_(code_word_80_), .code_word_79_(
        code_word_79_), .code_word_78_(code_word_78_), .code_word_77_(
        code_word_77_), .code_word_76_(code_word_76_), .code_word_75_(
        code_word_75_), .code_word_74_(code_word_74_), .code_word_73_(
        code_word_73_), .code_word_72_(code_word_72_), .code_word_71_(
        code_word_71_), .code_word_70_(code_word_70_), .code_word_69_(
        code_word_69_), .code_word_68_(code_word_68_), .code_word_67_(
        code_word_67_), .code_word_66_(code_word_66_), .code_word_65_(
        code_word_65_), .code_word_64_(code_word_64_), .code_word_63_(
        code_word_63_), .code_word_62_(code_word_62_), .code_word_61_(
        code_word_61_), .code_word_60_(code_word_60_), .code_word_59_(
        code_word_59_), .code_word_58_(code_word_58_), .code_word_57_(
        code_word_57_), .code_word_56_(code_word_56_), .code_word_55_(
        code_word_55_), .code_word_54_(code_word_54_), .code_word_53_(
        code_word_53_), .code_word_52_(code_word_52_), .code_word_51_(
        code_word_51_), .code_word_50_(code_word_50_), .code_word_49_(
        code_word_49_), .code_word_48_(code_word_48_), .code_word_47_(
        code_word_47_), .code_word_46_(code_word_46_), .code_word_45_(
        code_word_45_), .code_word_44_(code_word_44_), .code_word_43_(
        code_word_43_), .code_word_42_(code_word_42_), .code_word_41_(
        code_word_41_), .code_word_40_(code_word_40_), .code_word_39_(
        code_word_39_), .code_word_38_(code_word_38_), .code_word_37_(
        code_word_37_), .code_word_36_(code_word_36_), .code_word_35_(
        code_word_35_), .code_word_34_(code_word_34_), .code_word_33_(
        code_word_33_), .code_word_32_(code_word_32_), .code_word_31_(
        code_word_31_), .code_word_30_(code_word_30_), .code_word_29_(
        code_word_29_), .code_word_28_(code_word_28_), .code_word_27_(
        code_word_27_), .code_word_26_(code_word_26_), .code_word_25_(
        code_word_25_), .code_word_24_(code_word_24_), .code_word_23_(
        code_word_23_), .code_word_22_(code_word_22_), .code_word_21_(
        code_word_21_), .code_word_20_(code_word_20_), .code_word_19_(
        code_word_19_), .code_word_18_(code_word_18_), .code_word_17_(
        code_word_17_), .code_word_16_(code_word_16_), .code_word_15_(
        code_word_15_), .code_word_14_(code_word_14_), .code_word_13_(
        code_word_13_), .code_word_12_(code_word_12_), .code_word_11_(
        code_word_11_), .code_word_10_(code_word_10_), .code_word_9_(
        code_word_9_), .code_word_8_(code_word_8_), .code_word_7_(code_word_7_), .code_word_6_(code_word_6_), .code_word_5_(code_word_5_), .code_word_4_(
        code_word_4_), .code_word_3_(code_word_3_), .code_word_2_(code_word_2_), .code_word_1_(code_word_1_), .code_word_0_(code_word_0_) );
  SNPS_CLOCK_GATE_HIGH_qrcode_decoder_mydesign_0 clk_gate_loc_x_reg ( .CLK(clk), .EN(n135), .ENCLK(n134) );
  NOR4X1 U75 ( .A(state[0]), .B(state[2]), .C(state[3]), .D(n75), .Y(n114) );
  NOR4X1 U76 ( .A(state[2]), .B(state[1]), .C(state[3]), .D(n74), .Y(n111) );
  NOR4BX1 U78 ( .AN(state[2]), .B(state[0]), .C(state[3]), .D(n75), .Y(n113)
         );
  INVXL U114 ( .A(state[1]), .Y(n75) );
  BUFX3 U115 ( .A(srst_n), .Y(n127) );
  CLKBUFX2 U117 ( .A(n58), .Y(n53) );
  NOR3X1 U118 ( .A(state[3]), .B(state[1]), .C(n54), .Y(n58) );
  BUFX2 U167 ( .A(sram_rdata), .Y(n136) );
endmodule

