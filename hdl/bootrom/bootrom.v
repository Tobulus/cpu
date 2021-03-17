module bootrom(input wire I_clk,
    input wire I_reset,
    input wire I_enable,
    input wire[7:0] I_addr,
    output reg[15:0] O_data_out
);

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
