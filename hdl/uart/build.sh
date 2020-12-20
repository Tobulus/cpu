set -x
rm -rf ./obj_dir
verilator -Wall --cc uart_rx.v
verilator -Wall --cc uart_tx.v --exe test/test_uart.cpp Vuart_rx__ALL.a
cd obj_dir
make -f Vuart_rx.mk
make -f Vuart_tx.mk
