module ram(input I_clk,
    input I_reset, 
    input I_enable,
    input I_size,
    input I_write,
    /* verilator lint_off UNUSED */
    input I_addr,
    input I_data_in,
output O_data_out);

wire[15:0] I_addr, I_data_in;
reg[15:0] O_data_out;
wire[1:0] I_size;

reg[7:0] mem [2048:0];

// bootloader
initial begin
	mem[0] =  'h00;
	mem[1] =  'h80;
	mem[2] =  'h00;
	mem[3] =  'h8c;
	mem[4] =  'h01;
	mem[5] =  'h82;
	mem[6] =  'h04;
	mem[7] =  'h83;
	mem[8] =  'h00;
	mem[9] =  'h8e;
	mem[10] = 'h04;
	mem[11] = 'h8f;
	mem[12] = 'h64;
	mem[13] = 'h88;
	mem[14] = 'h00;
	mem[15] = 'h89;
	mem[16] = 'h20;
	mem[17] = 'h64;
	mem[18] = 'h40;
	mem[19] = 'h96;
	mem[20] = 'h7c;
	mem[21] = 'hc1;
	mem[22] = 'he0;
	mem[23] = 'h64;
	mem[24] = 'hc8;
	mem[25] = 'h9a;
	mem[26] = 'ha0;
	mem[27] = 'h5a;
	mem[28] = 'haa;
	mem[29] = 'hc1;
	mem[30] = 'hff;
	mem[31] = 'h8a;
	mem[32] = 'h00;
	mem[33] = 'h8b;
	mem[34] = 'ha8;
	mem[35] = 'h96;
	mem[36] = 'h6a;
	mem[37] = 'hc1;
	mem[38] = 'h41;
	mem[39] = 'h0d;
	mem[40] = 'h88;
	mem[41] = 'h70;
	mem[42] = 'h83;
	mem[43] = 'h09;
	mem[44] = 'he4;
	mem[45] = 'hb0;
	mem[46] = 'h00;
	mem[47] = 'h90;
	mem[48] = 'h64;
	mem[49] = 'h88;
	mem[50] = 'h00;
	mem[51] = 'h89;
	mem[52] = 'h10;
	mem[53] = 'hc6;
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
