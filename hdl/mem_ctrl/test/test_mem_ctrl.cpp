#include <stdlib.h>
#include "Vmem_ctrl.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() mem_ctrl->I_clk = 0;mem_ctrl->eval();

int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Vmem_ctrl* mem_ctrl = new Vmem_ctrl;
   
   mem_ctrl->I_clk = 1;
   mem_ctrl->I_exec = 1;   
   mem_ctrl->I_write = 1;
   mem_ctrl->I_addr = 2;
   mem_ctrl->I_data = 3;
   mem_ctrl->MEM_ready = 1;
   mem_ctrl->eval();

   CHECK(mem_ctrl->O_data_ready, 0, "Data should not be ready");
   CHECK(mem_ctrl->MEM_exec, 1, "MEM_exec should be 1");
   CHECK(mem_ctrl->MEM_addr, 2, "MEM_addr should be 2");
   CHECK(mem_ctrl->MEM_data_out, 3, "MEM_data_out should be 3");
   CHECK(mem_ctrl->MEM_write, 1, "MEM_write should be 1");

   NOP_CYCLE();

   mem_ctrl->I_clk = 1;
   mem_ctrl->I_exec = 0;   
   mem_ctrl->I_write = 0;
   mem_ctrl->I_addr = 0;
   mem_ctrl->I_data = 0;
   mem_ctrl->MEM_data_ready = 0;
   mem_ctrl->eval();

   CHECK(mem_ctrl->O_data_ready, 0, "Data should not be ready");
   CHECK(mem_ctrl->MEM_exec, 0, "MEM_exec should be 0");
   
   NOP_CYCLE();

   mem_ctrl->I_clk = 1;
   mem_ctrl->I_exec = 0;   
   mem_ctrl->I_write = 0;
   mem_ctrl->I_addr = 0;
   mem_ctrl->I_data = 0;
   mem_ctrl->MEM_data_ready = 1;
   mem_ctrl->eval();

   CHECK(mem_ctrl->MEM_exec, 0, "MEM_exec should be 1");
   CHECK(mem_ctrl->O_ready, 1, "Should be ready");
   
   NOP_CYCLE();

   printf("Success!\n");

   delete mem_ctrl;
   exit(0);
}
