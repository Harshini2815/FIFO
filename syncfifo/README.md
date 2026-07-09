# Synchronous FIFO in Verilog

A parameterized **Synchronous FIFO** implemented in Verilog with configurable data width and FIFO depth. The repository also includes three testbenches covering basic functionality, randomized verification, and concurrent read/write operations.

## Prerequisites

Install the following tools:

- Icarus Verilog (`iverilog`)
- GTKWave (`gtkwave`)

Ubuntu:

```bash
sudo apt update
sudo apt install iverilog gtkwave
```

## Running the Simulations

Compile the design with the required testbench:

```bash
iverilog -g2012 -o simtest syncfifo.v test/test.v
```

Run the simulation:

```bash
vvp simtest
```

Open the generated waveform:

```bash
gtkwave dump.vcd
```

To run a different testbench, simply replace `test.v` with `test_v1.sv` or `test_v2.sv` in the compile command.

## Testbenches

- **test.v** – Verifies sequential write and read operations along with full and empty flag behavior.
- **test_v1.sv** – Performs randomized verification using a SystemVerilog queue as a golden reference model.
- **test_v2.sv** – Exercises concurrent write and read operations to validate FIFO behavior under simultaneous access.