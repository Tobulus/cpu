#include <stdlib.h>
#include "Vdecoder.h"
#include "verilated.h"
#include "testbench.h"

class Decoder_Test_Bench: public TESTBENCH<Vdecoder> {
    public:
        void test_decode() {
            m_core->I_enable = 1;
            m_core->I_instruction = (1 << 12) | (1 << 10) | (1 << 7) | (1 << 2);

            this->tick();

            ASSERT_EQ(m_core->O_opcode, 1);
            ASSERT_EQ(m_core->O_rA_select, 4);
            ASSERT_EQ(m_core->O_rB_select, 1);
            ASSERT_EQ(m_core->O_rD_select, 2);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Decoder_Test_Bench *bench = new Decoder_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test_decode();

    printf("Success!\n");

    delete bench;
    exit(0);
}
