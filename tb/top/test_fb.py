from array import array
import itertools, struct, random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Combine, ClockCycles, FallingEdge, RisingEdge, Timer, with_timeout
from cocotb_bus.drivers import BitDriver
from cocotb_bus.drivers.avalon import AvalonMaster, AvalonMemory

from PIL import Image

W, H = 640, 480
FILL = (0, 0, 0)
fb = [FILL] * (H * W)

@cocotb.test()
async def fp_mat_mul(dut):
    await cocotb.start(Clock(dut.clk, 2).start())

    dut.cmd_read = 0
    dut.cmd_write = 0
    dut.host_read = 0
    dut.host_write = 0
    dut.mem_readdatavalid.value = 0
    dut.mem_waitrequest.value = 0
    BitDriver(dut.scan_ready, dut.clk).start((1 + (i & 1), 2) for i in itertools.count())

    dut.rst_n.value = 1
    await Timer(1)
    dut.rst_n.value = 0
    await Timer(1)
    dut.rst_n.value = 1

    cmd = AvalonMaster(dut, 'cmd', dut.clk, case_insensitive=False)
    host = AvalonMaster(dut, 'host', dut.clk, case_insensitive=False)

    vram = array('H', (0 for _ in range(1 << (26 - 1))))

    async def mem_coro():
        cnt = 0
        addr = None
        queue = []
        while True:
            await RisingEdge(dut.clk)

            #waitrequest = random.randint(0, 1)

            dut.mem_readdatavalid.value = 0
            #dut.mem_waitrequest.value = waitrequest

            if cnt:
                cnt -= 1
                if not cnt:
                    dut.mem_readdata.value = vram[addr]
                    dut.mem_readdatavalid.value = 1

            await FallingEdge(dut.clk)

            if True: #not waitrequest:
                mem_addr = dut.mem_address.value.integer >> 1
                if dut.mem_read.value:
                    #delay = random.randint(2, 5)
                    delay = 1
                    queue.append((delay, mem_addr))
                elif dut.mem_write.value:
                    vram[mem_addr] = dut.mem_writedata.value

            if not cnt and queue:
                cnt, addr = queue[0]
                del queue[0]

    async def fb_out():
        f = dut.dut.frag_
        p = f.shade.color
        l = f.addr_pipes.out
        while True:
            await FallingEdge(dut.clk)
            if not f.out_valid.value:
                continue

            v = p.value.integer
            r = v >> 16 & 0xff
            g = v >> 8 & 0xff
            b = v & 0xff
            fb[l.value.integer] = (r, g, b)

    async def dump_coro():
        i = 0
        mfb = []
        lim = W * H
        limm1 = lim - 1
        while True:
            await FallingEdge(dut.clk)
            if not dut.scan_ready.value or not dut.scan_valid.value:
                continue

            k = len(mfb)
            assert bool(dut.scan_endofpacket.value) == (k == limm1)
            assert bool(dut.scan_startofpacket.value) == (k == 0)
            v = dut.scan_data.value.integer
            r = ((v >> 20) >> 2) & 0xff
            g = ((v >> 10) >> 2) & 0xff
            b = ((v >>  0) >> 2) & 0xff
            mfb.append((r,g,b))
            if k == limm1:
                img = Image.new('RGB', (W, H))
                img.putdata(mfb)
                img.save(f'render-scan-{i}.png')
                mfb = []
                i += 1

    cocotb.start_soon(fb_out())
    cocotb.start_soon(mem_coro())
    cocotb.start_soon(dump_coro())

    await host.write(0x200000 >> 1, (0x300000) & 0xffff)
    await host.write(0x200002 >> 1, (0x300000) >> 16)
    await host.write(0x200004 >> 1, (3 - 1) & 0xffff)
    await host.write(0x200006 >> 1, (3 - 1) >> 16)
    await host.write(0x200008 >> 1, 0x400000 & 0xffff)
    await host.write(0x20000a >> 1, 0x400000 >> 16)
    await host.write(0x20000c >> 1, 9 & 0xffff)
    await host.write(0x20000e >> 1, 9 >> 16)

    # 0x00000120 | recv m1
    # 0x00001010 | send m1
    # 0x00001010 | send m1

    await host.write(0x300000 >> 1, 0x00000120 & 0xffff)
    await host.write(0x300002 >> 1, 0x00000120 >> 16)
    await host.write(0x300004 >> 1, 0x00001010 & 0xffff)
    await host.write(0x300006 >> 1, 0x00001010 >> 16)
    await host.write(0x300008 >> 1, 0x00001010 & 0xffff)
    await host.write(0x30000a >> 1, 0x00001010 >> 16)

    await host.write(0x400000 >> 1, 0x3c003c00 & 0xffff)
    await host.write(0x400002 >> 1, 0x3c003c00 >> 16)
    await host.write(0x400004 >> 1, 0xa400a555 & 0xffff)
    await host.write(0x400006 >> 1, 0xa400a555 >> 16)
    await host.write(0x400020 >> 1, 0x3c003c00 & 0xffff)
    await host.write(0x400022 >> 1, 0x3c003c00 >> 16)
    await host.write(0x400024 >> 1, 0xb100a555 & 0xffff)
    await host.write(0x400026 >> 1, 0xb100a555 >> 16)
    await host.write(0x400040 >> 1, 0x3c003c00 & 0xffff)
    await host.write(0x400042 >> 1, 0x3c003c00 >> 16)
    await host.write(0x400044 >> 1, 0xac00b4ab & 0xffff)
    await host.write(0x400046 >> 1, 0xac00b4ab >> 16)

    await cmd.write(2, 0x200000)
    await cmd.write(3, 1 - 1)

    await cmd.write(1, 0x2ff0000)
    await RisingEdge(dut.dut.scanout.vsync)
    await cmd.write(1, 0x3ff0000)

    for _ in range(2):
        await RisingEdge(dut.dut.scanout.vsync)

    await ClockCycles(dut.clk, 50000)

    img = Image.new('RGB', (W, H))
    img.putdata(fb)
    img.save('render-frag.png')
