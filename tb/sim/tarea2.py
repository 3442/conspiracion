N = 20

mem_dumps = [range(0x100, 0x108), range(0x200, 0x200 + 4 * N)]

def init():
    init_reg(r0, N)

def final():
    a, b, s = 1, 1, 0
    mem = []

    for _ in range(N):
        s += a
        c = a + b
        mem.append(a)
        a, b = b, c

        if s > 10000:
            break

    assert_reg(r5, 0x104)
    assert_mem(0x100, [s, 0xff if s > 10000 else 0xaa])
    assert_mem(0x200, mem)
