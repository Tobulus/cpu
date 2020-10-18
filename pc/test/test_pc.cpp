#include <stdlib.h>
#include "Vpc.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() pc->clk = 0;pc->eval();

int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Vpc* pc = new Vpc;
   
   pc->enable = 1;
   
   pc->clk = 1;
   pc->in = 1;
   pc->write = 1;

   pc->eval();
   CHECK(pc->out, 1, "out should be 1, but is %d", pc->out);
   NOP_CYCLE();

   int i;
   for (i = 2; i < 50; i++) {
       pc->clk = 1;
       pc->write = 0;
       
       pc->eval();
       
       CHECK(pc->out, i, "out should be %d, but is %d", i, pc->out);
       NOP_CYCLE();
   }

   printf("Success!\n");

   delete pc;
   exit(0);
}
