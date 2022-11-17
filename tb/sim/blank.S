.global reset

reset:
	ldr r0, =0x38000000
	ldr r1, =0xffffffff
	ldr r2, =(640*480)

	.loop:
	str r1, [r0], #4
    subs r2, r2, #1
	bne .loop

	mov pc, lr