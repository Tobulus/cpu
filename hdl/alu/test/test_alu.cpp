#include <stdlib.h>
#include "Valu.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() alu->I_clk = 0;alu->eval();

void test_unsigned_add(Valu* alu) {
   // addition
   alu->I_opcode = 0;
   // unsigned mode  
   alu->I_opcode_mode = 1;

   // two positive operands
   alu->I_clk = 1;
   alu->I_rA = 2;
   alu->I_rB = 3;

   alu->eval();

   CHECK(alu->O_out, 5, "out should be 5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand 0, second positive
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 5;

   alu->eval();

   CHECK(alu->O_out, 5, "out should be 5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first positive, second operand 0
   alu->I_clk = 1;
   alu->I_rA = 5;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 5, "out should be 5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand 0, second operand 0
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 0, "out should be 0 but is %d", alu->O_out);
   NOP_CYCLE();
}

void test_signed_add(Valu* alu) {
   // addition
   alu->I_opcode = 0;
   // signed
   alu->I_opcode_mode = 0;

   // unsigned operands
   alu->I_clk = 1;
   alu->I_rA = 2;
   alu->I_rB = 3;

   alu->eval();

   CHECK(alu->O_out, 5, "out should be 5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand signed, second unsigned
   alu->I_clk = 1;
   alu->I_rA = -3;
   alu->I_rB = 2;

   alu->eval();

   CHECK((signed short)alu->O_out, -1, "out should be -1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand unsigned, second signed
   alu->I_clk = 1;
   alu->I_rA = 3;
   alu->I_rB = -2;

   alu->eval();

   CHECK(alu->O_out, 1, "out should be 1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand signed, second 0
   alu->I_clk = 1;
   alu->I_rA = -1;
   alu->I_rB = 0;

   alu->eval();

   CHECK((signed short)alu->O_out, -1, "out should be -1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand 0, second signed
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = -1;

   alu->eval();

   CHECK((signed short)alu->O_out, -1, "out should be -1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand signed, second signed
   alu->I_clk = 1;
   alu->I_rA = -2;
   alu->I_rB = -3;

   alu->eval();

   CHECK((signed short)alu->O_out, -5, "out should be -5 but is %d", alu->O_out);
   NOP_CYCLE();
}

void test_unsigned_sub(Valu* alu) {
   // subtraction
   alu->I_opcode = 1;
   // unsigned mode  
   alu->I_opcode_mode = 1;

   // two positive operands - negative result
   alu->I_clk = 1;
   alu->I_rA = 2;
   alu->I_rB = 3;

   alu->eval();

   CHECK((signed short)alu->O_out, -1, "out should be -1 but is %d", alu->O_out);
   NOP_CYCLE();

   // two positive operands - positive result
   alu->I_clk = 1;
   alu->I_rA = 3;
   alu->I_rB = 2;

   alu->eval();

   CHECK(alu->O_out, 1, "out should be 1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand 0, second positive
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 5;

   alu->eval();

   CHECK((signed short)alu->O_out, -5, "out should be -5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first positive, second operand 0
   alu->I_clk = 1;
   alu->I_rA = 5;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 5, "out should be 5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand 0, second operand 0
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 0, "out should be 0 but is %d", alu->O_out);
   NOP_CYCLE();
}

void test_signed_sub(Valu* alu) {
   // addition
   alu->I_opcode = 1;
   // signed
   alu->I_opcode_mode = 0;

   // unsigned operands - negative result
   alu->I_clk = 1;
   alu->I_rA = 2;
   alu->I_rB = 3;

   alu->eval();

   CHECK((signed short)alu->O_out, -1, "out should be -1 but is %d", alu->O_out);
   NOP_CYCLE();

   // unsigned operands - positive result
   alu->I_clk = 1;
   alu->I_rA = 3;
   alu->I_rB = 2;

   alu->eval();

   CHECK(alu->O_out, 1, "out should be 1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand signed, second unsigned
   alu->I_clk = 1;
   alu->I_rA = -3;
   alu->I_rB = 2;

   alu->eval();

   CHECK((signed short)alu->O_out, -5, "out should be -5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand unsigned, second signed
   alu->I_clk = 1;
   alu->I_rA = 3;
   alu->I_rB = -2;

   alu->eval();

   CHECK(alu->O_out, 5, "out should be 5 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand signed, second 0
   alu->I_clk = 1;
   alu->I_rA = -1;
   alu->I_rB = 0;

   alu->eval();

   CHECK((signed short)alu->O_out, -1, "out should be -1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand 0, second signed
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = -1;

   alu->eval();

   CHECK((signed short)alu->O_out, 1, "O_out should be 1 but is %d", alu->O_out);
   NOP_CYCLE();

   // first operand signed, second signed
   alu->I_clk = 1;
   alu->I_rA = -2;
   alu->I_rB = -3;

   alu->eval();

   CHECK((signed short)alu->O_out, 1, "O_out should be 1 but is %d", alu->O_out);
   NOP_CYCLE();
}

void test_or(Valu* alu) {
   // OR
   alu->I_opcode = 2;

   // unsigned operands
   alu->I_clk = 1;
   alu->I_rA = 2;
   alu->I_rB = 3;

   alu->eval();

   CHECK(alu->O_out, (2|3), "O_out should be 3 but is %d", alu->O_out);
   NOP_CYCLE();

   // 0 as operands
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 0, "O_out should be 0 but is %d", alu->O_out);
   NOP_CYCLE();
}

void test_and(Valu* alu) {
   // AND
   alu->I_opcode = 3;

   // unsigned operands - negative result
   alu->I_clk = 1;
   alu->I_rA = 2;
   alu->I_rB = 3;

   alu->eval();

   CHECK(alu->O_out, (2&3), "O_out should be 2 but is %d", alu->O_out);
   NOP_CYCLE();

   // unsigned operands - positive result
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 0, "O_out should be 0 but is %d", alu->O_out);
   NOP_CYCLE();
}


void test_xor(Valu* alu) {
   // XOR
   alu->I_opcode = 4;

   // unsigned operands - negative result
   alu->I_clk = 1;
   alu->I_rA = 1;
   alu->I_rB = 2;

   alu->eval();

   CHECK(alu->O_out, (1^2), "O_out should be 3 but is %d", alu->O_out);
   NOP_CYCLE();

   // unsigned operands - positive result
   alu->I_clk = 1;
   alu->I_rA = 0;
   alu->I_rB = 0;

   alu->eval();

   CHECK(alu->O_out, 0, "O_out should be 0 but is %d", alu->O_out);
   NOP_CYCLE();
}



int main(int argc, char** argv, char** env) {
   Verilated::commandArgs(argc, argv);
   Valu* alu = new Valu;
   
   alu->I_enable = 1;

   test_unsigned_add(alu);
   test_signed_add(alu);
   test_unsigned_sub(alu);
   test_signed_sub(alu);
   test_or(alu);
   test_and(alu);
   test_xor(alu);

   printf("Success!\n");

   delete alu;
   exit(0);
}
