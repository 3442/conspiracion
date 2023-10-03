.global reset

reset:
	adr   r0, cpus

.inc_cpus:
	ldrex r1, [r0]
	add   r1, r1, #1
	strex r2, r1, [r0]
	teq   r2, #0
	bne   .inc_cpus

	cmp   r1, #1
	movne pc, lr

	ldr   r1, =0x30140000
	ldr   r2, [r1]
	ldr   r3, =0x01010100
	str   r3, [r1]
	ldr   r3, [r1]
.wait:
	ldr   r1, [r0]
	b     .wait

cpus: .word 0
