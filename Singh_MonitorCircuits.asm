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
; Main Program
;--------------------------------------------------------------------------
	org     0x0005

start	bsf	STATUS, RP0	; Select Bank 1
	bsf	TRISB, RB1	; Set TRISB<1> = 1 so PORTB<1> is an INPUT
	bcf	TRISD, RD2	; Set TRISD<2> = 0 so PORTD<2> is an OUTPUT
	bcf	STATUS, RP0	; Select Bank 0

monitor	bcf	PORTD, RD2	; Turn the buzzer off
	btfsc   PORTB, RB1	; Does PORTB<1> = 0? YES => Skip next instruction
	goto	monitor		; NO => Keep monitoring for motion
	bsf	PORTD, RD2	; YES => Turn on buzzer

	; TODO: Add delay to keep buzzer on for a minimum period.

	goto    monitor		; Keep monitoring for motion

        end
