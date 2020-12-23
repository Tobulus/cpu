#include <stdlib.h>
#include "Vuart_rx.h"
#include "Vuart_tx.h"
#include "verilated.h"
#include "testbench.h"

class Uart_Test_Bench: public TESTBENCH<Vuart_rx> {
    public:

        void dump_state(Vuart_tx *tx) {
            printf("tx-state: %d, count:%d, O_data:%d\n", tx->v__DOT__state, tx->v__DOT__clk_count, tx->O_data); 
            printf("rx-state: %d, count:%d, I_data_bit:%d, buffer:%d\n", m_core->v__DOT__state, m_core->v__DOT__clk_count, m_core->I_data_bit, m_core->v__DOT__buffer); 
        }

        void test_send_recv() {
            Vuart_tx* tx = new Vuart_tx;

            this->reset();
            tx->I_clk = 1;
            tx->I_reset = 1;
            tx->eval();

            tx->I_reset = 0;
            uint8_t data = 5;
            tx->I_data = data;
            tx->I_exec = 1;

            while (m_core->O_data_ready != 1) {
                dump_state(tx);

                tx->I_clk = 0;
                tx->eval();
                tx->I_clk = 1;
                tx->eval();
                tx->I_clk = 0;
                tx->eval();

                this->tick();

                m_core->I_data_bit = tx->O_data;
            }

            ASSERT_EQ(m_core->O_data, 5);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Uart_Test_Bench *bench = new Uart_Test_Bench; 

    bench->test_send_recv();

    printf("Success!\n");

    delete bench;
    exit(0);
}
