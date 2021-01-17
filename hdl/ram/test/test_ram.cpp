#include <stdlib.h>
#include "Vram.h"
#include "verilated.h"
#include "testbench.h"

class Ram_Test_Bench: public TESTBENCH<Vram> {
    public:
        void test_ram() {
            m_core->I_enable = 1;

            // write one byte
            m_core->I_size = 1;
            m_core->I_write = 1;
            m_core->I_addr = 0;
            m_core->I_data_in = 11;

            this->tick();

            // read the written byte
            m_core->I_size = 1;
            m_core->I_write = 0;
            m_core->I_addr = 0;

            this->tick();

            ASSERT_EQ(m_core->O_data_out, 11);
            
            // write two byte
            m_core->I_size = 2;
            m_core->I_write = 1;
            m_core->I_addr = 4;
            m_core->I_data_in = 355;

            this->tick();

            // read the two written bytes
            m_core->I_size = 2;
            m_core->I_write = 0;
            m_core->I_addr = 4;

            this->tick();

            ASSERT_EQ(m_core->O_data_out, 355);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Ram_Test_Bench *bench = new Ram_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test_ram();

    printf("Success!\n");

    delete bench;
    exit(0);
}
