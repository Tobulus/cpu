`include "../alu/ops.vh"

module ctrl_unit(input wire I_clk, 
    input wire I_reset,
    /* verilator lint_off UNUSED */
    input wire[15:0] I_instruction,
    input wire I_mem_ready,
    input wire I_data_ready,
    input wire I_irq_enabled,
    input wire I_irq_active,
    output reg O_irq_ack,
    output reg[8:0] O_state,
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
    else if (O_state == 9'b000000001)
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
                O_state <= 9'b000000010;
            end
        end
    end
    else if (O_state == 9'b000000010)
    begin
        // decode
        O_state <= 9'b000000100;
        instr <= I_instruction;
    end
    else if (O_state == 9'b000000100)
    begin
        // register read
        O_state <= 9'b000001000;
    end
    else if (O_state == 9'b000001000)
    begin
        // execute
        if (instr[15:12] == WRITE || instr[15:12] == READ || (instr[15:12] == SPECIAL && instr[2:0] == 3'b100) || instr[15:12] == STACK)
        begin
            if (I_mem_ready == 1 && mem_wait == 0)
            begin
                O_execute <= 1;
                mem_wait <= 1;
            end
            O_state <= 9'b000010000; 
        end
        else 
        begin
            O_state <= 9'b000100000;
        end
    end
    else if (O_state == 9'b000010000)
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
            if (((instr[15:12] == WRITE || (instr[15:12] == STACK && instr[8] == 0)) && I_mem_ready == 1) 
                || ((instr[15:12] == READ || (instr[15:12] == SPECIAL && instr[2:0] == 3'b100) || (instr[15:12] == STACK && instr[8])) && I_data_ready == 1))
            begin
                mem_wait <= 0;
                O_state <= 9'b000100000;
            end
        end
    end
    else if (O_state == 9'b000100000)
    begin
        // register write state
        if (I_irq_enabled && I_irq_active && irq_save_pc == 0) begin
            // irq requested -> fetch irq number and save pc
            O_irq_ack <= 1;
            O_state <= 9'b001000000;
        end
        else if (irq_save_pc == 1) begin
            // pc has been saved, now enter ISR
            irq_save_pc <= 0;
            O_push_pc <= 0;
            O_state <= 9'b100000000;
        end
        else begin
            O_state <= 9'b000000001;
        end
    end
    else if (O_state == 9'b001000000) begin
        // fetch irq number
        O_irq_ack <= 0;
        if (wait_irq_number == 1) begin
            O_state <= 9'b010000000;
            wait_irq_number <= 0;
        end
        else begin
            wait_irq_number <= 1;
        end
    end
    else if (O_state == 9'b010000000) begin
        // save pc to stack
        irq_save_pc <= 1;
        O_push_pc <= 1;
        O_irq_ack <= 0;
        O_state <= 9'b000000010;
    end
    else if (O_state == 9'b100000000) begin
        // enter ISR
        O_state <= 9'b000000001;
    end
end

endmodule
