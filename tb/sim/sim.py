#!/usr/bin/env python3

import importlib.util, pathlib, subprocess, sys

module, verilated, image = sys.argv[1:]
test_name = pathlib.Path(module).stem

spec = importlib.util.spec_from_file_location('sim', module)
module = importlib.util.module_from_spec(spec)

all_regs = {
    'r0': 'r0',
    'r1': 'r1',
    'r2': 'r2',
    'r3': 'r3',
    'r4': 'r4',
    'r5': 'r5',
    'r6': 'r6',
    'r7': 'r7',
    'r8': 'r8_usr',
    'r8_usr': 'r8_usr',
    'r8_fiq': 'r8_fiq',
    'r9': 'r9_usr',
    'r9_usr': 'r9_usr',
    'r9_fiq': 'r9_fiq',
    'r10': 'r10_usr',
    'r10_usr': 'r10_usr',
    'r10_fiq': 'r10_fiq',
    'r11': 'r11_usr',
    'r11_usr': 'r11_usr',
    'r11_fiq': 'r11_fiq',
    'r12': 'r12_usr',
    'r12_usr': 'r12_usr',
    'r12_fiq': 'r12_fiq',
    'sp': 'r13_usr',
    'r13': 'r13_usr',
    'r13_usr': 'r13_usr',
    'r13_svc': 'r13_svc',
    'r13_abt': 'r13_abt',
    'r13_und': 'r13_und',
    'r13_irq': 'r13_irq',
    'r13_fiq': 'r13_fiq',
    'lr': 'r14_usr',
    'r14': 'r14_usr',
    'r14_usr': 'r14_usr',
    'r14_svc': 'r14_svc',
    'r14_abt': 'r14_abt',
    'r14_und': 'r14_und',
    'r14_irq': 'r14_irq',
    'r14_fiq': 'r14_fiq',
    'pc': 'pc',
    'r15': 'pc',
    'cpsr': 'cpsr',
    'spsr_svc': 'spsr_svc',
    'spsr_abt': 'spsr_abt',
    'spsr_und': 'spsr_und',
    'spsr_irq': 'spsr_irq',
    'spsr_fiq': 'spsr_fiq',
    }

regs = {}
read_reg = lambda r: regs.setdefault(r, 0)

dumped = []
def read_mem(base, length):
    fragments = []
    i = 0

    while length > 0:
        assert i < len(dumped), f'memory at 0x{base:08x} not dumped'
        start, data = dumped[i]
        delta = base - start

        if delta < 0:
            i = len(dumped)
        elif delta < len(data):
            taken = min(length, len(data) - delta)
            fragments.append(data[delta:delta + taken])

            base += taken
            length -= taken
        else:
            i += 1

    return b''.join(fragments)

def hexdump(base, memory):
    lines = []
    offset = 0

    while offset < len(memory) > 0:
        taken = min(16, len(memory) - offset)
        line_bytes = memory[offset:offset + taken]

        half = lambda rng: ' '.join(f'{line_bytes[i]:02x}' if i < taken else '  ' for i in rng)
        left, right = half(range(0, 8)), half(range(8, 16))

        ascii = ''.join(c if c.isascii() and c.isprintable() else '.' for c in map(chr, line_bytes))
        lines.append(f' {base:08x}:  {left}  {right}  | {ascii}')

        base += 16
        offset += taken

    return '\n'.join(lines)

def assert_reg(r, expected):
    actual = read_reg(r)
    assert actual == expected, f'register {r} = 0x{actual:08x}, expected 0x{expected:08x}'

def assert_mem(base, value):
    if type(value) is int:
        value = value.to_bytes(4, 'little')
    elif type(value) is list:
        value = b''.join(w.to_bytes(4, 'little') if type(w) is int else w for w in value)

    actual = read_mem(base, len(value))
    assert actual == value, \
        f'memory at 0x{base:08x} holds:\n{hexdump(base, actual)}\n' + \
        f'But this was expected instead:\n{hexdump(base, value)}'

prelude = {
    'read_reg':   read_reg,
    'read_mem':   read_mem,
    'assert_reg': assert_reg,
    'assert_mem': assert_mem,
    }

prelude.update(all_regs)
module.__dict__.update(prelude)
spec.loader.exec_module(module)

module_get = lambda attr, default=None: getattr(module, attr, default)

cycles = module_get('cycles', 1024)
mem_dumps = module_get('mem_dumps', [])

exec_args = [verilated, '--cycles', str(cycles), '--dump-regs']

for rng in mem_dumps:
    length = rng.stop - rng.start
    assert rng.start >= 0 and rng.stop > rng.start \
       and rng.step == 1 and ((rng.start | length) & 3) == 0

    exec_args.extend(['--dump-mem', f'{rng.start >> 2},{length >> 2}'])

exec_args.append(image)
output = subprocess.run(exec_args, stdout=subprocess.PIPE, check=True, text=True)

in_regs = False
in_mem = False

for line in output.stdout.split('\n'):
    if line == '=== dump-regs ===':
        in_regs = True
    elif line == '=== dump-mem ===':
        in_mem = True
    elif not line:
        continue
    elif in_mem:
        base, data = line.split()
        dumped.append((int(base, 16) << 2, bytes.fromhex(data)))
    elif in_regs:
        value, reg = line.split()
        regs[reg] = int(value, 16)

if final := module_get('final'):
    final()

print(f'Test \'{test_name}\' passed', file=sys.stderr)
