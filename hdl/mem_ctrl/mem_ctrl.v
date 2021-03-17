module mem_ctrl(input wire I_clk,
    input wire I_reset, 
    input wire I_exec,
    input wire I_write,
    input wire[1:0] I_size,
    input wire[15:0] I_addr, 
    input wire[15:0] I_data,
    output reg[15:0] O_data, 
    output wire O_data_ready,
    output wire O_ready,
    input wire MEM_ready,
    output wire MEM_exec,
    output wire MEM_write,
    output reg[15:0] MEM_addr,
    output reg[1:0] MEM_size,
    output reg[15:0] MEM_data_out,
    input wire[15:0] MEM_data_in,
    input wire MEM_data_ready);

reg[1:0] state = 0;

always @(*)
begin
    MEM_addr = I_addr;
    MEM_write = I_write;
    MEM_size = I_size;
    MEM_data_out = I_data;
    O_data = MEM_data_in;

    if (state == 0)
    begin
        O_ready = MEM_ready && !I_exec;
    end
    else
    begin
        O_ready = 0;
    end
end

always @(posedge I_clk)
begin: MEM_CTRL
    if (I_reset == 0) begin
        if (state == 0 && I_exec == 1 && MEM_ready == 1) 
        begin
            O_data_ready <= 0;
            MEM_exec <= 1;
            if (I_write == 1) 
            begin
                state <= 2;
            end
            else
            begin
                state <= 1;
            end
        end
        else if (state == 1)
        begin
            MEM_exec <= 0;
            if (MEM_data_ready == 1)
            begin
                O_data_ready <= 1;
                state <= 2; // clear data_ready and check MEM_ready
            end
        end
        else if (state == 2)
        begin
            MEM_exec <= 0;
            O_data_ready <= 0;
            if (MEM_ready == 1)
            begin
                state <= 0;
            end
        end
    end
end

endmodule
