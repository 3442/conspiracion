import enum

import cocotb
from cocotb.binary import BinaryValue
from cocotb.triggers import Lock, RisingEdge, ReadOnly

from cocotb_bus.drivers import BusDriver

class AXIBurst(enum.IntEnum):
    FIXED = 0b00
    INCR = 0b01
    WRAP = 0b10


class AXIxRESP(enum.IntEnum):
    OKAY = 0b00
    EXOKAY = 0b01
    SLVERR = 0b10
    DECERR = 0b11


class AXIProtocolError(Exception):
    def __init__(self,  message: str, xresp: AXIxRESP):
        super().__init__(message)
        self.xresp = xresp


class AXIReadBurstLengthMismatch(Exception):
    pass


class AXI4Agent(BusDriver):
    '''
    AXI4 Agent

    Monitors an internal memory and handles read and write requests.
    '''
    _signals = [
        "ARREADY", "ARVALID", "ARADDR",             # Read address channel
        "ARLEN",   "ARSIZE",  "ARBURST", "ARPROT",

        "RREADY",  "RVALID",  "RDATA",   "RLAST",   # Read response channel

        "AWREADY", "AWADDR",  "AWVALID",            # Write address channel
        "AWPROT",  "AWSIZE",  "AWBURST", "AWLEN",

        "WREADY",  "WVALID",  "WDATA",

    ]

    # Not currently supported by this driver
    _optional_signals = [
        "WLAST",   "WSTRB",
        "BVALID",  "BREADY",  "BRESP",   "RRESP",
        "RCOUNT",  "WCOUNT",  "RACOUNT", "WACOUNT",
        "ARLOCK",  "AWLOCK",  "ARCACHE", "AWCACHE",
        "ARQOS",   "AWQOS",   "ARID",    "AWID",
        "BID",     "RID",     "WID"
    ]

    def __init__(self, entity, name, clock, memory, callback=None, event=None,
                 big_endian=False, **kwargs):

        BusDriver.__init__(self, entity, name, clock, **kwargs)
        self.clock = clock

        self.big_endian = big_endian
        self.bus.ARREADY.setimmediatevalue(0)
        self.bus.RVALID.setimmediatevalue(0)
        self.bus.RLAST.setimmediatevalue(0)
        self.bus.AWREADY.setimmediatevalue(0)
        self._memory = memory

        self.write_address_busy = Lock("%s_wabusy" % name)
        self.read_address_busy = Lock("%s_rabusy" % name)
        self.write_data_busy = Lock("%s_wbusy" % name)

        cocotb.start_soon(self._read_data())
        cocotb.start_soon(self._write_data())

    def _size_to_bytes_in_beat(self, AxSIZE):
        if AxSIZE < 7:
            return 2 ** AxSIZE
        return None

    async def _write_data(self):
        clock_re = RisingEdge(self.clock)

        while True:
            while True:
                self.bus.WREADY.value = 0
                await ReadOnly()
                if self.bus.AWVALID.value:
                    self.bus.WREADY.value = 1
                    break
                await clock_re

            await ReadOnly()
            _awaddr = int(self.bus.AWADDR)
            _awlen = int(self.bus.AWLEN)
            _awsize = int(self.bus.AWSIZE)
            _awburst = int(self.bus.AWBURST)
            _awprot = int(self.bus.AWPROT)

            burst_length = _awlen + 1
            bytes_in_beat = self._size_to_bytes_in_beat(_awsize)

            if __debug__:
                self.log.debug(
                    "AWADDR  %d\n" % _awaddr +
                    "AWLEN   %d\n" % _awlen +
                    "AWSIZE  %d\n" % _awsize +
                    "AWBURST %d\n" % _awburst +
                    "AWPROT %d\n" % _awprot +
                    "BURST_LENGTH %d\n" % burst_length +
                    "Bytes in beat %d\n" % bytes_in_beat)

            burst_count = burst_length

            await clock_re

            while True:
                if self.bus.WVALID.value:
                    word = self.bus.WDATA.value
                    word.big_endian = self.big_endian
                    _burst_diff = burst_length - burst_count
                    _st = _awaddr + (_burst_diff * bytes_in_beat)  # start
                    _end = _awaddr + ((_burst_diff + 1) * bytes_in_beat)  # end
                    self._memory[_st:_end] = array.array('B', word.buff)
                    burst_count -= 1
                    if burst_count == 0:
                        break
                await clock_re

    async def _read_data(self):
        clock_re = RisingEdge(self.clock)

        while True:
            self.bus.ARREADY.value = 1
            while True:
                await ReadOnly()
                if self.bus.ARVALID.value:
                    break
                await clock_re

            await ReadOnly()
            _araddr = int(self.bus.ARADDR)
            _arlen = int(self.bus.ARLEN)
            _arsize = int(self.bus.ARSIZE)
            _arburst = int(self.bus.ARBURST)
            _arprot = int(self.bus.ARPROT)

            burst_length = _arlen + 1
            bytes_in_beat = self._size_to_bytes_in_beat(_arsize)

            word = BinaryValue(n_bits=bytes_in_beat*8, bigEndian=self.big_endian)

            if __debug__:
                self.log.debug(
                    "ARADDR  %d\n" % _araddr +
                    "ARLEN   %d\n" % _arlen +
                    "ARSIZE  %d\n" % _arsize +
                    "ARBURST %d\n" % _arburst +
                    "ARPROT %d\n" % _arprot +
                    "BURST_LENGTH %d\n" % burst_length +
                    "Bytes in beat %d\n" % bytes_in_beat)

            burst_count = burst_length

            await clock_re
            self.bus.ARREADY.value = 0

            self.bus.RVALID.value = 1
            while burst_count > 0:
                _burst_diff = burst_length - burst_count
                _st = _araddr + (_burst_diff * bytes_in_beat)
                _end = _araddr + ((_burst_diff + 1) * bytes_in_beat)
                word.buff = self._memory[_st:_end].tobytes()
                self.bus.RDATA.value = word
                self.bus.RLAST.value = int(burst_count == 1)

                await ReadOnly()

                if self.bus.RREADY.value:
                    burst_count -= 1

                await clock_re
                self.bus.RLAST.value = 0

            self.bus.RVALID.value = 0
