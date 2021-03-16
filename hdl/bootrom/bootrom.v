module bootrom(input I_clk,
    input I_reset,
    input I_enable,
    input I_addr,
    output O_data_out
);

wire[7:0] I_addr;
reg[15:0] O_data_out;
reg[7:0] mem [255:0];

initial begin
    $readmemh("../../bootloader/bootloader.hex", mem);
end

always @(posedge I_clk)
begin: bootrom
    if (I_enable == 1 && I_reset == 0)
    begin
        O_data_out[7:0] <= mem[I_addr[7:0]];
        O_data_out[15:8] <= mem[I_addr[7:0] + 1];
    end
end
endmodule;
