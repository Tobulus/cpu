module ram(I_clk, 
    I_enable,
    I_write,
    I_addr,
    I_data_in,
O_data_out);
/* verilator lint_off UNUSED */
input I_clk, I_enable, I_write, I_addr, I_data_in;
output O_data_out;

wire I_clk, I_enable, I_write;
reg[15:0] I_addr, I_data_in, O_data_out;

reg[15:0] mem [63:0];

always @(posedge I_clk)
begin: ram
    if (I_enable == 1)
    begin
        if (I_write == 1)
        begin
            mem[I_addr[5:0]] <= I_data_in; 
        end
        else begin
            O_data_out <= mem[I_addr[5:0]];
        end
    end
end
endmodule;
