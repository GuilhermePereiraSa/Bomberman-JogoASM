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


posAzul: var #1         ; Contem a posicao atual do Azul - inicial = 1043
posAntAzul: var #1      ; Contem a posicao anterior do Azul

posRosa: var #1         ; Contem a posicao atual da Rosa - inicial = 156
posAntRosa: var #1      ; Contem a posicao anterior da Rosa

bomba: var #1           ; Contem a posicao da bomba
flagBomba: var #1       ; Flag de bomba acionada


; Memoria de Cenario necessaria - criar um vetor com todas as info da tela atual - deve ter de modificacao - caso a bomba seja explodida
; todos os blocos sao intransponiveis

; como faz a colisao de qualquer coisa no mapa? - verifica onde o player esta: posicao do player e onde ele vai casos:
; : se onde o player esta agora, tiver disparo da tecla de (onde o esta o bloco) - deny - nao faça nada

; e assim como o jogador - instanciamos cada bloco ou caixa para modificá-los aqui

; caixaS para efeitos -> explodir ou apenas passar por cima e ter efeito?

; se caixa: caso a bomba exploda 
;   -> e caixaS estiver numa regiao proxima e jogador NAO atingido (proximo) -> caixaS tem chance randomica (numeros, exemplo: se par entao sorteia dnv pra ver qual item) 
;       (se impar, nao faz nada)
;             faz o item aparecer no lugar onde foi explodida a caixa;
;   
;   -> (jogador atingido) 
;     -> jogador de OUTRO numero sai como vitorioso apos um delay; conta apenas o primeiro que morrer; flagzinha pra isso


; caso tecla R  -> jogador 1 bomba 
; caso tecla I  -> jogador 2 bomba

; bomba -> explosao em + -> se caixa estiver em +, explode normal
; bomba -> se caixaS -> explode normal, chance de item

; bomba alteracoes: caso colocamos efeitos especiais

;********************************************************
;                       MENU
;********************************************************

menu:
    call ApagaTela

    call printefeitoScreen

    ; Exibir titulo
    loadn r0, #526 ; posicao na tela
    loadn r1, #MsgTitulo
    loadn r2, #0
    call ImprimeStr

    ; Exibir Opcao 1
    loadn r0, #605 ; posicao na tela
    loadn r1, #MsgOpcao1
    loadn r2, #0
    call ImprimeStr

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
;                       JOGAR - MAIN
;********************************************************
Jogar:
    
    ;call ApagaTela
    ;loadn R1, #tela1Linha0  ; Endereco onde comeca a primeira linha do cenario!!
    ;loadn R2, #1536             ; cor branca!
    ;call ImprimeTela2           ;  Rotina de Impresao de Cenario na Tela Inteira
    ;
    ;loadn R1, #tela2Linha0  ; Endereco onde comeca a primeira linha do cenario!!
    ;loadn R2, #512              ; cor branca!
    ;call ImprimeTela2           ;  Rotina de Impresao de Cenario na Tela Inteira
    ;
    ;loadn R1, #tela3Linha0  ; Endereco onde comeca a primeira linha do cenario!!
    ;loadn R2, #2816             ; cor branca!
    ;call ImprimeTela2           ;  Rotina de Impresao de Cenario na Tela Inteira
    ;loadn R1, #tela4Linha0  ; Endereco onde comeca a primeira linha do cenario!!
    ;loadn R2, #256              ; cor branca!
    ;call ImprimeTela2           ;  Rotina de Impresao de Cenario na Tela Inteira


    Loadn R0, #1043            
    store posAzul, R0       ; Zera Posicao do AZUL
    store posAntAzul, R0    ; Zera Posicao Anterior do AZUL

    
    Loadn R0, #156
    store posRosa, R0      ; Zera Posicao Atual da ROSA
    store posAntRosa, R0   ; Zera Posicao Anterior da ROSA
    
    Loadn R0, #0            ; Contador para os Mods = 0
    loadn R2, #0            ; Para verificar se (mod(c/10)==0

    Loop:
    
        loadn R1, #10   ; movimentacao do azul
        mod R1, R0, R1
        cmp R1, R2      ; 
        ceq MoveAzul    ; 
    
        loadn R1, #30
        mod R1, R0, R1
        cmp R1, R2      ; 
        ceq MoveRosa   ;
    
        call Delay
        inc R0  ;c++
        jmp Loop



; Todo movimento de personagem com acionamento da tecla de bomba deve resultar em onde a bomba sera plantada



;------------------------

;********************************************************
;             FUNÇÕES AUXILIARES DE MOVIMENTO
;********************************************************

MoveAzul:
    push r0
    push r1
    
    call MoveAzul_RecalculaPos      ; Recalcula Posicao do AZUL

; So' Apaga e Redesenha se (pos != posAnt)
;   If (posNave != posAntNave)  {   

    load r0, posAzul
    load r1, posAntAzul
    cmp r0, r1
    jeq MoveAzul_Skip
        call MoveAzul_Apaga
        call MoveAzul_Desenha       ;}
    MoveAzul_Skip:
      
      pop r1
      pop r0
      rts

;--------------------------------
    
MoveAzul_Apaga:     ; Apaga a Nave preservando o Cenario!
    push R0
    push R1
    push R2
    push R3
    push R4
    push R5

    load R0, posAntAzul ; R0 = posAnt
    
    ; --> R2 = Tela1Linha0 + posAnt + posAnt/40  ; tem que somar posAnt/40 no ponteiro pois as linas da string terminam com /0 !!

    loadn R1, #0  ; Endereco onde comeca a primeira linha do cenario!!
    add R2, R1, r0  ; R2 = Tela1Linha0 + posAnt
    loadn R4, #40
    div R3, R0, R4  ; R3 = posAnt/40
    add R2, R2, R3  ; R2 = Tela1Linha0 + posAnt + posAnt/40
    
    loadi R5, R2    ; R5 = Char (Tela(posAnt))
    
    outchar R5, R0  ; Apaga o Obj na tela com o Char correspondente na memoria do cenario
    
    pop R5
    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts
;---------------------------------- 
    
MoveAzul_RecalculaPos:      ; Recalcula posicao do Azul em funcao das Teclas pressionadas
    push R0
    push R1
    push R2
    push R3

    load R0, posAzul
    
    inchar R1               ; Le Teclado para controlar o Azul
    loadn R2, #'a'
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_A
    
    loadn R2, #'d'
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_D
        
    loadn R2, #'w'
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_W
        
    loadn R2, #'s'
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_S
    
    loadn R2, #'e'
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_Bomba
    
  MoveAzul_RecalculaPos_Fim:    ; Se nao for nenhuma tecla valida, vai embora
    store posAzul, R0
    pop R3
    pop R2
    pop R1
    pop R0
    rts

  MoveAzul_RecalculaPos_A:  ; Move Nave para Esquerda
    loadn R1, #40
    loadn R2, #0
    mod R1, R0, R1      ; Testa condicoes de Contorno 
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_Fim
    dec R0  ; pos = pos -1
    jmp MoveAzul_RecalculaPos_Fim
        
  MoveAzul_RecalculaPos_D:  ; Move Nave para Direita    
    loadn R1, #40
    loadn R2, #39
    mod R1, R0, R1      ; Testa condicoes de Contorno 
    cmp R1, R2
    jeq MoveAzul_RecalculaPos_Fim
    inc R0  ; pos = pos + 1
    jmp MoveAzul_RecalculaPos_Fim
    
  MoveAzul_RecalculaPos_W:  ; Move Nave para Cima
    loadn R1, #40
    cmp R0, R1      ; Testa condicoes de Contorno 
    jle MoveAzul_RecalculaPos_Fim
    sub R0, R0, R1  ; pos = pos - 40
    jmp MoveAzul_RecalculaPos_Fim

  MoveAzul_RecalculaPos_S:  ; Move Nave para Baixo
    loadn R1, #1159
    cmp R0, R1      ; Testa condicoes de Contorno 
    jgr MoveAzul_RecalculaPos_Fim
    loadn R1, #40
    add R0, R0, R1  ; pos = pos + 40
    jmp MoveAzul_RecalculaPos_Fim   
    
  MoveAzul_RecalculaPos_Bomba:   
    loadn R1, #1            ; Se Atirou:
    store flagBomba, R1      ; flagBomba = 1

    store posTiro, R0       ; 

    jmp MoveAzul_RecalculaPos_Fim   
;----------------------------------
MoveAzul_Desenha:   ; Desenha caractere da Nave
    push R0
    push R1
    
    Loadn R1, #0  ; index personagem
    load R0, posAzul
    outchar R1, R0
    store posAntAzul, R0    ; Atualiza Posicao Anterior da Nave = Posicao Atual
    
    pop R1
    pop R0
    rts

;---------------------------------- 

;********************************************************
;                       COLISAO
;********************************************************
; index 1 : bomba - independente se do adversario ou nao 
; index 2 : bloco
; index 3 : luck box
; index 4 : caixa 




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
    Push R0
    Push R1
    
    Loadn R1, #50  ; a
   Delay_volta2:                ;Quebrou o contador acima em duas partes (dois loops de decremento)
    Loadn R0, #3000 ; b
   Delay_volta: 
    Dec R0                  ; (4*a + 6)b = 1000000  == 1 seg  em um clock de 1MHz
    JNZ Delay_volta 
    Dec R1
    JNZ Delay_volta2
    
    Pop R1
    Pop R0
    
    RTS                         ;return

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

    loadn R0, #0    ; posicao inicial tem que ser o comeco da tela!
    loadn R3, #40   ; Incremento da posicao da tela!
    loadn R4, #41   ; incremento do ponteiro das linhas da tela
    loadn R5, #1200 ; Limite da tela!
    
   ImprimeTela_Loop:
        call ImprimeStr
        add r0, r0, r3      ; incrementaposicao para a segunda linha na tela -->  r0 = R0 + 40
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




efeito : var #1200
  ;Linha 0
  static efeito + #0, #2396
  static efeito + #1, #1538
  static efeito + #2, #1538
  static efeito + #3, #1538
  static efeito + #4, #1538
  static efeito + #5, #1538
  static efeito + #6, #1538
  static efeito + #7, #1538
  static efeito + #8, #1538
  static efeito + #9, #1538
  static efeito + #10, #1538
  static efeito + #11, #1538
  static efeito + #12, #1538
  static efeito + #13, #1538
  static efeito + #14, #1538
  static efeito + #15, #1538
  static efeito + #16, #1538
  static efeito + #17, #1538
  static efeito + #18, #1538
  static efeito + #19, #1538
  static efeito + #20, #1538
  static efeito + #21, #1538
  static efeito + #22, #1538
  static efeito + #23, #1538
  static efeito + #24, #1538
  static efeito + #25, #1538
  static efeito + #26, #1538
  static efeito + #27, #1538
  static efeito + #28, #1538
  static efeito + #29, #1538
  static efeito + #30, #1538
  static efeito + #31, #1538
  static efeito + #32, #1538
  static efeito + #33, #1538
  static efeito + #34, #1538
  static efeito + #35, #1538
  static efeito + #36, #1538
  static efeito + #37, #1538
  static efeito + #38, #1538
  static efeito + #39, #2351

  ;Linha 1
  static efeito + #40, #1538
  static efeito + #41, #2396
  static efeito + #42, #2050
  static efeito + #43, #2050
  static efeito + #44, #2050
  static efeito + #45, #2050
  static efeito + #46, #2050
  static efeito + #47, #2050
  static efeito + #48, #2050
  static efeito + #49, #2050
  static efeito + #50, #2050
  static efeito + #51, #2050
  static efeito + #52, #2050
  static efeito + #53, #2050
  static efeito + #54, #2050
  static efeito + #55, #2050
  static efeito + #56, #2050
  static efeito + #57, #2050
  static efeito + #58, #2050
  static efeito + #59, #2050
  static efeito + #60, #2050
  static efeito + #61, #2050
  static efeito + #62, #2050
  static efeito + #63, #2050
  static efeito + #64, #2050
  static efeito + #65, #2050
  static efeito + #66, #2050
  static efeito + #67, #2050
  static efeito + #68, #2050
  static efeito + #69, #2050
  static efeito + #70, #2050
  static efeito + #71, #2050
  static efeito + #72, #2050
  static efeito + #73, #2050
  static efeito + #74, #2050
  static efeito + #75, #2050
  static efeito + #76, #2050
  static efeito + #77, #2050
  static efeito + #78, #2351
  static efeito + #79, #1538

  ;Linha 2
  static efeito + #80, #1538
  static efeito + #81, #2050
  static efeito + #82, #2396
  static efeito + #83, #1538
  static efeito + #84, #1538
  static efeito + #85, #1538
  static efeito + #86, #1538
  static efeito + #87, #1538
  static efeito + #88, #1538
  static efeito + #89, #1538
  static efeito + #90, #1538
  static efeito + #91, #1538
  static efeito + #92, #1538
  static efeito + #93, #1538
  static efeito + #94, #1538
  static efeito + #95, #1538
  static efeito + #96, #1538
  static efeito + #97, #1538
  static efeito + #98, #1538
  static efeito + #99, #1538
  static efeito + #100, #1538
  static efeito + #101, #1538
  static efeito + #102, #1538
  static efeito + #103, #1538
  static efeito + #104, #1538
  static efeito + #105, #1538
  static efeito + #106, #1538
  static efeito + #107, #1538
  static efeito + #108, #1538
  static efeito + #109, #1538
  static efeito + #110, #1538
  static efeito + #111, #1538
  static efeito + #112, #1538
  static efeito + #113, #1538
  static efeito + #114, #1538
  static efeito + #115, #1538
  static efeito + #116, #1538
  static efeito + #117, #2351
  static efeito + #118, #2050
  static efeito + #119, #1538

  ;Linha 3
  static efeito + #120, #1538
  static efeito + #121, #2050
  static efeito + #122, #1538
  static efeito + #123, #770
  static efeito + #124, #127
  static efeito + #125, #127
  static efeito + #126, #127
  static efeito + #127, #127
  static efeito + #128, #127
  static efeito + #129, #127
  static efeito + #130, #2819
  static efeito + #131, #2848
  static efeito + #132, #127
  static efeito + #133, #2848
  static efeito + #134, #127
  static efeito + #135, #127
  static efeito + #136, #127
  static efeito + #137, #127
  static efeito + #138, #127
  static efeito + #139, #770
  static efeito + #140, #770
  static efeito + #141, #127
  static efeito + #142, #127
  static efeito + #143, #127
  static efeito + #144, #2819
  static efeito + #145, #127
  static efeito + #146, #127
  static efeito + #147, #2848
  static efeito + #148, #2848
  static efeito + #149, #127
  static efeito + #150, #127
  static efeito + #151, #127
  static efeito + #152, #127
  static efeito + #153, #127
  static efeito + #154, #260
  static efeito + #155, #800
  static efeito + #156, #32
  static efeito + #157, #1538
  static efeito + #158, #2050
  static efeito + #159, #1538

  ;Linha 4
  static efeito + #160, #1538
  static efeito + #161, #2050
  static efeito + #162, #1538
  static efeito + #163, #127
  static efeito + #164, #127
  static efeito + #165, #770
  static efeito + #166, #127
  static efeito + #167, #127
  static efeito + #168, #127
  static efeito + #169, #127
  static efeito + #170, #2848
  static efeito + #171, #2848
  static efeito + #172, #127
  static efeito + #173, #2819
  static efeito + #174, #127
  static efeito + #175, #127
  static efeito + #176, #127
  static efeito + #177, #127
  static efeito + #178, #127
  static efeito + #179, #260
  static efeito + #180, #260
  static efeito + #181, #127
  static efeito + #182, #127
  static efeito + #183, #127
  static efeito + #184, #127
  static efeito + #185, #127
  static efeito + #186, #127
  static efeito + #187, #2848
  static efeito + #188, #2819
  static efeito + #189, #127
  static efeito + #190, #127
  static efeito + #191, #127
  static efeito + #192, #127
  static efeito + #193, #770
  static efeito + #194, #260
  static efeito + #195, #800
  static efeito + #196, #127
  static efeito + #197, #1538
  static efeito + #198, #2050
  static efeito + #199, #1538

  ;Linha 5
  static efeito + #200, #1538
  static efeito + #201, #2050
  static efeito + #202, #1538
  static efeito + #203, #127
  static efeito + #204, #127
  static efeito + #205, #770
  static efeito + #206, #770
  static efeito + #207, #770
  static efeito + #208, #770
  static efeito + #209, #770
  static efeito + #210, #770
  static efeito + #211, #770
  static efeito + #212, #770
  static efeito + #213, #770
  static efeito + #214, #770
  static efeito + #215, #770
  static efeito + #216, #770
  static efeito + #217, #770
  static efeito + #218, #770
  static efeito + #219, #770
  static efeito + #220, #770
  static efeito + #221, #770
  static efeito + #222, #770
  static efeito + #223, #770
  static efeito + #224, #770
  static efeito + #225, #770
  static efeito + #226, #770
  static efeito + #227, #770
  static efeito + #228, #770
  static efeito + #229, #770
  static efeito + #230, #770
  static efeito + #231, #770
  static efeito + #232, #770
  static efeito + #233, #770
  static efeito + #234, #260
  static efeito + #235, #2848
  static efeito + #236, #2848
  static efeito + #237, #1538
  static efeito + #238, #2050
  static efeito + #239, #1538

  ;Linha 6
  static efeito + #240, #1538
  static efeito + #241, #2050
  static efeito + #242, #1538
  static efeito + #243, #2819
  static efeito + #244, #127
  static efeito + #245, #127
  static efeito + #246, #800
  static efeito + #247, #260
  static efeito + #248, #800
  static efeito + #249, #127
  static efeito + #250, #800
  static efeito + #251, #800
  static efeito + #252, #800
  static efeito + #253, #800
  static efeito + #254, #800
  static efeito + #255, #127
  static efeito + #256, #800
  static efeito + #257, #800
  static efeito + #258, #2819
  static efeito + #259, #800
  static efeito + #260, #2848
  static efeito + #261, #2819
  static efeito + #262, #800
  static efeito + #263, #800
  static efeito + #264, #800
  static efeito + #265, #800
  static efeito + #266, #800
  static efeito + #267, #800
  static efeito + #268, #800
  static efeito + #269, #800
  static efeito + #270, #800
  static efeito + #271, #127
  static efeito + #272, #127
  static efeito + #273, #260
  static efeito + #274, #260
  static efeito + #275, #260
  static efeito + #276, #260
  static efeito + #277, #1538
  static efeito + #278, #2050
  static efeito + #279, #1538

  ;Linha 7
  static efeito + #280, #1538
  static efeito + #281, #2050
  static efeito + #282, #1538
  static efeito + #283, #770
  static efeito + #284, #127
  static efeito + #285, #800
  static efeito + #286, #770
  static efeito + #287, #770
  static efeito + #288, #800
  static efeito + #289, #800
  static efeito + #290, #770
  static efeito + #291, #770
  static efeito + #292, #770
  static efeito + #293, #800
  static efeito + #294, #127
  static efeito + #295, #127
  static efeito + #296, #127
  static efeito + #297, #127
  static efeito + #298, #127
  static efeito + #299, #770
  static efeito + #300, #770
  static efeito + #301, #127
  static efeito + #302, #127
  static efeito + #303, #127
  static efeito + #304, #127
  static efeito + #305, #127
  static efeito + #306, #800
  static efeito + #307, #770
  static efeito + #308, #770
  static efeito + #309, #770
  static efeito + #310, #127
  static efeito + #311, #127
  static efeito + #312, #770
  static efeito + #313, #770
  static efeito + #314, #127
  static efeito + #315, #127
  static efeito + #316, #770
  static efeito + #317, #1538
  static efeito + #318, #2050
  static efeito + #319, #1538

  ;Linha 8
  static efeito + #320, #1538
  static efeito + #321, #2050
  static efeito + #322, #1538
  static efeito + #323, #127
  static efeito + #324, #127
  static efeito + #325, #800
  static efeito + #326, #770
  static efeito + #327, #770
  static efeito + #328, #800
  static efeito + #329, #800
  static efeito + #330, #770
  static efeito + #331, #2337
  static efeito + #332, #770
  static efeito + #333, #127
  static efeito + #334, #127
  static efeito + #335, #260
  static efeito + #336, #260
  static efeito + #337, #127
  static efeito + #338, #127
  static efeito + #339, #770
  static efeito + #340, #770
  static efeito + #341, #127
  static efeito + #342, #127
  static efeito + #343, #260
  static efeito + #344, #260
  static efeito + #345, #127
  static efeito + #346, #800
  static efeito + #347, #770
  static efeito + #348, #2367
  static efeito + #349, #770
  static efeito + #350, #127
  static efeito + #351, #127
  static efeito + #352, #770
  static efeito + #353, #770
  static efeito + #354, #127
  static efeito + #355, #127
  static efeito + #356, #127
  static efeito + #357, #1538
  static efeito + #358, #2050
  static efeito + #359, #1538

  ;Linha 9
  static efeito + #360, #1538
  static efeito + #361, #2050
  static efeito + #362, #1538
  static efeito + #363, #127
  static efeito + #364, #127
  static efeito + #365, #800
  static efeito + #366, #770
  static efeito + #367, #770
  static efeito + #368, #260
  static efeito + #369, #127
  static efeito + #370, #770
  static efeito + #371, #770
  static efeito + #372, #770
  static efeito + #373, #127
  static efeito + #374, #127
  static efeito + #375, #260
  static efeito + #376, #260
  static efeito + #377, #127
  static efeito + #378, #800
  static efeito + #379, #800
  static efeito + #380, #800
  static efeito + #381, #800
  static efeito + #382, #127
  static efeito + #383, #260
  static efeito + #384, #260
  static efeito + #385, #2080
  static efeito + #386, #2080
  static efeito + #387, #770
  static efeito + #388, #770
  static efeito + #389, #770
  static efeito + #390, #2080
  static efeito + #391, #260
  static efeito + #392, #770
  static efeito + #393, #770
  static efeito + #394, #127
  static efeito + #395, #127
  static efeito + #396, #127
  static efeito + #397, #1538
  static efeito + #398, #2050
  static efeito + #399, #1538

  ;Linha 10
  static efeito + #400, #1538
  static efeito + #401, #2050
  static efeito + #402, #1538
  static efeito + #403, #2080
  static efeito + #404, #127
  static efeito + #405, #800
  static efeito + #406, #770
  static efeito + #407, #770
  static efeito + #408, #127
  static efeito + #409, #260
  static efeito + #410, #127
  static efeito + #411, #127
  static efeito + #412, #127
  static efeito + #413, #770
  static efeito + #414, #2080
  static efeito + #415, #127
  static efeito + #416, #127
  static efeito + #417, #127
  static efeito + #418, #127
  static efeito + #419, #770
  static efeito + #420, #770
  static efeito + #421, #127
  static efeito + #422, #127
  static efeito + #423, #127
  static efeito + #424, #127
  static efeito + #425, #127
  static efeito + #426, #770
  static efeito + #427, #127
  static efeito + #428, #127
  static efeito + #429, #127
  static efeito + #430, #260
  static efeito + #431, #127
  static efeito + #432, #770
  static efeito + #433, #770
  static efeito + #434, #127
  static efeito + #435, #127
  static efeito + #436, #127
  static efeito + #437, #1538
  static efeito + #438, #2050
  static efeito + #439, #1538

  ;Linha 11
  static efeito + #440, #1538
  static efeito + #441, #2050
  static efeito + #442, #1538
  static efeito + #443, #2080
  static efeito + #444, #2080
  static efeito + #445, #800
  static efeito + #446, #770
  static efeito + #447, #770
  static efeito + #448, #127
  static efeito + #449, #127
  static efeito + #450, #2819
  static efeito + #451, #2080
  static efeito + #452, #2080
  static efeito + #453, #127
  static efeito + #454, #770
  static efeito + #455, #127
  static efeito + #456, #127
  static efeito + #457, #127
  static efeito + #458, #127
  static efeito + #459, #770
  static efeito + #460, #770
  static efeito + #461, #127
  static efeito + #462, #127
  static efeito + #463, #127
  static efeito + #464, #127
  static efeito + #465, #770
  static efeito + #466, #127
  static efeito + #467, #127
  static efeito + #468, #127
  static efeito + #469, #2819
  static efeito + #470, #127
  static efeito + #471, #127
  static efeito + #472, #770
  static efeito + #473, #770
  static efeito + #474, #127
  static efeito + #475, #127
  static efeito + #476, #127
  static efeito + #477, #1538
  static efeito + #478, #2050
  static efeito + #479, #1538

  ;Linha 12
  static efeito + #480, #1538
  static efeito + #481, #2050
  static efeito + #482, #1538
  static efeito + #483, #260
  static efeito + #484, #2080
  static efeito + #485, #260
  static efeito + #486, #770
  static efeito + #487, #770
  static efeito + #488, #127
  static efeito + #489, #127
  static efeito + #490, #2080
  static efeito + #491, #127
  static efeito + #492, #2080
  static efeito + #493, #2080
  static efeito + #494, #2080
  static efeito + #495, #127
  static efeito + #496, #127
  static efeito + #497, #2368
  static efeito + #498, #127
  static efeito + #499, #2819
  static efeito + #500, #2819
  static efeito + #501, #800
  static efeito + #502, #2368
  static efeito + #503, #800
  static efeito + #504, #127
  static efeito + #505, #127
  static efeito + #506, #127
  static efeito + #507, #127
  static efeito + #508, #127
  static efeito + #509, #127
  static efeito + #510, #127
  static efeito + #511, #127
  static efeito + #512, #770
  static efeito + #513, #770
  static efeito + #514, #127
  static efeito + #515, #2819
  static efeito + #516, #127
  static efeito + #517, #1538
  static efeito + #518, #2050
  static efeito + #519, #1538

  ;Linha 13
  static efeito + #520, #1538
  static efeito + #521, #2050
  static efeito + #522, #1538
  static efeito + #523, #2848
  static efeito + #524, #2819
  static efeito + #525, #800
  static efeito + #526, #770
  static efeito + #527, #770
  static efeito + #528, #800
  static efeito + #529, #127
  static efeito + #530, #770
  static efeito + #531, #770
  static efeito + #532, #2080
  static efeito + #533, #2080
  static efeito + #534, #2080
  static efeito + #535, #2820
  static efeito + #536, #2820
  static efeito + #537, #127
  static efeito + #538, #127
  static efeito + #539, #2819
  static efeito + #540, #2819
  static efeito + #541, #127
  static efeito + #542, #800
  static efeito + #543, #127
  static efeito + #544, #127
  static efeito + #545, #2820
  static efeito + #546, #2820
  static efeito + #547, #800
  static efeito + #548, #770
  static efeito + #549, #770
  static efeito + #550, #127
  static efeito + #551, #127
  static efeito + #552, #770
  static efeito + #553, #770
  static efeito + #554, #127
  static efeito + #555, #770
  static efeito + #556, #127
  static efeito + #557, #1538
  static efeito + #558, #2050
  static efeito + #559, #1538

  ;Linha 14
  static efeito + #560, #1538
  static efeito + #561, #2050
  static efeito + #562, #1538
  static efeito + #563, #2080
  static efeito + #564, #770
  static efeito + #565, #800
  static efeito + #566, #770
  static efeito + #567, #770
  static efeito + #568, #127
  static efeito + #569, #127
  static efeito + #570, #127
  static efeito + #571, #2080
  static efeito + #572, #2080
  static efeito + #573, #2080
  static efeito + #574, #2080
  static efeito + #575, #800
  static efeito + #576, #800
  static efeito + #577, #800
  static efeito + #578, #800
  static efeito + #579, #770
  static efeito + #580, #770
  static efeito + #581, #800
  static efeito + #582, #800
  static efeito + #583, #127
  static efeito + #584, #127
  static efeito + #585, #800
  static efeito + #586, #800
  static efeito + #587, #800
  static efeito + #588, #127
  static efeito + #589, #127
  static efeito + #590, #127
  static efeito + #591, #127
  static efeito + #592, #770
  static efeito + #593, #770
  static efeito + #594, #800
  static efeito + #595, #770
  static efeito + #596, #127
  static efeito + #597, #1538
  static efeito + #598, #2050
  static efeito + #599, #1538

  ;Linha 15
  static efeito + #600, #1538
  static efeito + #601, #2050
  static efeito + #602, #1538
  static efeito + #603, #260
  static efeito + #604, #770
  static efeito + #605, #260
  static efeito + #606, #770
  static efeito + #607, #770
  static efeito + #608, #127
  static efeito + #609, #127
  static efeito + #610, #770
  static efeito + #611, #770
  static efeito + #612, #800
  static efeito + #613, #770
  static efeito + #614, #770
  static efeito + #615, #800
  static efeito + #616, #800
  static efeito + #617, #770
  static efeito + #618, #770
  static efeito + #619, #770
  static efeito + #620, #770
  static efeito + #621, #770
  static efeito + #622, #770
  static efeito + #623, #800
  static efeito + #624, #800
  static efeito + #625, #770
  static efeito + #626, #770
  static efeito + #627, #800
  static efeito + #628, #770
  static efeito + #629, #770
  static efeito + #630, #800
  static efeito + #631, #127
  static efeito + #632, #770
  static efeito + #633, #770
  static efeito + #634, #127
  static efeito + #635, #127
  static efeito + #636, #127
  static efeito + #637, #1538
  static efeito + #638, #2050
  static efeito + #639, #1538

  ;Linha 16
  static efeito + #640, #1538
  static efeito + #641, #2050
  static efeito + #642, #1538
  static efeito + #643, #2080
  static efeito + #644, #2080
  static efeito + #645, #800
  static efeito + #646, #770
  static efeito + #647, #770
  static efeito + #648, #800
  static efeito + #649, #127
  static efeito + #650, #770
  static efeito + #651, #770
  static efeito + #652, #800
  static efeito + #653, #770
  static efeito + #654, #770
  static efeito + #655, #800
  static efeito + #656, #800
  static efeito + #657, #770
  static efeito + #658, #770
  static efeito + #659, #770
  static efeito + #660, #770
  static efeito + #661, #770
  static efeito + #662, #770
  static efeito + #663, #800
  static efeito + #664, #800
  static efeito + #665, #770
  static efeito + #666, #770
  static efeito + #667, #800
  static efeito + #668, #770
  static efeito + #669, #770
  static efeito + #670, #800
  static efeito + #671, #127
  static efeito + #672, #770
  static efeito + #673, #770
  static efeito + #674, #127
  static efeito + #675, #127
  static efeito + #676, #127
  static efeito + #677, #1538
  static efeito + #678, #2050
  static efeito + #679, #1538

  ;Linha 17
  static efeito + #680, #1538
  static efeito + #681, #2050
  static efeito + #682, #1538
  static efeito + #683, #2080
  static efeito + #684, #2080
  static efeito + #685, #800
  static efeito + #686, #770
  static efeito + #687, #770
  static efeito + #688, #800
  static efeito + #689, #127
  static efeito + #690, #127
  static efeito + #691, #127
  static efeito + #692, #800
  static efeito + #693, #127
  static efeito + #694, #2080
  static efeito + #695, #770
  static efeito + #696, #127
  static efeito + #697, #127
  static efeito + #698, #127
  static efeito + #699, #260
  static efeito + #700, #260
  static efeito + #701, #127
  static efeito + #702, #127
  static efeito + #703, #800
  static efeito + #704, #770
  static efeito + #705, #127
  static efeito + #706, #800
  static efeito + #707, #800
  static efeito + #708, #127
  static efeito + #709, #127
  static efeito + #710, #127
  static efeito + #711, #127
  static efeito + #712, #770
  static efeito + #713, #770
  static efeito + #714, #127
  static efeito + #715, #127
  static efeito + #716, #127
  static efeito + #717, #1538
  static efeito + #718, #2050
  static efeito + #719, #1538

  ;Linha 18
  static efeito + #720, #1538
  static efeito + #721, #2050
  static efeito + #722, #1538
  static efeito + #723, #127
  static efeito + #724, #127
  static efeito + #725, #800
  static efeito + #726, #770
  static efeito + #727, #770
  static efeito + #728, #127
  static efeito + #729, #127
  static efeito + #730, #770
  static efeito + #731, #770
  static efeito + #732, #800
  static efeito + #733, #2080
  static efeito + #734, #127
  static efeito + #735, #127
  static efeito + #736, #127
  static efeito + #737, #127
  static efeito + #738, #127
  static efeito + #739, #2819
  static efeito + #740, #2819
  static efeito + #741, #127
  static efeito + #742, #127
  static efeito + #743, #800
  static efeito + #744, #127
  static efeito + #745, #127
  static efeito + #746, #127
  static efeito + #747, #800
  static efeito + #748, #770
  static efeito + #749, #770
  static efeito + #750, #800
  static efeito + #751, #2080
  static efeito + #752, #770
  static efeito + #753, #770
  static efeito + #754, #127
  static efeito + #755, #127
  static efeito + #756, #127
  static efeito + #757, #1538
  static efeito + #758, #2050
  static efeito + #759, #1538

  ;Linha 19
  static efeito + #760, #1538
  static efeito + #761, #2050
  static efeito + #762, #1538
  static efeito + #763, #127
  static efeito + #764, #127
  static efeito + #765, #800
  static efeito + #766, #770
  static efeito + #767, #770
  static efeito + #768, #127
  static efeito + #769, #127
  static efeito + #770, #127
  static efeito + #771, #127
  static efeito + #772, #2080
  static efeito + #773, #127
  static efeito + #774, #127
  static efeito + #775, #770
  static efeito + #776, #770
  static efeito + #777, #770
  static efeito + #778, #770
  static efeito + #779, #770
  static efeito + #780, #770
  static efeito + #781, #770
  static efeito + #782, #770
  static efeito + #783, #770
  static efeito + #784, #770
  static efeito + #785, #127
  static efeito + #786, #127
  static efeito + #787, #127
  static efeito + #788, #2080
  static efeito + #789, #2080
  static efeito + #790, #2080
  static efeito + #791, #2080
  static efeito + #792, #770
  static efeito + #793, #770
  static efeito + #794, #127
  static efeito + #795, #127
  static efeito + #796, #127
  static efeito + #797, #1538
  static efeito + #798, #2050
  static efeito + #799, #1538

  ;Linha 20
  static efeito + #800, #1538
  static efeito + #801, #2050
  static efeito + #802, #1538
  static efeito + #803, #127
  static efeito + #804, #127
  static efeito + #805, #800
  static efeito + #806, #770
  static efeito + #807, #770
  static efeito + #808, #127
  static efeito + #809, #800
  static efeito + #810, #770
  static efeito + #811, #770
  static efeito + #812, #770
  static efeito + #813, #800
  static efeito + #814, #127
  static efeito + #815, #127
  static efeito + #816, #770
  static efeito + #817, #127
  static efeito + #818, #2080
  static efeito + #819, #770
  static efeito + #820, #770
  static efeito + #821, #2080
  static efeito + #822, #2080
  static efeito + #823, #770
  static efeito + #824, #2080
  static efeito + #825, #2080
  static efeito + #826, #127
  static efeito + #827, #770
  static efeito + #828, #770
  static efeito + #829, #770
  static efeito + #830, #2080
  static efeito + #831, #2080
  static efeito + #832, #770
  static efeito + #833, #770
  static efeito + #834, #127
  static efeito + #835, #127
  static efeito + #836, #127
  static efeito + #837, #1538
  static efeito + #838, #2050
  static efeito + #839, #1538

  ;Linha 21
  static efeito + #840, #1538
  static efeito + #841, #2050
  static efeito + #842, #1538
  static efeito + #843, #2819
  static efeito + #844, #127
  static efeito + #845, #800
  static efeito + #846, #770
  static efeito + #847, #770
  static efeito + #848, #2080
  static efeito + #849, #2080
  static efeito + #850, #770
  static efeito + #851, #2340
  static efeito + #852, #770
  static efeito + #853, #2080
  static efeito + #854, #127
  static efeito + #855, #127
  static efeito + #856, #770
  static efeito + #857, #2080
  static efeito + #858, #2080
  static efeito + #859, #770
  static efeito + #860, #770
  static efeito + #861, #2080
  static efeito + #862, #2080
  static efeito + #863, #770
  static efeito + #864, #2080
  static efeito + #865, #127
  static efeito + #866, #127
  static efeito + #867, #770
  static efeito + #868, #2339
  static efeito + #869, #770
  static efeito + #870, #2080
  static efeito + #871, #2080
  static efeito + #872, #770
  static efeito + #873, #770
  static efeito + #874, #127
  static efeito + #875, #127
  static efeito + #876, #2819
  static efeito + #877, #1538
  static efeito + #878, #2050
  static efeito + #879, #1538

  ;Linha 22
  static efeito + #880, #1538
  static efeito + #881, #2050
  static efeito + #882, #1538
  static efeito + #883, #770
  static efeito + #884, #127
  static efeito + #885, #800
  static efeito + #886, #770
  static efeito + #887, #770
  static efeito + #888, #2080
  static efeito + #889, #2080
  static efeito + #890, #770
  static efeito + #891, #770
  static efeito + #892, #770
  static efeito + #893, #2819
  static efeito + #894, #127
  static efeito + #895, #127
  static efeito + #896, #127
  static efeito + #897, #127
  static efeito + #898, #2080
  static efeito + #899, #2819
  static efeito + #900, #2819
  static efeito + #901, #2080
  static efeito + #902, #2080
  static efeito + #903, #2080
  static efeito + #904, #127
  static efeito + #905, #2080
  static efeito + #906, #2819
  static efeito + #907, #770
  static efeito + #908, #770
  static efeito + #909, #770
  static efeito + #910, #2080
  static efeito + #911, #2080
  static efeito + #912, #770
  static efeito + #913, #770
  static efeito + #914, #127
  static efeito + #915, #127
  static efeito + #916, #770
  static efeito + #917, #1538
  static efeito + #918, #2050
  static efeito + #919, #1538

  ;Linha 23
  static efeito + #920, #1538
  static efeito + #921, #2050
  static efeito + #922, #1538
  static efeito + #923, #288
  static efeito + #924, #260
  static efeito + #925, #260
  static efeito + #926, #127
  static efeito + #927, #127
  static efeito + #928, #2080
  static efeito + #929, #2080
  static efeito + #930, #800
  static efeito + #931, #800
  static efeito + #932, #800
  static efeito + #933, #800
  static efeito + #934, #127
  static efeito + #935, #127
  static efeito + #936, #127
  static efeito + #937, #127
  static efeito + #938, #2080
  static efeito + #939, #127
  static efeito + #940, #2080
  static efeito + #941, #127
  static efeito + #942, #127
  static efeito + #943, #127
  static efeito + #944, #127
  static efeito + #945, #127
  static efeito + #946, #127
  static efeito + #947, #127
  static efeito + #948, #127
  static efeito + #949, #127
  static efeito + #950, #127
  static efeito + #951, #260
  static efeito + #952, #127
  static efeito + #953, #127
  static efeito + #954, #127
  static efeito + #955, #127
  static efeito + #956, #127
  static efeito + #957, #1538
  static efeito + #958, #2050
  static efeito + #959, #1538

  ;Linha 24
  static efeito + #960, #1538
  static efeito + #961, #2050
  static efeito + #962, #1538
  static efeito + #963, #2848
  static efeito + #964, #260
  static efeito + #965, #260
  static efeito + #966, #770
  static efeito + #967, #770
  static efeito + #968, #770
  static efeito + #969, #770
  static efeito + #970, #770
  static efeito + #971, #770
  static efeito + #972, #770
  static efeito + #973, #770
  static efeito + #974, #770
  static efeito + #975, #770
  static efeito + #976, #770
  static efeito + #977, #770
  static efeito + #978, #770
  static efeito + #979, #770
  static efeito + #980, #770
  static efeito + #981, #770
  static efeito + #982, #770
  static efeito + #983, #770
  static efeito + #984, #770
  static efeito + #985, #770
  static efeito + #986, #770
  static efeito + #987, #770
  static efeito + #988, #770
  static efeito + #989, #770
  static efeito + #990, #770
  static efeito + #991, #770
  static efeito + #992, #770
  static efeito + #993, #800
  static efeito + #994, #260
  static efeito + #995, #127
  static efeito + #996, #127
  static efeito + #997, #1538
  static efeito + #998, #2050
  static efeito + #999, #1538

  ;Linha 25
  static efeito + #1000, #1538
  static efeito + #1001, #2050
  static efeito + #1002, #1538
  static efeito + #1003, #127
  static efeito + #1004, #800
  static efeito + #1005, #260
  static efeito + #1006, #127
  static efeito + #1007, #127
  static efeito + #1008, #2819
  static efeito + #1009, #127
  static efeito + #1010, #127
  static efeito + #1011, #2848
  static efeito + #1012, #2848
  static efeito + #1013, #127
  static efeito + #1014, #127
  static efeito + #1015, #127
  static efeito + #1016, #127
  static efeito + #1017, #127
  static efeito + #1018, #127
  static efeito + #1019, #260
  static efeito + #1020, #260
  static efeito + #1021, #127
  static efeito + #1022, #127
  static efeito + #1023, #127
  static efeito + #1024, #127
  static efeito + #1025, #127
  static efeito + #1026, #127
  static efeito + #1027, #2819
  static efeito + #1028, #2848
  static efeito + #1029, #127
  static efeito + #1030, #127
  static efeito + #1031, #127
  static efeito + #1032, #127
  static efeito + #1033, #127
  static efeito + #1034, #127
  static efeito + #1035, #260
  static efeito + #1036, #2819
  static efeito + #1037, #1538
  static efeito + #1038, #2050
  static efeito + #1039, #1538

  ;Linha 26
  static efeito + #1040, #1538
  static efeito + #1041, #2050
  static efeito + #1042, #1538
  static efeito + #1043, #32
  static efeito + #1044, #127
  static efeito + #1045, #770
  static efeito + #1046, #127
  static efeito + #1047, #127
  static efeito + #1048, #127
  static efeito + #1049, #127
  static efeito + #1050, #127
  static efeito + #1051, #2848
  static efeito + #1052, #2819
  static efeito + #1053, #127
  static efeito + #1054, #127
  static efeito + #1055, #127
  static efeito + #1056, #127
  static efeito + #1057, #127
  static efeito + #1058, #127
  static efeito + #1059, #770
  static efeito + #1060, #770
  static efeito + #1061, #127
  static efeito + #1062, #127
  static efeito + #1063, #127
  static efeito + #1064, #127
  static efeito + #1065, #127
  static efeito + #1066, #127
  static efeito + #1067, #2848
  static efeito + #1068, #2848
  static efeito + #1069, #127
  static efeito + #1070, #127
  static efeito + #1071, #2819
  static efeito + #1072, #127
  static efeito + #1073, #770
  static efeito + #1074, #127
  static efeito + #1075, #127
  static efeito + #1076, #770
  static efeito + #1077, #1538
  static efeito + #1078, #2050
  static efeito + #1079, #1538

  ;Linha 27
  static efeito + #1080, #1538
  static efeito + #1081, #2050
  static efeito + #1082, #2351
  static efeito + #1083, #1538
  static efeito + #1084, #1538
  static efeito + #1085, #1538
  static efeito + #1086, #1538
  static efeito + #1087, #1538
  static efeito + #1088, #1538
  static efeito + #1089, #1538
  static efeito + #1090, #1538
  static efeito + #1091, #1538
  static efeito + #1092, #1538
  static efeito + #1093, #1538
  static efeito + #1094, #1538
  static efeito + #1095, #1538
  static efeito + #1096, #1538
  static efeito + #1097, #1538
  static efeito + #1098, #1538
  static efeito + #1099, #1538
  static efeito + #1100, #1538
  static efeito + #1101, #1538
  static efeito + #1102, #1538
  static efeito + #1103, #1538
  static efeito + #1104, #1538
  static efeito + #1105, #1538
  static efeito + #1106, #1538
  static efeito + #1107, #1538
  static efeito + #1108, #1538
  static efeito + #1109, #1538
  static efeito + #1110, #1538
  static efeito + #1111, #1538
  static efeito + #1112, #1538
  static efeito + #1113, #1538
  static efeito + #1114, #1538
  static efeito + #1115, #1538
  static efeito + #1116, #1538
  static efeito + #1117, #2396
  static efeito + #1118, #2050
  static efeito + #1119, #1538

  ;Linha 28
  static efeito + #1120, #1538
  static efeito + #1121, #2351
  static efeito + #1122, #2050
  static efeito + #1123, #2050
  static efeito + #1124, #2050
  static efeito + #1125, #2050
  static efeito + #1126, #2050
  static efeito + #1127, #2050
  static efeito + #1128, #2050
  static efeito + #1129, #2050
  static efeito + #1130, #2050
  static efeito + #1131, #2050
  static efeito + #1132, #2050
  static efeito + #1133, #2050
  static efeito + #1134, #2050
  static efeito + #1135, #2050
  static efeito + #1136, #2050
  static efeito + #1137, #2050
  static efeito + #1138, #2050
  static efeito + #1139, #2050
  static efeito + #1140, #2050
  static efeito + #1141, #2050
  static efeito + #1142, #2050
  static efeito + #1143, #2050
  static efeito + #1144, #2050
  static efeito + #1145, #2050
  static efeito + #1146, #2050
  static efeito + #1147, #2050
  static efeito + #1148, #2050
  static efeito + #1149, #2050
  static efeito + #1150, #2050
  static efeito + #1151, #2050
  static efeito + #1152, #2050
  static efeito + #1153, #2050
  static efeito + #1154, #2050
  static efeito + #1155, #2050
  static efeito + #1156, #2050
  static efeito + #1157, #2050
  static efeito + #1158, #2396
  static efeito + #1159, #1538

  ;Linha 29
  static efeito + #1160, #2351
  static efeito + #1161, #1538
  static efeito + #1162, #1538
  static efeito + #1163, #1538
  static efeito + #1164, #1538
  static efeito + #1165, #1538
  static efeito + #1166, #1538
  static efeito + #1167, #1538
  static efeito + #1168, #1538
  static efeito + #1169, #1538
  static efeito + #1170, #1538
  static efeito + #1171, #1538
  static efeito + #1172, #1538
  static efeito + #1173, #1538
  static efeito + #1174, #1538
  static efeito + #1175, #1538
  static efeito + #1176, #1538
  static efeito + #1177, #1538
  static efeito + #1178, #1538
  static efeito + #1179, #1538
  static efeito + #1180, #1538
  static efeito + #1181, #1538
  static efeito + #1182, #1538
  static efeito + #1183, #1538
  static efeito + #1184, #1538
  static efeito + #1185, #1538
  static efeito + #1186, #1538
  static efeito + #1187, #1538
  static efeito + #1188, #1538
  static efeito + #1189, #1538
  static efeito + #1190, #1538
  static efeito + #1191, #1538
  static efeito + #1192, #1538
  static efeito + #1193, #1538
  static efeito + #1194, #1538
  static efeito + #1195, #1538
  static efeito + #1196, #1538
  static efeito + #1197, #1538
  static efeito + #1198, #1538
  static efeito + #1199, #2396
  

;********************************************************
;                       PRINT SCREEN - Fase
;********************************************************
printefeitoScreen:
  push R0
  push R1
  push R2
  push R3

  loadn R0, #efeito
  loadn R1, #0
  loadn R2, #1200

  printefeitoScreenLoop:

    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2

    jne printefeitoScreenLoop

  pop R3
  pop R2
  pop R1
  pop R0
  rts

;------------------------
