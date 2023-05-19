;--------------------------
; Assembly Code - Master Tx
;--------------------------
#define __SFR_OFFSET 0x00
#include "avr/io.h"
;------------------------
.global I2C_master
.global lcd_write_string

;==============================================================
I2C_master:
    CBI   DDRC, 3         ;pin PC3 is i/p
    ;----------------------------------------------------------
    RCALL I2C_init        ;initialize TWI module
    ;----------------------------------------------------------
l1: SBIS  PINC, 3
    RJMP  l1              ;wait for "transmit" button press
    ;----------------------------------------------------------
    RCALL I2C_start       ;transmit START condition
    LDI   R27, 0b10010000 ;SLA(1001000) + W(0)
    RCALL I2C_write       ;write slave address SLA+W
    LDI   R27, 0b11110101 ;data byte to be transmitted
    RCALL I2C_write       ;write data byte
    RCALL I2C_stop        ;transmit STOP condition
    ;----------------------------------------------------------
    RJMP  l1              ;go back for another transmit
;==============================================================
I2C_init:
    LDI   R21, 0
    STS   TWSR, R21       ;prescaler = 0
    LDI   R21, 12         ;division factor = 12
    STS   TWBR, R21       ;SCK freq = 400kHz
    LDI   R21, (1<<TWEN)
    STS   TWCR, R21       ;enable TWI
    RET
;==============================================================
I2C_start:
    LDI   R21, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
    STS   TWCR, R21       ;transmit START condition
    ;----------------------------------------------------------
wt1:LDS   R21, TWCR
    SBRS  R21, TWINT      ;TWI interrupt = 1?
    RJMP  wt1             ;no, wait for end of transmission
    ;----------------------------------------------------------
    RET
;==============================================================
I2C_write:
    STS   TWDR, R27       ;copy SLA+W into data register
    LDI   R21, (1<<TWINT)|(1<<TWEN)
    STS   TWCR, R21       ;transmit SLA+W
    ;----------------------------------------------------------
wt2:LDS   R21, TWCR
    SBRS  R21, TWINT
    RJMP  wt2             ;wait for end of transmission
    ;----------------------------------------------------------
    RET
;==============================================================
I2C_stop:
    LDI   R21, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
    STS   TWCR, R21       ;transmit STOP condition
    RET
;==============================================================
lcd_write_string:
    ; Your code to write a string to the LCD here
    ; Load the address of the string into Z register

    ldi r30, lo8(msg)          ; Load the low byte of string address
    ldi r31, hi8(msg)          ; Load the high byte of string address
agn:LPM   R18, Z+                   ;load char of string onto R18
    CPI   R18, 0                    ;check if R18=0 (end of string)
    BREQ  ext                       ;if yes, exit

    ;--------------------------------------------------------------------

    ; Start I2C communication
    ldi r16, 0x27   ; Load LCD I2C address into r16
    rcall I2C_start             ; Start I2C communication
    rcall I2C_write        ; Send control byte with LCD address (write mode)

write_loop:
    ld r16, Z+                 ; Load character from Z register
    tst r16                    ; Check if end of string (null terminator)
    breq write_end             ; If end of string, exit the loop

    ; Write the character to the LCD
    rcall I2C_write        ; Send the character to the LCD
    rjmp write_loop            ; Continue loop

write_end:
    ; Stop I2C communication
    rcall I2C_stop              ; Stop I2C communication

    ret

ext:RCALL delay_sec
    RET

msg: .ascii "Hello, Arduino!"   ; String to be displayed on the LCD

delay_sec:                          ;3s delay
    LDI   R20, 255
l4: LDI   R21, 255
l5: LDI   R22, 255
l6: DEC   R22
    BRNE  l6
    DEC   R21
    BRNE  l5
    DEC   R20
    BRNE  l4
    RET

.equ MAX_CARS, 5    ; maximum number of cars allowed
.equ MIN_CARS, 0    ; minimum number of cars allowed

.org 0x0000           ; start of program memory

; Interrupt service routine for entrance interrupt
    cbi  DDRB, 1     ; configure PB1 as input for entrance sensor
    sbis PINB, 1     ; check if entrance sensor is triggered
    rjmp exit_isr    ; if not, go to exit interrupt
    ; if entrance sensor is triggered:
    cpi  r16, MAX_CARS ; compare number of cars with maximum
    breq nospace      ; if equal, go to nospace label
    inc  r16          ; increment number of cars
    ; turn on orange LED, wait, then turn on green LED
    sbi  PORTB, 2     ; set PB2 high for orange LED
    call delay
    sbi  PORTB, 3     ; set PB3 high for green LED
    ; update number of cars on port C
    out  PORTC, r16
    ; call PWM subroutine to increase sound
    rcall PWM
    reti              ; return from interrupt

; Interrupt service routine for exit interrupt
    cbi  DDRB, 0     ; configure PB0 as input for exit sensor
    sbis PINB, 0     ; check if exit sensor is triggered
    rjmp entrance_isr ; if not, go to entrance interrupt
    ; if exit sensor is triggered:
    dec  r16          ; decrement number of cars
    ; update number of cars on port C
    out  PORTC, r16
    ; call PWM subroutine to decrease sound
    rcall PWM
    ; if no car is left, go to Nocar label
    cpi  r16, MIN_CARS ; compare number of cars with minimum
    breq Nocar        ; if equal, go to Nocar label
    sbi  PORTB, 2     ; set PB2 high for orange LED
    cbi  PORTB, 3     ; set PB3 low for green LED
    reti              ; return from interrupt

; Subroutine for PWM
PWM:
    ; reset Timer0 registers to enable PWM output on PB1 and PB2
    ldi  r18, 0x63
    out  TCCR0A, r18
    ldi  r18, 0x01
    out  TCCR0B, r18
    ret

; Subroutine for delay of 1 second
delay:
    ldi  r18, 0x00
    ldi  r19, 0x80
loop:
    dec  r19
    brne loop
    dec  r18
    brne loop
    ret

; Initialize main program
main:
    ; Initialize Port B (PB0 as input for exit sensor, PB1 as input for entrance sensor, PB2 as output for orange LED, PB3 as output for green LED)
    ldi  r18, 0x03
    out  DDRB, r18
    ; Initialize Port C (output for number of cars)
    ldi  r18, 0xFF
    out  DDRC, r18
    ; Initialize Port D (output for PWM)
    ldi  r18, 0xFF
    out  DDRD, r18
    ; Initialize interrupts
    sei
    ; Infinite loop
loop:
    rjmp loop

; Label for when there is no space
nospace:
    sbi  PORTB, 0     ; set PB0 high for red LED
    cbi  PORTB, 2     ; set PB2 low for orange LED
    reti              ; return from interrupt

; Label for when there is no car
Nocar:
    reti              ; return from interrupt


