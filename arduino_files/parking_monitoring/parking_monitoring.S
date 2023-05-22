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

    CBI   DDRD, 2             ;clear PD2 (pin D02 as i/p - LDR sensor 1)
    CBI   DDRD, 3             ;clear PD3 (pin D03 as i/p - LDR sensor 2)
    CBI   DDRD, 4             ;clear PD4 (pin D04 as i/p - LDR sensor 3)

    RJMP init_ADC

;-----------------------------------------------------------------------------
LDRinputONE:
    SBRC  R18, 2             ;skip next statement if there's no input from LDRone
    RJMP  NOinputONE          ;jump to label NOinputONE 
    SBI   PORTB, 5            ;turn ON blue LED 1
    CBI   PORTB, 4            ;turn OFF red LED 1
    RJMP  LDRinputTWO         ;jump to label LDRinputTWO

LDRinputTWO:
    SBRC  R20, 2             ;skip next statement if there's no input from LDRtwo
    RJMP  NOinputTWO          ;jump to label NOinputTWO
    SBI   PORTB, 3            ;turn ON blue LED 2
    CBI   PORTB, 2            ;turn OFF red LED 2
    RJMP  LDRinputTHREE       ;jump to label LDRinputTHREE

LDRinputTHREE:
    SBRC  R22, 2             ;skip next statement if there's no input from LDRthree
    RJMP  NOinputTHREE        ;jump to label NOinputTHREE
    SBI   PORTB, 1            ;turn ON blue LED 3
    CBI   PORTB, 0            ;turn OFF red LED 3
    RJMP  LDRinputONE         ;jump to label LDRinputONE

;-----------------------------------------------------------------------------
NOinputONE:
    CBI   PORTB, 5            ;turn OFF blue LED 1
    SBI   PORTB, 4            ;turn ON  red  LED 1
    RJMP  LDRinputTWO         ;jump to label LDRinputTWO

NOinputTWO:
    CBI   PORTB, 3            ;turn OFF blue LED 2
    SBI   PORTB, 2            ;turn ON  red  LED 2
    RJMP  LDRinputTHREE       ;jump to label LDRinputTHREE

NOinputTHREE:
    CBI   PORTB, 1            ;turn OFF blue LED 3
    SBI   PORTB, 0            ;turn ON  red  LED 3
    RJMP  read_ADC0         ;jump to label read_ADC0


;-----------------------------------------------------------------------------

init_ADC:
    LDI   R23, 0xFF

    SBI   DDRC, 0     ; set pin PC0 as i/p for ADC0 for LDR 1
    SBI   DDRC, 1     ; set pin PC1 as i/p for ADC1 for LDR 2
    SBI   DDRC, 2     ; set pin PC2 as i/p for ADC2 for LDR 3
    ;--------------------------------------------------------------
    LDI   R23, 0x87   ; enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R23
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
        SBRS  R24, 7      ; skip jump when conversion is done (flag set)
        RJMP  wait_ADC0    ; loop until ADIF flag is set
    
    ; Read and store the ADC0 result
    LDS   R17, ADCL   ; get low-byte result from ADCL for ADC0
    LDS   R18, ADCH   ; get high-byte result from ADCH for ADC0

    RJMP read_ADC1
    
read_ADC1:
    LDI   R23, 0xC0   ; internal 2.56V, right-justified data, ADC1
    STS   ADMUX, R23
    LDI   R23, 0x87   ; enable ADC, ADC prescaler CLK/128
    STS   ADCSRA, R23
    
    LDI   R23, 0xC7   ; start conversion for ADC1
    STS   ADCSRA, R23
    
    ; Wait for conversion of ADC1
    wait_ADC1:
        LDS   R24, ADCSRA ; check ADIF flag in ADCSRA for ADC1
        SBRS  R24, 7      ; skip jump when conversion is done (flag set)
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
        SBRS  R24, 7      ; skip jump when conversion is done (flag set)
        RJMP  wait_ADC2    ; loop until ADIF flag is set
    
    ; Read and store the ADC2 result
    LDS   R21, ADCL   ; get low-byte result from ADCL for ADC2
    LDS   R22, ADCH   ; get high-byte result from ADCH for ADC2

    RJMP LDRinputONE
    

;------------------------------------------------------------------
