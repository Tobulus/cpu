#include <stdlib.h>
#include "Vpc.h"
#include "verilated.h"
#include "testbench.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}

class PC_Test_Bench: public TESTBENCH<Vpc> {

    public:

        void test_write_counter(uint8_t counter) {
            m_core->I_in = counter;
            m_core->I_write = 1;
            m_core->I_enable = 1;

            this->tick();

            CHECK(m_core->O_out, counter, "O_out should be %d, but is %d\n", counter, m_core->O_out);
        }

        void test_inc_counter(uint8_t expected) {
            m_core->I_write = 0;
            m_core->I_enable = 1;

            this->tick();

            CHECK(m_core->O_out, expected, "O_out should be %d, but is %d\n", expected, m_core->O_out);
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
