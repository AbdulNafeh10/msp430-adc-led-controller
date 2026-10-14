; Recovered from the original A3 report. Original instructions retained.

;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;-------------------------------------------------------------------------------
.cdecls C,LIST,"msp430.h"       ; Include device header file
;-------------------------------------------------------------------------------
.def    RESET                   ; Export program entry-point to
; make it known to linker.
;-------------------------------------------------------------------------------
.text                           ; Assemble into program memory.
.retain                         ; Override ELF conditional linking
; and retain current section.
.retainrefs                     ; And retain any sections that have
; references to current section.
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
; Initialize GPIO Ports and ADC Channel A2.
init:
bis.b   #01h, &P1DIR            ; Configure P1.0 as output for LED control
bic.b   #01h, &P1OUT            ; Initialize P1.0 to Low (turn LED off)
bis.b   #BIT2, &P1SEL0          ; Configure P1.2 for ADC function
bis.b   #BIT2, &P1SEL1          ; Continue configuration for ADC
bic.w   #0001h, &PM5CTL0        ; Enable GPIO power
; ADC Initialization with adjusted reference voltage
mov.w   #0210h, &ADCCTL0        ; Turn ADC on, sample and hold for 16 ADC clocks
mov.w   #0220h, &ADCCTL1        ; Set ADC clock source to SMCLK, divider = 1
mov.w   #0020h, &ADCCTL2        ; Set ADC resolution to 12-bit
mov.w   #0002h, &ADCMCTL0       ; Internal reference, Input Channel A2
main:
mov.w   #0213h, &ADCCTL0        ; Start ADC sampling and conversion
; Wait for ADC conversion to complete
wait_adc:
bit.w   #BIT0, &ADCIFG          ; Check ADC interrupt flag
jz      wait_adc                ; Loop if conversion not complete
mov.w   ADCMEM0, R5             ; Store ADC result in R4
; Scale the delay based on ADC result
clr.w   R6                      ; Clear R6 for accumulation
mov.w   #4, R7                  ; Set scaling factor (x4)
scale_loop:
add.w   R5, R6                  ; Perform scaling by addition
dec.w   R7                      ; Decrement scaling factor
jnz     scale_loop              ; Repeat until factor is depleted
mov.w   R6, R5                  ; Move scaled delay to R5
; Toggle LED and implement scaled delay
toggling:
xor.b   #01h, &P1OUT            ; Toggle LED state
; Nested loops for extended delay
outer_delay:
mov.w   #0Fh, R6                ; Set initial count for inner loop
inner_delay:
dec.w   R6                      ; Decrement inner loop counter
jnz     inner_delay             ; If not zero, repeat inner loop
dec.w   R5                      ; After inner loop, decrement outer loop counter
jnz     outer_delay             ; If not zero, repeat outer loop
jmp     main                    ; After completing delays, jump back to main loop
nop                             ; No operation
;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
.global __STACK_END
.sect   .stack
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
.sect   ".reset"                ; MSP430 RESET Vector
.short  RESET