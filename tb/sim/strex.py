mem_dumps = [range(0x1000, 0x1008)]

def final():
    assert_reg(r2, 1)
    assert_reg(r5, 1)
    assert_reg(r6, 0)

    assert_mem(0x1000, 0xfedcba98)
    assert_mem(0x1004, 0x01234567)
