`include "../alu/ops.vh"

module decoder(input I_clk,
    input I_reset, 
    input I_enable,
    input I_instruction,
    output O_opcode,
    output O_rD_select,
    output O_rA_select,
    output O_rB_select,
    output O_immediate,
output O_mode);

reg[15:0] I_instruction;
reg[3:0] O_opcode;
reg[2:0] O_rD_select, O_rA_select, O_rB_select;
reg[7:0] O_immediate;

always @(posedge I_clk)
begin: decoder
    if (I_enable == 1 && I_reset == 0)
    begin
        O_opcode    <= I_instruction[15:12];
        O_rD_select <= I_instruction[11:9];
        O_rA_select <= I_instruction[7:5];
        O_rB_select <= I_instruction[4:2];
        O_mode      <= I_instruction[8];

        if (I_instruction[15:12] == WRITE)
        begin
            O_immediate <= {I_instruction[11:9], I_instruction[2:0], 2'b00}; 
        end
        else
        begin
            O_immediate <= I_instruction[7:0];
        end
    end
end
endmodule
