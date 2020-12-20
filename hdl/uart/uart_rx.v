module uart_rx
#(parameter CLKS_PER_BIT = 120)
(input I_clk, 
    input I_reset,
    input I_data_bit,
    output O_data_ready,
output O_data);

reg O_data_ready;
reg[7:0] O_data, buffer, clk_count;
reg[3:0] state;

always @(posedge I_clk)
begin: uart_rx
    if (I_reset == 1) begin
        clk_count <= 0;
        state <= 0;
        O_data_ready <= 0;
    end
    else begin
        //Idle
        if (state == 0) begin
            if (I_data_bit == 0) begin
                state <= 1;
            end
            else begin
                O_data_ready <= 0;
            end
        end
        // Start-Bit
        else if (state == 1) begin
            // check that we are still low. Also shifts
            // the whole receiver by half phase
            if (clk_count == (CLKS_PER_BIT/2)) begin
                clk_count <= 0;
                if (I_data_bit == 0) begin
                    state <= 2;
                end
                else begin
                    state <= 0;
                end
            end
            else begin
                clk_count <= clk_count + 1;
            end
        end
        // Transfer
        else if(state <= 8) begin
            if (clk_count >= CLKS_PER_BIT) begin
                buffer[state] <= I_data_bit;
                state <= state + 1;
                clk_count <= 0;
            end
            else begin
                clk_count <= clk_count + 1;
            end
        end
        // Stop-Bit
        else begin
            if (clk_count >= CLKS_PER_BIT) begin
                if (I_data_bit == 1) begin
                    O_data <= buffer;
                    O_data_ready <= 1;
                end
                clk_count <= 0;
                state <= 0;
            end
            else begin
                clk_count <= clk_count + 1;
            end
        end
    end
end

endmodule
