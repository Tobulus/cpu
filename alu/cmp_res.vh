`ifndef cmp_res_vh
`define cmp_res_vh
    localparam CMP_EQ_BIT       = 0;
    localparam CMP_RA_GT_RB_BIT = 1;
    localparam CMP_RB_GT_RA_BIT = 2;
    localparam CMP_RA_ZERO_BIT  = 3;
    localparam CMP_RB_ZERO_BIT  = 4;

    localparam CMP_CODE_EQ       = 3'b000;
    localparam CMP_CODE_RA_GT_RB = 3'b001;
    localparam CMP_CODE_RB_GT_RA = 3'b010;
    localparam CMP_CODE_RA_ZERO  = 3'b011;
    localparam CMP_CODE_RB_ZERO  = 3'b100;
`endif
