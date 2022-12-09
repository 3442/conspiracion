.global reset
reset:
	mrc p15, 0, r0, c0, c0, 0b000
	mrc p15, 0, r1, c0, c0, 0b001
	mrc p15, 0, r2, c0, c0, 0b010
	mrc p15, 0, r3, c0, c0, 0b011
	mrc p15, 0, r4, c0, c0, 0b100
	mov pc, lr
