.global reset

reset:
    mov r5, #3
    mov r7, #6
    mov r9, #9
    mov sp, #256
    str r5, [sp, #-4]
    mov r0, #69
    mov r1, #-10

	.loop1:
    tst r1, r1
    beq .loop2
    add r1, r1, #1
    sub r0, r0, #1
    b   .loop1

	.loop2:
    b   .loop2
