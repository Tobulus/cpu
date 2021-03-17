`include "../alu/ops.vh"

module ctrl_unit(input wire I_clk, 
    input wire I_reset,
    /* verilator lint_off UNUSED */
    input reg[15:0] I_instruction,
    input wire I_mem_ready,
    input wire I_data_ready,
    output reg[5:0] O_state,
    output reg O_execute);

reg mem_wait = 0;
reg[3:0] instr;

always @(posedge I_clk)
begin: CTRL_UNIT
    if (I_reset == 1) 
    begin
        mem_wait <= 0;
        O_state <= 1;
    end
    else if (O_state == 6'b000001)
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
                instr <= I_instruction[15:12];
                mem_wait <= 0;
                O_state <= 6'b000010;
            end
        end
    end
    else if (O_state == 6'b000010)
    begin
        // decode
        O_state <= 6'b000100;
    end
    else if (O_state == 6'b000100)
    begin
        // register read
        O_state <= 6'b001000;
    end
    else if (O_state == 6'b001000)
    begin
        // execute
        if (instr == WRITE || instr == READ)
        begin
            if (I_mem_ready == 1 && mem_wait == 0)
            begin
                O_execute <= 1;
                mem_wait <= 1;
            end
            O_state <= 6'b010000; 
        end
        else 
        begin
            O_state <= 6'b100000;
        end
    end
    else if (O_state == 6'b010000)
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
            if ((instr == WRITE && I_mem_ready == 1) || (instr == READ && I_data_ready == 1))
            begin
                mem_wait <= 0;
                O_state <= 6'b100000;
            end
        end
    end
    else if (O_state == 6'b100000)
    begin
        // register write
        O_state <= 6'b000001;
    end
end

endmodule
