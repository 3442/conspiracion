.global reset
reset:

.equ START_BUTTON, 0x30050000 @Cambiar a dirección de memoria del botón
.equ KEY_SWITCHES, 0x30060000 @Cambiar a dirección de memoria de los switches

@Copiar buffer a VRAM (?)
	@ Esto es para guardar en memoria cada pixel
	@ en este caso se guarda un valor de 0xCA por ejemplo desde la posicion 0x100
	@ dos veces, hasta la 0x104 por ejemplo
	mov	r1, #0x100 
	mov	r2, #0xCA 
	mov	r7, #0x0
	
load:
	str	r2, [r1] 
	add	r1, r1, #4
	add	r7, r7, #1
	cmp	r7, #2
	bne	load

@Esperar botón
	ldr r2, =START_BUTTON
	ldr r3, =KEY_SWITCHES
	
@Prueba: poner botón de start en 1
	mov r9, #0x30050000
	mov r5, #1
	str r5, [r9]
@Prueba: poner switches en 1010
	mov r9, #0x30060000
	mov r5, #0b1011
	str r5, [r9]
	
idle:
	ldr r5, [r2] @Leer valor del botón
	ldr r6, [r3] @Leer valores de los switches 
	cmp r5, #1
	beq start
	b	idle


start:
	@Verificar el algoritmo seleccionado
	ldr r6, [r3]
	and r6, r6, #1
	cmp r6, #1
	beq not
	cmp r6, #0
	beq	xor
	
@Reiniciar contador y posicion de memoria	
	mov	r1, #0x100
	mov	r7, #0x0

@Recorrer la memoria desde #0x100 y hacer not al valor en cada posicion
@ y volverlo a guardar
not:
	ldr	r4, [r1]
	mvn	r4, r4
	str	r4, [r1] 	@Se vuelve a guardar en memoria ya modificado
	add	r1, r1, #4
	add	r7, r7, #1
	cmp	r7, #1000
	bne	not
	b	halt
		
xor:
	ldr	r4, [r1]
	ldr r6, [r3]
	lsr r6, r6, #1
	eor	r4, r4, r6
	str	r4, [r4] 	@Se vuelve a guardar en memoria ya modificado
	add	r1, r1, #4
	add	r7, r7, #1
	cmp	r7, #1000
	bne	xor
	b	halt

halt:
	b halt