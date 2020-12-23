#include <stdlib.h>
#include "Vmem_ctrl.h"
#include "verilated.h"
#include "testbench.h"

class Mem_Ctrl_Test_Bench : public TESTBENCH<Vmem_ctrl> {
    public:
        void test() {
            m_core->I_exec = 1;   
            m_core->I_write = 1;
            m_core->I_addr = 2;
            m_core->I_data = 3;
            m_core->MEM_ready = 1;

            this->tick();

            ASSERT_EQ(m_core->O_data_ready, 0);
            ASSERT_EQ(m_core->MEM_exec, 1);
            ASSERT_EQ(m_core->MEM_addr, 2);
            ASSERT_EQ(m_core->MEM_data_out, 3);
            ASSERT_EQ(m_core->MEM_write, 1);

            m_core->I_exec = 0;   
            m_core->I_write = 0;
            m_core->I_addr = 0;
            m_core->I_data = 0;
            m_core->MEM_data_ready = 0;

            this->tick();

            ASSERT_EQ(m_core->O_data_ready, 0);
            ASSERT_EQ(m_core->MEM_exec, 0);

            m_core->I_exec = 0;   
            m_core->I_write = 0;
            m_core->I_addr = 0;
            m_core->I_data = 0;
            m_core->MEM_data_ready = 1;

            this->tick();

            ASSERT_EQ(m_core->MEM_exec, 0);
            ASSERT_EQ(m_core->O_ready, 1);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Mem_Ctrl_Test_Bench* bench = new Mem_Ctrl_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test(); 

    printf("Success!\n");

    delete bench;
    exit(0);
}
