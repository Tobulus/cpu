`include "../system/mmap.vh"

module ram(input wire I_clk,
    input wire I_reset, 
    input wire I_enable,
    input wire [1:0] I_size,
    input wire I_write,
    input wire[15:0] I_addr,
    input wire[15:0] I_data_in,
    output reg[15:0] O_data_out
);

reg[7:0] mem [RAM_SIZE:0];

always @(posedge I_clk)
begin: ram
    if (I_enable == 1 && I_reset == 0)
    begin
        if (I_write == 1)
        begin
            mem[I_addr] <= I_data_in[7:0]; 
            if (I_size == 2) begin
                mem[I_addr + 1] <= I_data_in[15:8]; 
            end
        end
        else begin
            O_data_out[7:0] <= mem[I_addr];
            if (I_size == 2 && I_addr < RAM_SIZE) begin
                O_data_out[15:8] <= mem[I_addr + 1];
            end
            else begin
                O_data_out[15:8] <= 0;
            end
        end
    end
end
endmodule;
