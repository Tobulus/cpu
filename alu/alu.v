module alu(clk,
           enable,
           opcode,
           opcode_mode,
           immediate,
           pc,
           rA,
           rB,
           out,
           write_rD,
           write_pc,
           memory_mode);

    input clk, enable, opcode, opcode_mode, immediate, rA, rB, pc;

    output out, write_pc, write_rD, memory_mode;

    // input/output types
    wire clk, enable, write_pc, write_rD, opcode_mode;
    reg[3:0] opcode;
    reg[1:0] memory_mode;
    reg[15:0] pc, rA, rB, out;
    reg[7:0] immediate;

    // opcodes
    localparam ADD    = 4'b0000;
    localparam SUB    = 4'b0001;
    localparam OR     = 4'b0010;
    localparam AND    = 4'b0011;
    localparam XOR    = 4'b0100;
    localparam NOT    = 4'b0101;
    localparam READ   = 4'b0110;
    localparam WRITE  = 4'b0111;
    localparam LOAD   = 4'b1000;
    localparam CMP    = 4'b1001;
    localparam SHIFTL = 4'b1010;
    localparam SHIFTR = 4'b1011;
    localparam JMP    = 4'b1100;
    localparam JMPC   = 4'b1101;

    // opcode modes - the mode depends on the opcode
    localparam OPCODE_MODE_SIGNED = 1'b0;
    localparam OPCODE_MODE_UNSIGNED = 1'b1;

    localparam OPCODE_MODE_HI = 1'b0;
    localparam OPCODE_MODE_LO = 1'b1;

    // memory modes
    localparam MEM_NOP   = 2'b00;
    localparam MEM_READ  = 2'b01;
    localparam MEM_WRITE = 2'b10;

    // compare results
    localparam CMP_EQ = 0;
    localparam CMP_RA_GT = -1;
    localparam CMP_RB_GT = 1;  

    always @(posedge clk)
    begin: ALU
        if (enable == 1)
        begin
            if (opcode == ADD)
            begin
                if (opcode_mode == OPCODE_MODE_SIGNED)
                begin
                    out <= $signed(rA) + $signed(rB);
                end
                else begin
                    out <= $unsigned(rA) + $unsigned(rB);
                end
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == SUB)
            begin
                if (opcode_mode == OPCODE_MODE_SIGNED)
                begin
                    out <= $signed(rA) - $signed(rB);
                end
                else begin
                    out <= $unsigned(rA) - $unsigned(rB);
                end
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == OR)
            begin
                out <= rA | rB;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == AND)
            begin
                out <= rA & rB;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == XOR)
            begin
                out <= rA ^ rB;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == NOT)
            begin
                out <= ~rA;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == READ)
            begin
                out <= rA;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_READ;
            end
            else if (opcode == WRITE)
            begin
                out <= rA;
                write_pc <= 0;
                write_rD <= 0;
                memory_mode <= MEM_WRITE;
            end
            else if (opcode == LOAD)
            begin
                if (opcode_mode == OPCODE_MODE_HI)
                begin
                    out[15:8] <= immediate;
                    out[7:0] <= 0;
                end
                else begin
                    out[15:8] <= 0;
                    out[7:0] <= immediate;
                end
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == CMP)
            begin
                if (opcode_mode == OPCODE_MODE_SIGNED)
                begin
                    if ($signed(rA) < $signed(rB))
                    begin
                        out <= CMP_RB_GT;
                    end
                    else if ($signed(rA) < $signed(rB))
                    begin
                        out <= CMP_RA_GT;
                    end
                    else
                    begin
                        out <= CMP_EQ;
                    end
                end
                else
                    if ($unsigned(rA) < $unsigned(rB))
                    begin
                        out <= CMP_RB_GT;
                    end
                    else if ($unsigned(rA) < $unsigned(rB))
                    begin
                        out <= CMP_RA_GT;
                    end
                    else
                    begin
                        out <= CMP_EQ;
                    end
                end
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == SHIFTL)
            begin
                out <= rA << 1;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == SHIFTR)
            begin
                out <= rA >> 1;
                write_pc <= 0;
                write_rD <= 1;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == JMP)
            begin
                if (opcode_mode == OPCODE_MODE_SIGNED) begin
                    // sign extend two's complement
                    if (immediate[7] == 1'b1) begin
                       out <= $signed(pc) + $signed({{8{1'b1}}, immediate});
                    end
                    else begin
                       out <= $signed(pc) + $signed({{8{1'b0}}, immediate});
                    end
                end
                else begin
                    out <= pc + {{8{1'b0}}, immediate};
                end
                write_pc <= 1;
                write_rD <= 0;
                memory_mode <= MEM_NOP;
            end
            else if (opcode == JMPC)
            begin
                if (opcode_mode == OPCODE_MODE_SIGNED) begin
                    // sign extend two's complement
                    if (immediate[7] == 1'b1) begin
                       out <= $signed(pc) + $signed({{8{1'b1}}, immediate});
                    end
                    else begin
                       out <= $signed(pc) + $signed({{8{1'b0}}, immediate});
                    end
                end
                else begin
                    out <= pc + {{8{1'b0}}, immediate};
                end
                write_pc <= rA == rB;
                write_rD <= 0; 
                memory_mode <= MEM_NOP;
            end
        end
endmodule
