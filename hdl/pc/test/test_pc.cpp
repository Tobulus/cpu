#include <stdlib.h>
#include "Vpc.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() pc->I_clk = 0;pc->eval();

int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Vpc* pc = new Vpc;
   
   pc->I_enable = 1;
   
   pc->I_clk = 1;
   pc->I_in = 1;
   pc->I_write = 1;

   pc->eval();
   CHECK(pc->O_out, 1, "O_out should be 1, but is %d", pc->O_out);
   NOP_CYCLE();

   int i;
   for (i = 2; i < 50; i++) {
       pc->I_clk = 1;
       pc->I_write = 0;
       
       pc->eval();
       
       CHECK(pc->O_out, i, "O_out should be %d, but is %d", i, pc->O_out);
       NOP_CYCLE();
   }

   printf("Success!\n");

   delete pc;
   exit(0);
}
