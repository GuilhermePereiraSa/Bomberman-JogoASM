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



; completo
tela0Linha0  : string "ÇLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLÇ"
tela0Linha1  : string "LÇHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHÇL"
tela0Linha2  : string "LHÇLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLÇHL"
tela0Linha3  : string "LHL C              OOO           C   LHL"
tela0Linha4  : string "LHL  C              C            C   LHL"
tela0Linha5  : string "LHL   OOOOOOOOOOOOOOOOOOOOOOOOOOOOCCCLHL"
tela0Linha6  : string "LHLCCCC            UU            C   LHL"
tela0Linha7  : string "LHL   OOO   O      UU      O   OOO   LHL"
tela0Linha8  : string "LHL   OOO                      OOO   LHL"
tela0Linha9  : string "LHL   OOO   O        ÇÇÇ   O   OOO   LHL"
tela0Linha10 : string "LHL   OOO           Ç   Ç      OOO   LHL"
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
tela0Linha27 : string "LHÇLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLÇHL"
tela0Linha28 : string "LÇHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHÇL"
tela0Linha29 : string "ÇLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLÇ"     


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
tela3Linha0  : string "Ç                                      Ç"
tela3Linha1  : string " Ç                                    Ç "
tela3Linha2  : string "  Ç                                  Ç  "
tela3Linha3  : string "                                        "
tela3Linha4  : string "                                        "
tela3Linha5  : string "                                        "
tela3Linha6  : string "                                        "
tela3Linha7  : string "                                        "
tela3Linha8  : string "                                        "
tela3Linha9  : string "                     ÇÇÇ                "
tela3Linha10 : string "                    Ç   Ç               "
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
tela3Linha27 : string "  Ç                                  Ç  "
tela3Linha28 : string " Ç                                    Ç "
tela3Linha29 : string "Ç                                      Ç"


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