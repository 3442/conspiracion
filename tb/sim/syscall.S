.global reset
reset:
	# Switch to user mode
	mov  r0, lr
	mrs  r1, cpsr
	bic  r1, r1, #0b1111
	msr  cpsr_fxc, r1
	mov  lr, r0

	mov  r0, #123
	swi  #0
	mov  pc, lr

.global swi
swi:
	add  r0, r0, #1
	movs pc, r14
