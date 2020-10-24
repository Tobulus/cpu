module register(clk, 
                enable,
                rD_select,
                rA_select,
                rB_select,
                rA_out,
                rB_out,
                rD_in,
                rD_write);

   input clk, enable, rD_select, rA_select, rB_select, rD_in, rD_write;
   output rA_out, rB_out;

   wire clk, enable, rD_write;
   reg[2:0] rA_select, rB_select, rD_select;
   reg[15:0] rD_in, rA_out, rB_out;
   
   reg[15:0] registers[0:7];

   always @(posedge clk)
   begin: register
      if (enable == 1)
      begin
         rA_out <= registers[rA_select];
	 rB_out <= registers[rB_select];
	 if (rD_write == 1)
	 begin
            registers[rD_select] <= rD_in;
	 end
      end
   end
endmodule
