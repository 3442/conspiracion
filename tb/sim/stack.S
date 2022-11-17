.global reset
reset:
	ldr  r0, =stub1
	ldr  r1, =stub2
	push {r0, r1, lr}
	mov  r2, sp
	pop  {r5, pc}

stub1:
	ldr  r0, =0x01234567
	pop  {pc}

stub2:
	mov  r3, sp
	ldr  r1, =0x89abcdef
	push {r5}
	mov  r4, sp
	pop  {lr}
	mov  r5, sp
	bx   lr
