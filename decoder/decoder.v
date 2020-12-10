module decoder(clk, 
    enable,
    instr,
    op,
    rD_select,
    rA_select,
    rB_select,
immediate);

input clk, enable, instr;
output op, rD_select, rA_select, rB_select, immediate;

wire clk, enable;
reg[15:0] instr;
reg[3:0] op;
reg[2:0] rD_select, rA_select, rB_select;
reg[7:0] immediate;

always @(posedge clk)
begin: decoder
    if (enable == 1)
    begin
        op <= instr[15:12];
        rD_select <= instr[11:9];
        rA_select <= instr[7:5];
        rB_select <= instr[4:2];
        immediate <= instr[7:0];
    end
end
endmodule
