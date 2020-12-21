module pc(input I_clk,
    input I_reset,
    input I_enable,
    input I_in,
    input I_write,
output O_out);

reg[15:0] I_in, O_out;

always @(posedge I_clk)
begin: PC
    if (I_reset == 1) begin
        O_out <= 0;
    end
    else if (I_enable == 1)
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
