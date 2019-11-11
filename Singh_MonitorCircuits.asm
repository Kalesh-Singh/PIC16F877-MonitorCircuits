;**************************************************************************
;		Monitoring a PIR (Pyro-IR) Motion Sensor
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
; Main Program
;--------------------------------------------------------------------------

PIR	equ	0x01	; Constant PIR = PORTB<1> (Motion Detection Input)
BUZ	equ	0x02	; Constant BUZ = PORTD<2> (Relay switch)

	org     0x0005

start	bsf	STATUS, RP0	; Select Bank 1
	bsf	TRISB, PIR	; Set TRISB<1> = 1 so PORTB<1> is an INPUT
	bcf	TRISD, BUZ	; Set TRISD<2> = 0 so PORTD<2> is an OUTPUT
	bcf	STATUS, RP0	; Select Bank 0

; Monitor PIR - Motion is detected if PORTB<1> = 0
again	bcf	PORTD, BUZ	; Turn the buzzer off
	btfsc   PORTB, PIR	; Does PORTB<1> = 0? YES => Skip next instruction
	goto	again		; NO => Keep monitoring for motion
	bsf	PORTD, BUZ	; YES => Turn on buzzer

	; TODO: Add delay to keep buzzer on for a minimum period.

	goto    again		; Keep monitoring for motion

        end
