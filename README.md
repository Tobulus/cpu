# Introduction

This project is about achieving the basic knowledge how a computer really works by designing the hardware and all tooling/software on top of that.

This requires:
* Hardware modeled in Verilog
* An assembler for really low-level work which just saves us from writing 0's and 1's
* A UART bootloader which allows us to bootstrap the system
* A compiler to speed up software development
* A operating system

The idea comes from the outlining in ['From the transistor'](https://github.com/geohot/fromthetransistor)

As everyone should be able to try this out without buying expensive hardware like a FPGA we will use the great [Verilator](https://www.veripool.org/wiki/verilator) to simulate our hardware model.
