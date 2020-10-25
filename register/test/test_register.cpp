#include <stdlib.h>
#include "Vregister.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() reg->clk = 0;reg->eval();

int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Vregister* reg = new Vregister;
   
   reg->enable = 1;

   reg->clk = 1;
   reg->rD_write = 1;
   reg->rD_select = 2;
   reg->rD_in = 6;
   
   reg->eval();
   NOP_CYCLE()
   
   reg->clk = 1;
   reg->rD_write = 0;
   reg->rA_select = 2;

   reg->eval();
   CHECK(reg->rA_out, 6, "data_out should be 6 but is %d", reg->rA_out);

   printf("Success!\n");

   delete reg;
   exit(0);
}
