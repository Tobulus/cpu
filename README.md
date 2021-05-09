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

# Instruction set

The available instructions and the binary format is defined [here](https://github.com/Tobulus/cpu/blob/main/opcode.txt).

# Memory layout

The relevant memory layout is visualized [here](https://github.com/Tobulus/cpu/blob/main/mmap.txt).
This layout defines where the bootloader and application code is placed in RAM, where the stack starts to grow and where hardware devices are mapped into memory.

# Assembler

The assembler language definition can be found [here](https://github.com/Tobulus/cpu/tree/main/assembler).
Usage examples (*.asm files) can be found in the [system-test](https://github.com/Tobulus/cpu/tree/main/hdl/system/test).

# Bootloader

A UART-bootloader is [available](https://github.com/Tobulus/cpu/tree/main/bootloader), which allows to send arbitrary programs into RAM and execute them.

# Interrupts

The hardware uses a [IVT](https://en.wikipedia.org/wiki/Interrupt_vector_table) to handle interrupt handlers which must located at the beginning of the application code. See [timer.asm](https://github.com/Tobulus/cpu/blob/main/hdl/system/test/timer.asm) or [irq.asm](https://github.com/Tobulus/cpu/blob/main/hdl/system/test/irq.asm) for examples.

| Offset        | Handler  |
| ------------- | -----|
| 0x0           | Reset |
| 0x2           | UART1 |
| 0x4           | Timer1|
