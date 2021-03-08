#include <stdlib.h>
#include <fstream>
#include "Vsystem.h"
#include "Vuart_rx.h"
#include "Vuart_tx.h"
#include "verilated.h"
#include "testbench.h"

class System_Test_Bench: public TESTBENCH<Vsystem> {
    
    public:
    
        void test() {
		Vuart_tx* tx = new Vuart_tx;
		Vuart_rx* rx = new Vuart_rx;
		tx->I_reset = 1;
		rx->I_reset = 1;
		tx->eval();
		rx->eval();
		tx->I_reset = 0;
		rx->I_reset = 0;

		/* assemble the multiplication test program */
		//printf("before assemble\n");
		system("python3.8 ../../assembler/assembler.py --input test/add.asm --output test/add.bin");
		std::ifstream file;
		std::array<char, 1> bytes;
		//printf("before open\n");
		file.open("test/add.bin", std::ifstream::in | std::ios::binary);
		//printf("after open\n");
		m_core->I_reset = 1;
		this->tick();
		m_core->I_reset = 0;
		this->tick();
		
		// send the program
		while (file.read(bytes.data(), bytes.size())) {
			//printf("fetch instr to send...\n");
			tx->I_exec = 0;
			
			tx->I_clk = 0;
			tx->eval();
			tx->I_clk = 1;
			tx->eval();
			tx->I_clk = 0;
			tx->eval();
			
			this->tick();

			/*while (!m_core->UART_rx_ready) {
				printf("waiting for rx ready\n");
				tx->I_clk = 0;
				tx->eval();
				tx->I_clk = 1;
				tx->eval();
				tx->I_clk = 0;
				tx->eval();

				this->tick();
			}*/

			tx->I_data = bytes.at(0);
			tx->I_exec = 1;
			//printf("try to send %d\n", bytes.at(0));

			tx->I_clk = 0;
			tx->eval();
			tx->I_clk = 1;
			tx->eval();
			tx->I_clk = 0;
			tx->eval();
			this->tick();

			// send one byte
			while (!tx->O_ready) {
				//printf("sending byte\n");
				tx->I_clk = 0;
				tx->eval();
				tx->I_clk = 1;
				tx->eval();
				tx->I_clk = 0;
				tx->eval();

				this->tick();
				//printf("setting UART_rx_in_data to %d\n", tx->O_data);
				m_core->UART_rx_in_data = tx->O_data; 
			}
		}
		file.close();

		printf("send finish command to the bootloader");
		tx->I_data = 255;
		tx->I_exec = 1;

		// first 'end' byte -> 0xFF
		tx->I_clk = 0;
		tx->eval();
		tx->I_clk = 1;
		tx->eval();
		tx->I_clk = 0;
		tx->eval();
		this->tick();

		while (!tx->O_ready) {
			printf("sending byte\n");
			tx->I_clk = 0;
			tx->eval();
			tx->I_clk = 1;
			tx->eval();
			tx->I_clk = 0;
			tx->eval();

			this->tick();
			m_core->UART_rx_in_data = tx->O_data; 
		}

		printf("send second 'end' byte");
		tx->I_data = 255;
		tx->I_exec = 1;

		// second 'end' byte -> 0xFF
		tx->I_clk = 0;
		tx->eval();
		tx->I_clk = 1;
		tx->eval();
		tx->I_clk = 0;
		tx->eval();
		this->tick();
		printf("internal buffer=%d", tx->uart_tx__DOT__buffer);
		while (!tx->O_ready) {
			printf("sending byte\n");
			fflush(stdout);
			tx->I_clk = 0;
			tx->eval();
			tx->I_clk = 1;
			tx->eval();
			tx->I_clk = 0;
			tx->eval();

			this->tick();
			printf("tx state=%d", tx->uart_tx__DOT__state);
			printf("rx state=%d", m_core->system__DOT__uart_rx__DOT__state);
			printf("out=%d", tx->O_data);
			printf("tx-clkcount=%d", tx->uart_tx__DOT__clk_count);
			printf("rx-clkcount=%d", m_core->system__DOT__uart_rx__DOT__clk_count);
			m_core->UART_rx_in_data = tx->O_data; 
		}
		tx->I_clk = 0;
		tx->eval();
		tx->I_clk = 1;
		tx->eval();
		tx->I_clk = 0;
		tx->eval();
		this->tick();
		while (!tx->O_ready) {
			printf("sending byte\n");
			fflush(stdout);
			tx->I_clk = 0;
			tx->eval();
			tx->I_clk = 1;
			tx->eval();
			tx->I_clk = 0;
			tx->eval();

			this->tick();
			printf("tx state=%d", tx->uart_tx__DOT__state);
			printf("rx state=%d", m_core->system__DOT__uart_rx__DOT__state);
			printf("out=%d", tx->O_data);
			printf("tx-clkcount=%d", tx->uart_tx__DOT__clk_count);
			printf("rx-clkcount=%d", m_core->system__DOT__uart_rx__DOT__clk_count);
			m_core->UART_rx_in_data = tx->O_data; 
		}

		printf("finished send end command");
		fflush(stdout);
		tx->I_exec = 0;

		tx->I_clk = 0;
		tx->eval();
		tx->I_clk = 1;
		tx->eval();
		tx->I_clk = 0;
		tx->eval();
		this->tick();
		printf("wait for completion of add()...");
		fflush(stdout);
		// wait for the completion and check the result
		while (!rx->O_data_ready) {	
			rx->I_clk = 0;
			rx->eval();
			rx->I_clk = 1;
			rx->eval();
			rx->I_clk = 0;
			rx->eval();
			this->tick();

			rx->I_data_bit = m_core->UART_tx_out_data;
		}
		
		// add(1,2) == 3
		ASSERT_EQ(rx->O_data, 3);
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
