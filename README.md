# Clock Domain Crossing (CDC) - FIFOs

A professional SystemVerilog repository featuring robust implementations of Synchronous and Asynchronous First-In-First-Out (FIFO) memory buffers. This repository focuses on safe data transfer between different clock domains using dual-clock asynchronous FIFOs and standard single-clock synchronous FIFOs.

## Overview

In digital design, safely transferring data between different clock domains is crucial. This project provides:
*   **Synchronous FIFO (`sync_fifo.sv`)**: A standard FIFO where read and write operations are controlled by the same clock. Useful for buffering data within a single clock domain.
*   **Asynchronous FIFO (`async_fifo.sv`)**: A FIFO designed for Clock Domain Crossing (CDC). It uses two separate clocks (read clock and write clock) and Gray code pointers with 2-stage synchronizers to prevent metastability and safely pass data between asynchronous domains.

## Features

*   **SystemVerilog Implementation**: Modern, synthesis-friendly RTL design.
*   **Configurable Parameters**: Parameterized data width and depth to suit various application needs.
*   **Metastability Mitigation**: 2-stage flip-flop synchronizers employed in the asynchronous FIFO for robust pointer crossing.
*   **Gray Code Pointers**: Minimizes multi-bit switching transitions, ensuring reliable cross-domain synchronization.
*   **Comprehensive Testbenches**: Includes self-checking simulation environments to verify edge cases such as full/empty conditions and concurrent read/write access.

## Directory Structure

```text
.
├── clk_domain_crossing.srcs/
│   ├── sources_1/new/
│   │   ├── async_fifo.sv       # Asynchronous FIFO RTL module
│   │   └── sync_fifo.sv        # Synchronous FIFO RTL module
│   └── sim_1/new/
│       ├── tb_async_fifo.sv    # Testbench for the Asynchronous FIFO
│       ├── tb_sync.sv          # Testbench for the Synchronous FIFO
│       └── tb.sv               # Top-level / Alternative testbench for Sync FIFO
```

## Module Descriptions

### Asynchronous FIFO (`async_fifo.sv`)
A dual-clock FIFO that safely buffers data between a write clock domain (`wclk`) and a read clock domain (`rclk`).
*   **Write Domain**: Manages write pointer (`wptr`), write address (`waddr`), and full flag (`wfull`).
*   **Read Domain**: Manages read pointer (`rptr`), read address (`raddr`), and empty flag (`rempty`).
*   **Synchronization**: Read pointers are converted to Gray code, synchronized into the write domain, and decoded to determine the full status. Similarly, write pointers are synchronized into the read domain to determine the empty status.

#### Parameters:
| Parameter | Default Value | Description |
| :--- | :---: | :--- |
| `DATA_WIDTH` | 8 | The width of the data bus in bits. |
| `ADDR_WIDTH` | 4 | The width of the address bus. Depth is `2^ADDR_WIDTH`. |

### Synchronous FIFO (`sync_fifo.sv`)
A single-clock FIFO for buffering data streams seamlessly without crossing clock domains. It features simplified pointer management utilizing binary arithmetic.

#### Parameters:
| Parameter | Default Value | Description |
| :--- | :---: | :--- |
| `DATA_WIDTH` | 8 | The width of the data bus in bits. |
| `DEPTH` | 8 | The maximum number of entries the FIFO can hold. |

## Testbenches

The `sim_1/new/` directory contains standard testbenches to validate the designs:

*   **`tb_async_fifo.sv`**: Generates independent, asynchronous read and write clocks. It pushes data until the FIFO is full, waits, and then pops data until the FIFO is empty. Verifies the proper assertion of `wfull` and `rempty` flags across clock domains.
*   **`tb_sync.sv` / `tb.sv`**: Validates the synchronous FIFO through sequences of single writes, single reads, multiple writes/reads, burst fills to trigger the overflow flag, and completely draining the FIFO. Includes formatted console output for easy debugging.

## Getting Started

### Prerequisites
To simulate or synthesize these modules, you need an HDL simulator or synthesis tool that supports SystemVerilog (IEEE 1800-2012 or later). Common tools include:
*   AMD Vivado™ Design Suite
*   Intel® Quartus® Prime
*   Synopsys VCS
*   Siemens Questa Advanced Simulator / ModelSim
*   Verilator (for cycle-accurate C++ simulation)
*   Icarus Verilog (if SV support is enabled)

### Running Simulations
If you are using Vivado, you can open the project (`.xpr` file if available) or create a new project, add the files in `sources_1` and `sim_1`, and run the behavioral simulation.

For command-line simulators (e.g., using a generic tool):
```bash
# Example for testing Sync FIFO
vcs -sverilog clk_domain_crossing.srcs/sources_1/new/sync_fifo.sv clk_domain_crossing.srcs/sim_1/new/tb_sync.sv
./simv

# Example for testing Async FIFO
vcs -sverilog clk_domain_crossing.srcs/sources_1/new/async_fifo.sv clk_domain_crossing.srcs/sim_1/new/tb_async_fifo.sv
./simv
```

## License
Please refer to the repository owner for licensing information.
