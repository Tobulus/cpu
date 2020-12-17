#include <stdlib.h>
#include "Vdecoder.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() decoder->I_clk = 0;decoder->eval();

int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Vdecoder* decoder = new Vdecoder;
   
   decoder->I_enable = 1;
   
   decoder->I_clk = 1;
   decoder->I_instruction = (1 << 12) | (1 << 10) | (1 << 7) | (1 << 2);

   decoder->eval();
   CHECK(decoder->O_opcode, 1, "O_opcode should be 1, but is %d", decoder->O_opcode);
   CHECK(decoder->O_rA_select, 4, "O_rA_select should be 4, but is %d", decoder->O_rA_select);
   CHECK(decoder->O_rB_select, 1, "O_rB_select should be 1, but is %d", decoder->O_rB_select);
   CHECK(decoder->O_rD_select, 2, "O_rD_select should be 2, but is %d", decoder->O_rD_select);
//   CHECK(decoder->O_immediate, 0, "O_immediate should be 1, but is %d", decoder->O_immediate);

   NOP_CYCLE();

   printf("Success!\n");

   delete decoder;
   exit(0);
}
