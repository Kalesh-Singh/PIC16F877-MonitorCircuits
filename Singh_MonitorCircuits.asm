;**************************************************************************  
;
;**************************************************************************

	list P=16F877
	    
;--------------------------------------------------------------------------
; Program Code
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
;   Set the reset vector here.  If you are using a PIC16C5X device, use:
;               ORG     <last program memory location>
;   Otherwise, use:
;               ORG     0
;--------------------------------------------------------------------------

org     0x0000       
goto    start

;;--------------------------------------------------------------------------
;; Main Program
;;--------------------------------------------------------------------------

STATUS	equ	0x03	; Declare STATUS SFR - Bank 0
PORTB	equ	0x06    ; Declare PORTB SFR  - Bank 0
TRISB	equ	0x86    ; Declare TRISB SFR  - Bank 1
PORTD	equ	0x08    ; Declare PORTD SFR  - Bank 0
TRISD	equ	0x88    ; Declare TRISD SFR  - Bank 1

P0	equ	0x05	; Constant P0 = STATUS<5> (Bank Select)
P1	equ	0x06	; Constant P1 = STATUS<6> (Bank Select)
PIR	equ	0x01	; Constant PIR = PORTB<1> (Motion Detection Input)
BUZ	equ	0x02	; Constant BUZ = PORTD<2> (Relay switch)
	    
org     0x0005
    
start	bsf	STATUS, P0	; Select Bank 1
	bsf	TRISB, PIR	; Set TRISB<1> = 1 so PORTB<1> is an INPUT
	bcf	TRISD, BUZ	; Set TRISD<2> = 0 so PORTD<2> is an OUTPUT
	bcf	STATUS, P0	; Select Bank 0

again	bcf	PORTD, BUZ	; 
	btfsc   PORTB, PIR
	goto	again
	bsf	PORTD, BUZ
	goto    again
	    
        end
