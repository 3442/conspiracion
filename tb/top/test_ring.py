import random

import cocotb
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.binary import BinaryValue
from cocotb.triggers import ClockCycles, RisingEdge, Timer
from cocotb_bus.drivers import BitDriver
from cocotb_bus.scoreboard import Scoreboard
from cocotb_bus.monitors.avalon import AvalonST as AvalonSTMonitor

from tb.models import RingSegmentModel

AvalonSTMonitor._signals = {'valid': '_valid', 'data': ''}
AvalonSTMonitor._optional_signals = {'ready': '_ready'}

def rand_ready():
    while True:
        yield (1, random.randint(0, 5))

async def do_sends(segment, model, queue):
    while True:
        segment.send.value = 0
        segment.set_reply.value = 0

        ty, tag, index, data = await queue.get()
        assert ty in ('read', 'inval', 'read-inval')

        model.send(ty=ty, tag=tag, index=index, data=data)
        await ClockCycles(segment.clk, 1)

        trigger = RisingEdge(segment.out_data_ready)
        while True:
            await trigger
            if not segment.out_stall or len(model.queue) > 1:
                break

        segment.core_tag.value = tag
        segment.core_tag.value = 69
        segment.core_index.value = index
        segment.data_rd.value.assign(data)
        segment.send.value = 1
        segment.send_read.value = ty in ('read', 'read-inval')
        segment.send_inval.value = ty in ('inval', 'read-inval')

        await ClockCycles(segment.clk, 1)

async def gen_requests(clk, queue):
    while True:
        await ClockCycles(clk, random.randint(1, 5))
        tag = random.randint(0, (1 << 13) - 1)
        index = random.randint(0, (1 << 12) - 1)
        data = random.randint(0, (1 << 128) - 1)

        ty = ('read', 'inval', 'read-inval')[random.randint(0, 2)]
        await queue.put((ty, tag, index, data))

@cocotb.test()
async def test_send_recv(dut):
    await cocotb.start(Clock(dut.clk, 2).start())

    dut.rst_n.value = 1
    await Timer(1)
    dut.rst_n.value = 0
    await Timer(1)
    dut.rst_n.value = 1

    scoreboard = Scoreboard(dut)
    segments = [getattr(dut, f'segment_{i}') for i in range(4)]
    models = [RingSegmentModel() for _ in range(4)]
    queues = [Queue(maxsize=2) for _ in range(4)]

    for i in range(4):
        model, segment, next_model = models[i], segments[i], models[(i + 1) % 4]

        BitDriver(getattr(dut, f'data_{i}_ready'), dut.clk).start(rand_ready())
        monitor = AvalonSTMonitor(segment, 'out_data', dut.clk, callback=next_model.recv,
                                  case_insensitive=False, bus_separator='')

        scoreboard.add_interface(monitor, model.queue)

        await cocotb.start(do_sends(segment, model, queues[i]))
        await cocotb.start(gen_requests(segment.clk, queues[i]))

    await ClockCycles(dut.clk, 1000)
