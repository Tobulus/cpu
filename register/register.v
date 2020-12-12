module register(I_clk, 
    I_enable,
    I_rD_select,
    I_rA_select,
    I_rB_select,
    O_rA_out,
    O_rB_out,
    I_rD_in,
I_rD_write);

input I_clk, I_enable, I_rD_select, I_rA_select, I_rB_select, I_rD_in, I_rD_write;
output O_rA_out, O_rB_out;

wire I_clk, I_enable, I_rD_write;
reg[2:0] I_rA_select, I_rB_select, I_rD_select;
reg[15:0] I_rD_in, O_rA_out, O_rB_out;

reg[15:0] registers[0:7];

always @(posedge I_clk)
begin: register
    if (I_enable == 1)
    begin
        O_rA_out <= registers[I_rA_select];
        O_rB_out <= registers[I_rB_select];
        if (I_rD_write == 1)
        begin
            registers[I_rD_select] <= I_rD_in;
        end
    end
end
endmodule
