#include <stdlib.h>
#include "Vuart_rx.h"
#include "Vuart_tx.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define CHECK(var, val, ...) if(var!=val){printf(__VA_ARGS__);exit(1);}
#define NOP_CYCLE() tx->I_clk=0;rx->I_clk=0;tx->eval();rx->eval();

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vuart_rx* rx = new Vuart_rx; 
    Vuart_tx* tx = new Vuart_tx;

    rx->I_reset = 1;
    tx->I_reset = 1;
    rx->I_clk = 1;
    tx->I_clk = 1;

    rx->eval();
    tx->eval();

    rx->I_reset = 0;
    tx->I_reset = 0;

    NOP_CYCLE();

    // send data
    uint8_t data = 5;
    tx->I_data = data;
    tx->I_exec = 1;

    while (rx->O_data_ready != 1) {
        printf("tx-state: %d, count:%d, O_data:%d\n", tx->v__DOT__state, tx->v__DOT__clk_count, tx->O_data); 
        printf("rx-state: %d, count:%d, I_data_bit:%d, buffer:%d\n", rx->v__DOT__state, rx->v__DOT__clk_count, rx->I_data_bit, rx->v__DOT__buffer); 
        tx->I_clk = 1;
        rx->I_clk = 1;
        tx->eval();
        rx->eval();

        rx->I_data_bit = tx->O_data;

        NOP_CYCLE();
    }

    CHECK(rx->O_data, 5, "Data should be 5 but received %d", rx->O_data);

    printf("Success!\n");

    delete rx;
    delete tx;
    exit(0);
}
