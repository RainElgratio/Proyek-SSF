;------------------------------------------
; Assembly Code
;------------------------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------

.global start

;=============================================================================
start:
    SBI   DDRB, 5             ;set PB5 (pin D10 as o/p - blue LED 1)
    SBI   DDRB, 4             ;set PB4 (pin D12 as o/p - red  LED 1)
    SBI   DDRB, 3             ;set PB3 (pin D11 as o/p - blue LED 2)
    SBI   DDRB, 2             ;set PB2 (pin D10 as o/p - red  LED 2)
    SBI   DDRB, 1             ;set PB1 (pin D10 as o/p - blue LED 3)
    SBI   DDRB, 0             ;set PB0 (pin D10 as o/p - red  LED 3)

    SBI   DDRD, 7             ;set PD7 (pin D7 as o/p - a segment)
    SBI   DDRD, 6             ;set PD6 (pin D7 as o/p - b segment)
    SBI   DDRD, 5             ;set PD5 (pin D7 as o/p - c segment)
    SBI   DDRD, 4             ;set PD4 (pin D7 as o/p - d segment)
    SBI   DDRD, 3             ;set PD3 (pin D7 as o/p - e segment)
    SBI   DDRD, 2             ;set PD2 (pin D7 as o/p - f segment)
    SBI   DDRD, 0             ;set PD1 (pin D7 as o/p - g segment)
    

    ;CBI   DDRD, 2             ;clear PD2 (pin D02 as i/p - LDR sensor 1)
    ;CBI   DDRD, 3             ;clear PD3 (pin D03 as i/p - LDR sensor 2)
    ;CBI   DDRD, 4             ;clear PD4 (pin D04 as i/p - LDR sensor 3)

    RJMP init_ADC

;-----------------------------------------------------------------------------
LDRinputONE:
    LDI   R16, 0x01
    LDI   R17, 0x00
    SBRC  R18, 1             ;skip next statement if there's no input from LDRone
    ;SBIC   PIND, 2
    RJMP  inputONE          ;jump to label inputONE 
    SBI   PORTB, 5            ;turn ON blue LED 1
    CBI   PORTB, 4            ;turn OFF red LED 1
    ;LDI   R18, 0x00
    RJMP  LDRinputTWO         ;jump to label LDRinputTWO

LDRinputTWO:
    SBRC  R20, 1             ;skip next statement if there's no input from LDRtwo
    ;SBIC   PIND, 3
    RJMP  inputTWO          ;jump to label inputTWO
    SBI   PORTB, 3            ;turn ON blue LED 2
    CBI   PORTB, 2            ;turn OFF red LED 2
    ;LDI   R20, 0x00
    RJMP  LDRinputTHREE       ;jump to label LDRinputTHREE

LDRinputTHREE:
    SBRC  R22, 1             ;skip next statement if there's no input from LDRthree
    ;SBIC  PIND, 4
    RJMP  inputTHREE        ;jump to label inputTHREE
    SBI   PORTB, 1            ;turn ON blue LED 3
    CBI   PORTB, 0            ;turn OFF red LED 3
    ;LDI   R22, 0x00
    ;RJMP  LDRinputONE
    RCALL sevseg
    RJMP  read_ADC0         ;jump to label LDRinputONE

;-----------------------------------------------------------------------------
inputONE:
    CBI   PORTB, 5            ;turn OFF blue LED 1
    SBI   PORTB, 4            ;turn ON  red  LED 1
    ADD   R17, R16 
    RJMP  LDRinputTWO         ;jump to label LDRinputTWO

inputTWO:
    CBI   PORTB, 3            ;turn OFF blue LED 2
    SBI   PORTB, 2            ;turn ON  red  LED 2
    ADD   R17, R16
    RJMP  LDRinputTHREE       ;jump to label LDRinputTHREE

inputTHREE:
    CBI   PORTB, 1            ;turn OFF blue LED 3
    SBI   PORTB, 0            ;turn ON  red  LED 3
    ADD   R17, R16
    ;RJMP  LDRinputONE
    RCALL sevseg
    RJMP  read_ADC0         ;jump to label read_ADC0


;-----------------------------------------------------------------------------
sevseg:                     ;seven segment for the total of parked cars
    CPI   R17, 0x00
    BREQ  sevsegZERO
    CPI   R17, 0x01
    BREQ  sevsegONE
    CPI   R17, 0x02
    BREQ  sevsegTWO
    CPI   R17, 0x03
    BREQ  sevsegTHREE
    RJMP  sevseg

sevsegZERO:
    CBI   PORTD, 7
    CBI   PORTD, 6
    CBI   PORTD, 5
    CBI   PORTD, 4
    CBI   PORTD, 3
    CBI   PORTD, 2
    SBI   PORTD, 0
    RET
sevsegONE:
    SBI   PORTD, 7
    CBI   PORTD, 6
    CBI   PORTD, 5
    SBI   PORTD, 4
    SBI   PORTD, 3
    SBI   PORTD, 2
    SBI   PORTD, 0
    RET
sevsegTWO:
    CBI   PORTD, 7
    CBI   PORTD, 6
    SBI   PORTD, 5
    cBI   PORTD, 4
    CBI   PORTD, 3
    SBI   PORTD, 2
    CBI   PORTD, 0
    RET
sevsegTHREE:
    CBI   PORTD, 7
    CBI   PORTD, 6
    CBI   PORTD, 5
    CBI   PORTD, 4
    SBI   PORTD, 3
    SBI   PORTD, 2
    CBI   PORTD, 0
    RET


;-----------------------------------------------------------------------------

init_ADC:
    SBI   DDRC, 0     ; set pin PC0 as i/p for ADC0 for LDR 1
    SBI   DDRC, 1     ; set pin PC1 as i/p for ADC1 for LDR 2
    SBI   DDRC, 2     ; set pin PC2 as i/p for ADC2 for LDR 3
    ;--------------------------------------------------------------
;------------------------------------------------------------------


read_ADC0:
    LDI   R23, 0xC0   ; internal 2.56V, right-justified data, ADC0
    STS   ADMUX, R23
    LDI   R23, 0x87   ; enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R23

    LDI   R23, 0xC7   ; set ADSC in ADCSRA to start conversion for ADC0
    STS   ADCSRA, R23
    
    ; Wait for conversion of ADC0
    wait_ADC0:
        LDS   R24, ADCSRA ; check ADIF flag in ADCSRA for ADC0
        SBRS  R24, 4      ; skip jump when conversion is done (flag set)
        RJMP  wait_ADC0    ; loop until ADIF flag is set
    
    ; Read and store the ADC0 result
    LDS   R17, ADCL   ; get low-byte result from ADCL for ADC0
    LDS   R18, ADCH   ; get high-byte result from ADCH for ADC0

    RJMP read_ADC1
    
read_ADC1:
    LDI   R23, 0xC1   ; internal 2.56V, right-justified data, ADC1
    STS   ADMUX, R23
    LDI   R23, 0x87   ; enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R23
    
    LDI   R23, 0xC7   ; start conversion for ADC1
    STS   ADCSRA, R23
    
    ; Wait for conversion of ADC1
    wait_ADC1:
        LDS   R24, ADCSRA ; check ADIF flag in ADCSRA for ADC1
        SBRS  R24, 4      ; skip jump when conversion is done (flag set)
        RJMP  wait_ADC1    ; loop until ADIF flag is set
    
    ; Read and store the ADC1 result
    LDS   R19, ADCL   ; get low-byte result from ADCL for ADC1
    LDS   R20, ADCH   ; get high-byte result from ADCH for ADC1

    RJMP read_ADC2
    
read_ADC2:
    LDI   R23, 0xC2   ; internal 2.56V, right-justified data, ADC2
    STS   ADMUX, R23
    LDI   R23, 0x87   ; enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R23
    
    LDI   R23, 0xC7   ; start conversion for ADC2
    STS   ADCSRA, R23
    
    ; Wait for conversion of ADC2
    wait_ADC2:
        LDS   R24, ADCSRA ; check ADIF flag in ADCSRA for ADC2
        SBRS  R24, 4      ; skip jump when conversion is done (flag set)
        RJMP  wait_ADC2    ; loop until ADIF flag is set
    
    ; Read and store the ADC2 result
    LDS   R21, ADCL   ; get low-byte result from ADCL for ADC2
    LDS   R22, ADCH   ; get high-byte result from ADCH for ADC2

    RJMP LDRinputONE
    
;------------------------------------------------------------------





