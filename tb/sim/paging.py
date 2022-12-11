cycles = 4096

def final():
    assert_reg(r0, 0x01234567)
    assert_reg(r1, 0x89abcdef)
    assert_reg(r2, 0x89abcde0)
    assert_reg(r3, 0b0101) # Section translation fault, p. 720
    assert_reg(r4, read_reg(r5))
