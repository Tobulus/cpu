#include <stdlib.h>
#include "Vpc.h"
#include "verilated.h"
#include "testbench.h"

class PC_Test_Bench: public TESTBENCH<Vpc> {

    public:

        void test_write_counter(uint8_t counter) {
            m_core->I_in = counter;
            m_core->I_write = 1;
            m_core->I_enable = 1;

            this->tick();

            ASSERT_EQ(m_core->O_out, counter);
        }

        void test_inc_counter(uint8_t expected) {
            m_core->I_write = 0;
            m_core->I_enable = 1;

            this->tick();

            ASSERT_EQ(m_core->O_out, expected);
        }

};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    PC_Test_Bench *bench = new PC_Test_Bench();
    int i;

    bench->opentrace("trace.vcd");

    for (i = 0; i < 100; i++) {
        bench->test_write_counter(i);
    }

    bench->test_write_counter(0);

    for (i = 1; i < 100; i++) {
        bench->test_inc_counter(i);
    }

    printf("Success!\n");

    delete bench;
    exit(0);
}
