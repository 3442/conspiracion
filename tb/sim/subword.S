.global reset

reset:
	ldr   r0, =0x01234567
	push  {r0}
	ldr   r0, =0x89ab
	ldrb  r1, [sp, #2]
	strh  r0, [sp, #2]
	mov   r2, #0xcd
	strb  r2, [sp]
	ldr   r0, [sp]
	ldrsb r2, [sp]
	ldrb  r3, [sp]
	ldrsb r4, [sp, #1]!
	ldrsh r5, [sp, #1]
	mov   pc, lr
