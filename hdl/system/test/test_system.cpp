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
		printf("before assemble\n");
		system("python3.8 ../../assembler/assembler.py --input test/mult.asm --output test/mult.bin");
		std::ifstream file;
		std::array<char, 1> bytes;
		printf("before open\n");
		file.open("test/mult.bin", std::ifstream::in | std::ios::binary);
		printf("after open\n");
		m_core->I_reset = 1;
		this->tick();
		m_core->I_reset = 0;
		this->tick();
		
		// send the program
		while (file.read(bytes.data(), bytes.size())) {
			printf("fetch instr to send...\n");
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
			printf("try to send %d\n", bytes.at(0));

			tx->I_clk = 0;
			tx->eval();
			tx->I_clk = 1;
			tx->eval();
			tx->I_clk = 0;
			tx->eval();
			this->tick();

			// send one byte
			while (!tx->O_ready) {
				printf("sending byte\n");
				tx->I_clk = 0;
				tx->eval();
				tx->I_clk = 1;
				tx->eval();
				tx->I_clk = 0;
				tx->eval();

				this->tick();
				printf("setting UART_rx_in_data to %d\n", tx->O_data);
				m_core->UART_rx_in_data = tx->O_data; 
			}
		}
	
		file.close();

		printf("wait for completion of mult()...");
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
		
		// mult(3,4) == 12
		ASSERT_EQ(rx->O_data, 12);
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
