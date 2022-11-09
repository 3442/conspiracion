START = 0x0000_1000
END   = 0x0000_2000

cycles = 30000
mem_dumps = [range(START, END)]

def final():
    assert_mem(START, list(range(0, (END - START) >> 2)))
