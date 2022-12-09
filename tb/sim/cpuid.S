.global reset
reset:
	mrc p15, 0, r0, c0, c0, 0
	mov pc, lr
