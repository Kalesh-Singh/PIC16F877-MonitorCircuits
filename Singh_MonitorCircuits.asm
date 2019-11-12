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
;			    100us Delay
;--------------------------------------------------------------------------
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
Count100us	equ	    0x20

delay100us	movlw	    d'164'	    ; Load d'164' into W		    (1 cycle)
		movwf	    Count100us	    ; Move W into Count100us		    (1 cycle)

again100us	decfsz	    Count100us	    ; Decrement, test if Count100us = 0?    (1 cycle)
		goto	    again100us	    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		return			    ; YES => Return			    (2 cycles)

;--------------------------------------------------------------------------
;			    39600ns Delay
;--------------------------------------------------------------------------
; Count 39600ns for the extra fractional part of the remaining time

; Counter Setup = (1[movlw] + 1[movwf] + 1[nop]) x 200ns = 600ns
; Last Cycle of Loop Time = (1[decfsz] + 1[skip] + 2[return]) x 200ns = 800ns
; Calling delay39600ns =  2 cycles x 200ns = 400ns

; Setup Time = 600ns + 800ns + 400ns = 1800ns
;
; Remaining Time = 39600ns - Setup Time = 39600ns - 1800ns = 37800ns
;
; Loop Cycle Time (not for last cycle) = (1[decfsz] + 2[goto]) x 200ns = 600ns

; Remaining Time = Count39600ns x Loop Cycle Time
; 37800ns = Count39600ns x 600ns

; Hence, Count39600ns = 63
;--------------------------------------------------------------------------
Count39600ns	equ	    0x21

delay39600ns	movlw	    d'63'	    ; Load d'63' into W			    (1 cycle)
		movwf	    Count39600ns    ; Move W into Count39600ns		    (1 cycle)
		nop			    ; (1 cycle)

again39600ns	decfsz	    Count39600ns    ; Decrement, test if Count39600nss = 0? (1 cycle)
		goto	    again39600ns    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		return			    ; YES => Return			    (2 cycles)

;--------------------------------------------------------------------------
;			    10ms DELAY
;--------------------------------------------------------------------------
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = 100000ns + (1[decfsz] + 1[skip] + 2[return]) x 200ns + 39600ns = 140400ns
; Calling delay10ms =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 140400ns + 400ns = 141200ns
;
; Remaining Time = 10ms - Setup Time = 10000000ns - 141200ns = 9858800ns
;
; Loop Cycle Time (not for last cycle) = 100000ns + (1[decfsz] + 2[goto]) x 200ns = 100600ns

; Remaining Time = Count10ms x Loop Cycle Time
; 9858800ns = Count10ms x 100600ns

; Hence, Count10ms = 98
;--------------------------------------------------------------------------
Count10ms	equ	    0x22

delay10ms	movlw	    d'98'	    ; Load d'98' into W			    (1 cycle)
		movwf	    Count10ms	    ; Move W into Count10ms		    (1 cycle)

again10ms	call	    delay100us
		decfsz	    Count10ms	    ; Decrement, test if Count10ms = 0?	    (1 cycle)
		goto	    again10ms	    ; NO => Keep waiting		    (2 cycles)
					    ; Skip				    (1 cycle)
		call	    delay39600ns
		return			    ; YES => Return			    (2 cycles)

;--------------------------------------------------------------------------
;			    1s DELAY
; Counter Setup = (1[movlw] +1[movwf]) x 200ns = 400ns
; Last Cycle of Loop Time = 10000000ns + (1[decfsz] + 1[skip] + 2[return]) x 200ns = 100000800ns
; Calling delay10ms =  2 cycles x 200ns = 400ns
;
; Setup Time = 400ns + 10000800ns + 400ns = 10001600ns
;
; Remaining Time = 1s - Setup Time = 1000000000ns - 10001600ns = 989998400ns
;
; Loop Cycle Time (not for last cycle) = 10000000ns + (1[decfsz] + 2[goto]) x 200ns = 10000600ns

; Remaining Time = Count1s x Loop Cycle Time
; 989998400ns = Count1s x 10000600ns

; Hence, Count1s = 98.993900366 == 99

; 989998400ns - (10000600ns x 98) = 9939600ns
;------------------------------------------------------------------
; Count 9939600ns for the extra fractional part of the remaining time

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
;Count1s	equ	0x24
;Count9939600ns	0x25
;
;delay1s	    movlw	d'99'		; Load d'99' into W		(1 cycle)
;	    movwf	Count1s		; Move W into Count1s		(1 cycle)
;
;again1s	    call	delay10ms
;	    decfsz	Count1s		; Decrement and test if Count1ms = 0?	(1 cycle)
;	    goto	again1s		; NO => Keep waiting			(2 cycles)
;					; Skip					(1 cycle)
;
;	    movlw	d'99'		; Load d'99' into W		(1 cycle)
;	    movwf	Count9939600ns	; Move W into Count9939600ns	(1 cycle)
;again9939600ns
;	    call	delay100us
;	    goto	again39600ns	; NO => Keep waiting		(2 cycles)
;					; Skip				    (1 cycle)
;
;	    return			; YES => Return			(2 cycles)
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
	call	delay10ms
	goto    monitor		; Keep monitoring for motion

        end

