START = 0x0000_1004
END   = 0x0000_1100

mem_dumps = [range(START, END)]

def final():
    assert_mem(START, list(range(42, 42 + (END - START) >> 2)))
