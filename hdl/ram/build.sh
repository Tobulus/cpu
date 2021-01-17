set -x
rm -rf ./obj_dir
verilator -Wall --trace --cc *.v --exe test/test_*.cpp -CFLAGS -I../../test
cd obj_dir
make -f Vram.mk
