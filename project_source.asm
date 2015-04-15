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
#define BUZZ_DELAY_CYCLES

;Reserved Registers
#define COUNT_REGISTER R2
;R4-R7 available for other usage

cseg at 0			; tells the assembler to place the first
				; instruction at address 0
setup:				;
	mov P2M1,#0		; set Port 2 to bi-directional
	mov P1M1,#0		; set Port 1 to bi-directional
	mov P0M1,#0		; set Port 0 to bi-directional
	mov COUNT_REGISTER,#0	; Initialize count to 0

	lcall transition_left	;

loop:				; label for the sjmp instruction
	jb UP_SWITCH,skip_inc  	; allows increment to be called if switch is pressed
	lcall increment		; 
 skip_inc:			;

	jb DOWN_SWITCH,skip_dec	; allows decrement to be called if switch is pressed
	lcall decrement		;
 skip_dec:			;

	; Function call routine
 	jb MALICK_BUTTON,skip_malick	; 
	lcall transition_left   ; Play a transition
	push 03h		; Store the count

	lcall malick_feature	; Call the function

	pop 03h			; Restore the count
	lcall transition_right	;
	lcall led_display_count	;
 skip_malick:			;

 
 	jb OWEN_BUTTON,skip_owen	; 
	lcall transition_left	;
	push 03h		; Store the count

	lcall owen_feature	;

	pop 03h			; Restore the count
	lcall transition_right	;
	lcall led_display_count	;
 skip_owen:			;

	
 	jb JUDAH_BUTTON,skip_judah; 
	lcall transition_left	;
	push 03h		; Store the count

	lcall judah_feature	;

	pop 03h			; Restore the count
	lcall transition_right	;
	lcall led_display_count	;
 skip_judah:			;
 
 	jb DRUE_BUTTON,skip_drue; 
	lcall transition_left	;
	push 03h		; Store the count

	lcall drue_feature	;

	pop 03h			; Restore the count
	lcall transition_right	;
	lcall led_display_count	;
 skip_drue:			;

	sjmp loop		;

;start of increment subroutine
increment:			;
	lcall debounce_delay		; Delay to debounce
 inc_no_release:		; wait for button to be released
	jnb UP_SWITCH,inc_no_release;

	;Increment
	inc COUNT_REGISTER	;

	;check for overflow
	MOV A,COUNT_REGISTER	;
	ANL A, #10h		; Check the fifth bit for overflow
	jz inc_no_overflow	;
	lcall buzz		;
	mov COUNT_REGISTER,#0	; Reset the counter to 0

	
 inc_no_overflow:		;
	;update display
	lcall led_display_count	;
	
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

	;check for overflow
	MOV A,COUNT_REGISTER	;
	ANL A, #80h		; Check the eighth bit for overflow
	jz dec_no_overflow	;
	lcall buzz		;
	mov COUNT_REGISTER,#15	; Reset the counter to 15

	
 dec_no_overflow:	;
	
	;update display
	lcall led_display_count	;

	;more debouncing
	lcall debounce_delay	;
	ret			;
;end of decrement subroutine



;start of buzz subroutine
buzz:	
	mov R3, #128	;
 buzzer_loop:	
  	setb BUZZER	;	
	lcall buzz_delay	;
	clr BUZZER		;
	lcall buzz_delay	;
 djnz R3, buzzer_loop	;
	ret			;


buzz_delay:
	mov R5, #7			;
 buzz_delay_outer:
 	mov R6, #255			;
  buzz_delay_inner:				
  djnz R6, buzz_delay_inner	;
 djnz R5, buzz_delay_outer	;
 	ret				;
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
	anl A, #01h		; //Get the first bit (LSB) of count
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
	anl A, #08h		; //Get the fourth bit (MSB) of count
	jz bit3_off_jmp	;  
	clr LED_BIT_3		;
	sjmp bit3_on_jmp	; 
 bit3_off_jmp:			;
	setb LED_BIT_3		;
 bit3_on_jmp:			;

	ret			;
;end of led_display_count subroutine

;start of third_sec_delay function
third_sec_delay:		;

	mov R4,#10		;
 tsd_loop0:			;
	mov R5,#255		;
  tsd_loop1:			;
	mov R6,#255		;
   tsd_loop2:			;
	djnz R6,tsd_loop2	;
	djnz R5,tsd_loop1	;
	djnz R4,tsd_loop0	;
	ret;
;end of third_sec_delay

;start of transition_right
transition_right:		;

	lcall col1_on		;
	lcall third_sec_delay	;
	lcall col2_on		;
	lcall third_sec_delay	;
	lcall col1_off		;
	lcall col3_on		;
	lcall third_sec_delay	;
	lcall col2_off		;
	lcall third_sec_delay	;
	lcall col3_off		;
	
	ret			;
;end of transition_right

;start of transition_left
transition_left:		;
	lcall col3_on		;
	lcall third_sec_delay	;
	lcall col2_on		;
	lcall third_sec_delay	;
	lcall col3_off		;
	lcall col1_on		;
	lcall third_sec_delay	;
	lcall col2_off		;
	lcall third_sec_delay	;
	lcall col1_off		;
	
	ret			;
;end of transition_left

;start of column functions
col1_on:			;
	clr LED1_RED		;
	clr LED2_AMB		;
	clr LED3_YEL		;
	ret			;
col1_off:			;
	setb LED1_RED		;
	setb LED2_AMB		;
	setb LED3_YEL		;
	ret			;
col2_on:			;
	clr LED4_YEL		;
	clr LED5_RED		;
	clr LED6_GRN		;
	ret			;
col2_off:			;
	setb LED4_YEL		;
	setb LED5_RED		;
	setb LED6_GRN		;
	ret			;
col3_on:			;
	clr LED7_GRN		;
	clr LED8_RED		;
	clr LED9_AMB		;
	ret			;
col3_off:
	setb LED7_GRN		;
	setb LED8_RED		;
	setb LED9_AMB		;
	ret			;
clr_screen:
	lcall col1_off		;
	lcall col2_off		;
	lcall col3_off		;
	ret			;
all_lights_on:
	lcall col1_on		;
	lcall col2_on		;
	lcall col3_on		;
	ret			;
;end of column functions



;start of malick_feature
malick_feature:			;
	ret			;
;end of malick_feature

;start of owen_feature
owen_feature:			;

	;output 'O'
	clr LED1_RED		;
	clr LED2_AMB		;
	clr LED3_YEL		;
	clr LED4_YEL		;
	setb LED5_RED		;
	clr LED6_GRN		;
	clr LED7_GRN		;
	clr LED8_RED		;
	clr LED9_AMB		;

	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall clr_screen	;
	lcall third_sec_delay	;

	;output 'W'
	clr LED1_RED		;
	clr LED2_AMB		;
	clr LED3_YEL		;
	setb LED4_YEL		;
	clr LED5_RED		;
	clr LED6_GRN		;
	clr LED7_GRN		;
	clr LED8_RED		;
	clr LED9_AMB		;

	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall clr_screen	;
	lcall third_sec_delay	;
	
	;output 'E'
	clr LED1_RED		;
	clr LED2_AMB		;
	clr LED3_YEL		;
	clr LED4_YEL		;
	clr LED5_RED		;
	clr LED6_GRN		;
	clr LED7_GRN		;
	setb LED8_RED		;
	clr LED9_AMB		;


	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall clr_screen	;
	lcall third_sec_delay	;		

	;output 'N'
	clr LED1_RED		;
	clr LED2_AMB		;
	clr LED3_YEL		;
	clr LED4_YEL		;
	setb LED5_RED		;
	setb LED6_GRN		;
	clr LED7_GRN		;
	clr LED8_RED		;
	clr LED9_AMB		;


	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall third_sec_delay	;
	lcall clr_screen	;
	lcall third_sec_delay	;
	
	ret			;
;end of owen_feature

;start of judah_feature		;
judah_feature:
	ret			;
;end of judah_feature		;

;start of drue_feature		;
drue_feature: 
	jnb SW2, drue_next1; if hit SW2, advance
	jnb SW1, frown; if hit anythign else, make frowny face. : <
	jnb SW2, frown; if hit anythign else, make frowny face. : <
	jnb EXIT_BUTTON, drue_exit;
	jnb SW4, frown; if hit anythign else, make frowny face. : <
	jnb SW5, frown; if hit anythign else, make frowny face. : <
	jnb SW6, frown; if hit anythign else, make frowny face. : <
	jnb SW7, frown; if hit anythign else, make frowny face. : <
	jnb SW8, frown; if hit anythign else, make frowny face. : <
	jnb SW9, frown; if hit anythign else, make frowny face. : <
	sjmp poker_face;
 frown:
	setb LED1_RED;
	setb LED3_YEL;
	setb LED5_RED;
	setb LED7_GRN;
	setb LED9_AMB;
	sjmp drue_delay_frown;
 poker_face:
	clr LED5_RED;
	clr LED4_YEL;
	clr LED6_GRN;
	setb LED1_RED;
	setb LED3_YEL;
	setb LED7_GRN;
	setb LED9_AMB;
	setb LED8_RED;
	sjmp drue_feature;return to beginning

 drue_delay_frown: 	 
	mov R3, #128	;
  drue_delay_outer:
	mov R5, #7			;
   drue_delay_mid:
 	mov R6, #255			;
    drue_delay_inner:				
    djnz R6, drue_delay_inner	;
   djnz R5, drue_delay_mid	;
  djnz R3, drue_delay_outer;	
 sjmp poker_face;

 drue_delay_winner:
	mov R3, #128	;
  drue_delay2_outer:
	mov R5, #7			;
   drue_delay2_mid:
 	mov R6, #255			;
    drue_delay2_inner:				
    djnz R6, drue_delay2_inner	;
   djnz R5, drue_delay2_mid	;
  djnz R3, drue_delay2_outer;	
 sjmp drue_win_del_ret;	

 drue_exit:
	ret;	

 drue_next1:
	setb LED5_RED; make a smiley face!
	setb LED4_YEL;
	setb LED6_GRN;
	jnb SW2, drue_next1; forces it to wait until no longer pressing switch
  drue_next1_1:
	jnb SW1, frown;
	jnb SW2, frown; 
	jnb EXIT_BUTTON, drue_exit;
	jnb SW4, frown; 
	jnb SW5, drue_next2; 
	jnb SW6, frown; 
	jnb SW7, frown; 
	jnb SW8, frown; 
	jnb SW9, frown;  
	sjmp drue_next1_1;

 drue_next2:
	jnb SW5, drue_next2;
  drue_next2_1:
	jnb SW1, frown;
	jnb SW2, frown; 
	jnb EXIT_BUTTON, drue_exit;
	jnb SW4, frown; 
	jnb SW5, frown; 
	jnb SW6, frown; 
	jnb SW7, frown; 
	jnb SW8, youre_winner; 
	jnb SW9, frown;  
	sjmp drue_next2_1;

 youre_winner:
	jnb SW8, youre_winner;
	mov R7, 3;
  youre_loopser:
	setb LED1_RED; make everything flash then clear 3 times. Yay youre winner
	setb LED3_YEL;
	setb LED5_RED;
	setb LED7_GRN;
	setb LED9_AMB;
	setb LED4_YEL;
	setb LED6_GRN;
	setb LED8_RED;
	setb LED2_AMB;
	sjmp drue_delay_winner;
   drue_win_del_ret:
	clr LED1_RED; 
	clr LED3_YEL;
	clr LED5_RED;
	clr LED7_GRN;
	clr LED9_AMB;
	clr LED4_YEL;
	clr LED6_GRN;
	clr LED8_RED;
	clr LED2_AMB; 
	djnz R7, drue_exit;
	sjmp youre_loopser;
	  
;end of drue_feature		;


end
