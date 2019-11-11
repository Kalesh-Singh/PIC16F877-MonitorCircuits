;**************************************************************************
;		MONITORING A PIR (PYRO-IR) MOTION SENSOR
; Aim:
;   - Activate a buzzer whenever motion is detected.

; Objectives:
;   - The buzzer must turn on if and only if motion is detected.
;   - The buzzer must be on long enough for you to hear it.
;   - The buzzer must be turned off prior to re-checking the sensor for motion.

;
; Setup:
;   - The PIR has HIGH output voltage when motion is not detected
;     and low voltage (or 0 V) when motion is detected.
;   - The output of the PIR is connected to pin RB1.
;   - The input of the buzzer is connected to pin RD2.
;**************************************************************************
#include <p16f877.inc>

;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;   Set the reset vector here.
;--------------------------------------------------------------------------

	org     0x0000
	goto    start

;--------------------------------------------------------------------------
;			    DELAY SUBROUTINES
;
; Operating speed:  DC ? 20 MHz clock input
;		    DC ? 200 ns instruction cycle
;--------------------------------------------------------------------------

	org     0x0005

;--------------------------------------------------------------------------
;			    100us DELAY
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = (1[decfsz] + 1[skip] + 2[return]) x 200ns = 800ns
; Calling delay100us =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 800ns + 400ns = 1600ns
;
; Remaining Time = 1us - Setup Time = 100000ns - 1600ns = 98400ns
;
; Loop Cycle Time (not for last cycle) = (1[decfsz] + 2[goto]) x 200ns = 600ns

; Remaining Time = Count100us x Loop Cycle Time
; 98400ns = Count100us x 600ns

; Hence, Count100us = 164
;--------------------------------------------------------------------------
Count100us  equ		0x20

delay100us  movlw	0xA4		; Load d'164 into W			(1 cycle)
	    movwf	Count100us	; Move W into Count100us		(1 cycle)

again100us  decfsz	Count100us	; Decrement and test if Count100us = 0? (1 cycle)
	    goto	again100us	; NO => Keep waiting			(2 cycles)
					; Skip					(1 cycle)
	    return			; YES => Return				(2 cycles)

;--------------------------------------------------------------------------
;			    10ms DELAY
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = 100000ns + (1[decfsz] + 1[skip] + 2[return]) x 200ns = 100800ns
; Calling delay10ms =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 100800ns + 400ns = 101600ns
;
; Remaining Time = 10ms - Setup Time = 10000000ns - 101600ns = 9898400ns
;
; Loop Cycle Time (not for last cycle) = 100000ns + (1[decfsz] + 2[goto]) x 200ns = 100600ns

; Remaining Time = Count10ms x Loop Cycle Time
; 9898400ns = Count10ms x 100600ns

; Hence, Count10ms = 98.393... = 98

; 9898400ns - (100600ns x 98) = 39600ns
;------------------------------------------------------------------
; Count 39600ns for the extra fractional part of the remaining time

; Counter Setup = (1[movlw] +1[movwf]+1[nop]+1[nop]) x 200ns = 800ns
; Last Cycle of Loop Time = (1[decfsz] + 1[skip]) x 200ns = 400ns

; Setup Time = 800ns + 400ns = 1200ns
;
; Remaining Time = 39600ns - Setup Time = 39600ns - 1200ns = 38400ns
;
; Loop Cycle Time (not for last cycle) = (1[decfsz] + 2[goto]) x 200ns = 600ns

; Remaining Time = Count10ms x Loop Cycle Time
; 38400ns = Count39600ns x 600ns
; Therefore, Count39600ns = 64
;--------------------------------------------------------------------------
Count10ms	equ	0x21
Count39600ns	equ	0x22

delay10ms   movlw	0x62		; Load d'98 into W			(1 cycle)
	    movwf	Count10ms	; Move W into Count10ms			(1 cycle)

again10ms   call	delay100us
	    decfsz	Count10ms	; Decrement and test if Count10ms = 0?  (1 cycle)
	    goto	again10ms	; NO => Keep waiting			(2 cycles)
					; Skip					(1 cycle)

	    movlw	0x40		; Load d'64 into W			(1 cycle)
	    movwf	Count39600ns	; Move W into Count39600ns		(1 cycle)
	    nop				; (1 cycle)
	    nop				; (1 cycle)
again39600ns
	    decfsz	Count39600ns	; Decrement and test if Count39600ns = 0?  (1 cycle)
	    goto	again39600ns	; NO => Keep waiting			(2 cycles)
					; Skip					(1 cycle)

	    return			; YES => Return				(2 cycles)
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; Main Program
;--------------------------------------------------------------------------
start	bsf	STATUS, RP0	; Select Bank 1
	bsf	TRISB, RB1	; Set TRISB<1> = 1 so PORTB<1> is an INPUT
	bcf	TRISD, RD2	; Set TRISD<2> = 0 so PORTD<2> is an OUTPUT
	bcf	STATUS, RP0	; Select Bank 0

monitor	bcf	PORTD, RD2	; Turn the buzzer off
	call	delay100us
	btfsc   PORTB, RB1	; Does PORTB<1> = 0? YES => Skip next instruction
	goto	monitor		; NO => Keep monitoring for motion
	bsf	PORTD, RD2	; YES => Turn on buzzer
	call	delay100us
	goto    monitor		; Keep monitoring for motion

        end

