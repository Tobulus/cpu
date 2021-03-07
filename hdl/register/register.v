module register(input I_clk,
    input I_reset, 
    input I_enable,
    input I_rD_select,
    input I_rA_select,
    input I_rB_select,
    input  I_rD_in,
    input I_rD_write,
    input I_rD_write_pos,
    output  O_rA_out,
output O_rB_out);

reg[2:0] I_rA_select, I_rB_select, I_rD_select;
reg[15:0] I_rD_in, O_rA_out, O_rB_out;
wire[1:0] I_rD_write_pos;
reg[15:0] registers[0:7];
integer i;

always @(posedge I_clk)
begin: register
    if (I_reset) begin
        for (i=0; i < 8; i=i+1) registers[i] <= 0;
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
