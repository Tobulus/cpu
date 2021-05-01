module core(input wire I_clk, 
    input wire I_reset,
    input wire I_irq_active,
    input wire MEM_ready,
    input wire[15:0] MEM_data_in, 
    input wire MEM_data_ready,
    output reg O_irq_ack,
    output reg MEM_exec, 
    output reg MEM_write,
    output reg[1:0] MEM_size, 
    output reg[15:0] MEM_addr, 
    output reg[15:0] MEM_data_out);

wire alu_enable, decoder_enable, register_enable, pc_enable, mem_enable, push_pc;
wire write_rD, alu_pc_write, pc_write, mem_ready, mem_execute, mem_write, mem_data_ready, alu_write_rD, mode, irq_ack, alu_irq_enable;
wire[1:0] rD_write_pos;
reg[1:0] memory_mode, memory_size, alu_memory_size;
reg[2:0] rD_select, rA_select, rB_select;
reg[3:0] opcode;
reg[7:0] immediate;
reg[15:0] irq_number, pc_out, pc_in, rA_out, rB_out, alu_out, register_in, instruction, mem_addr, mem_data_in, mem_data_out;
/* verilator lint_off UNUSED */
reg[8:0] state;
reg read_irq_number;

alu alu(.I_clk(I_clk),
    .I_reset(I_reset), 
    .I_enable(alu_enable),
    .I_opcode(opcode),
    .I_opcode_mode(mode),
    .I_immediate(immediate),
    .I_pc(pc_out),
    .I_rA(rA_out),
    .I_rB(rB_out),
    .I_compare_code(rD_select),
    .I_irq_active(irq_ack),
    .O_memory_mode(memory_mode),
    .O_memory_size(alu_memory_size),
    .O_out(alu_out),
    .O_write_rD(alu_write_rD),
    .O_write_pc(alu_pc_write),
    .O_irq_enable(alu_irq_enable));

ctrl_unit ctrl_unit(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_irq_active(I_irq_active),
    .I_irq_enabled(alu_irq_enable), 
    .I_instruction(instruction),
    .I_mem_ready(mem_ready),
    .I_data_ready(mem_data_ready),
    .O_irq_ack(irq_ack),
    .O_state(state),
    .O_execute(mem_execute),
    .O_push_pc(push_pc));

decoder decoder(.I_clk(I_clk), 
    .I_reset(I_reset), 
    .I_enable(decoder_enable),
    .I_instruction(instruction),
    .O_opcode(opcode),
    .O_rD_select(rD_select),
    .O_rD_write_pos(rD_write_pos),
    .O_rA_select(rA_select),
    .O_rB_select(rB_select),
    .O_immediate(immediate),
    .O_mode(mode));

mem_ctrl mem_ctrl(.I_clk(I_clk), 
    .I_reset(I_reset), 
    .I_exec(mem_execute),
    .I_write(mem_write),
    .I_size(memory_size),
    .I_addr(mem_addr),
    .I_data(mem_data_in),
    .O_data(mem_data_out),
    .O_data_ready(mem_data_ready),
    .O_ready(mem_ready),
    .MEM_ready(MEM_ready),
    .MEM_exec(MEM_exec),
    .MEM_write(MEM_write),
    .MEM_size(MEM_size),
    .MEM_addr(MEM_addr),
    .MEM_data_out(MEM_data_out),
    .MEM_data_in(MEM_data_in),
    .MEM_data_ready(MEM_data_ready));

register register(.I_clk(I_clk), 
    .I_reset(I_reset), 
    .I_enable(register_enable),
    .I_rD_write(write_rD),
    .I_rD_select(rD_select),
    .I_rD_write_pos(rD_write_pos),
    .I_rA_select(rA_select),
    .I_rB_select(rB_select),
    .O_rA_out(rA_out),
    .O_rB_out(rB_out),
    .I_rD_in(register_in));

pc pc(.I_clk(I_clk),
    .I_reset(I_reset), 
    .I_in(pc_in),
    .I_enable(pc_enable),
    .I_write(pc_write),
    .O_out(pc_out));

always @(posedge I_clk)
begin: IRQ_READ_NUMBER
    if (irq_ack == 1) begin
        read_irq_number <= 1;
    end
    if (read_irq_number == 1) begin
        irq_number <= MEM_data_in;
        read_irq_number <= 0;
    end
end

always @(*)
begin
    if (I_reset == 1) begin
       // nothing to do currently 
    end
    else begin
        // only update the instruction on decode stage
        if (state[1]) begin
            instruction = push_pc ? {STACK, 4'b1110, {3{1'b1}}, 5'b00001} : MEM_data_in;//TODO: mem_data_out;
        end
        decoder_enable = state[1];
        register_enable = state[2] || state[5];
        alu_enable = state[3];
        mem_enable = state[4] || state[7];
        // inc pc on reg write-back and write pc on ISR enter
        pc_enable = state[5] || state[8];
        mem_data_in = (opcode == STACK && instruction[0] == 1) ? pc_out : rB_out;
        write_rD = state[5] && alu_write_rD;
        memory_size = state[0] ? 2 : alu_memory_size;
        O_irq_ack = irq_ack;
        
        // POP or RETI
        if (state[0] != 1 && ((opcode == SPECIAL && instruction[2:0] == 3'b100) || (opcode == STACK && instruction[8] == 1))) begin
            mem_addr = rA_out;
        end
        else begin
            mem_addr = mem_enable ? alu_out : pc_out;
        end

        if (state[8]) begin
            // branch to ISR
            pc_in = 16'h64 + irq_number * 2;
            pc_write = 1;
        end
        else if (instruction[15:12] == SPECIAL && instruction[2:0] == 3'b100) begin
            // return from ISR
            pc_in = mem_data_out;
            pc_write = 1;
        end
        else begin
            pc_in = alu_out;
            pc_write = alu_pc_write;
        end

        if (memory_mode == MEM_READ) begin
            register_in = mem_data_out;
        end
        else begin
            register_in = alu_out;
        end

        if (mem_enable && memory_mode == MEM_WRITE)
        begin
            mem_write = 1;
        end
        else begin
            mem_write = 0;
        end
    end
end

endmodule
