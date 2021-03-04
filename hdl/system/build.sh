set -x
rm -rf ./obj_dir
verilator -Wall --trace --cc *.v -I../alu/ -I../core/ -I../ram/ -I../register/ -I../mem_ctrl/ -I../ctrl_unit/ -I../pc/ -I../decoder/ -I../uart/ --exe test/test_*.cpp -CFLAGS -I../../test -CFLAGS -I../../uart/obj_dir -LDFLAGS "-L../../uart/obj_dir -l:Vuart_rx__ALL.a -l:Vuart_tx__ALL.a"
cd obj_dir
make -f Vsystem.mk
