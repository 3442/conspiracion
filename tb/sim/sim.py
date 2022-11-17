#!/usr/bin/env python3

import importlib.util, os, pathlib, random, subprocess, sys

module_path, verilated, image = sys.argv[1:]
test_name = pathlib.Path(module_path).stem
module = None

seed = os.getenv('SIM_SEED', str(random.randint(0, 0x7fff_ffff)))

all_regs = [
    ('r0', 'r0'),
    ('r1', 'r1'),
    ('r2', 'r2'),
    ('r3', 'r3'),
    ('r4', 'r4'),
    ('r5', 'r5'),
    ('r6', 'r6'),
    ('r7', 'r7'),
    ('r8', 'r8_usr'),
    ('r8_usr', 'r8_usr'),
    ('r8_fiq', 'r8_fiq'),
    ('r9', 'r9_usr'),
    ('r9_usr', 'r9_usr'),
    ('r9_fiq', 'r9_fiq'),
    ('r10', 'r10_usr'),
    ('r10_usr', 'r10_usr'),
    ('r10_fiq', 'r10_fiq'),
    ('r11', 'r11_usr'),
    ('r11_usr', 'r11_usr'),
    ('r11_fiq', 'r11_fiq'),
    ('r12', 'r12_usr'),
    ('r12_usr', 'r12_usr'),
    ('r12_fiq', 'r12_fiq'),
    ('sp', 'r13_usr'),
    ('sp_usr', 'r13_usr'),
    ('sp_svc', 'r13_svc'),
    ('sp_abt', 'r13_abt'),
    ('sp_und', 'r13_und'),
    ('sp_irq', 'r13_irq'),
    ('sp_fiq', 'r13_fiq'),
    ('r13', 'r13_usr'),
    ('r13_usr', 'r13_usr'),
    ('r13_svc', 'r13_svc'),
    ('r13_abt', 'r13_abt'),
    ('r13_und', 'r13_und'),
    ('r13_irq', 'r13_irq'),
    ('r13_fiq', 'r13_fiq'),
    ('lr', 'r14_usr'),
    ('lr_usr', 'r14_usr'),
    ('lr_svc', 'r14_svc'),
    ('lr_abt', 'r14_abt'),
    ('lr_und', 'r14_und'),
    ('lr_irq', 'r14_irq'),
    ('lr_fiq', 'r14_fiq'),
    ('r14', 'r14_usr'),
    ('r14_usr', 'r14_usr'),
    ('r14_svc', 'r14_svc'),
    ('r14_abt', 'r14_abt'),
    ('r14_und', 'r14_und'),
    ('r14_irq', 'r14_irq'),
    ('r14_fiq', 'r14_fiq'),
    ('pc', 'pc'),
    ('r15', 'pc'),
    ('cpsr', 'cpsr'),
    ('spsr_svc', 'spsr_svc'),
    ('spsr_abt', 'spsr_abt'),
    ('spsr_und', 'spsr_und'),
    ('spsr_irq', 'spsr_irq'),
    ('spsr_fiq', 'spsr_fiq'),
    ]

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

def module_get(attr, default=None):
    return getattr(module, attr, default) if module else None

COLOR_RESET  = '\033[0m'
COLOR_RED    = '\033[31;1m'
COLOR_GREEN  = '\033[32m'
COLOR_YELLOW = '\033[33;1m'
COLOR_BLUE   = '\033[34;1m'

def exit(*, success):
    global seed

    if not success:
        while_running()
        if exec_args:
            print('cmdline:', subprocess.list2cmdline(exec_args), file=sys.stderr)

    status, color = ('passed', COLOR_GREEN) if success else (f'failed (seed: {seed})', COLOR_RED)
    print( \
        f'{color}Test \'{COLOR_YELLOW}{test_name}{COLOR_RESET}{color}\' ' +
        f'{status}{COLOR_RESET}', file=sys.stderr)

    sys.exit(0 if success else 1)

def dump_regs():
    order = {item[0]: i for i, item in enumerate(all_regs)}
    next_col = 0

    for reg, value in sorted(regs.items(), key=lambda item: order[item[0]]):
        if next_col > 0:
            print('   ', end='', file=sys.stderr)

        print(f'{reg:<8} = 0x{value:08x}', end='', file=sys.stderr)
        if next_col == 3:
            print(file=sys.stderr)
            next_col = 0
        else:
            next_col += 1

    if next_col != 0:
        print(file=sys.stderr)

printed_while_running = False
def while_running():
    global printed_while_running

    if not printed_while_running:
        print(
            f'{COLOR_BLUE}While running test \'{COLOR_YELLOW}{test_name}' + \
            f'{COLOR_RESET}{COLOR_BLUE}\'{COLOR_RESET}')

        printed_while_running = True

def test_assert(condition, message):
    if not condition:
        while_running()
        print(f'{COLOR_RED}{message()}{COLOR_RESET}', file=sys.stderr)

        if regs:
            dump_regs()

        exit(success=False)

def unsigned(n):
    assert -0x8000_0000 <= n <= 0xffff_ffff
    return n + 0x1_0000_0000 if n < 0 else n

def split_dword(n):
    assert -0x8000_0000_0000_0000 <= n <= 0xffff_ffff_ffff_ffff
    if n < 0:
        n += 0x1_0000_0000_0000_0000

    return (n >> 32, n & 0xffff_ffff)

def int_bytes(n):
    return n.to_bytes(4, 'little', signed=n < 0) if type(n) is int else n

def assert_reg(r, expected):
    actual = read_reg(r)
    expected = unsigned(expected)

    test_assert( \
        actual == expected, \
        lambda: f'Register {r} = 0x{actual:08x}, expected 0x{expected:08x}')

def assert_mem(base, value):
    if type(value) is list:
        value = b''.join(int_bytes(w) for w in value)
    else:
        value = int_bytes(value)

    actual = read_mem(base, len(value))
    test_assert( \
        actual == value, \
        lambda: \
        f'Memory at 0x{base:08x} holds:\n{hexdump(base, actual)}\n' + \
        f'But this was expected instead:\n{hexdump(base, value)}')

init_regs = {}

def init_reg(r, value):
    global init_regs 
    assert init_regs is not None
    init_regs[r] = unsigned(value)

if test_name in os.getenv('SIM_SKIP', '').split(','):
    print( \
        f'{COLOR_BLUE}Test \'{COLOR_YELLOW}{test_name}{COLOR_RESET}' +
        f'{COLOR_BLUE}\' skipped{COLOR_RESET}', file=sys.stderr)

    exit(success=True)

spec = importlib.util.spec_from_file_location('sim', module_path)
module = importlib.util.module_from_spec(spec)

prelude = {
    'read_reg':    read_reg,
    'read_mem':    read_mem,
    'assert_reg':  assert_reg,
    'assert_mem':  assert_mem,
    'init_reg':    init_reg,
    'split_dword': split_dword,
    }

prelude.update({k: v for k, v in all_regs})
module.__dict__.update(prelude)
spec.loader.exec_module(module)

cycles = module_get('cycles', 1024)
mem_dumps = module_get('mem_dumps', [])

if init := module_get('init'):
    init()

exec_args = [verilated, '--headless', '--cycles', str(cycles), '--dump-regs']

for rng in mem_dumps:
    length = rng.stop - rng.start
    assert rng.start >= 0 and rng.stop > rng.start \
       and rng.step == 1 and ((rng.start | length) & 3) == 0

    exec_args.extend(['--dump-mem', f'{rng.start >> 2},{length >> 2}'])

for r, value in init_regs.items():
    exec_args.extend(['--init-reg', f'{r}={value}'])

for addr, const in module_get('consts', {}).items():
    exec_args.extend(['--const', f'{addr},{const}'])

for addr, filename in module_get('loads', {}).items():
    exec_args.extend(['--load', f'{addr},{filename}'])

init_regs = None
exec_args.append(image)

exec_args.append(f'+verilator+seed+{seed}')
if not os.getenv('SIM_PULLX', 0):
    exec_args.append('+verilator+rand+reset+2')

output = subprocess.run(exec_args, stdout=subprocess.PIPE, text=True)
if output.returncode != 0:
    exit(success=False)

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
    else:
        while_running()
        print(f'{COLOR_BLUE}{line}{COLOR_RESET}')

if final := module_get('final'):
    final()

if os.getenv('SIM_DUMP', ''):
    dump_regs()
    for rng in mem_dumps:
        print(f'Memory range 0x{rng.start:08x}..0x{rng.stop:08x}')
        print(hexdump(rng.start, read_mem(rng.start, rng.stop - rng.start)))

exit(success=True)
