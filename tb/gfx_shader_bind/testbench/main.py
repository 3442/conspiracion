import random

import cocotb
from cocotb.triggers import ClockCycles, FallingEdge, ReadOnly, RisingEdge

from cocotb_bus.scoreboard import Scoreboard

from cocotb_coverage.coverage import coverage_db

from .axi import AXI4Agent
from .data import BAD_PC, FrontWave
from .common import MAX_GROUPS, MEM_WORDS, log
from .models import Memory, PcTable
from .drivers import ClockResetDriver, LoopDriver, PcDriver
from .checkers import PcChecker, PipelineIntegrityChecker
from .monitors import FrontWaveMonitor

@cocotb.test()
async def test(dut):
    mem = Memory('insn_mem', word_size=4, words=MEM_WORDS)
    mem_agent = AXI4Agent(dut, 'mem', dut.clk, mem, case_insensitive=False)

    out_groups = set()
    out_groups_done = set()
    out_groups_retry = set()
    out_monitor = FrontWaveMonitor(dut, 'wave', dut.clk, case_insensitive=False)

    lst = set()
    def out_callback(wave):
        nonlocal out_groups, out_groups_done, out_groups_retry

        if wave.insn is not None:
            lst.add(wave.group)

        out_groups.add(wave.group)
        if wave.insn is None:
            out_groups_retry.add(wave.group)
        else:
            out_groups_done.add(wave.group)
            if wave.group in out_groups_retry:
                out_groups_retry.remove(wave.group)

    out_monitor.add_callback(out_callback)

    out_expected = []
    out_scoreboard = Scoreboard(dut, fail_immediately=False)
    out_scoreboard.add_interface(out_monitor, out_expected)

    clock_reset = ClockResetDriver(dut)
    clock_reset.start()

    pc_table = PcTable()
    pc_driver = PcDriver(dut, 'pc_front', dut.clk, table=pc_table, case_insensitive=False)
    loop_driver = LoopDriver(dut, 'loop', dut.clk, case_insensitive=False)

    pc_checker = PcChecker(dut, 'bind', dut.clk, mem=mem, pc_table=pc_table)
    pipeline_checker = PipelineIntegrityChecker(dut, 'bind', dut.clk)

    out_monitor.add_callback(pc_checker.sample_wave)

    await clock_reset.wait_for_reset()

    await FallingEdge(dut.front.bind_.icache.in_flush) #FIXME
    await RisingEdge(dut.clk)

    for iteration in range(50):
        all_groups = list(range(MAX_GROUPS))
        random.shuffle(all_groups)

        for group in range(MAX_GROUPS):
            pc_table[group] = BAD_PC * 4

        for group in all_groups:
            pc = random.randint(0, 512) * 4
            pc_table[group] = pc
            mem.randomize_line(pc)

        for group in all_groups:
            out_expected.append(FrontWave(group=group, insn=mem.read_cached(4 * pc_table[group]), soft=True))
            await loop_driver.put(group)

        for _ in range(30):
            retry = out_groups_retry.copy()
            retry_len = len(retry)
            out_groups_retry.clear()

            if not retry and len(out_groups_done) == MAX_GROUPS:
                break

            for group in retry:
                out_expected.append(FrontWave(group=group, insn=mem.read_cached(pc_table[group] * 4), soft=True))
                await loop_driver.put(group)
                await RisingEdge(dut.clk)

            await ClockCycles(dut.clk, max(0, 16 - retry_len))
        else:
            raise TimeoutError(f'Timed out during iteration {iteration} waiting for all groups to finish: {list(out_groups_retry)}')

        out_groups.clear()
        out_groups_done.clear()

    coverage_db.report_coverage(log.info, bins=True)
    coverage_db.export_to_xml(filename="coverage.xml")
    coverage_db.export_to_yaml(filename='coverage.yml')

    raise out_scoreboard.result
