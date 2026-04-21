<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a 21-stage inverter chain ring oscillator whose feedback loop is formed externally using the Tiny Tapeout I/O pins. When enabled, the inverter chain oscillates due to the odd number of inversions in the loop.

The ring oscillator output is synchronized into the system clock domain using a two-flip-flop synchronizer. The design counts the number of output transitions (both rising and falling edges) over a fixed window of 65,536 system clock cycles. The latched count provides a digital measurement proportional to the ring oscillator frequency, which varies with process, voltage, and temperature (PVT).

The measured count is presented on `uo_out[7:0]`. A byte-select mode allows different bytes of the 32-bit latched count to be observed. Because the oscillator loop is formed externally, the design avoids internal combinational feedback and is compatible with the Tiny Tapeout synthesis flow.

## How to test

1. Provide a clock on the Tiny Tapeout `clk` pin (from the demo board).
2. Set `ui[0] = 1` to enable the inverter chain.
4. Optional: Set `ui[2] = 0` to view the default middle byte `([23:16])`, or Set `ui[2] = 1` and choose the byte with `ui[4:3]`.
4. Connect `uio[0]` (RING_OUT) to `ui[1]` (RING_IN) using a jumper wire to form the ring oscillator loop.
5. Observe `uo_out[7:0]`, which updates once per measurement window and reflects the oscillator frequency.
6. Optionally vary supply voltage or temperature to see the count change.

## External hardware

- One jumper wire to connect `uio[0]` to `ui[1]` and form the external feedback loop.
- Tiny Tapeout demo board to provide the system clock and observe outputs.