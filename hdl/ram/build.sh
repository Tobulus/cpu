set -x
rm -rf ./obj_dir
verilator -Wall --trace --cc *.v --exe test/test_*.cpp
cd obj_dir
make -f Vram.mk
