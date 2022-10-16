SP = 256

mem_dumps = [range(SP - 4, SP)]

def final():
    assert_reg(r0, 59)
    assert_reg(r1, 0)
    assert_reg(sp, SP)
    assert_mem(SP - 4, 3)
