;#include <reg932.inc>
#define BUZZER_PIN p1.7
#define UP_SWITCH p0.1
#define DOWN_SWITCH p2.0
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
	jb UP_SWITCH,skip_inc  ; skips over increment if up switch not pressed
	lcall increment		; 
skip_inc:			;
	jb DOWN_SWITCH,skip_dec;
	lcall decrement		;
skip_dec:			;
	sjmp loop		;

;start of increment subroutine
increment:			;
	
inc_no_release:			;
	jnb UP_SWITCH,inc_no_release;
	setb LED_BIT_0		;
	ret			;
;end of increment subroutine

;start of decrement subroutine
decrement:			;

dec_no_release:			;
	jnb DOWN_SWITCH,dec_no_release;
	clr LED_BIT_0		;
	ret			;
;end of decrement subroutine

;start of buzz subroutine
buzz:				;
	ret			;
;end of buzz subroutine

end
