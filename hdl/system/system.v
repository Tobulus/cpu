module system(input I_clk, input I_reset, input UART_rx_in_data, output UART_tx_out_data);

wire ram_enable, mem_exec, mem_write, UART_tx_ready, UART_rx_data_ready, UART_tx_exec;
wire[15:0] ram_data_in, ram_data_out, mem_addr, mem_data_in, mem_data_out;

wire[7:0] UART_rx_out_data, UART_tx_in_data;

reg mem_ready = 1, mem_data_ready = 0;

core core(.I_clk(I_clk),
    .I_reset(I_reset),
    .MEM_ready(mem_ready),
    .MEM_exec(mem_exec),
    .MEM_write(mem_write),
    .MEM_addr(mem_addr),
    .MEM_data_in(mem_data_in),
    .MEM_data_out(mem_data_out),
.MEM_data_ready(mem_data_ready));

ram ram(.I_clk(I_clk), 
    .I_enable(ram_enable),
    .I_write(mem_write),
    .I_addr(mem_addr),
    .I_data_in(ram_data_in),
.O_data_out(ram_data_out));

uart_rx uart_rx(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_data_bit(UART_rx_in_data),
    .O_data_ready(UART_rx_data_ready),
.O_data(UART_rx_out_data));

uart_tx uart_tx(.I_clk(I_clk), 
    .I_reset(I_reset),
    .I_data(UART_tx_in_data),
    .I_exec(UART_tx_exec), 
    .O_ready(UART_tx_ready), 
.O_data(UART_tx_out_data));

always @(posedge I_clk) 
begin: system
    if (mem_ready && mem_exec == 1) begin
        // UART data
        if (mem_addr == 16'h400) begin
            if (mem_write == 1) begin
                UART_tx_exec <= 1;
                UART_tx_in_data <= mem_data_out;
            end
            else begin
                mem_data_in <= UART_rx_out_data;
            end
        end
        // UART rx data ready status
        else if (mem_addr == 16'h401) begin
            mem_data_in <= UART_rx_data_ready;
        end
        // UART tx ready status
        else if (mem_addr == 16'h402) begin
            mem_data_in <= UART_tx_ready;
        end
        // RAM
        else begin
            ram_enable <= 1;
            if (mem_write == 1) begin
                ram_data_in <= mem_data_out;
            end    
            else begin
                mem_data_in <= ram_data_out;
            end

            mem_ready <= 0;
        end
    end
    else if (mem_ready == 0) begin
        mem_ready <= 1;
        mem_data_ready <= 1;
        ram_enable <= 0;
        UART_tx_exec <= 0;
    end
end

endmodule;
