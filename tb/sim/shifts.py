def final():
	assert_reg(r0, 0x00015000)
	assert_reg(r2, 0x00015000)
	assert_reg(r3, 0xaaa9fd55)
	assert_reg(r4, 0)
	assert_reg(r5, -1)
