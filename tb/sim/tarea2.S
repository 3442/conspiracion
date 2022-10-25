@ Tarea 2, CE3201 Taller de Diseño Digital
@ Alejandro Soto Chacón, 2019008164

.global fibonacci
fibonacci:
	mov   r0, #0x150
	ldr   r0, [r0]
	mov   r1, #0x200
	mov   r2, #1
	mov   r3, #1
	mov   r4, #0
	tst   r0, r0
	beq   .end
	ldr   r6, =10000 @ Relativo a PC
	.loop:
	add   r5, r2, r3
	add   r4, r4, r2
	str   r2, [r1], #4
	mov   r2, r3
	mov   r3, r5
	cmp   r4, r6
	bhi   .end
	subs  r0, r0, #1
	bne   .loop
	.end:
	mov   r5, #0x100
	str   r4, [r5], #4
	mov   r4, #0xff
	mov   r6, #0xaa
	@ Necesariamente se cumple alguna de las dos condiciones
	@ ya que una es la opuesta de la otra
	strhi r4, [r5]
	strls r6, [r5]
	mov   pc, lr

@ Punto de entrada, requerido ya que el simulador solamente es capaz
@ ed establecer condiciones iniciales de registros, no de memoria.
@ En este caso se pasa el número de iteraciones en r0 y el stub lo
@ escribe en la posición correcta.
.global reset
reset:
	mov r1, #0x150
	str r0, [r1]
	b   fibonacci
