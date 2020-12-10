module mem_ctrl(I_clk, 
                I_exec,
                I_write,
                I_addr, 
                I_data,
                O_data, 
                O_data_ready,
                O_ready,
                MEM_ready,
                MEM_exec,
                MEM_write,
                MEM_addr,
                MEM_data_out,
                MEM_data_in,
                MEM_data_ready);

   input I_clk, I_exec, I_write, I_addr, I_data, MEM_ready, MEM_data_in, MEM_data_ready;

   output O_ready, O_data_ready, O_data, MEM_exec, MEM_addr, MEM_data_out, MEM_write;

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
      if (state == 0 && I_exec == 1 && MEM_ready == 1) 
      begin
          O_data_ready <= 0;
          MEM_exec <= 1;
          if (I_write == 1) 
          begin
              state <= 1;
          end
          else
          begin
              state <= 2;
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

endmodule
