#include <stdlib.h>
#include "Vctrl_unit.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() ctrl_unit->clk = 0;ctrl_unit->eval();

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vctrl_unit* ctrl_unit = new Vctrl_unit;
    
    // Reset
    ctrl_unit->reset = 1;
    ctrl_unit->clk = 1;
    ctrl_unit->eval();

    CHECK(ctrl_unit->state, 1, "State should be 1 after reset");
    NOP_CYCLE();
   
    // Fetch - perform memory operation
    ctrl_unit->I_mem_ready = 1; 
    ctrl_unit->reset = 0;
    ctrl_unit->clk = 1;
    ctrl_unit->eval();

    CHECK(ctrl_unit->state, 1, "State should be 1 but is %d", ctrl_unit->state);
    CHECK(ctrl_unit->O_execute, 1, "O_execute should be 1 but is %d", ctrl_unit->O_execute);
    NOP_CYCLE();

    // Fetch - memory operation has been submitted but data is not yet available
    ctrl_unit->I_mem_ready = 0; 
    ctrl_unit->I_data_ready = 0;
    ctrl_unit->clk = 1;
    ctrl_unit->eval();

    CHECK(ctrl_unit->state, 1, "State should be 1 but is %d", ctrl_unit->state);
    CHECK(ctrl_unit->O_execute, 0, "O_execute should be 0 but is %d", ctrl_unit->O_execute);
    NOP_CYCLE();

    // Fetch - instruction is available
    ctrl_unit->I_mem_ready = 0; 
    ctrl_unit->I_data_ready = 1;
    ctrl_unit->clk = 1;
    ctrl_unit->eval();

    CHECK(ctrl_unit->state, 2, "State should be 1 but is %d", ctrl_unit->state);
    CHECK(ctrl_unit->O_execute, 0, "O_execute should be 0 but is %d", ctrl_unit->O_execute);
    NOP_CYCLE();

    // Decode 
    ctrl_unit->clk = 1;
    ctrl_unit->eval();
    CHECK(ctrl_unit->state, 4, "State should be 4 but is %d", ctrl_unit->state);
    NOP_CYCLE();
    
    // Register read 
    ctrl_unit->clk = 1;
    ctrl_unit->eval();
    CHECK(ctrl_unit->state, 8, "State should be 8 but is %d", ctrl_unit->state);
    NOP_CYCLE();   
    
    // Execute
    ctrl_unit->I_instruction = 0;
    ctrl_unit->clk = 1;
    ctrl_unit->eval();
    CHECK(ctrl_unit->state, 32, "State should be 32 but is %d", ctrl_unit->state);
    NOP_CYCLE();
    
    // Register write 
    ctrl_unit->clk = 1;
    ctrl_unit->eval();
    CHECK(ctrl_unit->state, 1, "State should be 1 but is %d", ctrl_unit->state);
    NOP_CYCLE();
    
    printf("Success!\n");

    delete ctrl_unit;
    exit(0);
}
