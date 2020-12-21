#include <stdlib.h>
#include "Vdecoder.h"
#include "verilated.h"
#include "testbench.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}

class Decoder_Test_Bench: public TESTBENCH<Vdecoder> {
    public:
        void test_decode() {
            m_core->I_enable = 1;
            m_core->I_instruction = (1 << 12) | (1 << 10) | (1 << 7) | (1 << 2);

            this->tick();

            CHECK(m_core->O_opcode, 1, "O_opcode should be 1, but is %d\n", m_core->O_opcode);
            CHECK(m_core->O_rA_select, 4, "O_rA_select should be 4, but is %d\n", m_core->O_rA_select);
            CHECK(m_core->O_rB_select, 1, "O_rB_select should be 1, but is %d\n", m_core->O_rB_select);
            CHECK(m_core->O_rD_select, 2, "O_rD_select should be 2, but is %d\n", m_core->O_rD_select);
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
