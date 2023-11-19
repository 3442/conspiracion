import itertools

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer
from cocotb_bus.drivers import BitDriver

@cocotb.test()
async def fifo(dut):
    await cocotb.start(Clock(dut.clk, 2).start())

    dut.in_valid.value = 0
    dut.out_ready.value = 0

    dut.rst_n.value = 1
    await Timer(1)
    dut.rst_n.value = 0
    await Timer(1)
    dut.rst_n.value = 1

    async def send():
        in_ = getattr(dut, 'in')
        in_ready = dut.in_ready
        in_valid = dut.in_valid

        val = 0
        while True:
            in_.value = val
            await RisingEdge(dut.clk)
            if in_valid.value and in_ready.value:
                val = (val + 1) & 0xff

    async def recv():
        out = dut.out
        out_ready = dut.out_ready
        out_valid = dut.out_valid

        val = 0
        while True:
            await RisingEdge(dut.clk)
            if out_valid.value and out_ready.value:
                assert out.value == val, f'expected {val}, got {out.value.integer}'
                val = (val + 1) & 0xff

    await cocotb.start(send())
    await cocotb.start(recv())

    await ClockCycles(dut.clk, 2)

    valid_driver = BitDriver(dut.in_valid, dut.clk)
    valid_driver.start((1 + (i % 2), (i + 1) % 3) for i in itertools.count())

    await ClockCycles(dut.clk, 1 << 10)
    valid_driver.stop()

    ready_driver = BitDriver(dut.out_ready, dut.clk)
    ready_driver.start((1, i % 5) for i in itertools.count())

    await ClockCycles(dut.clk, 1 << 10)
    valid_driver.start()

    await ClockCycles(dut.clk, 1 << 10)
    ready_driver.stop()
    valid_driver.stop()

    await ClockCycles(dut.clk, 2)

    dut.in_valid.value = 1
    dut.out_ready.value = 1

    await ClockCycles(dut.clk, 1 << 16)
