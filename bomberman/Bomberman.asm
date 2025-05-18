; Tela 
; carrega tela de menu

jmp menu

Msg1: string "DESEJA JOGAR NOVAMENTE? (s/n)" ; Mensagem para jogar novamente
OpSaidaFinal: var #1		; Contem a letra que foi digitada - 1 byte apenas
MsgFim: string "OBRIGADO POR JOGAR!"


MsgTitulo: string "==== BOMBERMAN ===="
MsgOpcao1: string "1 - JOGAR"
MsgOpcao2: string "2 - SAIR"
OpInicio: var #1 ; guarda a escolha do jogador


;; tecla == 'n'
    ;call DigLetra
	;loadn r0, #'n'
	;load r1, Letra
	;cmp r0, r1
;
    ;; tecla == 's'
    ;loadn r0, #'s'
	;cmp r0, r1



; copiar loop

; copiar movimentação e suas funções

	
;********************************************************
;                       MENU
;********************************************************

menu:
    call ApagaTela

    ; Exibir titulo
    loadn r0, #526 ; posicao na tela
    loadn r1, #MsgTitulo
    loadn r2, #0
    call ImprimeStr

    ; Exibir Opcao 1
    loadn r0, #605 ; posicao na tela
    loadn r1, #MsgOpcao1
    loadn r2, #0
    ;call ImprimeStr

    ; Exibir Opcao 2
    loadn r0, #605 ; posicao na tela
    loadn r1, #MsgOpcao2
    loadn r2, #0
    call ImprimeStr

    ; provavel ter que fazer o numero virar char!!!
    inchar r1
    store r1, OpInicio

    ; Verifica opcao
    loadn r2, #'1'
    cmp r1, r2
    je Jogar 

    loadn r2, #'2'
    cmp r1, r2
    je Sair 

    ; Se invalido, volta ao menu

    jmp menu

;------------------------
	
;********************************************************
;                       JOGAR
;********************************************************
Jogar:


;------------------------

	
;********************************************************
;                       SAIR
;********************************************************
Sair:
    call ApagaTela
    ; Pode colocar mensagem de despedida, ou parar o programa
    loadn r0, #100
    loads r1, MsgFim
    
    ;call ImprimeStr

    hlt ; halt 



    




;------------------------

	
;********************************************************
;                       APAGA TELA
;********************************************************
ApagaTela:
	push r0
	push r1
	
	loadn r0, #1200		; apaga as 1200 posicoes da Tela
	loadn r1, #' '		; com "espaco"
	
	   ApagaTela_Loop:	;;label for(r0=1200;r3>0;r3--)
		dec r0
		outchar r1, r0
		jnz ApagaTela_Loop
 
	pop r1
	pop r0
	rts	
	
;------------------------	


; Fim do jogo