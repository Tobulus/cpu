#include <stdlib.h>
#include "Vregister.h"
#include "verilated.h"
#include "testbench.h"

class Register_Test_Bench: public TESTBENCH<Vregister> {

    public:
        void test_rw_registers() {
            int i;

            m_core->I_enable = 1;
            
            this->reset();

            for (i = 0; i < 8; i++) {
                m_core->I_rD_write = 1;
                m_core->I_rD_select = i;
                m_core->I_rD_in = i;

                this->tick();

                m_core->I_rD_write = 0;
                m_core->I_rA_select = i;
                m_core->I_rB_select = i;

                this->tick();

                ASSERT_EQ(m_core->O_rA_out, i);
                ASSERT_EQ(m_core->O_rB_out, i);
            }
        }

};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Register_Test_Bench *bench = new Register_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test_rw_registers();

    printf("Success!\n");

    delete bench;
    exit(0);
}
