module ram(clk, 
    enable,
    write,
    addr,
    data_in,
data_out);
/* verilator lint_off UNUSED */
input clk, enable, write, addr, data_in;
output data_out;

wire clk, enable, write;
reg[15:0] addr, data_in, data_out;

reg[15:0] mem [63:0];

always @(posedge clk)
begin: ram
    if (enable == 1)
    begin
        if (write == 1)
        begin
            mem[addr[5:0]] <= data_in; 
        end
        else begin
            data_out <= mem[addr[5:0]];
        end
    end
end
endmodule;
