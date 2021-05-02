`include "mmap.vh"

module system(input wire I_clk, 
    input wire I_reset,
    input wire UART_rx_in_data, 
    output wire UART_rx_ready,
    output wire UART_tx_out_data);

wire ram_enable, bootrom_enable, mem_exec, mem_write;
wire UART_tx_ready, UART_rx_data_ready, UART_tx_exec, irq_ack;
wire[15:0] ram_data_in, bootrom_out, ram_data_out, mem_addr, mem_data_in, mem_data_out;
wire[7:0] UART_rx_out_data, UART_tx_in_data;
reg[7:0] rx_data;
wire[1:0] mem_size;
reg mem_ready = 1, mem_data_ready = 0, rx_data_ready, irq_enabled = 0;
reg[1:0] state = 0;

core core(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_irq_active(irq_enabled),
    .O_irq_ack(irq_ack),
    .MEM_ready(mem_ready),
    .MEM_exec(mem_exec),
    .MEM_write(mem_write),
    .MEM_size(mem_size),
    .MEM_addr(mem_addr),
    .MEM_data_in(mem_data_in),
    .MEM_data_out(mem_data_out),
    .MEM_data_ready(mem_data_ready));

ram ram(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_size(mem_size),       
    .I_enable(ram_enable),
    .I_write(mem_write),
    .I_addr(mem_addr),
    .I_data_in(ram_data_in),
    .O_data_out(ram_data_out));

bootrom bootrom(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_enable(bootrom_enable),
    .I_addr(mem_addr[7:0]),
    .O_data_out(bootrom_out));

uart_rx uart_rx(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_data_bit(UART_rx_in_data),
    .O_ready(UART_rx_ready),
    .O_data_ready(UART_rx_data_ready),
    .O_data(UART_rx_out_data));

uart_tx uart_tx(.I_clk(I_clk), 
    .I_reset(I_reset),
    .I_data(UART_tx_in_data),
    .I_exec(UART_tx_exec), 
    .O_ready(UART_tx_ready), 
    .O_data(UART_tx_out_data));

always@(posedge I_clk)
begin: device_observer
    // ordering of the signals defines the irq prio
    if (UART_rx_data_ready) begin
        rx_data_ready <= 1;
        rx_data <= UART_rx_out_data;
        irq_enabled <= 1;
    end

    if (irq_ack == 1) begin
        if (rx_data_ready == 1) begin
            irq_enabled <= 0;
            mem_data_in[15:8] <= 0;
            mem_data_in[7:0] <= 1; // irq-id
            rx_data_ready <= 0;
        end
    end
end

always @(posedge I_clk) 
begin: system
    if (I_reset == 1) begin
        mem_ready <= 1; 
        mem_data_ready <= 0;
        state <= 0;
    end
    else begin
        if (state == 0) begin
            mem_data_ready <= 0;

            if (mem_ready == 1 && mem_exec == 1) begin
                mem_ready <= 0;
                // UART1 data r/w
                if (mem_addr == UART_1_RW) begin
                    if (mem_write == 1) begin
                        UART_tx_exec <= 1;
                        UART_tx_in_data <= mem_data_out[7:0];
                    end
                    else begin
                        mem_data_in[15:8] <= 0;
                        mem_data_in[7:0] <= rx_data;
                        state <= 1;
                        irq_enabled <= 0;
                    end
                end
                // UART1 rx data ready status
                else if (mem_addr == UART_1_RX_DATA_READY) begin
                    mem_data_in[15:1] <= 0;
                    mem_data_in[0] <= rx_data_ready;
                    state <= 1;
                    rx_data_ready <= 0;
                end
                // UART1 tx ready status
                else if (mem_addr == UART_1_TX_READY) begin
                    mem_data_in[15:1] <= 0;
                    mem_data_in[0] <= UART_tx_ready;
                    state <= 1;
                end
                // RAM or bootrom
                else begin
                    if (mem_write == 0 && mem_addr < APP) begin
                        bootrom_enable <= 1;
                    end
                    else begin
                        if (mem_write == 1) begin
                            ram_data_in <= mem_data_out;
                        end    
                        ram_enable <= 1;
                    end
                    state <= 2;
                end
            end
        end
        else if (state == 2) begin
            state <= 3;
            if (mem_write == 0 && mem_addr < APP) begin
                bootrom_enable <= 0;
            end
            else begin
                ram_enable <= 0;
            end
        end
        else if (state == 3) begin
            if (mem_write == 0 && mem_addr < APP) begin
                mem_data_in <= bootrom_out;
                bootrom_enable <= 0; // TODO already disabled in 2?
            end
            else begin
                if (mem_write == 0) begin
                    mem_data_in <= ram_data_out;
                end
                ram_enable <= 0; // TODO already disabled in 2?
            end
            mem_ready <= 1;
            mem_data_ready <= 1;
            state <= 0;
        end
        else if (state == 1 && mem_ready == 0) begin
            mem_ready <= 1;
            mem_data_ready <= 1;
            ram_enable <= 0;
            UART_tx_exec <= 0;
            state <= 0;
        end
    end
end

endmodule;
