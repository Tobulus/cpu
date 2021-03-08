module uart_tx
#(parameter CLKS_PER_BIT = 120)
(input I_clk,
    input I_reset,
    input I_data,
    input I_exec,
    output O_ready,
output O_data);

reg O_data;
reg[7:0] I_data, buffer, clk_count;
reg[3:0] state;

always @(posedge I_clk)
begin: uart_tx
    if (I_reset == 1)
    begin
        clk_count <= 0;
        state <= 0;
        O_ready <= 1;
        O_data <= 1;
    end
    else
    begin
        // Idle
        if (state == 0) begin
            O_ready <= 1;
            O_data <= 1;
            if (I_exec == 1) begin
                buffer <= I_data;
                state <= 1;
                clk_count <= 0;
            end
        end
        // Start-Bit
        else if (state == 1) begin
            clk_count <= clk_count + 1;
            O_ready <= 0;
            O_data <= 0;
            if (clk_count >= CLKS_PER_BIT) begin
                state <= 2;
                clk_count <= 0;
            end
        end
        // Transfer
        else if (state <= 9) begin
            O_data <= buffer[state-2];
            clk_count <= clk_count + 1;
            if (clk_count >= CLKS_PER_BIT) begin
                state <= state + 1;
                clk_count <= 0;
            end
        end
        // Stop-Bit
        else begin
            O_ready <= 0;
            O_data <= 1;
            clk_count <= clk_count + 1;
            if (clk_count >= CLKS_PER_BIT) begin
                state <= 0;
                clk_count <= 0;
            end
        end
    end
end

endmodule