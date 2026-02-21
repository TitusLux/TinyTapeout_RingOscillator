![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Tiny Tapeout – Ring Oscillator Counter

This project implements a **5-stage inverter-chain ring oscillator** with an external feedback loop and a digital counter to measure the oscillator frequency. The design demonstrates how process, voltage, and temperature variations affect oscillator frequency on real silicon.

The oscillator is enabled via an input pin, the feedback loop is formed externally using a jumper wire, and the number of oscillator transitions is counted over a fixed measurement window. The result is presented on the output pins.

---

## How it works

- The design contains a **5-stage inverter chain**.
- The oscillator loop is formed **externally** by connecting `uio[0]` (RING_OUT) to `ui[1]` (RING_IN). This avoids internal combinational feedback so the design is compatible with the Tiny Tapeout synthesis flow.
- When `ui[0]` (EN) is high, the inverter chain oscillates due to the odd number of inversions in the loop.
- The oscillator output is synchronized into the system clock domain using a 2-flop synchronizer.
- Both rising and falling edges of the oscillator are counted over a fixed window of **65,536 clock cycles**.
- The latched count is output on `uo_out[7:0]`. This value is proportional to the ring oscillator frequency.

Because the oscillator frequency depends on process, voltage, and temperature, different chips (and even the same chip at different temperatures) will produce different counts.

---

## How to test

### On the Tiny Tapeout demo board

1. Provide a clock on the Tiny Tapeout `clk` pin (from the demo board).
2. Set `ui[0] = 1` to enable the oscillator.
3. Connect `uio[0]` to `ui[1]` with a jumper wire to form the ring oscillator loop.
4. Observe `uo_out[7:0]`, which updates once per measurement window and reflects the oscillator frequency.
5. Try changing temperature (e.g., touch the chip or cool it slightly) and observe changes in the output count.

To disable the oscillator, set `ui[0] = 0`.

### In simulation

The provided cocotb testbench performs basic sanity checks (reset behavior and driven outputs). Because a real ring oscillator relies on analog delay, the RTL simulation does not model the true oscillation behavior. The primary functional validation is intended to be performed on silicon.

---

## Pinout summary

- `ui[0]` – EN (enable ring oscillator)
- `ui[1]` – RING_IN (external feedback input)
- `uio[0]` – RING_OUT (jumper to `ui[1]`)
- `uo_out[7:0]` – COUNT[7:0] (latched edge count per window)

---

## Resources

- Tiny Tapeout: https://tinytapeout.com  
- Docs: https://tinytapeout.com/hdl/testing/  
- LibreLane: https://www.zerotoasiccourse.com/terminology/librelane/
