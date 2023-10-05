.global reset

reset:
	ldr r0, =0x1004
	ldr r1, =0x1100
	mov r2, #42

	.loop:
	str r2, [r0], #4
	add r2, r2, #1
	cmp r0, r1
	bne .loop

	mov pc, lr
