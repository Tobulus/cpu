#include <stdlib.h>
#include "Vdecoder.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() decoder->clk = 0;decoder->eval();

int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Vdecoder* decoder = new Vdecoder;
   
   decoder->enable = 1;
   
   decoder->clk = 1;
   decoder->instr = (1 << 12) | (1 << 10) | (1 << 7) | (1 << 2);

   decoder->eval();
   CHECK(decoder->op, 1, "op should be 1, but is %d", decoder->op);
   CHECK(decoder->rA_select, 4, "rA_select should be 4, but is %d", decoder->rA_select);
   CHECK(decoder->rB_select, 1, "rB_select should be 1, but is %d", decoder->rB_select);
   CHECK(decoder->rD_select, 2, "rD_select should be 2, but is %d", decoder->rD_select);
//   CHECK(decoder->immediate, 0, "immediate should be 1, but is %d", decoder->immediate);

   NOP_CYCLE();

   printf("Success!\n");

   delete decoder;
   exit(0);
}
