def init():
    init_reg(r0, -10)
    init_reg(r1, 23)
    init_reg(r2, -1234)

def final():
    assert_reg(r0, -10 * 23 - 1234)
