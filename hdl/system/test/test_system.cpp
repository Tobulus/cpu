#include <stdlib.h>
#include <fstream>
#include "Vsystem.h"
#include "Vuart_rx.h"
#include "Vuart_tx.h"
#include "verilated.h"
#include "testbench.h"

class System_Test_Bench: public TESTBENCH<Vsystem> {

    public:
        void tx_tick(Vuart_tx* tx) {
            tx->I_clk = 0;
            tx->eval();
            tx->I_clk = 1;
            tx->eval();
            tx->I_clk = 0;
            tx->eval();
        }

        void rx_tick(Vuart_rx* rx) {
            rx->I_clk = 0;
            rx->eval();
            rx->I_clk = 1;
            rx->eval();
            rx->I_clk = 0;
            rx->eval();
        }

        void transfer_byte(Vuart_tx* tx, uint8_t byte) {
            tx->I_exec = 0;

            tx_tick(tx);
            this->tick();

            tx->I_data = byte;
            tx->I_exec = 1;

            tx_tick(tx);
            this->tick();
            
            tx->I_exec = 0;

            /* send one byte */
            while (!tx->O_ready) {
                tx_tick(tx);
                this->tick();
                m_core->UART_rx_in_data = tx->O_data; 
            }
        }

        void test_add() {
            Vuart_tx* tx = new Vuart_tx;
            Vuart_rx* rx = new Vuart_rx;

            /* reset UARTs */
            tx->I_reset = 1;
            rx->I_reset = 1;
            rx_tick(rx);
            tx_tick(tx);
            tx->I_reset = 0;
            rx->I_reset = 0;

            /* assemble the multiplication test program */
            system("python3.8 ../../assembler/assembler.py --input test/add.asm --output test/add.bin");

            std::ifstream file;
            std::array<char, 1> bytes;
            file.open("test/add.bin", std::ifstream::in | std::ios::binary);
            m_core->I_reset = 1;
            this->tick();
            m_core->I_reset = 0;
            this->tick();

            /* read the binary test program and send it via the UART to the RAM */
            while (file.read(bytes.data(), bytes.size())) {
                transfer_byte(tx, bytes.at(0));
            }

            file.close();

            /* program is transfered - now tell the bootloader to jump to the
             * beginning of the transfered executable by sending two times 0xFF */

            transfer_byte(tx, 0xFF);
            transfer_byte(tx, 0xFF);

            printf("wait for completion of test program...\n");
            fflush(stdout);

            /* wait for the completion and check the result which was received via UART */
            while (!rx->O_data_ready) {
                rx_tick(rx);    
                this->tick();
                rx->I_data_bit = m_core->UART_tx_out_data;
            }
            
            printf("Done.\n");

            /* add(1,2) == 3 */
            ASSERT_EQ(rx->O_data, 3);
        }
        
        void test_mult() {
            Vuart_tx* tx = new Vuart_tx;
            Vuart_rx* rx = new Vuart_rx;

            /* reset UARTs */
            tx->I_reset = 1;
            rx->I_reset = 1;
            rx_tick(rx);
            tx_tick(tx);
            tx->I_reset = 0;
            rx->I_reset = 0;

            /* assemble the multiplication test program */
            system("python3.8 ../../assembler/assembler.py --input test/mult.asm --output test/mult.bin");

            std::ifstream file;
            std::array<char, 1> bytes;
            file.open("test/mult.bin", std::ifstream::in | std::ios::binary);
            m_core->I_reset = 1;
            this->tick();
            m_core->I_reset = 0;
            this->tick();

            /* read the binary test program and send it via the UART to the RAM */
            while (file.read(bytes.data(), bytes.size())) {
                transfer_byte(tx, bytes.at(0));
            }

            file.close();

            /* program is transfered - now tell the bootloader to jump to the
             * beginning of the transfered executable by sending two times 0xFF */

            transfer_byte(tx, 0xFF);
            transfer_byte(tx, 0xFF);

            printf("wait for completion of test program...\n");
            fflush(stdout);

            /* wait for the completion and check the result which was received via UART */
            while (!rx->O_data_ready) {
                rx_tick(rx);    
                this->tick();
                rx->I_data_bit = m_core->UART_tx_out_data;
            }

            printf("Done.\n");

            /* mult(3,4) == 12 */
            ASSERT_EQ(rx->O_data, 12);
        }
};

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    System_Test_Bench *bench = new System_Test_Bench;
    bench->opentrace("trace.vcd");

    //bench->test_add();
    bench->test_mult();

    printf("Success!\n");

    delete bench;
    exit(0);
}
