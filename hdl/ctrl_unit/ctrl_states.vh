`ifndef ctrl_states_vh
`define ctrl_states_vh
    localparam FETCH         = 10'b0000000001;
    localparam DECODE        = 10'b0000000010;
    localparam REG_READ      = 10'b0000000100;
    localparam EXEC          = 10'b0000001000;
    localparam STORE         = 10'b0000010000;
    localparam REG_WRITE     = 10'b0000100000;
    localparam FETCH_IRQ_NUM = 10'b0001000000;
    localparam SAVE_PC       = 10'b0010000000;
    localparam ENTER_ISR     = 10'b0100000000;
    localparam DECREMENT_SP  = 10'b1000000000;
`endif
