module pc(I_clk,
    I_enable,
    I_in,
    I_write,
O_out);

input I_clk, I_enable, I_write, I_in;
output O_out;

wire I_clk, I_enable, I_write;
reg[15:0] I_in, O_out;

always @(posedge I_clk)
begin: PC
    if (I_enable == 1)
    begin
        if (I_write == 1)
        begin
            O_out <= I_in;
        end
        else begin
            O_out <= O_out + 1;
        end
    end
end
endmodule
