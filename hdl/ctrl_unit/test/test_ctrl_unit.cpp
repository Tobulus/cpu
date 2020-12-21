#include <stdlib.h>
#include "Vctrl_unit.h"
#include "verilated.h"
#include "testbench.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}

class Ctrl_Unit_Test_Bench: public TESTBENCH<Vctrl_unit> {
    public:
        void test() {
            this->reset();

            CHECK(m_core->O_state, 1, "State should be 1 after I_reset");

            // Fetch - perform memory operation
            m_core->I_mem_ready = 1; 
            m_core->I_reset = 0;
            m_core->I_clk = 1;
            this->tick();

            CHECK(m_core->O_state, 1, "State should be 1 but is %d", m_core->O_state);
            CHECK(m_core->O_execute, 1, "O_execute should be 1 but is %d", m_core->O_execute);

            // Fetch - memory operation has been submitted but data is not yet available
            m_core->I_mem_ready = 0; 
            m_core->I_data_ready = 0;
            m_core->I_clk = 1;
            this->tick();

            CHECK(m_core->O_state, 1, "State should be 1 but is %d", m_core->O_state);
            CHECK(m_core->O_execute, 0, "O_execute should be 0 but is %d", m_core->O_execute);

            // Fetch - instruction is available
            m_core->I_mem_ready = 0; 
            m_core->I_data_ready = 1;
            m_core->I_clk = 1;
            this->tick();

            CHECK(m_core->O_state, 2, "State should be 1 but is %d", m_core->O_state);
            CHECK(m_core->O_execute, 0, "O_execute should be 0 but is %d", m_core->O_execute);

            // Decode 
            m_core->I_clk = 1;
            this->tick();
            CHECK(m_core->O_state, 4, "State should be 4 but is %d", m_core->O_state);

            // Register read 
            m_core->I_clk = 1;
            this->tick();
            CHECK(m_core->O_state, 8, "State should be 8 but is %d", m_core->O_state);

            // Execute
            m_core->I_instruction = 0;
            m_core->I_clk = 1;
            this->tick();
            CHECK(m_core->O_state, 32, "State should be 32 but is %d", m_core->O_state);

            // Register write 
            m_core->I_clk = 1;
            this->tick();
            CHECK(m_core->O_state, 1, "State should be 1 but is %d", m_core->O_state);
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
