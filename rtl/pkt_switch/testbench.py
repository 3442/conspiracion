
'''Copyright (c) 2020-2023, MC ASIC Design Consulting
All rights reserved.

Author: Marek Cieplucha, https://github.com/mciepluc

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met (The BSD 2-Clause
License):

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL POTENTIAL VENTURES LTD BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. '''

"""
Example packet switch testbench with functional coverage and constrained
randomization. Simple packet switch is a module that routes packets from the
input interface to output interfaces (1 or 2) depending on configured address
or length based filter. Test generates random packets and checks if it has been
transmitted correctly.
"""

import cocotb
from cocotb.triggers import Timer, RisingEdge, ReadOnly

from cocotb_bus.drivers import BusDriver
from cocotb_bus.monitors import BusMonitor

from cocotb_coverage.coverage import *
from cocotb_coverage.crv import *

import numpy as np

class Packet(Randomized):
    def __init__(self, data = [0, 3, 0]):
        Randomized.__init__(self)
        self.addr = data[0]
        self.len = len(data)
        self.payload = data[2:]

        self.add_rand("addr", list(range(256)))
        self.add_rand("len", list(range(3,32)))

    def post_randomize(self):
        self.payload = [np.random.randint(256) for _ in range(self.len-2)]

class PacketIFDriver(BusDriver):
    '''
    Packet Interface Driver
    '''
    _signals = ["data", "valid"]

    def __init__(self, entity, name, clock):
        BusDriver.__init__(self, entity, name, clock)
        self.clock = clock
        self.bus.data.setimmediatevalue(0)
        self.bus.valid.setimmediatevalue(0)

    @cocotb.coroutine
    def send(self, packet):
        self.bus.valid.value = 1
        # transmit header
        self.bus.data.value = packet.addr
        yield RisingEdge(self.clock)
        self.bus.data.value = packet.len
        yield RisingEdge(self.clock)
        for byte in packet.payload:
            self.bus.data.value = byte
            yield RisingEdge(self.clock)
        self.bus.valid.value = 0
        yield RisingEdge(self.clock)

class PacketIFMonitor(BusMonitor):
    '''
    Packet Interface Monitor
    '''
    _signals = ["data", "valid"]

    def __init__(self, entity, name, clock):
        BusMonitor.__init__(self, entity, name, clock)
        self.clock = clock

    @cocotb.coroutine
    def _monitor_recv(self):
        pkt_receiving = False
        received_data = []
        while True:
            yield RisingEdge(self.clock)
            yield ReadOnly()
            if (self.bus.valid == 1):
                pkt_receiving = True
                received_data.append(int(self.bus.data))
            elif pkt_receiving and (self.bus.valid == 0): # packet ended
                pkt = Packet(received_data)
                self._recv(pkt)
                pkt_receiving = False
                received_data = []

# simple clock generator
@cocotb.coroutine
def clock_gen(signal, period=10000):
    while True:
        signal.value = 0
        yield Timer(period/2)
        signal.value = 1
        yield Timer(period/2)

@cocotb.test()
async def pkt_switch_test(dut):
    """ PKT_SWITCH Test """

    log = cocotb.logging.getLogger("cocotb.test") # logger instance
    await cocotb.start(clock_gen(dut.clk, period=100))   # start clock running

    # reset & init
    dut.rst_n.value = 1
    dut.datain_data.value = 0
    dut.datain_valid.value = 0
    dut.ctrl_addr.value = 0
    dut.ctrl_data.value = 0
    dut.ctrl_wr.value = 0

    await Timer(1000)
    dut.rst_n.value = 0
    await Timer(1000)
    dut.rst_n.value = 1

    # procedure of writing configuration registers
    @cocotb.coroutine
    def write_config(addr, data):
        for [a, d] in zip(addr, data):
            dut.ctrl_addr.value = a
            dut.ctrl_data.value = d
            dut.ctrl_wr.value = 1
            yield RisingEdge(dut.clk)
            dut.ctrl_wr.value = 0

    enable_transmit_both = lambda: write_config([0], [4])
    disable_filtering = lambda: write_config([0], [0])

    @cocotb.coroutine
    def enable_addr_filtering(addr, mask):
        yield write_config([0, 2, 3], [1, addr, mask])

    @cocotb.coroutine
    def enable_len_filtering(low_limit, up_limit):
        yield write_config([0, 4, 5], [2, low_limit, up_limit])

    driver = PacketIFDriver(dut, name="datain", clock=dut.clk)
    monitor0 = PacketIFMonitor(dut, name="dataout0", clock=dut.clk)
    monitor1 = PacketIFMonitor(dut, name="dataout1", clock=dut.clk)

    expected_data0 = [] # queue of expeced packet at interface 0
    expected_data1 = [] # queue of expeced packet at interface 1


    def scoreboarding(pkt, queue_expected):
        assert pkt.addr == queue_expected[0].addr
        assert pkt.len == queue_expected[0].len
        assert pkt.payload == queue_expected[0].payload
        queue_expected.pop()

    monitor0.add_callback(lambda _: scoreboarding(_, expected_data0))
    monitor1.add_callback(lambda _: scoreboarding(_, expected_data1))
    monitor0.add_callback(lambda _: log.info("Receiving packet on interface 0 (packet not filtered)"))
    monitor1.add_callback(lambda _: log.info("Receiving packet on interface 1 (packet filtered)"))

    # functional coverage - check received packet

    @CoverPoint(
      "top.packet_length",
      xf = lambda pkt, event, addr, mask, ll, ul: pkt.len,    # packet length
      bins = list(range(3,32))                                # may be 3 ... 31 bytes
    )
    @CoverPoint("top.event", vname="event", bins = ["DIS", "TB", "AF", "LF"])
    @CoverPoint(
      "top.filt_addr",
      xf = lambda pkt, event, addr, mask, ll, ul:         # filtering based on particular bits in header
        (addr & mask & 0x0F) if event == "AF" else None,  # check only if event is "address filtering"
      bins = list(range(16)),                             # check only 4 LSBs if all options tested
    )
    @CoverPoint(
      "top.filt_len_eq",
      xf = lambda pkt, event, addr, mask, ll, ul: ll == ul,  # filtering of a single packet length
      bins = [True, False]
    )
    @CoverPoint(
      "top.filt_len_ll",
      vname = "ll",                    # lower limit of packet length
      bins = list(range(3,32))         # 3 ... 31
    )
    @CoverPoint(
      "top.filt_len_ul",
      vname = "ul",                    # upper limit of packet length
      bins = list(range(3,32))         # 3 ... 31
    )
    @CoverCross(
      "top.filt_len_ll_x_packet_length",
      items = ["top.packet_length", "top.filt_len_ll"]
    )
    @CoverCross(
      "top.filt_len_ul_x_packet_length",
      items = ["top.packet_length", "top.filt_len_ul"]
    )
    def log_sequence(pkt, event, addr, mask, ll, ul):
        log.info("Processing packet:")
        log.info("  ADDRESS: %X", pkt.addr)
        log.info("  LENGTH: %d", pkt.len)
        log.info("  PAYLOAD: " + str(pkt.payload))
        if event == "DIS":
            log.info("Filtering disabled")
        elif event == "TB":
            log.info("Transmit on both interfaces")
        elif event == "AF":
            log.info("Address filtering, address: %02X, mask: %02X", addr, mask)
        elif event == "LF":
            log.info("Length filtering, lower limit: %d, upper limit: %d", ll, ul)

    # main loop
    for _ in range(1000): # is that enough repetitions to ensure coverage goal? Check out!

        event = np.random.choice(["DIS", "TB", "AF", "LF"])
        # DIS - disable filtering : expect all packets on interface 0
        # TB  - transmit bot : expect all packets on interface 0 and 1
        # AF  - address filtering : expect filtered packets on interface 1, others on 0
        # LF  - length filtering : expect filtered packets on interface 1, others on 0

        # randomize test data
        pkt = Packet();
        pkt.randomize()
        addr = np.random.randint(256)               # 0x00 .. 0xFF
        mask = np.random.randint(256)               # 0x00 .. 0xFF
        low_limit = np.random.randint(3,32)         # 3 ... 31
        up_limit = np.random.randint(low_limit,32)  # low_limit ... 31

        # expect the packet on the particular interface
        if event == "DIS":
            await disable_filtering()
            expected_data0.append(pkt)
        elif event == "TB":
            await enable_transmit_both()
            expected_data0.append(pkt)
            expected_data1.append(pkt)
        elif event == "AF":
            await enable_addr_filtering(addr, mask)
            if ((pkt.addr & mask) == (addr & mask)):
                expected_data1.append(pkt)
            else:
                expected_data0.append(pkt)
        elif event == "LF":
            await enable_len_filtering(low_limit, up_limit)
            if (low_limit <= pkt.len <= up_limit):
                expected_data1.append(pkt)
            else:
                expected_data0.append(pkt)

        # wait DUT
        await driver.send(pkt)
        await RisingEdge(dut.clk)
        await RisingEdge(dut.clk)

        # LOG the action
        log_sequence(pkt, event, addr, mask, low_limit, up_limit)

    # print coverage report
    coverage_db.report_coverage(log.info, bins=False)
    # export
    coverage_db.export_to_xml(filename="coverage_pkt_switch.xml")
    coverage_db.export_to_yaml(filename="coverage_pkt_switch.yml")
