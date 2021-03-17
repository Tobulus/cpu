module register(input wire I_clk,
    input wire I_reset, 
    input wire I_enable,
    input reg[2:0] I_rD_select,
    input reg[2:0] I_rA_select,
    input reg[2:0] I_rB_select,
    input reg[15:0] I_rD_in,
    input wire I_rD_write,
    input wire[1:0] I_rD_write_pos,
    output reg[15:0] O_rA_out,
    output reg[15:0] O_rB_out);

reg[15:0] registers[0:7];
integer i;

always @(posedge I_clk)
begin: register
    if (I_reset) begin
        for (i=0; i < 8; i=i+1) begin
            registers[i] <= 0;
        end
    end
    else if (I_enable == 1)
    begin
        O_rA_out <= registers[I_rA_select];
        O_rB_out <= registers[I_rB_select];
        if (I_rD_write == 1)
        begin
            if (I_rD_write_pos == 0) begin
                registers[I_rD_select] <= I_rD_in;
            end
            else if (I_rD_write_pos == 1) begin
                registers[I_rD_select][7:0] <= I_rD_in[7:0];
            end
            else if(I_rD_write_pos == 2) begin
                registers[I_rD_select][15:8] <= I_rD_in[15:8];
            end
        end
    end
end
endmodule
