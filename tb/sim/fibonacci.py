BASE = 0x0001_0000
COUNT = 20

mem_dumps = [range(BASE, BASE + 4 * COUNT)]

def final():
    words = []
    a, b = 1, 1

    for _ in range(COUNT):
        words.append(a)
        c = a + b
        a, b = b, c

    assert_mem(BASE, words)
