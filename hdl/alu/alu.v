`include "ops.vh"
`include "mem_acc.vh"
`include "cmp_res.vh"

module alu(input wire I_clk,
    input wire I_reset,
    input wire I_enable,
    input wire[3:0] I_opcode,
    input wire I_opcode_mode,
    input wire[7:0] I_immediate,
    input wire[15:0] I_pc,
    input wire[15:0] I_rA,
    input wire[15:0] I_rB,
    input wire[2:0] I_compare_code,
    input wire I_irq_active,
    output reg[15:0] O_out,
    output reg O_write_rD,
    output reg O_write_pc,
    output reg O_irq_enable,
    output reg[1:0] O_memory_size,
    output reg[1:0] O_memory_mode);

localparam OPCODE_MODE_SIGNED = 1'b0;
localparam OPCODE_MODE_UNSIGNED = 1'b1;

localparam OPCODE_MODE_HI = 1'b1;
localparam OPCODE_MODE_LO = 1'b0;

localparam OPCODE_MODE_IMMEDIATE = 1'b1;

reg irq_recover = 0;

always @(posedge I_clk)
begin: IRQ_ACTIVE
    // ctrl-unit entered an interrupt
    // -> disable interrupts
    if (I_irq_active) begin
        O_irq_enable <= 0;
    end
end

always @(posedge I_clk)
begin: ALU
    if (I_reset) begin
        O_irq_enable <= 0;
    end
    else if (I_enable == 1) begin
        if (I_opcode == ADD)
        begin
            if (I_opcode_mode == OPCODE_MODE_SIGNED)
            begin
                if (I_immediate[0] == 1) begin
                    O_out <= $signed(I_rA) + $signed({{12{I_immediate[4]}}, I_immediate[4:1]});
                end
                else begin
                    O_out <= $signed(I_rA) + $signed(I_rB);
                end
            end
            else begin
                if (I_immediate[0] == 1) begin
                    O_out <= $unsigned(I_rA) + $unsigned({12'b0, I_immediate[4:1]});
                end
                else begin
                    O_out <= $unsigned(I_rA) + $unsigned(I_rB);
                end
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == SUB)
        begin
            if (I_opcode_mode == OPCODE_MODE_SIGNED)
            begin
                if (I_immediate[0] == 1) begin
                    O_out <= $signed(I_rA) - $signed({{12{I_immediate[4]}}, I_immediate[4:1]});
                end
                else begin
                    O_out <= $signed(I_rA) - $signed(I_rB);
                end
            end
            else begin
                if (I_immediate[0] == 1) begin
                    O_out <= $unsigned(I_rA) - $signed({12'b0, I_immediate[4:1]});
                end
                else begin
                    O_out <= $unsigned(I_rA) - $unsigned(I_rB);
                end
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == OR)
        begin
            if (I_opcode_mode == OPCODE_MODE_IMMEDIATE) begin
                O_out <= I_rA | {11'b0, I_immediate[4:0]};
            end 
            else begin 
                O_out <= I_rA | I_rB;
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == AND)
        begin
            if (I_opcode_mode == OPCODE_MODE_IMMEDIATE) begin
                O_out <= I_rA & {11'b0, I_immediate[4:0]};
            end 
            else begin 
                O_out <= I_rA & I_rB;
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == XOR)
        begin
            if (I_opcode_mode == OPCODE_MODE_IMMEDIATE) begin
                O_out <= I_rA ^ {11'b0, I_immediate[4:0]};
            end 
            else begin 
                O_out <= I_rA ^ I_rB;
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == NOT)
        begin
            O_out <= ~I_rA;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == READ)
        begin
            O_out <= $signed(I_rA) + $signed({{11{I_immediate[4]}}, I_immediate[4:0]});
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_READ;
            O_memory_size <= I_opcode_mode == 1 ? 2 : 1;
        end
        else if (I_opcode == WRITE)
        begin
            O_out <= $signed(I_rA) + $signed({{11{I_immediate[4]}}, I_immediate[4:0]});
            O_write_pc <= 0;
            O_write_rD <= 0;
            O_memory_mode <= MEM_WRITE;
            O_memory_size <= I_opcode_mode == 1 ? 2 : 1;
        end
        else if (I_opcode == LOAD)
        begin
            if (I_opcode_mode == OPCODE_MODE_HI)
            begin
                O_out[15:8] <= I_immediate;
                O_out[7:0] <= 0;
            end
            else begin
                O_out[15:8] <= 0;
                O_out[7:0] <= I_immediate;
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == CMP)
        begin
            if (I_opcode_mode == OPCODE_MODE_SIGNED)
            begin
                O_out[CMP_RB_GT_RA_BIT] <= $signed(I_rA) < $signed(I_rB) ? 1 : 0;
                O_out[CMP_RA_GT_RB_BIT] <= $signed(I_rA) > $signed(I_rB) ? 1 : 0;
                O_out[CMP_EQ_BIT]       <= $signed(I_rA) == $signed(I_rB) ? 1 : 0;
                O_out[CMP_RA_ZERO_BIT]  <= $signed(I_rA) == 0 ? 1 : 0;
                O_out[CMP_RB_ZERO_BIT]  <= $signed(I_rB) == 0 ? 1 : 0;
            end
            else
            begin
                O_out[CMP_RB_GT_RA_BIT] <= $unsigned(I_rA) < $unsigned(I_rB) ? 1 : 0;
                O_out[CMP_RA_GT_RB_BIT] <= $unsigned(I_rA) > $unsigned(I_rB) ? 1 : 0;
                O_out[CMP_EQ_BIT]       <= $unsigned(I_rA) == $unsigned(I_rB) ? 1 : 0;
                O_out[CMP_RA_ZERO_BIT]  <= $unsigned(I_rA) == 0 ? 1 : 0;
                O_out[CMP_RB_ZERO_BIT]  <= $unsigned(I_rB) == 0 ? 1 : 0;
            end
            O_out[15:5] <= 0;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == SHIFT)
        begin
            if (I_opcode_mode == 1) begin
                O_out <= I_rA >> $unsigned(I_immediate);
            end
            else begin
                O_out <= I_rA << $unsigned(I_immediate);
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == JMP)
        begin
            if (I_opcode_mode == 0) begin
                O_out <= $signed(I_pc) + $signed({{8{I_immediate[7]}}, I_immediate});
            end
            else begin
                O_out <= I_rA;
            end
            O_write_pc <= 1;
            O_write_rD <= 0;
            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
        end
        else if (I_opcode == JMPC)
        begin
            if (I_opcode_mode == 1) begin
                O_out <= $signed(I_pc) + $signed({{8{I_immediate[4]}}, I_immediate});
            end
            else begin
                O_out <= I_rB;
            end

            O_memory_mode <= MEM_NOP;
            O_memory_size <= 1;
            O_write_rD <= 0;

            if (I_compare_code == CMP_CODE_EQ)
            begin
                O_write_pc <= I_rA[CMP_EQ_BIT] == 1 ? 1 : 0;
            end
            else if(I_compare_code == CMP_CODE_RA_GT_RB)
            begin
                O_write_pc <= I_rA[CMP_RA_GT_RB_BIT] == 1 ? 1 : 0;
            end
            else if(I_compare_code == CMP_CODE_RB_GT_RA)
            begin
                O_write_pc <= I_rA[CMP_RB_GT_RA_BIT] == 1 ? 1 : 0;
            end
            else if(I_compare_code == CMP_CODE_RA_ZERO)
            begin
                O_write_pc <= I_rA[CMP_RA_ZERO_BIT] == 1 ? 1 : 0;
            end
            else if(I_compare_code == CMP_CODE_RB_ZERO)
            begin
                O_write_pc <= I_rA[CMP_RB_ZERO_BIT] == 1 ? 1 : 0;
            end
        end
        else if(I_opcode == SPECIAL)
        begin
            // Save pc
            if (I_immediate[2:0] == 3'b000) begin 
                O_out <= I_pc;
                O_memory_mode <= MEM_NOP;
                O_write_rD <= 1;
                O_write_pc <= 0;
                O_memory_size <= 1;
            end
            // Enable irq
            else if (I_immediate[2:0] == 3'b001) begin 
                O_out <= I_pc;
                O_memory_mode <= MEM_NOP;
                O_write_rD <= 0;
                O_write_pc <= 0;
                O_memory_size <= 1;
                O_irq_enable <= 1;
                irq_recover <= 1;
            end
            // Disable irq
            else if (I_immediate[2:0] == 3'b010) begin 
                O_out <= I_pc;
                O_memory_mode <= MEM_NOP;
                O_write_rD <= 0;
                O_write_pc <= 0;
                O_memory_size <= 1;
                O_irq_enable <= 0;
                irq_recover <= 0;
            end
            // Return from irq
            else if (I_immediate[2:0] == 3'b100) begin 
                O_out <= $signed(I_rA) + 2;
                O_memory_mode <= MEM_READ;
                O_write_rD <= 1;
                O_write_pc <= 1;
                O_memory_size <= 2;
                O_irq_enable <= irq_recover;
            end
        end
        else if(I_opcode == STACK)
        begin
            if (I_opcode_mode == 0) begin
                // PUSH
                O_out <= $signed(I_rA) - 2;
                O_memory_mode <= MEM_WRITE;
                O_write_rD <= 1;
                O_write_pc <= 0;
                O_memory_size <= 2;
            end 
            else if (I_opcode_mode == 1) begin
                // POP
                O_out <= $signed(I_rA) + 2;
                O_memory_mode <= MEM_READ;
                O_write_rD <= 1;
                O_write_pc <= 0;
                O_memory_size <= 2;
            end
        end
    end
end
endmodule
