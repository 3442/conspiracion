def final():
    assert_reg(r0, 0x89ab45cd)
    assert_reg(r1, 0x23)
    assert_reg(r2, 0xffffffcd)
    assert_reg(r3, 0xcd)
    assert_reg(r4, 0x00000045)
    assert_reg(r5, 0xffff89ab)
    assert_reg(sp_svc, 0x2000_0000 - 3)
