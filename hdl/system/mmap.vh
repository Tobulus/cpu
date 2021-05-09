`ifndef mmap_vh
`define mmap_vh
    // 32kB RAM
    localparam RAM_SIZE  = 16'h8000;

    // Application
    localparam APP       = 16'h0064;
    
    // Timer
    localparam TIMER1_COUNT         = RAM_SIZE - 10;
    localparam TIMER_ENABLE         = RAM_SIZE - 9;

    // UART1
    localparam UART_1_RW            = RAM_SIZE - 2;
    localparam UART_1_RX_DATA_READY = RAM_SIZE - 1;
    localparam UART_1_TX_READY      = RAM_SIZE;
`endif
