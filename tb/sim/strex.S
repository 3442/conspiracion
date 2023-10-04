.global reset

reset:
	ldr   r0, =0x1000
	ldr   r1, =0x01234567
	str   r1, [r0]
	mvn   r1, r1
	str   r1, [r0, #4]
	mov   r12, lr
	swi   #0
	mov   lr, r12
	strex r2, r0, [r0] @ Debe fallar
	ldrex r3, [r0]
	add   r0, r0, #4
	ldrex r4, [r0]
	strex r5, r3, [r0] @ Debe fallar
	sub   r0, r0, #4
	strex r6, r4, [r0] @ Debe servir
	mov   pc, lr

.global swi
swi:
	movs  pc, lr
