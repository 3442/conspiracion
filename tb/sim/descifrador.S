.global reset
reset:

@ IO utilizado:
@  5 switches para la llave
@  1 switch de selección de algoritmo (xor o not)
@  1 botón de inicio

.equ START_BUTTON, 0x30050000 @ Dirección de memoria del botón
.equ KEY_SWITCHES, 0x30060000 @ Dirección de memoria de los switches
.equ START, 0x00010000 @ Dirección de memoria de los pixeles
.equ VRAM, 0x38000000 

@ Dirección inicial de lectura, contador y tamaño de la imagen
ldr r1, =START
ldr r11, =VRAM
mov r7, #0x0
ldr r8, =(640*480)

init:
  ldr  r4, [r1], #4 	@ Guarda en r4 el dato en la posición de memoria de start
  str  r4, [r11], #4  @ Vuelve a guardar en memoria ya modificado
  add  r7, r7, #1  	  @ Incrementa contador de tamaño de la imagen
  cmp  r7, r8    	@ Compara contador con tamaño de la imagen 640 * 480
  bne  init

ldr r1, =START
ldr r11, =VRAM
mov r7, #0x0

@Esperar botón
ldr r2, =START_BUTTON
ldr r3, =KEY_SWITCHES

idle:
  ldr r5, [r2]  @ Lee valor del botón
  ldr r6, [r3]  @ Lee valores de los switches 
  tst r5, #1    @ Si el botón de inicio es 1, se salta a start
  beq idle

@ Verificar el algoritmo seleccionado
tst r6, #1    	@ Si el valor es 1, se salta a xor, si es 0 a not
bne xor
  
@ Recorrer la memoria desde START y hacer not al valor en cada posicion
@ y volverlo a guardar
not:
  @Procesar la mask
  ldr r0, =0x00ffffff
	b loop

xor:
@Procesar la llave
	lsr r9, r6, #1
	mov r0, r9
	orr r0, r0, r9, lsl #8
	orr r0, r0, r9, lsl #16

loop:
  ldr  r4, [r1] 	@ Guarda en r4 el dato en la posición de memoria de start
  eor  r4, r4, r0  	  @ Hace XOR entre r4 
  str  r4, [r1], #4  @ Vuelve a guardar en memoria ya modificado
  add  r7, r7, #1  	  @ Incrementa contador de tamaño de la imagen
  cmp  r7, r8    	@ Compara contador con tamaño de la imagen 640 * 480
  bne  loop

release:
  ldr r5, [r2]  @ Lee valor del botón
  tst r5, #1    @ Si el botón de inicio es 1, se salta a start
  bne release

  b reset