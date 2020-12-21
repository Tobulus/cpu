set -x
rm -rf ./obj_dir
verilator -Wall --trace --cc *.v -I../alu/ -I../register/ -I../mem_ctrl/ -I../ctrl_unit/ -I../pc/ -I../decoder/ --exe test/test_*.cpp -CFLAGS -I../../test
cd obj_dir
make -f Vcore.mk
