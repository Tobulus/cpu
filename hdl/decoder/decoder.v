`include "../alu/ops.vh"

module decoder(input wire I_clk,
    input wire I_reset, 
    input wire I_enable,
    input reg[15:0] I_instruction,
    output reg [3:0] O_opcode,
    output reg[2:0] O_rD_select,
    output wire[1:0] O_rD_write_pos,
    output reg[2:0] O_rA_select,
    output reg[2:0] O_rB_select,
    output reg[7:0] O_immediate,
    output wire O_mode);

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
            O_immediate <= {{3{I_instruction[11]}}, I_instruction[11:9], I_instruction[1:0]}; 
            O_rD_write_pos <= 0;
        end
        else if(I_instruction[15:12] == LOAD || I_instruction[15:12] == JMP)
        begin
            O_immediate <= I_instruction[7:0];
            if (I_instruction[8] == 0) begin
                O_rD_write_pos <= 1;
            end
            else begin
                O_rD_write_pos <= 2;
            end
        end
        else begin
            O_immediate <= {{3{I_instruction[4]}}, I_instruction[4:0]};
            O_rD_write_pos <= 0;
        end
    end
end
endmodule
