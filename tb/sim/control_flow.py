def init():
    init_reg(r0, 0xdeadc0de);
    init_reg(r1, 0xbaaaaaad);

def final():
    assert_reg(r0, 0xae13ab83)
