`include "../alu/ops.vh"

module ctrl_unit(clk, 
    reset,
    I_instruction,
    I_mem_ready,
    I_data_ready,
    state,
O_execute);

/* verilator lint_off UNUSED */
input clk, I_instruction, I_mem_ready, I_data_ready, reset;
output state, O_execute;

reg[15:0] I_instruction;
reg[5:0] state;
reg O_execute;

reg mem_wait = 0;

always @(posedge clk)
begin: CTRL_UNIT
    if (reset == 1) 
    begin
        state <= 1;
    end
    else if (state == 6'b000001)
    begin
        // fetch
        if (I_mem_ready == 1 && mem_wait == 0)
        begin
            O_execute <= 1;
            mem_wait <= 1;
        end
        else if (mem_wait == 1)
        begin
            O_execute <= 0;
            if (I_data_ready == 1)
            begin
                mem_wait <= 0;
                state <= 6'b000010;
            end
        end
    end
    else if (state == 6'b000010)
    begin
        // decode
        state <= 6'b000100;
    end
    else if (state == 6'b000100)
    begin
        // register read
        state <= 6'b001000;
    end
    else if (state == 6'b001000)
    begin
        // execute
        if (I_instruction[15:12] == WRITE || I_instruction[15:12] == READ)
        begin
            if (I_mem_ready == 1 && mem_wait == 0)
            begin
                O_execute <= 1;
                mem_wait <= 1;
            end
            state <= 6'b010000; 
        end
        else 
        begin
            state <= 6'b100000;
        end
    end
    else if (state == 6'b010000)
    begin
        // store
        if (I_mem_ready == 1 && mem_wait == 0)
        begin
            O_execute <= 1;
            mem_wait <= 1;
        end
        else if (mem_wait == 1)
        begin
            O_execute <= 0;
            if (I_instruction[15:12] == WRITE || I_data_ready == 1)
            begin
                mem_wait <= 0;
                state <= 6'b100000;
            end
        end
    end
    else if (state == 6'b100000)
    begin
        // register write
        state <= 6'b000001;
    end
end

endmodule
