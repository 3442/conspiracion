def final():
    assert_reg(r0, 0x0123_4567)
    assert_reg(r1, 0x89ab_cdef)
    assert_reg(r2, 0x1fff_fff4)
    assert_reg(r3, 0x1fff_fffc)
    assert_reg(r4, 0x1fff_fff8)
    assert_reg(r5, 0x1fff_fffc)
    assert_reg(sp_svc, 0x2000_0000)
