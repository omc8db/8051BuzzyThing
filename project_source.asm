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

cseg at 0				; tells the assembler to place the first
					; instruction at address 0
;//Judah Timer Interrupt

ljmp setup				; jumps over the interrupt vector table (0x0003 to 0x0073)

cseg at 0x000B				; interrupt vector address for TIMER_0
 		lcall timer_0_isr	; jumps to the timer 0 interrupt subroutine
	reti				; returns from the interrupt		

;//end Judah Timer Interrupt

setup:					;
	mov P2M1,#0			; set Port 2 to bi-directional
	mov P1M1,#0			; set Port 1 to bi-directional
	mov P0M1,#0			; set Port 0 to bi-directional
	mov COUNT_REGISTER,#0		; Initialize count to 0

	lcall transition_left	;

loop:				; label for the sjmp instruction
	jb UP_SWITCH,skip_inc  	; allows increment to be called if switch is pressed
	lcall increment		; 
 skip_inc:			;

	jb DOWN_SWITCH,skip_dec	; allows decrement to be called if switch is pressed
	lcall decrement		;
 skip_dec:			;

 	jb MALICK_BUTTON,skip_malick	; 
	lcall transition_left   ;
	lcall malick_feature	;
	lcall transition_right	;
	lcall led_display_count	;
 skip_malick:			;

 
 	jb OWEN_BUTTON,skip_owen	; 
	lcall transition_left		;
	lcall owen_feature	;
	lcall transition_right	;
	lcall led_display_count	;
 skip_owen:			;

	
 	jb JUDAH_BUTTON,skip_judah	; 
	lcall transition_left		;
	lcall judah_feature	;
	lcall transition_right	;
	lcall led_display_count	;
 skip_judah:			;
 
 	jb DRUE_BUTTON,skip_drue	; 
	lcall transition_left		;
	lcall drue_feature	;
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
;end of column functions



;start of malick_feature
malick_feature:			;
	ret			;
;end of malick_feature

;start of owen_feature
owen_feature:			;
	ret			;
;end of owen_feature

;//Judah Feature 

judah_feature:

;//this feature plays the Nintendo classic Mario Bros intro ditty on the buzzer speaker

;//R3 set the length of note. At (7.373 MHz/2) 16 = eighth note, 32 = quarter note, 64 = half note

;//R4 (upper byte) and R5 (lower byte)  set the tempo of the song. At (7.373 MHz/2) tempo = ? TODO;

;//R6 (upper byte) and R7 (lower byte) set the pitch of the note (as the re-load value for TIMER_0 pitch generator isr)

;//A is reserved for use inside the (TIMER_O) pitch generator isr

;//Judah Setup

	mov TMOD, #0x01			; set TIMER_0 to mode 1 

	mov TH0,  #0x00			; load upper 8 bits of TIMER_0 (init TIMER_0) 
	mov TL0,  #0x00			; load lower 8 bits of TIMER_0 (init TIMER_0)
	mov R6,   #0x00			; load the same 16-bits from TIMER_0 into R6 (to reload TIMER_0 each isr)
	mov R7,   #0x00			; load the same 16-bits from TIMER_0 into R7 (to reload TIMER_0 each isr)

	SETB EA				; set global interrupt enable bit
	SETB ET0			; enable TIMER_0 overflow interrupt
	SETB TR0			; start TIMER_0 count

;//End Judah Setup

;//Judah Main

	nop				;
	nop				;

	lcall buzzNoteE6		;buzz the note on E
	mov R3, #16			;sets the duration for the eighth note
	lcall holdNote			;holdNote checks R3 for the duration (16 = eigth note buzz)
	lcall pauseBetweenNote		;

	lcall buzzNoteC6		;buzz the note on E
	mov R3, #16			;sets the duration for the eighth note
	lcall holdNote			;holdNote checks R3 for the duration (16 = eigth note buzz)
	lcall pauseBetweenNote		;

	lcall restNote			;rest
	mov R3, #16			;sets the duration for the eighth note
	lcall holdNote			;holdNote checks R3 for the duration (16 = eigth note rest)
	lcall pauseBetweenNote		;

	lcall buzzNoteE6		;buzz the note on E
	mov R3, #32			;sets the duration for an eighth note
	lcall holdNote			;holdNote checks R3 for the duration (32 = quarter note buzz)
	lcall pauseBetweenNote		;

	lcall restNote			;rest
	mov R3, #32			;sets the duration for an eighth note
	lcall holdNote			;holdNote checks R3 for the duration (32 = eigth note rest)
	lcall pauseBetweenNote		;


	lcall buzzNoteC6		;buzz the note on E
	mov R3, #64			;sets the duration for an quarter note
	lcall holdNote			;holdNote checks R3 for the duration (64 = quarter note buzz)
	lcall pauseBetweenNote		;

	clr TR0				; start TIMER_0 count
	clr EA				; clr global interrupt enable bit
	clr ET0				; clr TIMER_0 overflow interrupt

ret

;//End Judah Main

;//Judah Subroutines

buzzNoteE6:				;buzzer gets music note E (sixth octave) 1318.51 cycles per second

		mov R6, #0xF5		;
		mov R7, #0x14		;

		lcall holdNote		;

	ret				;

buzzNoteC6:				;buzzer gets music note C (sixth octave) 1046.50 cycles per second
		
		mov R6, #0xF2		;
		mov R7, #0x3D		;
		lcall holdNote		;
                
	ret				;

buzzNoteG6:
    		mov R6, #0xF6		;
		mov R7, #0xD1		;
		lcall holdNote		;
                
	ret				;

;//TODO

buzzNoteC5:					;buzzer gets music note C (sixth octave) 1046.50 cycles per second
		
		mov R6, #0x00		;//TODO
		mov R7, #0x00		;//TOD0
		lcall holdNote		;
                
	ret				;
				
pauseBetweenNote:

		mov R3, #1	;

		mov R6, #0	; TIMER 0 re-load value is set to minimum
		mov R7, #0	; 
		lcall holdNote  ;
	ret			;


restNote:
		mov R6, #0	;TIMER 0 re-load value is set to minimum
		mov R7, #0	;possible value.
		clr TR0		;stops TIMER 0 to stop sound
		lcall holdNote  ;
		setb TR0	;restarts TIMER 0 for next note
	ret			;

;// Judah Subroutine hold_note

holdNote:

 loop0:
	mov R4, #100		;Hardcoded Tempo
 
  loop1:				
	 mov R5, #255		;Hardcoded Tempo
 
   loop2:				
	   nop			;

   djnz R5, loop2		;

  djnz R4, loop1		;

 djnz R3, loop0			;

ret				;

;//end hold_note 

timer_0_isr:			

		cpl BUZZER 		;compliment the BUZZER (P1.7) to drive the speaker

		clr c			;DO I NEED THIS?

		mov A, R6		;upper byte of 16-bit timer re-load value into A
		mov TH0, A		;A into the upper byte of TIMER 0
		mov A, R7		;lower byte of 16-bit timer re-load value into A
		mov TL0, A		;A into the lower byte of TIMER 0

ret					;//return from the isr

;//End Judah timer_0_isr

;//End Judah Subroutines

;//End Judah Feature		

;start of drue_feature		;
drue_feature:
	ret			;
;end of drue_feature		;

end
