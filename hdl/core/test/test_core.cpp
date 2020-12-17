#include <stdlib.h>
#include "Vcore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() core->I_clk = 0;core->eval();

void dump_state(Vcore* core) {
    int i;
    
    printf("----------------------------------\n");
    printf("mem_enable=%d\n", core->v__DOT__mem_enable);
    printf("alu_write_rD=%d\n", core->v__DOT__alu_write_rD);
    printf("pc_write=%d\n", core->v__DOT__pc_write);
    printf("mem_ready=%d\n", core->v__DOT__mem_ready);
    printf("mem_execute=%d\n", core->v__DOT__mem_execute);
    printf("mem_write=%d\n", core->v__DOT__mem_write);
    printf("mem_data_ready=%d\n", core->v__DOT__mem_data_ready);
    printf("memory_mode=%d\n", core->v__DOT__memory_mode);
    printf("rD_select=%d\n", core->v__DOT__rD_select);
    printf("rA_select=%d\n", core->v__DOT__rA_select);
    printf("rB_select=%d\n", core->v__DOT__rB_select);
    printf("opcode=%d\n", core->v__DOT__opcode);
    printf("immediate=%d\n", core->v__DOT__immediate);
    printf("state=%d\n", core->v__DOT__state);
    printf("ctrl_unit_mem_wait=%d\n", core->v__DOT__ctrl_unit__DOT__mem_wait);
    printf("mem_ctrl_state=%d\n", core->v__DOT__mem_ctrl__DOT__state);
    printf("pc_out=%d\n", core->v__DOT__pc_out);
    printf("rA_out=%d\n", core->v__DOT__rA_out);
    printf("rB_out=%d\n", core->v__DOT__rB_out);
    printf("alu_out=%d\n", core->v__DOT__alu_out);
    printf("mem_addr=%d\n", core->v__DOT__mem_addr);
    printf("mem_ctrl_state[0]=%d\n", core->__Vtable1_v__DOT__mem_ctrl__DOT__state[0]);
    printf("mem_ctrl_state[1]=%d\n", core->__Vtable1_v__DOT__mem_ctrl__DOT__state[1]);
    printf("MEM_data_out=%d\n", core->MEM_data_out);

    for(i=0; i < 8; i++){
        printf("register[%d]=%d\n",i, core->v__DOT__register__DOT__registers[i]);
    }
}

void await_completion(Vcore* core) {
    int lastState = core->v__DOT__state;
    dump_state(core);

    while (lastState <= core->v__DOT__state) {
        lastState = core->v__DOT__state;
        core->I_clk = 1;
        core->eval();
        dump_state(core);
        NOP_CYCLE();
    }
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vcore* core = new Vcore;

    core->I_clk = 1;
    core->I_reset = 1;
    core->eval();

    NOP_CYCLE();

    core->I_reset = 0;
    core->MEM_data_ready = 1;

    core->I_clk = 1;
    core->MEM_ready = 1;
    // LOAD %1, 1
    core->MEM_data_in = (8 << 12) | (1 << 9) |  1;
    core->eval();

    await_completion(core);

    core->I_clk = 1;
    core->MEM_ready = 1;
    // LOAD %2, 2
    core->MEM_data_in = (8 << 12) | (1 << 10) |  2;
    core->eval();

    await_completion(core);

    core->I_clk = 1;
    core->MEM_ready = 1;
    // ADD %3, %2, %1
    core->MEM_data_in =  (1 << 10) | (1 << 9) | (1 << 6) | (1 << 2);
    core->eval();

    await_completion(core);

    core->I_clk = 1;
    core->MEM_ready = 1;
    // WRITE %3
    core->MEM_data_in =  (7 << 12) | (3 << 2);
    core->eval();

    await_completion(core);   

    CHECK(core->MEM_data_out, 3, "MEM_data_out should be 3 but is %d", core->MEM_data_out);

    printf("Success!\n");

    delete core;
    exit(0);
}
