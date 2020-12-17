set -x
rm -rf ./obj_dir
verilator -Wall --cc *.v -I../alu/ -I../core/ -I../ram/ -I../register/ -I../mem_ctrl/ -I../ctrl_unit/ -I../pc/ -I../decoder/ --exe test/test_*.cpp
cd obj_dir
make -f Vcore.mk
