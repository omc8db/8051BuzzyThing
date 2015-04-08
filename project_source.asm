#include <reg932.h>
#include <simon2.h>

;These names come from simon2.h. They are printed on the silkscreen.
;Inputs
#define UP_SWITCH SW4
#define DOWN_SWITCH SW1

#define MALICK_BUTTON SW7
#define OWEN_BUTTON SW8
#define JUDAH_BUTTON SW9
#define DRUE_BUTTON SW6
#define EXIT_BUTTON SW3

;Outputs
#define LED_BIT_0 LED1_RED
#define LED_BIT_1 LED2_AMB
#define LED_BIT_2 LED4_YEL
#define LED_BIT_3 LED5_RED

;Parameters
#define DEBOUNCE_DELAY_CYCLES 255	; Change this

;Reserved Registers
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
	lcall debounce_delay		; Delay to debounce
 inc_no_release:		; wait for button to be released
	jnb UP_SWITCH,inc_no_release;

	;Increment
	inc COUNT_REGISTER	;
	;update display
	lcall led_display_count	;

	;check for overflow
	MOV A,COUNT_REGISTER	;
	ANL A, #10h		; Check the fifth bit for overflow
	jz inc_no_overflow	;
	lcall buzz		;
	mov COUNT_REGISTER,#0	; Reset the counter to 0

	
 inc_no_overflow:	;
	
	;more debouncing
	lcall debounce_delay	;
	ret			;
;end of increment subroutine



;start of decrement subroutine
decrement:			;
	lcall debounce_delay	;
 dec_no_release:		;
	jnb DOWN_SWITCH,dec_no_release;
	clr LED_BIT_0		;

	;Decrement
	dec COUNT_REGISTER	;
	;update display
	lcall led_display_count	;

	;check for overflow
	MOV A,COUNT_REGISTER	;
	ANL A, #80h		; Check the eighth bit for overflow
	jz dec_no_overflow	;
	lcall buzz		;
	mov COUNT_REGISTER,#15	; Reset the counter to 15

	
 dec_no_overflow:	;
	

	;more debouncing
	lcall debounce_delay	;
	ret			;
;end of decrement subroutine



;start of buzz subroutine
buzz:				;
	cpl LED8_RED		;
	ret			;
;end of buzz subroutine



;start of debounce_delay subroutine
debounce_delay:
	mov R4,#DEBOUNCE_DELAY_CYCLES	;
 debounce_delay_loop0:
	mov R3,#DEBOUNCE_DELAY_CYCLES	;
 debounce_delay_loop1:		;
	djnz R3,debounce_delay_loop1;
	djnz R4,debounce_delay_loop0;
	ret			;
;end of debounce_delay subroutine



;start of led_display_count subroutine
led_display_count:			;
	mov A, COUNT_REGISTER	;
	anl A, #01h		; //Get the lsb of count
	;A is nonzero if the bit we want is nonzero
	; Otherwise, A is the value of the bit
	jz bit0_off_jmp	;  
	clr LED_BIT_0		;
	sjmp bit0_on_jmp	; 
 bit0_off_jmp:			;
	setb LED_BIT_0		;
 bit0_on_jmp:			;

	mov A, COUNT_REGISTER	;
	anl A, #02h		; //Get the second bit of count
	jz bit1_off_jmp	;  
	clr LED_BIT_1		;
	sjmp bit1_on_jmp	; 
 bit1_off_jmp:			;
	setb LED_BIT_1		;
 bit1_on_jmp:			;

	mov A, COUNT_REGISTER	;
	anl A, #04h		; //Get the third bit of count
	jz bit2_off_jmp	;  
	clr LED_BIT_2		;
	sjmp bit2_on_jmp	; 
 bit2_off_jmp:			;
	setb LED_BIT_2		;
 bit2_on_jmp:			;
	
	mov A, COUNT_REGISTER	;
	anl A, #08h		; //Get the fourth bit of count
	jz bit3_off_jmp	;  
	clr LED_BIT_3		;
	sjmp bit3_on_jmp	; 
 bit3_off_jmp:			;
	setb LED_BIT_3		;
 bit3_on_jmp:			;

	ret			;
;end of count_output subroutine
   
end
