import os.path, sys, socket, traceback

loads = {}

if os.path.exists('build/uImage'):
    loads[0x0100000] = 'build/uImage'

if os.path.exists('build/initrd.img'):
    loads[0x1000000] = 'build/initrd.img'

cycles = None
enable_tty = True
start_halted = True
sock, client = None, None

def init():
    global sock

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind(('127.0.0.1', 1234))
    sock.listen()

def halt():
    return yield_to_gdb()

def fatal():
    global stop_reason
    stop_reason = 'fatal'
    yield_to_gdb()

#def do_output(text):
#    if text is None:
#        return not is_halted()
#    elif not client:
#        return False

#    reply(b'O' + hexout(text.encode('ascii')))
#    return True

buffer = b''
stop_reason = None

def yield_to_gdb():
    global client, buffer, stop_reason

    if not client:
        client, peer = sock.accept()
        register_interrupt(client)
        stop_reason = 'reset'

    dead = stop_reason == 'fatal'
    sendStop = True

    if stop_reason == 'break':
        stop_reply = b'S05'
    elif stop_reason == 'reset':
        stop_reply = b'S05'
        stop_reason = 'break'
        sendStop = False
    elif stop_reason == 'fatal':
        stop_reply = b'S0a'

    if sendStop:
        reply(stop_reply)

    detached = False
    while not detached:
        data = client.recv(4096)
        if not data:
            break

        buffer = buffer + data if buffer else data

        try:
            start = buffer.index(b'$')
            marker = buffer.index(b'#', start + 1)
        except ValueError:
            continue

        if marker + 2 >= len(buffer):
            continue

        data = buffer[start + 1:marker]
        cksum = int(buffer[marker + 1:marker + 3], 16)

        if cksum != (sum(data) & 0xff):
            raise Exception(f'bad packet checksum: {buffer[start:marker + 3]}')

        buffer = buffer[marker + 3:]

        client.send(b'+')

        if data == b'?':
            replyout = stop_reply
        elif data == b'c' and not dead:
            return 'continue'
        elif data == b'D':
            replyout = b'OK'
            detached = True
        elif data == b'g':
            replyout = hexout(read_reg(gdb_reg(r)) for r in range(16))
        elif data[0] == b'G':
            for reg, value in enumerate(hexin(data[1:])):
                write_reg(reg, value)
        elif data[0] == b'm'[0]:
            addr, length = (int(x, 16) for x in data[1:].split(b','))
            replyout = hexout(read_mem(addr, length, may_fail = True))
        elif data[0] == b'M'[0]:
            addrlen, data = data[1:].split(b':')
            addr, length = (int(x, 16) for x in addrlen.split(b','))

            data = bytes.fromhex(str(data, 'ascii'))
            assert len(data) == length

            write_mem(addr, data)
            replyout = b'OK'
        elif data[0] == b'p'[0]:
            reg = gdb_reg(int(data[1:], 16))
            replyout = hexout(read_reg(reg) if reg is not None else None)
        elif data[0] == b'P'[0]:
            reg, value = data[1:].split(b'=')
            write_reg(gdb_reg(int(reg, 16)), hexin(value, single=True))
        elif data == b's' and not dead:
            return 'step'
        elif data.startswith(b'qRcmd,'):
            try:
                result = eval(bytes.fromhex(str(data.removeprefix(b'qRcmd,'), 'ascii')))
            except Exception:
                result = None
                out(traceback.format_exc())

            if result is not None:
                out(repr(result))

            flush_out()
            replyout = b'OK'
        else:
            replyout = b''

        reply(replyout)

    if detached:
        client.close()
        client = None

def reply(replyout):
    client.send(b'$' + replyout + b'#' + hexout(sum(replyout) & 0xff, size=1))

def gdb_reg(n):
    if 0 <= n < 8:
        return (r0, r1, r2, r3, r4, r5, r6, r7)[n]

    if n == 15:
        return pc

    if n == 0x19:
        return cpsr

    mode = read_reg(cpsr) & 0b11111
    if 8 <= n < 13:
        if mode == 0b10001:
            regs = (r8_fiq, r9_fiq, r10_fiq, r11_fiq, r12_fiq)
        else:
            regs = (r8_usr, r9_usr, r10_usr, r11_usr, r12_usr)

        return regs[n - 8]

    if 13 <= n < 15:
        if mode == 0b10011:
            regs = (r13_svc, r14_svc)
        elif mode == 0b10111:
            regs = (r13_abt, r14_abt)
        elif mode == 0b11011:
            regs = (r13_und, r14_und)
        elif mode == 0b10010:
            regs = (r13_irq, r14_irq)
        elif mode == 0b10001:
            regs = (r13_fiq, r14_fiq)
        else:
            regs = (r13_usr, r14_usr)

        return regs[n - 13]

    print('bad gdb regnum:', n, file=sys.stderr)
    return None

def hexin(data, *, single=False):
    if type(data) is bytes:
        data = str(data, 'ascii')

    output = []
    for i in range(len(data) >> 3):
        output.append(int.from_bytes(bytes.fromhex(data[i << 3:(i + 1) << 3]), 'little'))

    if single:
        output, = output

    return output

def hexout(data, *, size=4):
    if data is None:
        return b''
    elif type(data) is bytes:
        return data.hex().encode('ascii')
    elif type(data) is int:
        return data.to_bytes(size, 'little').hex().encode('ascii')

    return b''.join(hexout(d) for d in data)
