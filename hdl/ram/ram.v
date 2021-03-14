module ram(input I_clk,
    input I_reset, 
    input I_enable,
    input I_size,
    input I_write,
    /* verilator lint_off UNUSED */
    input I_addr,
        input I_data_in,
        output O_data_out
    );

    wire[15:0] I_addr, I_data_in;
    reg[15:0] O_data_out;
    wire[1:0] I_size;

    reg[7:0] mem [2048:0];

    // bootloader
    initial begin
        $readmemh("../../bootloader/bootloader.hex", mem);
    end

    always @(posedge I_clk)
    begin: ram
        if (I_enable == 1 && I_reset == 0)
        begin
            if (I_write == 1)
            begin
                mem[I_addr[11:0]] <= I_data_in[7:0]; 
                if (I_size == 2) begin
                    mem[I_addr[11:0] + 1] <= I_data_in[15:8]; 
                end
            end
            else begin
                O_data_out[7:0] <= mem[I_addr[11:0]];
                if (I_size == 2 && I_addr[11:0] < 2048) begin
                    O_data_out[15:8] <= mem[I_addr[11:0] + 1];
                end
                else begin
                    O_data_out[15:8] <= 0;
                end
            end
        end
    end
    endmodule;
