;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 1DT301, Computer Technology I
; Date: 2018-10-05
; Author:
; Amata Anantaprayoon (aa224iu)
; Adell Tatrous (at222ux)
;
; Lab number: 4
; Title: Timer and UART
;
; Hardware: STK600, CPU ATmega2560
;
; Function: A program uses the serial communication port0(RS232).
;			The program should receive characters that are sent from the computer, 
;  			and show the code on the LEDs and send back to the terminal by using interrupt
;
; Input ports: RS232
;
; Output ports: PORTB, RS232
;
; Subroutines: 
;
; Included files: m2560def.inc
;
; Other information: echo
;
; Changes in program: 2018-10-05: Implementation
;					
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
.include "m2560def.inc"
.def temp = r16
.def char = r17
.def flag = r18
.equ UBRR_val = 12					; osc. = 1MHz, 4800 bps

.CSEG
.org 0x00
	rjmp start

.org URXC1addr 
	rjmp getChar

.org UDRE1addr
	rjmp putChar


.org 0x72
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

start:
	ldi temp, 0xFF					; set portB to output
	out DDRB, temp 
	ldi temp, 0x55					; Initial value to outputs
	out PORTB, temp

	ldi temp, UBRR_val				; store PErscaler value in UBRR1L
	sts UBRR1L, temp

	;TX = Transmitter, RX = receiver
	ldi temp, (1<<RXEN1) | (1<<TXEN1) | (1<<RXCIE1) | (1<<UDRIE1)
	sts UCSR1B, temp				; set TX and RX enable flags

sei
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

main:
	call portOutput
rjmp main

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;get char from PuTTY
getChar:
	
	ldi flag, 1						; flag up
	lds temp, UCSR1A 				; read UCSR1A I/O register to temp(r16)
	sbrs temp, RXC1					; RXC1=1 => new char
		rjmp getChar				; if temp clear = getChar
	lds char, UDR1					; read char in UDR

reti
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

portOutput:
	
	com char
	out PORTB, char					; lights up LEDs
	com char

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

;echo char to PuTTY
putChar:
	
	cpi flag, 0						; if flag = 0 means we already show the char in PuTTY
	brne echo
reti
	
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

echo:

	lds temp, UCSR1A				; read UCSR1A I/O register to temp(r16)
	sbrs temp, UDRE1				; check if UDRE1 is empty
		rjmp putChar				; if empty -> putchar
	sts UDR1, char					; write char to UDR1
	ldi flag, 0
ret

