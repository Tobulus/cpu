#include <stdlib.h>
#include "Vregister.h"
#include "verilated.h"
#include "testbench.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}

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

                CHECK(m_core->O_rA_out, i,"O_rA_out should be %d but is %d\n", i, m_core->O_rA_out);
                CHECK(m_core->O_rB_out, i,"O_rB_out should be %d but is %d\n", i, m_core->O_rB_out);
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
