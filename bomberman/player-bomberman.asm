; Tela 
; carrega tela de menu

jmp MostrarMenu

Msg1: string "DESEJA JOGAR NOVAMENTE? (s/n)" ; Mensagem para jogar novamente
OpSaidaFinal: var #1		; Contem a letra que foi digitada - 1 byte apenas
MsgFim: string "OBRIGADO POR JOGAR!"


MsgTitulo: string "==== BOMBERMAN ===="
MsgOpcao1: string "1 - JOGAR"
MsgOpcao2: string "2 - SAIR"
OpInicio: var #1 ; guarda a escolha do jogador


posAzul: var #1         ; Contem a posicao atual do Azul - inicial = 1043
posAntAzul: var #1      ; Contem a posicao anterior do Azul

posRosa: var #1         ; Contem a posicao atual da Rosa - inicial = 156
posAntRosa: var #1      ; Contem a posicao anterior da Rosa

bomba: var #1           ; Contem a posicao da bomba
;flagBomba: var #1       ; Flag de bomba acionada


teclaLidaAzul: var #1
teclaLidaRosa: var #1

Letra: var #1		; Contem a letra que foi digitada

;********************************************************
;                       MENU
; Apresenta o menu (tela inicial) do jogo
;********************************************************

MostrarMenu:
    call ApagaTela

    ; call printefeitoScreen -- Procedimento que ainda nao existe

    ; Exibir titulo
    loadn r0, #526 ; posicao na tela
    loadn r1, #MsgTitulo
    loadn r2, #0 ; Cor da mensagem (branco)
    call ImprimeStr

    ; Exibir Opcao 1
    loadn r0, #605 ; posicao na tela
    loadn r1, #MsgOpcao1
    loadn r2, #0 ; cor da mensagem (branco)
    call ImprimeStr

    ; Exibir Opcao 2
    loadn r0, #645 ; posicao na tela
    loadn r1, #MsgOpcao2
    loadn r2, #0 ; cor da mensagem (branco)
    call ImprimeStr
    
    MostrarMenu_Entrada:        ; Procedimento que espera por uma entrada valida do usuario
        call DigLetra

        ; provavel ter que fazer o numero virar char!!!
        load r1, Letra          ; Troquei o inchar para a chamada DigLetra
        ; store r1, OpInicio -- Ordem dos argumentos errados
        store OpInicio, r1

        ; Verifica opcoes
        loadn r3, #'1'
        loadn r4, #'2'

        cmp r1, r3
        jeq main ; Sintaxe da instrucao errada, x(je) -> jeq

        cmp r1, r4
        jeq Sair ; Sintaxe da instrucao errada, x(je) -> jeq

        jmp MostrarMenu_Entrada         ; Se for opcao invalida, nao fazer nada

;------------------------
	
;********************************************************
;                        MAIN
; Procedimento principal do jogo
;********************************************************
main:
    
    ; 0 branco                          0000 0000
    ; 256 marrom                        0001 0000
    ; 512 verde                         0010 0000
    ; 768 oliva                         0011 0000
    ; 1024 azul marinho                 0100 0000
    ; 1280 roxo                         0101 0000
    ; 1536 teal                         0110 0000
    ; 1792 prata                        0111 0000
    ; 2048 cinza                        1000 0000
    ; 2304 vermelho                     1001 0000
    ; 2560 lima                         1010 0000
    ; 2816 amarelo                      1011 0000
    ; 3072 azul                         1100 0000
    ; 3328 rosa                         1101 0000
    ; 3584 aqua                         1110 0000
    ; 3840 branco                       1111 0000

    ; carregar cenarios com as especificas cores;

    ; INICIALIZACAO DAS VARIAVEIS COM POSICAO
    loadn r0, #1043            
    store posAzul, r0       ; Zera Posicao do AZUL
    store posAntAzul, r0    ; Zera Posicao Anterior do AZUL

    
    loadn r0, #156
    store posRosa, r0      ; Zera Posicao Atual da ROSA
    store posAntRosa, r0   ; Zera Posicao Anterior da ROSA
    
;********************************************************
;                       CENARIO - MAIN
; Procedimento que instancia o cenario inicial do jogo.
;********************************************************
    call ApagaTela ; Limpa a tela antes de comecar a desenhar o cenario

    breakp

	loadn r1, #tela1Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #2048  			; cor cinza!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

	loadn r1, #tela2Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #3584  			; cor aqua!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

	loadn r1, #tela3Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #2304  			; cor vermelha!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

	loadn r1, #tela4Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #521  			; cor verde!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

	loadn r1, #tela5Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #0      			; cor branca!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

	loadn r1, #tela6Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #1280  			; cor roxa!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

	loadn r1, #tela7Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #2816  			; cor amarela!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    breakp

    halt

;================================================================
; LOOP PRINCIPAL (lê teclas e chama MovePlayer)
;================================================================
    Loop:
        inchar r1
        store teclaLidaAzul, r1

        ; Porque temos duas rotinas de leitura?
        inchar r1
        store teclaLidaRosa, r1

        ; --- Azul ---
        load r0, posAzul
        load r1, posAntAzul
        load r2, teclaLidaAzul
        ; call  MovePlayer -- chamada para procedimento que nao existe
        store posAzul, r0
        store posAntAzul, r1

        ; --- Bomba Azul? tecla 'e' ---
        loadn r3, #'e'
        load r4, teclaLidaAzul
        cmp r4, r3
        ; jeq DropBombAzul -- pulo para procedimento que nao existe

        ; --- Rosa ---
        load  r0, posRosa
        load  r1, posAntRosa
        load  r2, teclaLidaRosa
        ; call  MovePlayer -- chamada de procedimento que nao existe
        store posRosa, r0
        store posAntRosa, r1

        ; --- Bomba Rosa? tecla 'i' ---
        loadn r3, #'i'
        load  r4, teclaLidaRosa
        cmp   r4, r3
        ; jeq   DropBombRosa -- chamada de funcao que nao existe

        call Delay
        inc   r0      ; frame counter -- O que eh isso aqui?
        jmp Loop

; ;---------------------------------------------------------
; ; ROTINA GENÉRICA DE MOVIMENTO (DRY)
; ; Entrada:
; ;   r0 = posAtual
; ;   r2 = tecla lida (já vindo de teclaLidaAzul ou Rosa)
; ; Saída:
; ;   r0 = novaPos
; ;   r1 = posAnt
; ;---------------------------------------------------------
; RecalculaPosPlayer:
;     push  r1
;     push  r3
; 
;     mov  r1, r0          ; r1 ← posAnt
; 
;     ; — teclas do PLAYER 1 (W/A/S/D) —
;     loadn r3, #'w'        ; cima
;     cmp   r2, r3
;     jeq   RP1_UP
;     loadn r3, #'s'        ; baixo
;     cmp   r2, r3
;     jeq   RP1_DOWN
;     loadn r3, #'a'        ; esquerda
;     cmp   r2, r3
;     jeq   RP1_LEFT
;     loadn r3, #'d'        ; direita
;     cmp   r2, r3
;     jeq   RP1_RIGHT
; 
;     ; — teclas do PLAYER 2 (O/L/K/K) —
;     loadn r3, #'o'        ; cima
;     cmp   r2, r3
;     jeq   RP2_UP
;     loadn r3, #'l'        ; baixo
;     cmp   r2, r3
;     jeq   RP2_DOWN
;     loadn r3, #'k'        ; esquerda
;     cmp   r2, r3
;     jeq   RP2_LEFT
;     loadn r3, #135        ; direita (c cedilha)
;     cmp   r2, r3
;     jeq   RP2_RIGHT
; 
;     ; não é movimento → sai
;     jmp   RP_END
; 
; ;========= PLAYER 1 MOVES ==========
; RP1_UP:
;     loadn r3, #40
;     cmp   r0, r3
;     jle   RP_END
;     sub   r0, r0, r3
;     jmp   RP_END
; 
; RP1_DOWN:
;     loadn r3, #1159
;     cmp   r0, r3
;     jgr   RP_END
;     loadn r3, #40
;     add   r0, r0, r3
;     jmp   RP_END
; 
; RP1_LEFT:
;     loadn r3, #40
;     loadn r4, #0
;     mod   r3, r0, r3
;     cmp   r3, r4
;     jeq   RP_END
;     dec   r0
;     jmp   RP_END
; 
; RP1_RIGHT:
;     loadn r3, #40
;     loadn r4, #39
;     mod   r3, r0, r3
;     cmp   r3, r4
;     jeq   RP_END
;     inc   r0
;     jmp   RP_END
; 
; ;========= PLAYER 2 MOVES ==========
; RP2_UP:   jmp   RP1_UP
; RP2_DOWN: jmp   RP1_DOWN
; RP2_LEFT: jmp   RP1_LEFT
; RP2_RIGHT:jmp   RP1_RIGHT
; 
; RP_END:
;     pop   r3
;     pop   r1
;     rts
; 
; 
; ;================================================================
; ;                APAGA O PLAYER NA POSIKÃO ANTIGA
; ;================================================================
; ; Usa r1 = posAntiga
; ApagaPlayer:
;     push  r2
;     push  r3
;     push  r4
;     push  r5
; 
;     mov  r0, r1              ; r0 = posAnt
;     loadn r2, #0              ; base do cenário
;     add   r2, r2, r0          ; r2 = Tela1Linha0 + posAnt
;     loadn r4, #40
;     div   r3, r0, r4          ; linha = posAnt/40
;     add   r2, r2, r3          ; ajusta o deslocamento por linhas
;     loadi r5, r2              ; r5 = char original do cenário
;     outchar r5, r0            ; restaura o char do cenário
; 
;     pop   r5
;     pop   r4
;     pop   r3
;     pop   r2
;     rts
; 
; ;================================================================
; ;               DESENHA O PLAYER NA NOVA POSIKÃO
; ;================================================================
; ; Usa r0 = posNova, r1 = posAntiga (para atualizar posAnt depois)
; DesenhaPlayer:
;     push  r2
;     push  r3
; 
;     loadn r2, #0              ; índice do sprite/personagem
;     outchar r2, r0
;     store posAnt, r0          ; atualiza posAnt = nova pos
;     ; OBS: quem chamou deve armazenar posAnt em variáveis corretas
; 
;     pop   r3
;     pop   r2
;     rts
; 
; ;----------------------------------



;********************************************************
;                       COLISAO
;********************************************************
; index 1 : bomba - independente se do adversario ou nao 
; index 2 : bloco
; index 3 : luck box
; index 4 : caixa 


; Memoria de Cenario necessaria - criar um vetor com todas as info da tela atual - deve ter de modificacao - caso a bomba seja explodida
; todos os blocos sao intransponiveis

; como faz a colisao de qualquer coisa no mapa? - verifica onde o player esta: posicao do player e onde ele vai casos:
; : se onde o player esta agora, tiver disparo da tecla de (onde o esta o bloco) - deny - nao faça nada

; e assim como o jogador - instanciamos cada bloco ou caixa para modificá-los aqui

; caixaS para efeitos -> explodir ou apenas passar por cima e ter efeito?





;---------------------------------- 

;********************************************************
;                       BOMBA
;********************************************************
; bomba - param. é o endr. atual -> quando chamada resulta no inicio de um loop
; loop -> cada iteração a bomba a bomba muda de "cenario" -> retorna ao cenario da bomba normal
; limite de "tiques" para a bomba explodir? 3, eu acho



; se caixa: caso a bomba exploda 
;   -> e caixaS estiver numa regiao proxima e jogador NAO atingido (proximo) -> caixaS tem chance randomica (numeros, exemplo: se par entao sorteia dnv pra ver qual item) 
;       (se impar, nao faz nada)
;             faz o item aparecer no lugar onde foi explodida a caixa;
;   
;   -> (jogador atingido) 
;     -> jogador de OUTRO numero sai como vitorioso apos um delay; conta apenas o primeiro que morrer; flagzinha pra isso


; caso tecla E  -> jogador 1 bomba 
; caso tecla I  -> jogador 2 bomba

; bomba -> explosao em + -> se caixa estiver em +, explode normal
; bomba -> se caixaS -> explode normal, chance de item

; bomba alteracoes: caso colocamos efeitos especiais

;----------------------------------

	
;********************************************************
;                       SAIR
;********************************************************
Sair:
    call ApagaTela
    ; Pode colocar mensagem de despedida, ou parar o programa
    loadn r0, #100
    loadn r1, #MsgFim
    
    call ImprimeStr

    halt


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



;********************************************************
;                   IMPRIME STRING
;********************************************************
    
ImprimeStr: ;  Rotina de Impresao de Mensagens:    r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso;  r1 = endereco onde comeca a mensagem; r2 = cor da mensagem.   Obs: a mensagem sera' impressa ate' encontrar "/0"
    push r0 ; protege o r0 na pilha para preservar seu valor
    push r1 ; protege o r1 na pilha para preservar seu valor
    push r2 ; protege o r1 na pilha para preservar seu valor
    push r3 ; protege o r3 na pilha para ser usado na subrotina
    push r4 ; protege o r4 na pilha para ser usado na subrotina
    
    loadn r3, #'\0' ; Criterio de parada

   ImprimeStr_Loop: 
        loadi r4, r1
        cmp r4, r3      ; If (Char == \0)  vai Embora
        jeq ImprimeStr_Sai
        add r4, r2, r4  ; Soma a Cor
        outchar r4, r0  ; Imprime o caractere na tela
        inc r0          ; Incrementa a posicao na tela
        inc r1          ; Incrementa o ponteiro da String
        jmp ImprimeStr_Loop
    
   ImprimeStr_Sai:  
    pop r4  ; Resgata os valores dos registradores utilizados na Subrotina da Pilha
    pop r3
    pop r2
    pop r1
    pop r0
    rts
    
    


;------------------------

;********************************************************
;                       DELAY
;********************************************************       


Delay:
                        ;Utiliza Push e Pop para nao afetar os Ristradores do programa principal
    Push r0
    Push r1
    
    Loadn r1, #50  ; a
   Delay_volta2:                ;Quebrou o contador acima em duas partes (dois loops de decremento)
    Loadn r0, #3000 ; b
   Delay_volta: 
    Dec r0                  ; (4*a + 6)b = 1000000  == 1 seg  em um clock de 1MHz
    JNZ Delay_volta 
    Dec r1
    JNZ Delay_volta2
    
    Pop r1
    Pop r0
    
    rts                         ;return

;------------------------


;********************************************************
;                       IMPRIME TELA
;********************************************************   

ImprimeTela:    ;  Rotina de Impresao de Cenario na Tela Inteira
        ;  r1 = endereco onde comeca a primeira linha do Cenario
        ;  r2 = cor do Cenario para ser impresso

    push r0 ; protege o r3 na pilha para ser usado na subrotina
    push r1 ; protege o r1 na pilha para preservar seu valor
    push r2 ; protege o r1 na pilha para preservar seu valor
    push r3 ; protege o r3 na pilha para ser usado na subrotina
    push r4 ; protege o r4 na pilha para ser usado na subrotina
    push r5 ; protege o r4 na pilha para ser usado na subrotina

    loadn r0, #0    ; posicao inicial tem que ser o comeco da tela!
    loadn r3, #40   ; Incremento da posicao da tela!
    loadn r4, #41   ; incremento do ponteiro das linhas da tela
    loadn r5, #1200 ; Limite da tela!
    
   ImprimeTela_Loop:
        call ImprimeStr
        add r0, r0, r3      ; incrementaposicao para a segunda linha na tela -->  r0 = r0 + 40
        add r1, r1, r4      ; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
        cmp r0, r5          ; Compara r0 com 1200
        jne ImprimeTela_Loop    ; Enquanto r0 < 1200

    pop r5  ; Resgata os valores dos registradores utilizados na Subrotina da Pilha
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts
                
;---------------------

;-------------------------------


;********************************************************
;                       IMPRIME TELA2
;********************************************************	

ImprimeTela2: 	;  Rotina de Impresao de Cenario na Tela Inteira
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina

	loadn r0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn r3, #40  	; Incremento da posicao da tela!
	loadn r4, #41  	; incremento do ponteiro das linhas da tela
	loadn r5, #1200 ; Limite da tela!
	loadn r6, #tela0Linha0	; Endereco onde comeca a primeira linha do cenario!!
	
   ImprimeTela2_Loop:
		call ImprimeStr2
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		add r6, r6, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela2_Loop	; Enquanto r0 < 1200

	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
				
;---------------------

;---------------------------	
;********************************************************
;                   IMPRIME STRING2
;********************************************************
	
ImprimeStr2:    ; Rotina de Impresao de Mensagens; Obs: a mensagem sera' impressa ate' encontrar "/0"
    ; r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso
    ; r1 = endereco onde comeca a mensagem
    ; r2 = cor da mensagem.

	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	push r6	; protege o r6 na pilha para ser usado na subrotina
	
	
	loadn r3, #'\0'	; Criterio de parada
	loadn r5, #' '	; Espaco em Branco

    ImprimeStr2_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr2_Sai
		cmp r4, r5		; If (Char == ' ')  vai Pula outchar do espaco para na apagar outros caracteres
		jeq ImprimeStr2_Skip
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
   		storei r6, r4
    ImprimeStr2_Skip:
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		inc r6
		jmp ImprimeStr2_Loop
	
    ImprimeStr2_Sai:	
	pop r6	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts


;------------------------		

;********************************************************
;                   DIGITE UMA LETRA
;********************************************************

DigLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push r0
	push r1
	loadn r1, #255	; Se nao digitar nada vem 255

   DigLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			;compara r0 com 255
		jeq DigLetra_Loop	; Fica lendo ate' que digite uma tecla valida

	store Letra, r0			; Salva a tecla na variavel global "Letra"

	pop r1
	pop r0
	rts


; completo
tela0Linha0  : string "KLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLK"
tela0Linha1  : string "LKHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHKL"
tela0Linha2  : string "LHKLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLKHL"
tela0Linha3  : string "LHL C              OOO           C   LHL"
tela0Linha4  : string "LHL  C              C            C   LHL"
tela0Linha5  : string "LHL   OOOOOOOOOOOOOOOOOOOOOOOOOOOOCCCLHL"
tela0Linha6  : string "LHLCCCC            UU            C   LHL"
tela0Linha7  : string "LHL   OOO   O      UU      O   OOO   LHL"
tela0Linha8  : string "LHL   OOO                      OOO   LHL"
tela0Linha9  : string "LHL   OOO   O        KKK   O   OOO   LHL"
tela0Linha10 : string "LHL   OOO           K   K      OOO   LHL"
tela0Linha11 : string "LHL   OOO   O     PPPP     O   OOO   LHL"
tela0Linha12 : string "LHL C OOO       PPPPPPPP       OOO C LHL"
tela0Linha13 : string "LHL U OOO   O  PP PPPPPPP  O   OOO U LHL"
tela0Linha14 : string "LHL C OOO      PP PPPPPPP      OOO C LHL"
tela0Linha15 : string "LHL   OOO   O   PPPPPPPP   O   OOO   LHL"
tela0Linha16 : string "LHL   OOO         PPPP         OOO   LHL"
tela0Linha17 : string "LHL   OOO   O              O   OOO   LHL"
tela0Linha18 : string "LHL   OOO                      OOO   LHL"
tela0Linha19 : string "LHL   OOO   O              O   OOO   LHL"
tela0Linha20 : string "LHL   OOO          UU          OOO   LHL"
tela0Linha21 : string "LHL   OOO   O      UU      O   OOO   LHL"
tela0Linha22 : string "LHLCCC                           CCCCLHL"
tela0Linha23 : string "LHL  COOOOOOOOOOOOOOOOOOOOOOOOOOOO   LHL"
tela0Linha24 : string "LHL  COOOOOOOOOOOOOOOOOOOOOOOOOOOO   LHL"
tela0Linha25 : string "LHL  C              C            CC  LHL"
tela0Linha26 : string "LHL  O             OOO           O  OLHL"
tela0Linha27 : string "LHKLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLKHL"
tela0Linha28 : string "LKHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHKL"
tela0Linha29 : string "KLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLK"     


; l - cinza
tela1Linha0  : string " LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL "
tela1Linha1  : string "L                                      L"
tela1Linha2  : string "L  LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL  L"
tela1Linha3  : string "L L                                  L L"
tela1Linha4  : string "L L                                  L L"
tela1Linha5  : string "L L                                  L L"
tela1Linha6  : string "L L                                  L L"
tela1Linha7  : string "L L                                  L L"
tela1Linha8  : string "L L                                  L L"
tela1Linha9  : string "L L                                  L L"
tela1Linha10 : string "L L                                  L L"
tela1Linha11 : string "L L                                  L L"
tela1Linha12 : string "L L                                  L L"
tela1Linha13 : string "L L                                  L L"
tela1Linha14 : string "L L                                  L L"
tela1Linha15 : string "L L                                  L L"
tela1Linha16 : string "L L                                  L L"
tela1Linha17 : string "L L                                  L L"
tela1Linha18 : string "L L                                  L L"
tela1Linha19 : string "L L                                  L L"
tela1Linha20 : string "L L                                  L L"
tela1Linha21 : string "L L                                  L L"
tela1Linha22 : string "L L                                  L L"
tela1Linha23 : string "L L                                  L L"
tela1Linha24 : string "L L                                  L L"
tela1Linha25 : string "L L                                  L L"
tela1Linha26 : string "L L                                  L L"
tela1Linha27 : string "L  LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL  L"
tela1Linha28 : string "L                                      L"
tela1Linha29 : string " LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL "  
 

; h - ciano 
tela2Linha0  : string "                                        "
tela2Linha1  : string "  HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH  "
tela2Linha2  : string " H                                    H "
tela2Linha3  : string " H                                    H "
tela2Linha4  : string " H                                    H "
tela2Linha5  : string " H                                    H "
tela2Linha6  : string " H                                    H "
tela2Linha7  : string " H                                    H "
tela2Linha8  : string " H                                    H "
tela2Linha9  : string " H                                    H "
tela2Linha10 : string " H                                    H "
tela2Linha11 : string " H                                    H "
tela2Linha12 : string " H                                    H "
tela2Linha13 : string " H                                    H "
tela2Linha14 : string " H                                    H "
tela2Linha15 : string " H                                    H "
tela2Linha16 : string " H                                    H "
tela2Linha17 : string " H                                    H "
tela2Linha18 : string " H                                    H "
tela2Linha19 : string " H                                    H "
tela2Linha20 : string " H                                    H "
tela2Linha21 : string " H                                    H "
tela2Linha22 : string " H                                    H "
tela2Linha23 : string " H                                    H "
tela2Linha24 : string " H                                    H "
tela2Linha25 : string " H                                    H "
tela2Linha26 : string " H                                    H "
tela2Linha27 : string " H                                    H "
tela2Linha28 : string "  HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH  "
tela2Linha29 : string "                                        " 

; ç - vermelho
tela3Linha0  : string "K                                      K"
tela3Linha1  : string " K                                    K "
tela3Linha2  : string "  K                                  K  "
tela3Linha3  : string "                                        "
tela3Linha4  : string "                                        "
tela3Linha5  : string "                                        "
tela3Linha6  : string "                                        "
tela3Linha7  : string "                                        "
tela3Linha8  : string "                                        "
tela3Linha9  : string "                     KKK                "
tela3Linha10 : string "                    K   K               "
tela3Linha11 : string "                                        "
tela3Linha12 : string "                                        "
tela3Linha13 : string "                                        "
tela3Linha14 : string "                                        "
tela3Linha15 : string "                                        "
tela3Linha16 : string "                                        "
tela3Linha17 : string "                                        "
tela3Linha18 : string "                                        "
tela3Linha19 : string "                                        "
tela3Linha20 : string "                                        "
tela3Linha21 : string "                                        "
tela3Linha22 : string "                                        "
tela3Linha23 : string "                                        "
tela3Linha24 : string "                                        "
tela3Linha25 : string "                                        "
tela3Linha26 : string "                                        "
tela3Linha27 : string "  K                                  K  "
tela3Linha28 : string " K                                    K "
tela3Linha29 : string "K                                      K"


; o - parede verde
tela4Linha0  : string "                                        "
tela4Linha1  : string "                                        "
tela4Linha2  : string "                                        "
tela4Linha3  : string "                   OOO                  "
tela4Linha4  : string "                                        "
tela4Linha5  : string "      OOOOOOOOOOOOOOOOOOOOOOOOOOOO      "
tela4Linha6  : string "                                        "
tela4Linha7  : string "      OOO   O              O   OOO      "
tela4Linha8  : string "      OOO                      OOO      "
tela4Linha9  : string "      OOO   O              O   OOO      "
tela4Linha10 : string "      OOO                      OOO      "
tela4Linha11 : string "      OOO   O              O   OOO      "
tela4Linha12 : string "      OOO                      OOO      "
tela4Linha13 : string "      OOO   O              O   OOO      "
tela4Linha14 : string "      OOO                      OOO      "
tela4Linha15 : string "      OOO   O              O   OOO      "
tela4Linha16 : string "      OOO                      OOO      "
tela4Linha17 : string "      OOO   O              O   OOO      "
tela4Linha18 : string "      OOO                      OOO      "
tela4Linha19 : string "      OOO   O              O   OOO      "
tela4Linha20 : string "      OOO                      OOO      "
tela4Linha21 : string "      OOO   O              O   OOO      "
tela4Linha22 : string "                                        "
tela4Linha23 : string "     COOOOOOOOOOOOOOOOOOOOOOOOOOOO      "
tela4Linha24 : string "     COOOOOOOOOOOOOOOOOOOOOOOOOOOO      "
tela4Linha25 : string "                                        "
tela4Linha26 : string "     O             OOO           O  O   "
tela4Linha27 : string "                                        "
tela4Linha28 : string "                                        "
tela4Linha29 : string "                                        " 
    
;p -5preto     
tela5Linha0  : string "                                        "
tela5Linha1  : string "                                        "
tela5Linha2  : string "                                        "
tela5Linha3  : string "                                        "
tela5Linha4  : string "                                        "
tela5Linha5  : string "                                        "
tela5Linha6  : string "                                        "
tela5Linha7  : string "                                        "
tela5Linha8  : string "                                        "
tela5Linha9  : string "                                        "
tela5Linha10 : string "                                        "
tela5Linha11 : string "                  PPPP                  "
tela5Linha12 : string "                PPPPPPPP                "
tela5Linha13 : string "               PP PPPPPPP               "
tela5Linha14 : string "               PP PPPPPPP               "
tela5Linha15 : string "                PPPPPPPP                "
tela5Linha16 : string "                  PPPP                  "
tela5Linha17 : string "                                        "
tela5Linha18 : string "                                        "
tela5Linha19 : string "                                        "
tela5Linha20 : string "                                        "
tela5Linha21 : string "                                        "
tela5Linha22 : string "                                        "
tela5Linha23 : string "                                        "
tela5Linha24 : string "                                        "
tela5Linha25 : string "                                        "
tela5Linha26 : string "                                        "
tela5Linha27 : string "                                        "
tela5Linha28 : string "                                        "
tela5Linha29 : string "                                        "

; c caixa
tela6Linha0  : string "                                        "
tela6Linha1  : string "                                        "
tela6Linha2  : string "                                        "
tela6Linha3  : string "    C                            C      "
tela6Linha4  : string "     C              C            C      "
tela6Linha5  : string "                                  CCC   "
tela6Linha6  : string "   CCCC                          C      "
tela6Linha7  : string "                                        "
tela6Linha8  : string "                                        "
tela6Linha9  : string "                                        "
tela6Linha10 : string "                                        "
tela6Linha11 : string "                                        "
tela6Linha12 : string "    C                              C    "
tela6Linha13 : string "                                        "
tela6Linha14 : string "    C                              C    "
tela6Linha15 : string "                                        "
tela6Linha16 : string "                                        "
tela6Linha17 : string "                                        "
tela6Linha18 : string "                                        "
tela6Linha19 : string "                                        "
tela6Linha20 : string "                                        "
tela6Linha21 : string "                                        "
tela6Linha22 : string "   CCC                           CCCC   "
tela6Linha23 : string "     C                                  "
tela6Linha24 : string "     C                                  "
tela6Linha25 : string "     C              C            CC     "
tela6Linha26 : string "                                        "
tela6Linha27 : string "                                        "
tela6Linha28 : string "                                        "
tela6Linha29 : string "                                        " 

; u luckblock
tela7Linha0  : string "                                        "
tela7Linha1  : string "                                        "
tela7Linha2  : string "                                        "
tela7Linha3  : string "                                        "
tela7Linha4  : string "                                        "
tela7Linha5  : string "                                        "
tela7Linha6  : string "                   UU                   "
tela7Linha7  : string "                   UU                   "
tela7Linha8  : string "                                        "
tela7Linha9  : string "                                        "
tela7Linha10 : string "                                        "
tela7Linha11 : string "                                        "
tela7Linha12 : string "                                        "
tela7Linha13 : string "    U                              U    "
tela7Linha14 : string "                                        "
tela7Linha15 : string "                                        "
tela7Linha16 : string "                                        "
tela7Linha17 : string "                                        "
tela7Linha18 : string "                                        "
tela7Linha19 : string "                                        "
tela7Linha20 : string "                   UU                   "
tela7Linha21 : string "                   UU                   "
tela7Linha22 : string "                                        "
tela7Linha23 : string "                                        "
tela7Linha24 : string "                                        "
tela7Linha25 : string "                                        "
tela7Linha26 : string "                                        "
tela7Linha27 : string "                                        "
tela7Linha28 : string "                                        "
tela7Linha29 : string "                                        " 
