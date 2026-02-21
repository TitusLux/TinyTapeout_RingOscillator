# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_sanity_only(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="us").start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Outputs should be driven/resolvable
    assert dut.uo_out.value.is_resolvable, "uo_out is X/Z"
    assert dut.uio_out.value.is_resolvable, "uio_out is X/Z"
    assert dut.uio_oe.value.is_resolvable, "uio_oe is X/Z"

    # External-loop RO uses uio[0] as output
    assert int(dut.uio_oe.value) == 0b0000_0001, f"uio_oe unexpected: {dut.uio_oe.value}"