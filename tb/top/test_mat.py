from array import array
import itertools, struct, random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Combine, ClockCycles, FallingEdge, RisingEdge, Timer, with_timeout
from cocotb_bus.drivers import BitDriver
from cocotb_bus.drivers.avalon import AvalonMaster, AvalonMemory

@cocotb.test()
async def fp_mat_mul(dut):
    await cocotb.start(Clock(dut.clk, 2).start())

    dut.rst_n.value = 1
    await Timer(1)
    dut.rst_n.value = 0
    await Timer(1)
    dut.rst_n.value = 1

    for i in range(32):
        await cmd.write(i, int.from_bytes(struct.pack('<e', i + 1), 'little'))

    await ClockCycles(dut.clk, 50)
    for i in range(4):
        for j in range(4):
            read, = struct.unpack('<e', (await cmd.read(i * 4 + j)).integer.to_bytes(2, 'little'))
            expected = sum((1 + i * 4 + k) * (17 + k * 4 + j) for k in range(4))
            assert read == expected, f'expected {expected} at ({i}, {j}), got {read}'
