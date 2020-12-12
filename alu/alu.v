`include "ops.vh"
`include "mem_acc.vh"
`include "cmp_res.vh"

module alu(I_clk,
    I_enable,
    I_opcode,
    I_opcode_mode,
    I_immediate,
    I_pc,
    I_rA,
    I_rB,
    O_out,
    O_write_rD,
    O_write_pc,
O_memory_mode);

input I_clk, I_enable, I_opcode, I_opcode_mode, I_immediate, I_rA, I_rB, I_pc;

output O_out, O_write_pc, O_write_rD, O_memory_mode;

// input/output types
wire I_clk, I_enable, O_write_pc, O_write_rD, I_opcode_mode;
reg[3:0] I_opcode;
reg[1:0] O_memory_mode;
reg[15:0] I_pc, I_rA, I_rB, O_out;
reg[7:0] I_immediate;

// opcode modes - the mode depends on the opcode
localparam OPCODE_MODE_SIGNED = 1'b0;
localparam OPCODE_MODE_UNSIGNED = 1'b1;

localparam OPCODE_MODE_HI = 1'b0;
localparam OPCODE_MODE_LO = 1'b1;

always @(posedge I_clk)
begin: ALU
    if (I_enable == 1)
    begin
        if (I_opcode == ADD)
        begin
            if (I_opcode_mode == OPCODE_MODE_SIGNED)
            begin
                O_out <= $signed(I_rA) + $signed(I_rB);
            end
            else begin
                O_out <= $unsigned(I_rA) + $unsigned(I_rB);
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
        end
        else if (I_opcode == SUB)
        begin
            if (I_opcode_mode == OPCODE_MODE_SIGNED)
            begin
                O_out <= $signed(I_rA) - $signed(I_rB);
            end
            else begin
                O_out <= $unsigned(I_rA) - $unsigned(I_rB);
            end
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
        end
        else if (I_opcode == OR)
        begin
            O_out <= I_rA | I_rB;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
        end
        else if (I_opcode == AND)
        begin
            O_out <= I_rA & I_rB;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
        end
        else if (I_opcode == XOR)
        begin
            O_out <= I_rA ^ I_rB;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
        end
        else if (I_opcode == NOT)
        begin
            O_out <= ~I_rA;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_NOP;
        end
        else if (I_opcode == READ)
        begin
            O_out <= I_rA;
            O_write_pc <= 0;
            O_write_rD <= 1;
            O_memory_mode <= MEM_READ;
        end
        else if (I_opcode == WRITE)
        begin
            O_out <= I_rA;
            O_write_pc <= 0;
            O_write_rD <= 0;
            O_memory_mode <= MEM_WRITE;
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
        end
        else if (I_opcode == CMP)
        begin
            if (I_opcode_mode == OPCODE_MODE_SIGNED)
            begin
                if ($signed(I_rA) < $signed(I_rB))
                begin
                    O_out <= CMP_RB_GT;
                end
                else if ($signed(I_rA) < $signed(I_rB))
                begin
                    O_out <= CMP_RA_GT;
                end
                else
                begin
                    O_out <= CMP_EQ;
                end
            end
            else
            if ($unsigned(I_rA) < $unsigned(I_rB))
            begin
                O_out <= CMP_RB_GT;
            end
            else if ($unsigned(I_rA) < $unsigned(I_rB))
            begin
                O_out <= CMP_RA_GT;
            end
            else
            begin
                O_out <= CMP_EQ;
            end
        end
        O_write_pc <= 0;
        O_write_rD <= 1;
        O_memory_mode <= MEM_NOP;
    end
    else if (I_opcode == SHIFTL)
    begin
        O_out <= I_rA << 1;
        O_write_pc <= 0;
        O_write_rD <= 1;
        O_memory_mode <= MEM_NOP;
    end
    else if (I_opcode == SHIFTR)
    begin
        O_out <= I_rA >> 1;
        O_write_pc <= 0;
        O_write_rD <= 1;
        O_memory_mode <= MEM_NOP;
    end
    else if (I_opcode == JMP)
    begin
        if (I_opcode_mode == OPCODE_MODE_SIGNED) begin
            // sign extend two's complement
            if (I_immediate[7] == 1'b1) begin
                O_out <= $signed(I_pc) + $signed({{8{1'b1}}, I_immediate});
            end
            else begin
                O_out <= $signed(I_pc) + $signed({{8{1'b0}}, I_immediate});
            end
        end
        else begin
            O_out <= I_pc + {{8{1'b0}}, I_immediate};
        end
        O_write_pc <= 1;
        O_write_rD <= 0;
        O_memory_mode <= MEM_NOP;
    end
    else if (I_opcode == JMPC)
    begin
        if (I_opcode_mode == OPCODE_MODE_SIGNED) begin
            // sign extend two's complement
            if (I_immediate[7] == 1'b1) begin
                O_out <= $signed(I_pc) + $signed({{8{1'b1}}, I_immediate});
            end
            else begin
                O_out <= $signed(I_pc) + $signed({{8{1'b0}}, I_immediate});
            end
        end
        else begin
            O_out <= I_pc + {{8{1'b0}}, I_immediate};
        end
        O_write_pc <= I_rA == I_rB;
        O_write_rD <= 0; 
        O_memory_mode <= MEM_NOP;
    end
end
endmodule
