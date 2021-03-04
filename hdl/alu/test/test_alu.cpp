#include <stdlib.h>
#include "Valu.h"
#include "verilated.h"
#include "testbench.h"

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

            ASSERT_EQ(m_core->O_out, 5);

            // first operand 0, second positive
            m_core->I_rA = 0;
            m_core->I_rB = 5;

            this->tick();

            ASSERT_EQ(m_core->O_out, 5);

            // first positive, second operand 0
            m_core->I_rA = 5;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 5);

            // first operand 0, second operand 0
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 0);
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

            ASSERT_EQ(m_core->O_out, 5);

            // first operand signed, second unsigned
            m_core->I_rA = -3;
            m_core->I_rB = 2;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -1);

            // first operand unsigned, second signed
            m_core->I_rA = 3;
            m_core->I_rB = -2;

            this->tick();

            ASSERT_EQ(m_core->O_out, 1);

            // first operand signed, second 0
            m_core->I_rA = -1;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -1);

            // first operand 0, second signed
            m_core->I_rA = 0;
            m_core->I_rB = -1;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -1);

            // first operand signed, second signed
            m_core->I_rA = -2;
            m_core->I_rB = -3;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -5);
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

            ASSERT_EQ((signed short)m_core->O_out, -1);

            // two positive operands - positive result
            m_core->I_rA = 3;
            m_core->I_rB = 2;

            this->tick();

            ASSERT_EQ(m_core->O_out, 1);

            // first operand 0, second positive
            m_core->I_rA = 0;
            m_core->I_rB = 5;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -5);

            // first positive, second operand 0
            m_core->I_rA = 5;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 5);

            // first operand 0, second operand 0
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 0);
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

            ASSERT_EQ((signed short)m_core->O_out, -1);

            // unsigned operands - positive result
            m_core->I_rA = 3;
            m_core->I_rB = 2;

            this->tick();

            ASSERT_EQ(m_core->O_out, 1);

            // first operand signed, second unsigned
            m_core->I_rA = -3;
            m_core->I_rB = 2;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -5);

            // first operand unsigned, second signed
            m_core->I_rA = 3;
            m_core->I_rB = -2;

            this->tick();

            ASSERT_EQ(m_core->O_out, 5);

            // first operand signed, second 0
            m_core->I_rA = -1;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, -1);

            // first operand 0, second signed
            m_core->I_rA = 0;
            m_core->I_rB = -1;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, 1);

            // first operand signed, second signed
            m_core->I_rA = -2;
            m_core->I_rB = -3;

            this->tick();

            ASSERT_EQ((signed short)m_core->O_out, 1);
        }

        void test_or() {
            m_core->I_enable = 1;

            // OR
            m_core->I_opcode = 2;

            // unsigned operands
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            ASSERT_EQ(m_core->O_out, (2|3));

            // 0 as operands
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 0);
        }

        void test_and() {
            m_core->I_enable = 1;

            // AND
            m_core->I_opcode = 3;

            // unsigned operands - negative result
            m_core->I_rA = 2;
            m_core->I_rB = 3;

            this->tick();

            ASSERT_EQ(m_core->O_out, (2&3));

            // unsigned operands - positive result
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 0);
        }

        void test_xor() {
            m_core->I_enable = 1;

            // XOR
            m_core->I_opcode = 4;

            // unsigned operands - negative result
            m_core->I_rA = 1;
            m_core->I_rB = 2;

            this->tick();

            ASSERT_EQ(m_core->O_out, (1^2));

            // unsigned operands - positive result
            m_core->I_rA = 0;
            m_core->I_rB = 0;

            this->tick();

            ASSERT_EQ(m_core->O_out, 0);
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
            ASSERT_EQ(m_core->O_out, expected);

            // CMP - two unequal signed integers
            m_core->I_opcode = 9;
            m_core->I_opcode_mode = 0;

            m_core->I_rA = 1;
            m_core->I_rB = -1;

            this->tick();

            expected = 1 << CMP_RA_GT_RB_BIT;
            ASSERT_EQ(m_core->O_out, expected);
        }

        void test_jmp() {
            m_core->I_enable = 1;
            m_core->I_opcode = 11;
            m_core->I_opcode_mode = 0;
            m_core->I_pc = 1;
            m_core->I_immediate = 5;

            this->tick();

            ASSERT_EQ(m_core->O_out, 6);

            m_core->I_opcode_mode = 0;
            m_core->I_pc = 5;
            m_core->I_immediate = -2;

            this->tick();

            ASSERT_EQ(m_core->O_out, 3);
            
	    m_core->I_opcode_mode = 1;
            m_core->I_pc = 5;
	    m_core->I_rA = 4;
            m_core->I_immediate = -2;

            this->tick();

            ASSERT_EQ(m_core->O_out, 4);

	    m_core->I_opcode_mode = 0;
	    m_core->I_opcode = 0xC;
	    m_core->I_rA = 1;

	    this->tick();

	    ASSERT_EQ(m_core->O_write_pc, 1);
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
    bench->test_jmp();

    printf("Success!\n");

    delete bench;
    exit(0);
}
