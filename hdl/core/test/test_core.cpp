#include <stdlib.h>
#include "Vcore.h"
#include "verilated.h"
#include "testbench.h"

class Core_Test_Bench: public TESTBENCH<Vcore> {
    
    public:
    
        void dump_state() {
            int i;

            printf("----------------------------------\n");
            printf("mem_enable=%d\n", m_core->core__DOT__mem_enable);
            printf("alu_write_rD=%d\n", m_core->core__DOT__alu_write_rD);
            printf("pc_write=%d\n", m_core->core__DOT__pc_write);
            printf("mem_ready=%d\n", m_core->core__DOT__mem_ready);
            printf("mem_execute=%d\n", m_core->core__DOT__mem_execute);
            printf("mem_write=%d\n", m_core->core__DOT__mem_write);
            printf("mem_data_ready=%d\n", m_core->core__DOT__mem_data_ready);
            printf("memory_mode=%d\n", m_core->core__DOT__memory_mode);
            printf("rD_select=%d\n", m_core->core__DOT__rD_select);
            printf("rA_select=%d\n", m_core->core__DOT__rA_select);
            printf("rB_select=%d\n", m_core->core__DOT__rB_select);
            printf("opcode=%d\n", m_core->core__DOT__opcode);
            printf("immediate=%d\n", m_core->core__DOT__immediate);
            printf("state=%d\n", m_core->core__DOT__state);
            printf("ctrl_unit_mem_wait=%d\n", m_core->core__DOT__ctrl_unit__DOT__mem_wait);
            printf("mem_ctrl_state=%d\n", m_core->core__DOT__mem_ctrl__DOT__state);
            printf("pc_out=%d\n", m_core->core__DOT__pc_out);
            printf("rA_out=%d\n", m_core->core__DOT__rA_out);
            printf("rB_out=%d\n", m_core->core__DOT__rB_out);
            printf("alu_out=%d\n", m_core->core__DOT__alu_out);
            printf("mem_addr=%d\n", m_core->core__DOT__mem_addr);
            printf("mem_ctrl_state[0]=%d\n", m_core->__Vtable1_core__DOT__mem_ctrl__DOT__state[0]);
            printf("mem_ctrl_state[1]=%d\n", m_core->__Vtable1_core__DOT__mem_ctrl__DOT__state[1]);
            printf("MEM_data_out=%d\n", m_core->MEM_data_out);

            for(i=0; i < 8; i++){
                printf("register[%d]=%d\n",i, m_core->core__DOT__register__DOT__registers[i]);
            }
        }

        void await_completion() {
            int lastState = m_core->core__DOT__state;
            dump_state();

            while (lastState <= m_core->core__DOT__state) {
                lastState = m_core->core__DOT__state;
                
                this->tick();
                
                dump_state();
            }
        }

        void test() {
            this->reset();

            m_core->MEM_data_ready = 1;

            m_core->MEM_ready = 1;
            // LOAD %1, 1
            m_core->MEM_data_in = (8 << 12) | (1 << 9) |  1;
            this->tick();

            this->await_completion();

            m_core->MEM_ready = 1;
            // LOAD %2, 2
            m_core->MEM_data_in = (8 << 12) | (1 << 10) |  2;
            this->tick();

            this->await_completion();

            m_core->MEM_ready = 1;
            // ADD %3, %2, %1
            m_core->MEM_data_in =  (1 << 10) | (1 << 9) | (1 << 6) | (1 << 2);
            this->tick();

            this->await_completion();

            m_core->MEM_ready = 1;
            // WRITE %3
            m_core->MEM_data_in =  (7 << 12) | (3 << 2);
            this->tick();

            await_completion();   

            ASSERT_EQ(m_core->MEM_data_out, 3);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Core_Test_Bench *bench = new Core_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test();

    printf("Success!\n");

    delete bench;
    exit(0);
}
