#include <reg932.h>
#include <simon2.h>

#define UP_SWITCH SW4
#define DOWN_SWITCH SW1

#define LED_BIT_0 LED1_RED
#define LED_BIT_1 LED2_AMB
#define LED_BIT_2 LED4_YEL
#define LED_BIT_3 LED5_RED

#define DELAY_CYCLES 50	; Change this

#define COUNT_REGISTER R2

cseg at 0			; tells the assembler to place the first
				; instruction at address 0
setup:				;
	mov P2M1,#0		; set Port 2 to bi-directional
	mov P1M1,#0		; set Port 1 to bi-directional
	mov P0M1,#0		; set Port 0 to bi-directional

	mov COUNT_REGISTER,#0	; Initialize count to 0

loop:				; label for the sjmp instruction
	jb UP_SWITCH,skip_inc  	; allows increment to be called if switch is pressed
	lcall increment		; 
skip_inc:			;
	jb DOWN_SWITCH,skip_dec	; allows decrement to be called if switch is pressed
	lcall decrement		;
skip_dec:			;
	sjmp loop		;



;start of increment subroutine
increment:			;
	lcall delay		; Delay to debounce
inc_no_release:			;
	jnb UP_SWITCH,inc_no_release;
	setb LED_BIT_0		;
	ret			;
;end of increment subroutine



;start of decrement subroutine
decrement:			;
	lcall delay		;
dec_no_release:			;
	jnb DOWN_SWITCH,dec_no_release;
	clr LED_BIT_0		;
	ret			;
;end of decrement subroutine



;start of buzz subroutine
buzz:				;
	ret			;
;end of buzz subroutine



;start of delay subroutine
delay:
	mov R3,#DELAY_CYCLES	;
delay_loop:			;
	djnz R3,delay_loop	;
	ret			;
;end of delay subroutine

end
