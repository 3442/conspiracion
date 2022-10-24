.global reset
reset:
	ldr r0, =0xffffffff
	ldr r1, =0xbaaaaa9f
	ldr r2, =0x00000054
	ldr r3, =0xfffffffe
	# r3 = 5d55
	lsr r3, r1, #17
	# r0 = 15000
	lsl r0, r2, #10
	# tmp = aaa9f000
	# r3 = aaa9fd55
	orr r3, r3, r1, lsl #12
	# tmp = 0
	# r2 = r0 = 00015000
	eor r2, r0, r2, asr #7
	mov pc, lr
