#!/usr/bin/env python3

import argparse, importlib.util, io, os, pathlib, random, selectors, signal, socket, subprocess, sys

parser = argparse.ArgumentParser()
parser.add_argument('module_path')
parser.add_argument('verilated')
parser.add_argument('image')
parser.add_argument('--coverage')
parser.add_argument('--trace')
args = parser.parse_args()

module_path = args.module_path
verilated = args.verilated
image = args.image
coverage_out = args.coverage
trace = args.trace

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
    ('sysctrl', 'sysctrl'),
    ('ttbr', 'ttbr'),
    ('far', 'far'),
    ('fsr', 'fsr'),
    ('dacr', 'dacr'),
    ('bh0', 'bh0'),
    ('bh1', 'bh1'),
    ('bh2', 'bh2'),
    ('bh3', 'bh3'),
    ]

regs = {}
read_reg = lambda r: regs.setdefault(r, 0)

do_output = None
output_buffer = None

def out(*args, **kwargs):
    global output_buffer

    if do_output:
        if output_buffer is None:
            output_buffer = io.StringIO()

        print(*args, **kwargs, file=output_buffer)
        if do_output(None):
            flush_out()
    else:
        print(*args, **kwargs, file=sys.stderr)

def flush_out():
    global do_output, output_buffer
    if output_buffer and output_buffer:
        text = output_buffer.getvalue()
        output_buffer.close()
        output_buffer = None

        try:
            if do_output(text):
                return
        except:
            do_output = None
            print(text, file=sys.stderr)

def write_reg(reg, value):
    assert halted

    value = unsigned(value)
    regs[reg] = value

    print('patch-reg', value, reg, file=sim_end, flush=True)

dumped = []
halted = False

def recv_mem_dump():
    dumped.clear()
    for line in sim_end:
        line = line.strip()
        if line == '=== dump-mem ===' or not line:
            continue
        elif line == '=== end-mem ===':
            break

        try:
            base, data = line.split()
            dumped.append((int(base, 16) << 2, bytes.fromhex(data)))
        except ValueError:
            while_running()
            out(f'{COLOR_BLUE}{line}{COLOR_RESET}')

mem_virtual = True

def set_mem_phys():
    global mem_virtual
    mem_virtual = False

def set_mem_virt():
    global mem_virtual
    mem_virtual = True

def read_mem(base, length, *, may_fail=False, phys=None):
    fragments = []
    i = 0

    if phys is None:
        phys = not mem_virtual

    if halted and length > 0:
        print('dump-phys' if phys else 'dump-mem', base >> 2, (length + base - (base & ~0b11) + 0b11) >> 2, file=sim_end, flush=True)
        recv_mem_dump()

    while length > 0:
        if i >= len(dumped) and may_fail:
            return None

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

def write_mem(base, data):
    assert halted
 
    if not data:
        return

    prefix = read_mem(base & ~0b11, base & 0b11)
    suffix = read_mem(base + len(data), (4 - ((base + len(data)) & 0b11)) & 0b11)
    print('patch-mem ', base >> 2, ' ', prefix.hex(), data.hex(), suffix.hex(), sep='', file=sim_end, flush=True)

    #TODO: Invalidate written addresses only
    dumped.clear()

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

def module_or_env_bool(var):
    value = os.getenv(var.upper())
    if value is not None:
        return bool(int(value))

    return module_get(var, False)

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
            out('cmdline:', subprocess.list2cmdline(exec_args))

    status, color = ('passed', COLOR_GREEN) if success else (f'failed (seed: {seed})', COLOR_RED)
    out( \
        f'{color}Test \'{COLOR_YELLOW}{test_name}{COLOR_RESET}{color}\' ' +
        f'{status}{COLOR_RESET}')

    flush_out()
    sys.exit(0 if success else 1)

def dump_regs():
    order = {item[0]: i for i, item in enumerate(all_regs)}
    next_col = 0

    for reg, value in sorted(regs.items(), key=lambda item: order[item[0]]):
        if next_col > 0:
            out('   ', end='')

        out(f'{reg:<8} = 0x{value:08x}', end='')
        if next_col == 3:
            out()
            next_col = 0
        else:
            next_col += 1

    if next_col != 0:
        out()

printed_while_running = False
def while_running():
    global printed_while_running

    if not printed_while_running:
        out(
            f'{COLOR_BLUE}While running test \'{COLOR_YELLOW}{test_name}' + \
            f'{COLOR_RESET}{COLOR_BLUE}\'{COLOR_RESET}')

        printed_while_running = True

def test_assert(condition, message):
    if not condition:
        while_running()
        out(f'{COLOR_RED}{message()}{COLOR_RESET}')

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
    out( \
        f'{COLOR_BLUE}Test \'{COLOR_YELLOW}{test_name}{COLOR_RESET}' +
        f'{COLOR_BLUE}\' skipped{COLOR_RESET}')

    exit(success=True)

sel = selectors.DefaultSelector()
def interrupt():
    if not halted:
        process.send_signal(signal.SIGUSR1)

def register_interrupt(source):
    sel.register(source, selectors.EVENT_READ, interrupt)

spec = importlib.util.spec_from_file_location('sim', module_path)
module = importlib.util.module_from_spec(spec)

prelude = {
    'out':                out,
    'flush_out':          flush_out,
    'is_halted':          lambda: halted,
    'read_reg':           read_reg,
    'write_reg':          write_reg,
    'read_mem':           read_mem,
    'write_mem':          write_mem,
    'assert_reg':         assert_reg,
    'assert_mem':         assert_mem,
    'init_reg':           init_reg,
    'dump_regs':          dump_regs,
    'split_dword':        split_dword,
    'set_mem_phys':       set_mem_phys,
    'set_mem_virt':       set_mem_virt,
    'register_interrupt': register_interrupt,
    }

prelude.update({k: v for k, v in all_regs})
module.__dict__.update(prelude)
spec.loader.exec_module(module)

mem_dumps = module_get('mem_dumps', [])
do_output = module_get('do_output')

if init := module_get('init'):
    init()

exec_args = [verilated, '--dump-regs']

cycles = module_get('cycles', 1024)
if cycles is not None:
    exec_args.extend(['--cycles', str(cycles)])

if not module_or_env_bool('enable_tty'):
    exec_args.append('--no-tty')

if not module_or_env_bool('enable_video'):
    exec_args.append('--headless')

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

if module_or_env_bool('start_halted'):
    exec_args.append('--start-halted')

sim_end_sock, target_end = socket.socketpair()
sim_end = sim_end_sock.makefile('rw')
target_fd = target_end.fileno()

exec_args.extend(['--control-fd', str(target_fd)])

init_regs = None
exec_args.append(image)

if coverage_out:
    exec_args.extend(['--coverage', coverage_out])

if trace:
    exec_args.extend(['--trace', trace])

exec_args.append(f'+verilator+seed+{seed}')
if not os.getenv('SIM_PULLX', 0):
    exec_args.append('+verilator+rand+reset+2')

process = subprocess.Popen(exec_args, pass_fds=(target_fd,), stderr=subprocess.PIPE)
target_end.close()

in_regs = False
halt = module_get('halt')

done = False
halted = False
faulted = False

def read_ctrl():
    global done, halted, faulted, in_regs

    while True:
        try:
            sim_end_sock.setblocking(False)
            line = next(sim_end)
        except StopIteration:
            done = True
            return
        finally:
            sim_end_sock.setblocking(True)

        if line := line.strip():
            if line == '=== halted ===':
                halted = True
                break
            elif line == '=== fault ===':
                faulted = True
                break
            elif line == '=== dump-regs ===':
                in_regs = True
            elif line == '=== end-regs ===':
                in_regs = False
            elif line == '=== dump-mem ===':
                recv_mem_dump()
            elif in_regs:
                value, reg = line.split()
                regs[reg] = int(value, 16)
            else:
                while_running()
                out(f'{COLOR_BLUE}{line}{COLOR_RESET}')

sel.register(sim_end_sock, selectors.EVENT_READ, read_ctrl)
while not done:
    events = sel.select()
    for key, _ in events:
        (key.data)()

    if faulted:
        if fatal := module_get('fatal'):
            fatal()

        break
    elif halted:
        mode = None
        if halt:
            mode = halt()

        print('step' if mode == 'step' else 'continue', file=sim_end, flush=True)
        flush_out()

        if not halt:
            break

        halted = False

process.wait(timeout=1)
if process.returncode != 0:
    out(f'{COLOR_RED}{verilated} exited with status {process.returncode}{COLOR_RESET}')
    exit(success=False)

if final := module_get('final'):
    final()

if os.getenv('SIM_DUMP', ''):
    dump_regs()
    for rng in mem_dumps:
        out(f'Memory range 0x{rng.start:08x}..0x{rng.stop:08x}')
        out(hexdump(rng.start, read_mem(rng.start, rng.stop - rng.start)))

exit(success=True)
