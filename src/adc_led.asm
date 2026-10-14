; MSP430 potentiometer-controlled LED blink rate
; R5: ADC reading / delay count, R6: inner loop, R7: scaling loop
; P1.0: LED output, P1.2/A2: potentiometer input

            .cdecls C,LIST,"msp430.h"
            .def    RESET
            .text
            .retain
            .retainrefs

DELAY_SCALE .set 4
INNER_COUNT .set 15

RESET:      mov.w   #__STACK_END, SP
            mov.w   #WDTPW|WDTHOLD, &WDTCTL

            bis.b   #BIT0, &P1DIR       ; LED on P1.0
            bic.b   #BIT0, &P1OUT
            bis.b   #BIT2, &P1SEL0      ; P1.2 selects ADC input A2
            bis.b   #BIT2, &P1SEL1
            bic.w   #LOCKLPM5, &PM5CTL0

            mov.w   #0210h, &ADCCTL0
            mov.w   #0220h, &ADCCTL1
            mov.w   #0020h, &ADCCTL2
            mov.w   #0002h, &ADCMCTL0

main:
            mov.w   #0213h, &ADCCTL0    ; Start next conversion
wait_adc:
            bit.w   #BIT0, &ADCIFG
            jz      wait_adc
            mov.w   &ADCMEM0, R5

            ; Multiply the 12-bit reading by four for a visible delay.
            clr.w   R6
            mov.w   #DELAY_SCALE, R7
scale_loop:
            add.w   R5, R6
            dec.w   R7
            jnz     scale_loop
            mov.w   R6, R5
            tst.w   R5
            jnz     toggle_led          ; Avoid 16-bit wrap at ADC = 0
            mov.w   #1, R5

toggle_led:
            xor.b   #BIT0, &P1OUT
outer_delay:
            mov.w   #INNER_COUNT, R6
inner_delay:
            dec.w   R6
            jnz     inner_delay
            dec.w   R5
            jnz     outer_delay
            jmp     main

            .global __STACK_END
            .sect   .stack
            .sect   ".reset"
            .short  RESET