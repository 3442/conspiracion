import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Combine, ClockCycles, RisingEdge, Timer, with_timeout
from cocotb_bus.drivers.avalon import AvalonMaster

from tb.models import CorePaceModel, SmpModel

@cocotb.test()
async def bring_up(dut):
    await cocotb.start(Clock(dut.clk, 2).start())

    dut.cpu_alive_0.value = 1
    dut.cpu_alive_1.value = 1
    dut.cpu_alive_2.value = 1
    dut.cpu_alive_3.value = 1

    dut.rst_n.value = 1
    await Timer(1)
    dut.rst_n.value = 0
    await Timer(1)
    dut.rst_n.value = 1

    model = SmpModel()
    master = AvalonMaster(dut, 'avl', dut.clk, case_insensitive=False)

    cpu0 = CorePaceModel(clk=dut.clk, halt=dut.halt_0, step=dut.step_0,
                         bkpt=dut.breakpoint_0, halted=dut.cpu_halted_0)

    cpu1 = CorePaceModel(clk=dut.clk, halt=dut.halt_1, step=dut.step_1,
                         bkpt=dut.breakpoint_1, halted=dut.cpu_halted_1)

    cpu2 = CorePaceModel(clk=dut.clk, halt=dut.halt_2, step=dut.step_2,
                         bkpt=dut.breakpoint_2, halted=dut.cpu_halted_2)

    cpu3 = CorePaceModel(clk=dut.clk, halt=dut.halt_3, step=dut.step_3,
                         bkpt=dut.breakpoint_3, halted=dut.cpu_halted_3)

    cocotb.start_soon(cpu0.run())
    cocotb.start_soon(cpu1.run())
    cocotb.start_soon(cpu2.run())
    cocotb.start_soon(cpu3.run())

    await with_timeout(Combine(*(RisingEdge(halted) for halted in
                                 [dut.cpu_halted_1, dut.cpu_halted_2, dut.cpu_halted_3])),
                       50)

    await ClockCycles(dut.clk, 10)
    assert await master.read(0) == model.read()

    await master.write(0, 0x01000102)
    model.halt(0)
    model.run(1)
    model.run(3)

    await ClockCycles(dut.clk, 10)
    assert await master.read(0) == model.read()
