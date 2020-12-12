module core(I_clk, 
    I_reset,
    MEM_ready,
    MEM_exec, 
    MEM_write, 
    MEM_addr, 
    MEM_data_in, 
    MEM_data_out, 
MEM_data_ready);

input I_clk, I_reset, MEM_ready, MEM_data_in, MEM_data_ready;
output MEM_exec, MEM_write, MEM_addr, MEM_data_out;

reg[15:0] MEM_data_in, MEM_data_out, MEM_addr;

wire alu_enable, decoder_enable, register_enable, pc_enable, mem_enable, opcode_mode, write_rD, pc_write, mem_ready, mem_execute, mem_write, mem_data_ready, alu_write_rD;
reg[1:0] memory_mode;
reg[2:0] rD_select, rA_select, rB_select;
reg[3:0] opcode;
reg[7:0] immediate;
reg[15:0] pc_out, pc_in, rA_out, rB_out, alu_out, register_in, instruction, mem_addr, mem_data_in, mem_data_out;
/* verilator lint_off UNUSED */
reg[5:0] state;

alu alu(.I_clk(I_clk), 
    .I_enable(alu_enable),
    .I_opcode(opcode),
    .I_opcode_mode(opcode_mode),
    .I_immediate(immediate),
    .I_pc(pc_out),
    .O_memory_mode(memory_mode),
    .I_rA(rA_out),
    .I_rB(rB_out),
    .O_out(alu_out),
    .O_write_rD(alu_write_rD),
.O_write_pc(pc_write));

ctrl_unit ctrl_unit(.I_clk(I_clk),
    .I_reset(I_reset),
    .I_instruction(instruction),
    .I_mem_ready(mem_ready),
    .I_data_ready(mem_data_ready),
    .O_state(state),
.O_execute(mem_execute));

decoder decoder(.I_clk(I_clk), 
    .I_enable(decoder_enable),
    .I_instruction(instruction),
    .O_opcode(opcode),
    .O_rD_select(rD_select),
    .O_rA_select(rA_select),
    .O_rB_select(rB_select),
.O_immediate(immediate));

mem_ctrl mem_ctrl(.I_clk(I_clk), 
    .I_exec(mem_execute),
    .I_write(mem_write),
    .I_addr(mem_addr),
    .I_data(mem_data_in),
    .O_data(mem_data_out),
    .O_data_ready(mem_data_ready),
    .O_ready(mem_ready),
    .MEM_ready(MEM_ready),
    .MEM_exec(MEM_exec),
    .MEM_write(MEM_write),
    .MEM_addr(MEM_addr),
    .MEM_data_out(MEM_data_out),
    .MEM_data_in(MEM_data_in),
.MEM_data_ready(MEM_data_ready));

register register(.I_clk(I_clk), 
    .I_enable(register_enable),
    .I_rD_write(write_rD),
    .I_rD_select(rD_select),
    .I_rA_select(rA_select),
    .I_rB_select(rB_select),
    .O_rA_out(rA_out),
    .O_rB_out(rB_out),
.I_rD_in(register_in));

pc pc(.I_clk(I_clk),
    .I_in(pc_in),
    .I_enable(pc_enable),
    .I_write(pc_write),
.O_out(pc_out));

always @(*)
begin
    instruction = MEM_data_in;
    opcode_mode = instruction[7];
    decoder_enable = state[1];
    register_enable = state[2] || state[5];
    alu_enable = state[3];
    mem_enable = state[4];
    pc_enable = state[5];
    pc_in = alu_out;
    mem_addr = mem_enable ? alu_out : pc_out;
    mem_data_in = rB_out;
    write_rD = state[5] && alu_write_rD;
    register_in = state[4] ? mem_data_out : alu_out;

    if (mem_enable && memory_mode == MEM_WRITE)
    begin
        mem_write = 1;
    end
    else 
    begin
        mem_write = 0;
    end
end

endmodule
