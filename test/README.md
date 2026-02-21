# Tiny Tapeout Ring Oscillator – Testbench

This is the testbench for the **Tiny Tapeout Ring Oscillator** project.  
It uses [cocotb](https://docs.cocotb.org/en/stable/) to drive the DUT and perform basic sanity checks.

Because this design contains a **real ring oscillator (combinational feedback loop)**, the RTL simulation does not model the true analog oscillation behavior. The cocotb test focuses on:

- Reset behavior  
- Pin connectivity  
- Ensuring outputs are driven (not X/Z)

For more info on Tiny Tapeout testing, see:  
https://tinytapeout.com/hdl/testing/

---

## Setting up

1. Edit `test/Makefile` and modify `PROJECT_SOURCES` to point to your Verilog file:
   ```makefile
   PROJECT_SOURCES = ../src/tt_um_tituslux_ringosc.v

2. Edit `test/tb.v` and make sure the DUT matches your module name:

```verilog
tt_um_tituslux_ringosc user_project ( ... );


## How to run

To run the RTL simulation:

```sh
cd test
make
```

To run gatelevel simulation, first harden your project and copy `../runs/wokwi/results/final/verilog/gl/tt_um_tituslux_ringosc.v` to `gate_level_netlist.v`.

Then run:

```sh
cd test
make -B GATES=yes
```

If you wish to save the waveform in VCD format instead of FST format, edit tb.v to use `$dumpfile("tb.vcd");` and then run:

```sh
cd test
make -B FST=
```

This will generate `tb.vcd` instead of `tb.fst`.

## How to view the waveform file

Using GTKWave

```sh
gtkwave tb.fst tb.gtkw
```

Using Surfer

```sh
surfer tb.fst
```
