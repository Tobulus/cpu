`include "ops.vh"
`include "mem_acc.vh"
`include "cmp_res.vh"

module alu(input I_clk,
    input I_reset,
    input I_enable,
    input I_opcode,
    input I_opcode_mode,
    input I_immediate,
    input I_pc,
    input I_rA,
    input I_rB,
    input I_compare_code,
    output O_out,
    output O_write_rD,
    output O_write_pc,
    output O_memory_size,
    output O_memory_mode);

reg[3:0] I_opcode;
reg[2:0] I_compare_code;
reg[1:0] O_memory_mode, O_memory_size;
reg[15:0] I_pc, I_rA, I_rB, O_out;
reg[7:0] I_immediate;

localparam OPCODE_MODE_SIGNED = 1'b0;
localparam OPCODE_MODE_UNSIGNED = 1'b1;

localparam OPCODE_MODE_HI = 1'b1;
localparam OPCODE_MODE_LO = 1'b0;

localparam OPCODE_MODE_IMMEDIATE = 1'b1;

always @(posedge I_clk)
begin: ALU
    if (I_enable == 1 && I_reset == 0)
    begin
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
        else if(I_opcode == SPC)
        begin
            O_out <= I_pc;
            O_memory_mode <= MEM_NOP;
            O_write_rD <= 1;
            O_write_pc <= 0;
            O_memory_size <= 1;
        end
    end
end
endmodule
