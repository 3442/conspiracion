import cocotb
from cocotb.triggers import ReadOnly, RisingEdge

from cocotb_bus.monitors import BusMonitor

from .data import FrontWave

class FrontWaveMonitor(BusMonitor):
    _signals = ['insn', 'group', 'retry', 'valid']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    async def _monitor_recv(self):
        pkt_receiving = False
        received_data = []

        while True:
            await RisingEdge(self.clock)
            await ReadOnly()

            if not self.bus.valid.value:
                continue

            wave = FrontWave(
                group=self.bus.group.value.integer,
                insn=(self.bus.insn.value.integer if not self.bus.retry.value else None),
            )

            self._recv(wave)
