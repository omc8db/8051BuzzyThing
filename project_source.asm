;#include <reg932.inc>
#define BUZZER_PIN p1.7
#define UP_SWITCH p2.0
#define DOWN_SWITCH p0.1
#define LED_BIT_0 p2.4
#define LED_BIT_1 p0.6
#define LED_BIT_2 p0.5
#define LED_BIT_3 p1.6

cseg at 0			; tells the assembler to place the first
				; instruction at address 0
	mov 0xA4,#0		; set Port 2 to bi-directional
	mov 0x91,#0		; set Port 1 to bi-directional
	mov 0x84,#0		; set Port 0 to bi-directional
loop:				; label for the sjmp instruction
	mov c,UP_SWITCH		; move SW1 to red LED1
	mov LED_BIT_0,c		;
	mov LED_BIT_1,c		;
	mov c,DOWN_SWITCH
	mov LED_BIT_2,c		;
	mov LED_BIT_3,c		;
	sjmp loop
end