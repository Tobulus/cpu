`include "../alu/ops.vh"
`include "ctrl_states.vh"

module ctrl_unit(input wire I_clk, 
    input wire I_reset,
    /* verilator lint_off UNUSED */
    input wire[15:0] I_instruction,
    input wire I_mem_ready,
    input wire I_data_ready,
    input wire I_irq_enabled,
    input wire I_irq_active,
    output reg O_irq_ack,
    output reg[9:0] O_state,
    output reg O_execute,
    output reg O_push_pc);

reg mem_wait = 0, wait_irq_number = 0, irq_save_pc = 0;
reg[15:0] instr;

always @(posedge I_clk)
begin: CTRL_UNIT
    if (I_reset == 1) 
    begin
        mem_wait <= 0;
        O_state <= 1;
    end
    else if (O_state == FETCH)
    begin
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
                O_state <= DECODE;
            end
        end
    end
    else if (O_state == DECODE)
    begin
        O_state <= REG_READ;
        instr <= I_instruction;
    end
    else if (O_state == REG_READ)
    begin
        O_state <= EXEC;
    end
    else if (O_state == EXEC)
    begin
        if (instr[15:12] == WRITE || instr[15:12] == READ || (instr[15:12] == SPECIAL && instr[2:0] == 3'b100) || instr[15:12] == STACK)
        begin
            if (I_mem_ready == 1 && mem_wait == 0)
            begin
                O_execute <= 1;
                mem_wait <= 1;
            end
            O_state <= STORE; 
        end
        else 
        begin
            O_state <= REG_WRITE;
        end
    end
    else if (O_state == STORE)
    begin
        if (I_mem_ready == 1 && mem_wait == 0)
        begin
            O_execute <= 1;
            mem_wait <= 1;
        end
        else if (mem_wait == 1)
        begin
            O_execute <= 0;
            if (((instr[15:12] == WRITE || (instr[15:12] == STACK && instr[8] == 0)) && I_mem_ready == 1) 
                || ((instr[15:12] == READ || (instr[15:12] == SPECIAL && instr[2:0] == 3'b100) || (instr[15:12] == STACK && instr[8])) && I_data_ready == 1))
            begin
                mem_wait <= 0;
                O_state <= REG_WRITE;
            end
        end
    end
    else if (O_state == REG_WRITE)
    begin
        // register write state
        if (instr[15:12] == STACK && instr[8]) begin
            // POP instruction does two reg-writes: the value which was popped
            // from stack and the decrement of the SP
            O_state <= DECREMENT_SP;
        end
        else begin
            if (I_irq_enabled && I_irq_active && irq_save_pc == 0) begin
                // irq requested -> fetch irq number and save pc
                O_irq_ack <= 1;
                O_state <= FETCH_IRQ_NUM;
            end
            else if (irq_save_pc == 1) begin
                // pc has been saved, now enter ISR
                irq_save_pc <= 0;
                O_push_pc <= 0;
                O_state <= ENTER_ISR;
            end
            else begin
                O_state <= FETCH;
            end
        end
    end
    else if (O_state == FETCH_IRQ_NUM) begin
        O_irq_ack <= 0;
        if (wait_irq_number == 1) begin
            O_state <= SAVE_PC;
            wait_irq_number <= 0;
        end
        else begin
            wait_irq_number <= 1;
        end
    end
    else if (O_state == SAVE_PC) begin
        irq_save_pc <= 1;
        O_push_pc <= 1;
        O_irq_ack <= 0;
        O_state <= DECODE;
    end
    else if (O_state == ENTER_ISR) begin
        O_state <= FETCH;
    end
    else if (O_state == DECREMENT_SP) begin
        if (I_irq_enabled && I_irq_active && irq_save_pc == 0) begin
            // irq requested -> fetch irq number and save pc
            O_irq_ack <= 1;
            O_state <= FETCH_IRQ_NUM;
        end
        else if (irq_save_pc == 1) begin
            // pc has been saved, now enter ISR
            irq_save_pc <= 0;
            O_push_pc <= 0;
            O_state <= ENTER_ISR;
        end
        else begin
            O_state <= FETCH;
        end
    end
end

endmodule
