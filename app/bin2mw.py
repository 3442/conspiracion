#!/usr/bin/env python3

import sys

with open(sys.argv[1], 'rb') as f:
    addr = 0x2000_0000
    while word := f.read(4):
        word = int.from_bytes(word, 'little')
        print(f'mw.l {addr:08x} {word:08x}')
        addr += 4
