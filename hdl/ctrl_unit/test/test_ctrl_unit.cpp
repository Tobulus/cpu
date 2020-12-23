#include <stdlib.h>
#include "Vctrl_unit.h"
#include "verilated.h"
#include "testbench.h"

class Ctrl_Unit_Test_Bench: public TESTBENCH<Vctrl_unit> {
    public:
        void test() {
            this->reset();

            ASSERT_EQ(m_core->O_state, 1);

            // Fetch - perform memory operation
            m_core->I_mem_ready = 1; 
            m_core->I_reset = 0;
            m_core->I_clk = 1;
            this->tick();

            ASSERT_EQ(m_core->O_state, 1);
            ASSERT_EQ(m_core->O_execute, 1);

            // Fetch - memory operation has been submitted but data is not yet available
            m_core->I_mem_ready = 0; 
            m_core->I_data_ready = 0;
            m_core->I_clk = 1;
            this->tick();

            ASSERT_EQ(m_core->O_state, 1);
            ASSERT_EQ(m_core->O_execute, 0);

            // Fetch - instruction is available
            m_core->I_mem_ready = 0; 
            m_core->I_data_ready = 1;
            m_core->I_clk = 1;
            this->tick();

            ASSERT_EQ(m_core->O_state, 2);
            ASSERT_EQ(m_core->O_execute, 0);

            // Decode 
            m_core->I_clk = 1;
            this->tick();
            ASSERT_EQ(m_core->O_state, 4);

            // Register read 
            m_core->I_clk = 1;
            this->tick();
            ASSERT_EQ(m_core->O_state, 8);

            // Execute
            m_core->I_instruction = 0;
            m_core->I_clk = 1;
            this->tick();
            ASSERT_EQ(m_core->O_state, 32);

            // Register write 
            m_core->I_clk = 1;
            this->tick();
            ASSERT_EQ(m_core->O_state, 1);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Ctrl_Unit_Test_Bench *bench = new Ctrl_Unit_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test();

    printf("Success!\n");

    delete bench;
    exit(0);
}
