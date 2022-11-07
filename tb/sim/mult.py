A, B, C = -123456, 7890, -98765

def init():
    init_reg(r0, A)
    init_reg(r1, B)
    init_reg(r2, C)

def final():
    hi, lo = split_dword(A * A * (A + 2 * B) + C)
    assert_reg(r0, lo)
    assert_reg(r1, hi)
