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
reg[7:0] rx_data, timer_enable = 0, irq_num = 0;
wire[1:0] mem_size;
reg mem_ready = 1, mem_data_ready = 0, rx_data_ready, buff_rx_data_ready, irq_enabled = 0;
reg[1:0] state = 0;
reg[15:0] timer1_count = 1, timer1_config = 0;

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
begin: irq_observer
    //TODO: data race condition on irq_num
    // ordering of the signals defines the irq prio
    if (UART_rx_data_ready) begin
        irq_enabled <= 1;
        irq_num <= 1;
        buff_rx_data_ready <= 1;
        rx_data <= UART_rx_out_data;
    end
    else if (timer1_count == 0) begin
        irq_enabled <= 1;
        irq_num <= 2;
    end

    if (irq_ack == 1) begin
        irq_enabled <= 0;
        mem_data_in[15:8] <= 0;
        mem_data_in[7:0] <= irq_num;
        if (irq_num == 1) begin
            rx_data_ready <= 0;
        end 
        else if (irq_num == 2) begin
            timer1_count <= timer1_config;
        end
    end
end

always @(posedge I_clk)
begin: timer
    if ((timer_enable & 1) == 1 && timer1_count > 0) begin
        timer1_count <= timer1_count - 1;
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

            if (mem_exec == 0 && !UART_rx_data_ready && buff_rx_data_ready) begin
                rx_data_ready <= buff_rx_data_ready;
                buff_rx_data_ready <= 0;
            end
            else if (mem_ready == 1 && mem_exec == 1) begin
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
                // TIMER enable
                else if (mem_addr == TIMER_ENABLE) begin
                    if (mem_write == 1) begin
                        timer_enable <= mem_data_out[7:0];
                    end
                    state <= 1;
                end
                // TIMER1 count
                else if (mem_addr == TIMER1_COUNT) begin
                    if (mem_write == 1) begin
                        timer1_config <= mem_data_out;
                        timer1_count <= mem_data_out;
                    end 
                    else begin
                        mem_data_in <= timer1_count;
                    end
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
            end
            else begin
                if (mem_write == 0) begin
                    mem_data_in <= ram_data_out;
                end
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
