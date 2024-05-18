import cocotb
from cocotb.triggers import RisingEdge, ReadOnly

from cocotb_coverage.coverage import CoverCheck

class PipelineIntegrityChecker:
    def __init__(self, dut, name, clk):
        self._clk, self._dut = clk, dut
        self._queue = [None] * dut.front.bind_.BIND_STAGES.value
        self._ready_sticky = False

        @CoverCheck(
            f'{name}.runnable_tx_ready',
            f_pass = lambda ready: not self._ready_sticky and     ready,
            f_fail = lambda ready:     self._ready_sticky and not ready,
        )
        def sample_ready(ready):
            self._ready_sticky = self._ready_sticky or ready

        @CoverCheck(
            f'{name}.in_to_out_integrity',
            f_pass = lambda group: group == self._queue[0] and group is not None,
            f_fail = lambda group: group != self._queue[0],
        )
        def sample_wave_group(group):
            pass

        self._sample_ready = sample_ready
        self._sample_wave_group = sample_wave_group

        cocotb.start_soon(self._run())

    async def _run(self):
        while True:
            await RisingEdge(self._clk)
            await ReadOnly()

            self._sample_ready(self._dut.runnable_in_ready.value)

            if self._dut.wave_valid.value:
                self._sample_wave_group(self._dut.wave_group.value)
            else:
                self._sample_wave_group(None)

            new_group = None
            if self._dut.runnable_out_valid.value:
                new_group = self._dut.runnable_out_data.value

            self._queue[:-1] = self._queue[1:]
            self._queue[-1] = new_group

class PcChecker:
    def __init__(self, dut, name, clk, *, mem, pc_table):
        self._clk, self._dut = clk, dut
        self._mem, self._pc_table = mem, pc_table

        @CoverCheck(
            f'{name}.pc_ok',
            f_pass = lambda wave: wave.insn and self._pc_ok(wave),
            f_fail = lambda wave: wave.insn and not self._pc_ok(wave),
        )
        def sample_wave(wave):
            pass

        self.sample_wave = sample_wave

    def _pc_ok(self, wave):
        return wave.insn == self._mem.read(self._pc_table[wave.group] * 4)
