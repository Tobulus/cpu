#include <stdlib.h>
#include "Vbootrom.h"
#include "verilated.h"
#include "testbench.h"

class Bootrom_Test_Bench: public TESTBENCH<Vbootrom> {
    public:
        void test_bootrom() {
            m_core->I_enable = 1;
            m_core->I_addr = 0;

            this->tick();

            ASSERT_EQ(m_core->O_data_out, 0x8000);

            m_core->I_addr = 2;

            this->tick();

            ASSERT_EQ(m_core->O_data_out, 0x8c00);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Bootrom_Test_Bench *bench = new Bootrom_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test_bootrom();

    printf("Success!\n");

    delete bench;
    exit(0);
}
