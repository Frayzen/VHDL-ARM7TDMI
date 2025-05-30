# Single-Cycle MIPS Processor (VHDL)

![VHDL](https://img.shields.io/badge/VHDL-IEEE%20STD_1076-blue) 
![ModelSim](https://img.shields.io/badge/Simulator-ModelSim-orange)
![FPGA](https://img.shields.io/badge/Target-FPGA-brightgreen)

## Project Overview
This repository contains a complete implementation of a 32-bit single-cycle MIPS processor in VHDL, developed as part of a digital design course. The processor integrates fundamental computer components including:

- Register file (32 registers)
- Arithmetic Logic Unit (ALU)
- Control unit
- Instruction memory
- Data memory
- Program counter

## Part 3 table

| INSTRUCTION | nPCSel | RegWr | ALUSrc | ALUCtr | PSREn | MemWr | WrSrc | RegSel | RegAff |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **ADDi** | 0 | 1 | 1 | 000 | 0 | 0 | 0 | 0 | 0 |
| **ADDr** | 0 | 1 | 0 | 000 | 0 | 0 | 0 | 0 | 0 |
| **BAL** | 1 | 0 | 0 | 000 | 0 | 0 | 0 | 0 | 0 |
| **BLT** | 0 | 0 | 0 | 000 | 0 | 0 | 0 | 0 | 0 |
| **CMP** | 0 | 0 | 1 | 010 | 1 | 0 | 0 | 0 | 0 |
| **LDR** | 0 | 1 | 1 | 000 | 0 | 0 | 1 | 1 | 0 |
| **MOV** | 0 | 1 | 1 | 001 | 0 | 0 | 0 | 0 | 0 |
| **STR** | 0 | 0 | 1 | 000 | 0 | 1 | 0 | 1 | 1 |

## Key Features
- **MIPS ISA Support**: Implements core instructions (R-type, I-type, J-type) **Pipelined Design**: Single-clock-cycle-per-instruction execution
- **Tested Components**:
  - 32x32-bit register file with dual read ports
  - ALU with 16 operations (AND, OR, ADD, SUB, etc.)
  - Branch prediction unit
- **FPGA Proven**: Synthesizable design tested on Intel/Altera DE10 boards

## Repository Structure

/ARM7TDMI
│
├── /src # VHDL source files
│ ├── TODO # Explain TODO
│ └── TODO # Explain TODO
│
├── /sim # Simulation files
│ ├── TODO # Explain TODO
│ └── TODO # Explain TODO
├── /simu # FPGA project files
│ ├── TODO # Explain TODO
│ └── TODO # Explain TODO
│
└── /docs # Documentation
  ├── TODO # Explain TODO
  └── TODO # Explain TODO

## Simulation & Verification
### Requirements
- ModelSim
- VHDL-2008 compatible simulator
- vhdeps python module to compile

### Running Tests
```bash
# Compile all components
./simu/compile.sh


# Run main testbench
./simu/run_tests.sh

# Debug specific test
./simu/debug.sh # Note that fzf is recommended (but not required)


