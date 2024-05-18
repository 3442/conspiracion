import cocotb
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.triggers import Event, ReadOnly, RisingEdge

from cocotb_bus.drivers import BusDriver

from .data import BAD_PC

class ClockResetDriver:
    def __init__(self, dut):
        self._reset_event = Event('reset_done')

        dut.clk.setimmediatevalue(0)
        dut.rst_n.setimmediatevalue(0)

        self._dut = dut
        self._clock_gen = Clock(dut.clk, 2, 'step')

    def start(self):
        cocotb.start_soon(self._clock_gen.start())
        cocotb.start_soon(self.reset())

    async def reset(self):
        self._reset_event.clear()

        self._dut.rst_n.value = 0
        await RisingEdge(self._dut.clk)
        self._dut.rst_n.value = 1
        await ReadOnly()

        self._reset_event.set()

    async def wait_for_reset(self):
        await self._reset_event.wait()

class PcDriver(BusDriver):
    _signals = ['pc', 'group']

    def __init__(self, *args, table, **kwargs):
        super().__init__(*args, **kwargs)

        self._table = table
        self._delay1 = BAD_PC
        self._delay2 = BAD_PC
        self._delay3 = BAD_PC

        cocotb.start_soon(self._run())

    async def _run(self):
        while True:
            self.bus.pc.value = self._delay3

            await RisingEdge(self.clock)

            self._delay3 = self._delay2
            self._delay2 = self._delay1
            self._delay1 = self._table[self.bus.group.value]

class LoopDriver(BusDriver):
    _signals = ['group', 'valid']

    def __init__(self, *args, maxsize=8, **kwargs):
        super().__init__(*args, **kwargs)

        self._queue = Queue(maxsize=maxsize)
        self.bus.valid.setimmediatevalue(0)

        cocotb.start_soon(self._run())

    async def put(self, group):
        await self._queue.put(group)

    async def _run(self):
        while True:
            await RisingEdge(self.clock)

            valid = not self._queue.empty()
            if valid:
                group = self._queue.get_nowait()
                valid = group is not None

            self.bus.valid.value = int(valid)
            if valid:
                self.bus.group.value = group
