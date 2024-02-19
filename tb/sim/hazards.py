SP = 256

cycles = 1024
mem_dumps = [range(SP - 4, SP)]

def final():
    assert_reg(r0, 60)
    assert_reg(r1, 0)
    assert_reg(sp_svc, SP)
    assert_mem(SP - 4, 3)
