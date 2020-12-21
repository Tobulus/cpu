module mem_ctrl(input I_clk,
    input I_reset, 
    input I_exec,
    input I_write,
    input I_addr, 
    input I_data,
    output O_data, 
    output O_data_ready,
    output O_ready,
    input MEM_ready,
    output MEM_exec,
    output MEM_write,
    output MEM_addr,
    output MEM_data_out,
    input MEM_data_in,
input MEM_data_ready);

reg[15:0] I_addr, I_data, O_data, MEM_data_in, MEM_data_out, MEM_addr;
reg[1:0] state = 0;

always @(*)
begin
    MEM_addr = I_addr;
    MEM_write = I_write;
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
                state <= 0;
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
