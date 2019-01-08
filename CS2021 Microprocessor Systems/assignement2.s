	AREA	AsmTemplate, CODE, READONLY
	IMPORT	main

	EXPORT	start
start

IO0DIR	EQU	0xE0028008
IO0SET	EQU	0xE0028004
IO0CLR	EQU	0xE002800C

	ldr	r1,=IO0DIR
	ldr	r2,=0x0000FF00	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO0SET
	ldr r11,=IO0CLR
; r1 points to the SET register
; r2 points to the CLEAR register
	ldr r6,=0
	ldr r4,=LUT
loop
	add r6,r6, #1
	ldr r5, [r4]
	lsl r5, #8
	str r5, [r1]
	
	add r4, #1
	
	ldr	r10,=6000000
dloop	subs	r10,r10,#1
	bne	dloop
	
	CMP r6, #16
	beq endLoop
	
	ldr	r12,=0x0000FF00
	str r12, [r11]
	
	B loop
endLoop

	ldr r6,= 0
	ldr r4,=LUT
	b loop
	
	AREA joe, DATA, READONLY
LUT	DCB 2_00111111
	DCB 2_00000110
	DCB 2_01011011
	DCB	2_01001111	;{2,3}
	DCB 2_01100110
	DCB 2_01101101	;{4,5}
	DCB 2_01111101
	DCB 2_00000111	;{6,7}
	DCB 2_01111111
	DCB 2_01100111	;{8,9}
	DCB 2_01110111
	DCB 2_01111100	;{a,b}
	DCB 2_00111001
	DCB	2_01011110	;{c,d}
	DCB 2_01111001
	DCB	2_01110001	;{e,f}
	
	END	