import sys, socket

start_halted = True

def init():
    global client

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind(('127.0.0.1', 1234))
    sock.listen()
    print('Listening for gdb on', sock.getsockname(), file=sys.stderr)

    client, peer = sock.accept()
    sock.close()
    print('Accepted connection from', peer, file=sys.stderr)

buffer = b''
haltFromStop = False

def halt():
    global buffer, haltFromStop

    if haltFromStop:
        reply(b'S05')
        haltFromStop = False

    while True:
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
            out = b'S05'
        elif data[0] == b'c'[0]:
            assert not data[1:] #TODO
            break
        elif data == b'D':
            out = b'OK'
        elif data == b'g':
            out = hexout(read_reg(gdb_reg(r)) for r in range(16))
        elif data[0] == b'm'[0]:
            addr, length = (int(x, 16) for x in data[1:].split(b','))
            out = hexout(read_mem(addr, length))
        elif data[0] == b'M'[0]:
            addrlen, data = data[1:].split(b':')
            addr, length = (int(x, 16) for x in addrlen.split(b','))

            data = bytes.fromhex(str(data, 'ascii'))
            assert len(data) == length

            write_mem(addr, data)
            out = b'OK'
        elif data[0] == b'p'[0]:
            reg = gdb_reg(int(data[1:], 16))
            out = hexout(read_reg(reg) if reg is not None else None)
        else:
            print('unhandled packet:', data)
            out = b''

        reply(out)

    haltFromStop = True

def reply(out):
    client.send(b'$' + out + b'#' + hexout(sum(out) & 0xff, 1))

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
            regs = (r8_fiq, r9_fiq, r10_fiq, r11_fiq, r12_fiq)

        return regs[n - 8]

    if 13 <= n < 15:
        if mode == 0b10011:
            regs = (r13_svc, r14_svc)
        if mode == 0b10111:
            regs = (r13_abt, r14_abt)
        if mode == 0b11011:
            regs = (r13_und, r14_und)
        if mode == 0b10010:
            regs = (r13_irq, r14_irq)
        if mode == 0b10001:
            regs = (r13_fiq, r14_fiq)
        else:
            regs = (r13_usr, r14_usr)

        return regs[n - 13]

    return None

def hexout(data, size=4):
    if data is None:
        return b''
    elif type(data) is bytes:
        return data.hex().encode('ascii')
    elif type(data) is int:
        return data.to_bytes(size, 'little').hex().encode('ascii')

    return b''.join(hexout(d) for d in data)
