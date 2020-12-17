`ifndef opcodes_vh
`define opcodes_vh
    localparam ADD    = 4'b0000;
    localparam SUB    = 4'b0001;
    localparam OR     = 4'b0010;
    localparam AND    = 4'b0011;
    localparam XOR    = 4'b0100;
    localparam NOT    = 4'b0101;
    localparam READ   = 4'b0110;
    localparam WRITE  = 4'b0111;
    localparam LOAD   = 4'b1000;
    localparam CMP    = 4'b1001;
    localparam SHIFTL = 4'b1010;
    localparam SHIFTR = 4'b1011;
    localparam JMP    = 4'b1100;
    localparam JMPC   = 4'b1101;
    localparam SPC    = 4'b1110;
`endif
