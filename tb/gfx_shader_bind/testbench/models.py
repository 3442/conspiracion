import random

from cocotb.binary import BinaryValue

from cocotb_coverage.coverage import CoverCross, CoverPoint

from .data import BAD_PC
from .common import log

class PcTable:
    def __init__(self):
        self._pcs = {}

    def __getitem__(self, group):
        if isinstance(group, BinaryValue):
            group = group.integer

        return self._pcs.get(group, BAD_PC)

    def __setitem__(self, group, pc):
        assert (pc & 3) == 0
        if isinstance(group, BinaryValue):
            group = group.integer

        self._pcs[group] = pc >> 2

class Memory:
    def __init__(self, name, *, word_size, words, start=0):
        word_mask = word_size - 1
        assert word_size > 0 and (word_mask & word_size) == 0, \
            f'{word_size} is not a power of two'

        self._data = {}
        self._dirty = {}
        self._observed = set()

        self._start = start
        self._words = words
        self._word_size = word_size
        self._subword_mask = word_mask

        self._all_ones = (1 << (8 * word_size)) - 1

        @CoverPoint(
            f'{name}.read_dirty',
            bins        = [True,    False],
            bins_labels = ['dirty', 'clean'],
            rel = lambda word_num, dirty: self._test_bin(word_num, self._dirty, dirty),
        )
        @CoverPoint(
            f'{name}.read_observed',
            bins        = [True,             False],
            bins_labels = ['multiple_reads', 'first_read'],
            rel = lambda word_num, observed: self._test_bin(word_num, self._observed, observed),
        )
        @CoverCross(
            f'{name}.read_dirty_observed',
            items = [
                f'{name}.read_dirty',
                f'{name}.read_observed',
                ],
            ign_bins = [
                ('dirty', 'first_read'),
                ],
        )
        def _read_word(word_num):
            if self._expect_in_range(word_num):
                self._observed.add(word_num)

            word = self._data.get(word_num)
            if word is None:
                log.warning(f'Uninitialized memory read: {self._addr_repr(word_num)}')
                word = self._all_ones

            return word

        @CoverPoint(
            f'{name}.write_dirty',
            bins        = [True,           False],
            bins_labels = ['dirty_write', 'clean_write'],
            xf  = lambda word_num, data: word_num,
            rel = lambda word_num, dirty: self._test_bin(word_num, self._observed, dirty),
        )
        def _write_word(word_num, data):
            if self._expect_in_range(word_num):
                if word_num in self._observed:
                    dirty = self._dirty.setdefault(word_num, set())
                    dirty.add(self._data.get(word_num, self._all_ones))
                    dirty.add(data)

                self._data[word_num] = data

        self._read_word = _read_word
        self._write_word = _write_word

    def read(self, addr):
        return self._data[addr >> 2]

    def read_cached(self, addr):
        addr = addr >> 2

        data = self._data[addr]
        if dirty := self._dirty.get(addr):
            data = tuple(dirty.union({data}))

        return data

    def randomize_line(self, addr):
        first_word = (addr >> 2) & ~15
        for word_num in range(first_word, first_word + 16):
            self._write_word(word_num, random.randint(0, self._all_ones))

    def __getitem__(self, index):
        if not isinstance(index, slice):
            return super()[index]

        assert index.stop >= index.start
        assert (index.stop & self._subword_mask) == 0
        assert (index.start & self._subword_mask) == 0

        return MemoryRead(self, index.start // self._word_size, index.stop // self._word_size)

    def _expect_in_range(self, word_num):
        delta = word_num - self._start

        in_range = delta >= 0 and delta < self._words
        if not in_range:
            log.error(f'Bad memory address: {self._addr_repr(word_num)}')

        return in_range

    def _test_bin(self, word_num, flag_set, flag_bin):
        if not self._expect_in_range(word_num):
            return False

        return (word_num in flag_set) == flag_bin

    def _addr_repr(self, word_num):
        addr = word_num * self._word_size
        return f'0x{addr:08x}'

class MemoryRead:
    def __init__(self, mem, start, stop):
        self._mem, self._start, self._stop = mem, start, stop

    def tobytes(self):
        array = bytearray()
        for word_num in range(self._start, self._stop):
            word = self._mem._read_word(word_num)
            array.extend(word.to_bytes(self._mem._word_size, 'little'))

        return array
