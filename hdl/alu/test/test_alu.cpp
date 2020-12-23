#include <stdlib.h>
#include "Valu.h"
#include "verilated.h"
#include "testbench.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}

#define CMP_EQ_BIT       0
#define CMP_RA_GT_RB_BIT 1
#define CMP_RB_GT_RA_BIT 2
#define CMP_RA_ZERO_BIT  3
#define CMP_RB_ZERO_BIT  4

class Alu_Test_Bench: public TESTBENCH<Valu> {

    public:

        void test_unsigned_add() {
            m_core->I_enable = 1;

            // addition
            m_core->I_opcode = 0;
            // unsigned mode  
            m_core->I_opcode_mode = 1;

            // two positive operands
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            CHECK(m_core->O_out, 5, "out should be 5 but is %d", m_core->O_out);

            // first operand 0, second positive
            m_core->I_rA = 0;
            m_core->I_rB = 5;

            this->tick();

            CHECK(m_core->O_out, 5, "out should be 5 but is %d", m_core->O_out);

            // first positive, second operand 0
            m_core->I_rA = 5;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 5, "out should be 5 but is %d", m_core->O_out);

            // first operand 0, second operand 0
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 0, "out should be 0 but is %d", m_core->O_out);
        }

        void test_signed_add() {
            m_core->I_enable = 1;

            // addition
            m_core->I_opcode = 0;
            // signed
            m_core->I_opcode_mode = 0;

            // unsigned operands
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            CHECK(m_core->O_out, 5, "out should be 5 but is %d", m_core->O_out);

            // first operand signed, second unsigned
            m_core->I_rA = -3;
            m_core->I_rB = 2;

            this->tick();

            CHECK((signed short)m_core->O_out, -1, "out should be -1 but is %d", m_core->O_out);

            // first operand unsigned, second signed
            m_core->I_rA = 3;
            m_core->I_rB = -2;

            this->tick();

            CHECK(m_core->O_out, 1, "out should be 1 but is %d", m_core->O_out);

            // first operand signed, second 0
            m_core->I_rA = -1;
            m_core->I_rB = 0;

            this->tick();

            CHECK((signed short)m_core->O_out, -1, "out should be -1 but is %d", m_core->O_out);

            // first operand 0, second signed
            m_core->I_rA = 0;
            m_core->I_rB = -1;

            this->tick();

            CHECK((signed short)m_core->O_out, -1, "out should be -1 but is %d", m_core->O_out);

            // first operand signed, second signed
            m_core->I_rA = -2;
            m_core->I_rB = -3;

            this->tick();

            CHECK((signed short)m_core->O_out, -5, "out should be -5 but is %d", m_core->O_out);
        }

        void test_unsigned_sub() {
            m_core->I_enable = 1;

            // subtraction
            m_core->I_opcode = 1;
            // unsigned mode  
            m_core->I_opcode_mode = 1;

            // two positive operands - negative result
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            CHECK((signed short)m_core->O_out, -1, "out should be -1 but is %d", m_core->O_out);

            // two positive operands - positive result
            m_core->I_rA = 3;
            m_core->I_rB = 2;

            this->tick();

            CHECK(m_core->O_out, 1, "out should be 1 but is %d", m_core->O_out);

            // first operand 0, second positive
            m_core->I_rA = 0;
            m_core->I_rB = 5;

            this->tick();

            CHECK((signed short)m_core->O_out, -5, "out should be -5 but is %d", m_core->O_out);

            // first positive, second operand 0
            m_core->I_rA = 5;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 5, "out should be 5 but is %d", m_core->O_out);

            // first operand 0, second operand 0
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 0, "out should be 0 but is %d", m_core->O_out);
        }

        void test_signed_sub() {
            m_core->I_enable = 1;

            // addition
            m_core->I_opcode = 1;
            // signed
            m_core->I_opcode_mode = 0;

            // unsigned operands - negative result
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            CHECK((signed short)m_core->O_out, -1, "out should be -1 but is %d", m_core->O_out);

            // unsigned operands - positive result
            m_core->I_rA = 3;
            m_core->I_rB = 2;

            this->tick();

            CHECK(m_core->O_out, 1, "out should be 1 but is %d", m_core->O_out);

            // first operand signed, second unsigned
            m_core->I_rA = -3;
            m_core->I_rB = 2;

            this->tick();

            CHECK((signed short)m_core->O_out, -5, "out should be -5 but is %d", m_core->O_out);

            // first operand unsigned, second signed
            m_core->I_rA = 3;
            m_core->I_rB = -2;

            this->tick();

            CHECK(m_core->O_out, 5, "out should be 5 but is %d", m_core->O_out);

            // first operand signed, second 0
            m_core->I_rA = -1;
            m_core->I_rB = 0;

            this->tick();

            CHECK((signed short)m_core->O_out, -1, "out should be -1 but is %d", m_core->O_out);

            // first operand 0, second signed
            m_core->I_rA = 0;
            m_core->I_rB = -1;

            this->tick();

            CHECK((signed short)m_core->O_out, 1, "O_out should be 1 but is %d", m_core->O_out);

            // first operand signed, second signed
            m_core->I_rA = -2;
            m_core->I_rB = -3;

            this->tick();

            CHECK((signed short)m_core->O_out, 1, "O_out should be 1 but is %d", m_core->O_out);
        }

        void test_or() {
            m_core->I_enable = 1;

            // OR
            m_core->I_opcode = 2;

            // unsigned operands
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            CHECK(m_core->O_out, (2|3), "O_out should be 3 but is %d", m_core->O_out);

            // 0 as operands
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 0, "O_out should be 0 but is %d", m_core->O_out);
        }

        void test_and() {
            m_core->I_enable = 1;

            // AND
            m_core->I_opcode = 3;

            // unsigned operands - negative result
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            CHECK(m_core->O_out, (2&3), "O_out should be 2 but is %d", m_core->O_out);

            // unsigned operands - positive result
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 0, "O_out should be 0 but is %d", m_core->O_out);
        }

        void test_xor() {
            m_core->I_enable = 1;

            // XOR
            m_core->I_opcode = 4;

            // unsigned operands - negative result
            m_core->I_rA = 1;
            m_core->I_rB = 2;

            this->tick();

            CHECK(m_core->O_out, (1^2), "O_out should be 3 but is %d", m_core->O_out);

            // unsigned operands - positive result
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            CHECK(m_core->O_out, 0, "O_out should be 0 but is %d", m_core->O_out);
        }

        void test_cmp() {
            uint8_t expected;

            m_core->I_enable = 1;
            
            // CMP - two unequal unsigned integers
            m_core->I_opcode = 9;
            m_core->I_opcode_mode = 1;

            m_core->I_rA = 0;
            m_core->I_rB = 1;
            
            this->tick();

            expected = (1 << CMP_RB_GT_RA_BIT) | (1 << CMP_RA_ZERO_BIT);
            CHECK(m_core->O_out, expected, "O_out should be %d but is %d\n", expected, m_core->O_out);
            
            // CMP - two unequal signed integers
            m_core->I_opcode = 9;
            m_core->I_opcode_mode = 0;

            m_core->I_rA = 1;
            m_core->I_rB = -1;
            
            this->tick();

            expected = 1 << CMP_RA_GT_RB_BIT;
            CHECK(m_core->O_out, expected, "O_out should be %d but is %d\n”", expected, m_core->O_out);
        }

};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Alu_Test_Bench *bench = new Alu_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test_unsigned_add();
    bench->test_signed_add();
    bench->test_unsigned_sub();
    bench->test_signed_sub();
    bench->test_or();
    bench->test_and();
    bench->test_xor();
    bench->test_cmp();

    printf("Success!\n");

    delete bench;
    exit(0);
}
