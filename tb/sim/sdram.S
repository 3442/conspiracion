.global reset

reset:
	ldr r0, =0x1000
	ldr r1, =0x2000
	mov r2, #0

	.loop:
	str r2, [r0], #4
	add r2, r2, #1
	cmp r0, r1
	bne .loop

	mov pc, lr
