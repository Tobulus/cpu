module system(I_clk, I_reset);

input I_clk, I_reset;

wire mem_exec, mem_write;
wire[15:0] mem_addr, mem_data_in, mem_data_out;

core core(.I_clk(I_clk),
    .I_reset(I_reset),
    .MEM_ready(1),
    .MEM_exec(mem_exec),
    .MEM_write(mem_write),
    .MEM_addr(mem_addr),
    .MEM_data_in(mem_data_in),
    .MEM_data_out(mem_data_out),
.MEM_data_ready(1));

ram ram(.I_clk(I_clk), 
    .I_enable(mem_exec),
    .I_write(mem_write),
    .I_addr(mem_addr),
    .I_data_in(mem_data_out),
.O_data_out(mem_data_in));

endmodule;
