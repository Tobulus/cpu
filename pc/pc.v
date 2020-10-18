module pc(clk,
          enable,
          in,
          write,
          out);
   
   input clk, enable, write, in;
   output out;

   wire clk, enable, write;
   reg[15:0] in, out;

always @(posedge clk)
begin: PC
   if (enable == 1)
   begin
      if (write == 1)
      begin
          out <= in;
      end
      else begin
          out <= out + 1;
      end
   end
end
endmodule
