module decoder(I_clk, 
    I_enable,
    I_instruction,
    O_opcode,
    O_rD_select,
    O_rA_select,
    O_rB_select,
O_immediate);

/* verilator lint_off UNUSED */
input I_clk, I_enable, I_instruction;
output O_opcode, O_rD_select, O_rA_select, O_rB_select, O_immediate;

wire I_clk, I_enable;
reg[15:0] I_instruction;
reg[3:0] O_opcode;
reg[2:0] O_rD_select, O_rA_select, O_rB_select;
reg[7:0] O_immediate;

always @(posedge I_clk)
begin: decoder
    if (I_enable == 1)
    begin
        O_opcode <= I_instruction[15:12];
        O_rD_select <= I_instruction[11:9];
        O_rA_select <= I_instruction[7:5];
        O_rB_select <= I_instruction[4:2];
        O_immediate <= I_instruction[7:0];
    end
end
endmodule
