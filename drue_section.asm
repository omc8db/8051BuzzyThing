;start of drue_feature		;
drue_feature: 
	jnb SW2 drue_next1; if hit SW2, advance
	jnb SW1, frown; if hit anythign else, make frowny face. : <
	jnb SW2, frown; if hit anythign else, make frowny face. : <
	jnb EXIT_BUTTON, ret;
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

 drue_next1:
	setb LED5_RED; make a smiley face!
	setb LED4_YEL;
	setb LED6_GRN;
	jnb SW2 drue_next1; forces it to wait until no longer pressing switch
  drue_next1_1:
	jnb SW1, frown;
	jnb SW2, frown; 
	jnb EXIT_BUTTON, ret;
	jnb SW4, frown; 
	jnb SW5, drue_next2; 
	jnb SW6, frown; 
	jnb SW7, frown; 
	jnb SW8, frown; 
	jnb SW9, frown;  
	sjmp drue_next1_1;

 drue_next2:
	jnb SW5 drue_next2;
  drue_next2_1:
	jnb SW1, frown;
	jnb SW2, frown; 
	jnb EXIT_BUTTON, ret;
	jnb SW4, frown; 
	jnb SW5, frown; 
	jnb SW6, frown; 
	jnb SW7, frown; 
	jnb SW8, youre_winner; 
	jnb SW9, frown;  
	sjmp drue_next2_1;

 youre_winner:
	jnb SW8 youre_winner;
	mov a, 3;
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
   drue_del_win_ret:
	clr LED1_RED; 
	clr LED3_YEL;
	clr LED5_RED;
	clr LED7_GRN;
	clr LED9_AMB;
	clr LED4_YEL;
	clr LED6_GRN;
	clr LED8_RED;
	clr LED2_AMB; 
	djnz drue_exit;
	sjmp youre_loopser;

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
  drue_delay_outer:
	mov R5, #7			;
   drue_delay_mid:
 	mov R6, #255			;
    drue_delay_inner:				
    djnz R6, drue_delay_inner	;
   djnz R5, drue_delay_mid	;
  djnz R3, drue_delay_outer;	
 sjmp drue_win_del_ret;	

 drue_exit:
	ret;	
	  
;end of drue_feature		;