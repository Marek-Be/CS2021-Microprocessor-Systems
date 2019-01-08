	AREA	Practical3, CODE, READONLY
	IMPORT	main

	EXPORT	start
start

IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN	EQU	0xE0028010
	
	; Definitions  -- references to 'UM' are to the User Manual.

	; Timer Stuff -- UM, Table 173

T0	equ	0xE0004000		; Timer 0 Base Address
T1	equ	0xE0008000

IR	equ	0			; Add this to a timer's base address to get actual register address
TCR	equ	4
MCR	equ	0x14
MR0	equ	0x18

TimerCommandReset	equ	2
TimerCommandRun	equ	1
TimerModeResetAndInterrupt	equ	3
TimerResetTimer0Interrupt	equ	1
TimerResetAllInterrupts	equ	0xFF
	
; VIC Stuff -- UM, Table 41
VIC	equ	0xFFFFF000		; VIC Base Address
IntEnable	equ	0x10
VectAddr	equ	0x30
VectAddr0	equ	0x100
VectCtrl0	equ	0x200

Timer0ChannelNumber	equ	4	; UM, Table 63
Timer0Mask	equ	1<<Timer0ChannelNumber	; UM, Table 63
IRQslot_en	equ	5		; UM, Table 58

	ldr	r1,=IO1DIR
	ldr	r2,=0x000f0000	;select P1.19--P1.16
	str	r2,[r1]		;make them outputs
	ldr	r1,=IO1SET
	str	r2,[r1]		;set them to turn the LEDs off
	ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

; initialisation code

; Initialise the VIC
	ldr	r6,=VIC			; looking at you, VIC!

	ldr	r7,=irqhan
	str	r7,[r6,#VectAddr0] 	; associate our interrupt handler with Vectored Interrupt 0

	mov	r7,#Timer0ChannelNumber+(1<<IRQslot_en)
	str	r7,[r6,#VectCtrl0] 	; make Timer 0 interrupts the source of Vectored Interrupt 0

	mov	r7,#Timer0Mask
	str	r7,[r6,#IntEnable]	; enable Timer 0 interrupts to be recognised by the VIC

	mov	r7,#0
	str	r7,[r6,#VectAddr]   	; remove any pending interrupt (may not be needed)

; Initialise Timer 0
	ldr	r6,=T0			; looking at you, Timer 0!

	mov	r7,#TimerCommandReset
	str	r7,[r6,#TCR]

	mov	r7,#TimerResetAllInterrupts
	str	r7,[r6,#IR]

	ldr	r7,=(14745600/200)-1	 ; 5 ms = 1/200 second
	str	r7,[r6,#MR0]

	mov	r7,#TimerModeResetAndInterrupt
	str	r7,[r6,#MCR]

	mov	r7,#TimerCommandRun
	str	r7,[r6,#TCR]

;from here, initialisation is finished, so it should be the main body of the main program
	
	ldr r3,=0x00010000
	str	r3,[r2]	   	; clear the bit -> turn on the LED
	
	ldr r8,=count

	ldr	r5,=0x00100000	; end when the mask reaches this value
wloop	
	ldr	r3,=0x00010000	; start with P1.16.
floop
	str	r3,[r2]	   	; clear the bit -> turn on the LED

;delay for about a half second
dloop 
	ldr r9,[r8]
	cmp r9,#200
	blt dloop
	mov r9,#0
	strb r9,[r8]
	
	str	r3,[r1]		;set the bit -> turn off the LED
	mov	r3,r3,lsl #1	;shift up to next bit. P1.16 -> P1.17 etc.
	cmp	r3,r5
	bne	floop
	b	wloop
;stop	B	stop


	AREA	InterruptStuff, CODE, READONLY
irqhan	sub	lr,lr,#4
	stmfd	sp!,{r0-r1,lr}	; the lr will be restored to the pc

;this is the body of the interrupt handler

;here you'd put the unique part of your interrupt handler
;all the other stuff is "housekeeping" to save registers and acknowledge interrupts

	ldr r0,=count
	ldrb r1,[r0]
	add r1,r1,#1
	strb r1,[r0]

;this is where we stop the timer from making the interrupt request to the VIC
;i.e. we 'acknowledge' the interrupt
	ldr	r0,=T0
	mov	r1,#TimerResetTimer0Interrupt
	str	r1,[r0,#IR]	   	; remove MR0 interrupt request from timer

;here we stop the VIC from making the interrupt request to the CPU:
	ldr	r0,=VIC
	mov	r1,#0
	str	r1,[r0,#VectAddr]	; reset VIC

	ldmfd	sp!,{r0-r1,pc}^	; return from interrupt, restoring pc from lr
				; and also restoring the CPSR

	AREA	Subroutines, CODE, READONLY

	AREA	Stuff, DATA, READWRITE
count	
	dcb 0x0000

	END