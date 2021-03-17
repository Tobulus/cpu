module system(input wire I_clk, 
    input wire I_reset,
    input wire UART_rx_in_data, 
    output wire UART_rx_ready,
    output wire UART_tx_out_data);

wire ram_enable, bootrom_enable, mem_exec, mem_write;
wire UART_tx_ready, UART_rx_data_ready, UART_tx_exec;
wire[15:0] ram_data_in, bootrom_out, ram_data_out, mem_addr, mem_data_in, mem_data_out;
wire[7:0] UART_rx_out_data, UART_tx_in_data;
reg[7:0] rx_data;
wire[1:0] mem_size;
reg mem_ready = 1, mem_data_ready = 0, rx_data_ready, booting = 1;
reg[1:0] state = 0;

core core(.I_clk(I_clk),
    .I_reset(I_reset),
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
begin: uart_observe
    if (UART_rx_data_ready) begin
        rx_data_ready <= 1;
        rx_data <= UART_rx_out_data;
    end
end

always @(posedge I_clk) 
begin: system
    if (I_reset == 1) begin
        booting <= 1;
    end
    else begin
        if (state == 0) begin
            mem_data_ready <= 0;

            if (mem_ready == 1 && mem_exec == 1) begin
                mem_ready <= 0;
                // UART data
                if (mem_addr == 16'h400) begin
                    if (mem_write == 1) begin
                        UART_tx_exec <= 1;
                        UART_tx_in_data <= mem_data_out[7:0];
                    end
                    else begin
                        mem_data_in[15:8] <= 0;
                        mem_data_in[7:0] <= rx_data;
                        state <= 1;
                    end
                end
                // UART rx data ready status
                else if (mem_addr == 16'h401) begin
                    mem_data_in[15:1] <= 0;
                    mem_data_in[0] <= rx_data_ready;
                    state <= 1;
                    rx_data_ready <= 0;
                end
                // UART tx ready status
                else if (mem_addr == 16'h402) begin
                    mem_data_in[15:1] <= 0;
                    mem_data_in[0] <= UART_tx_ready;
                    state <= 1;
                end
                // RAM or bootrom
                else begin
                    // we are leaving the bootloader -> unmap it from memory
                    if (booting == 1 && mem_write == 0 && mem_addr >= 16'h64) begin
                        booting <= 0;
                    end

                    if (booting == 1 && mem_write == 0 && mem_addr < 16'h64) begin
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
            if (booting == 1 && mem_write == 0) begin
                bootrom_enable <= 0;
            end
            else begin
                ram_enable <= 0;
            end
        end
        else if (state == 3) begin
            if (booting == 1 && mem_write == 0) begin
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
