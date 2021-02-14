#include <stdlib.h>
#include "Vsystem.h"
#include "verilated.h"
#include "testbench.h"

class System_Test_Bench: public TESTBENCH<Vsystem> {
    
    public:
    
        void test() {
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    System_Test_Bench *bench = new System_Test_Bench;
    bench->opentrace("trace.vcd");

    bench->test();

    printf("Success!\n");

    delete bench;
    exit(0);
}
