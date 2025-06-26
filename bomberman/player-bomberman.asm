; Tela 
; carrega tela de menu

IncRand: var #1			; Incremento para circular na Tabela de nr. Randomicos
Rand : var #30			; Tabela de nr. Randomicos entre 7 - 10
    static Rand + #0, #9
    static Rand + #1, #7
    static Rand + #2, #10
    static Rand + #3, #8
    static Rand + #4, #7
    static Rand + #5, #10
    static Rand + #6, #8
    static Rand + #7, #9
    static Rand + #8, #7
    static Rand + #9, #10
    static Rand + #10, #8
    static Rand + #11, #7
    static Rand + #12, #9
    static Rand + #13, #10
    static Rand + #14, #8
    static Rand + #15, #7
    static Rand + #16, #10
    static Rand + #17, #9
    static Rand + #18, #8
    static Rand + #19, #7
    static Rand + #20, #10
    static Rand + #21, #8
    static Rand + #22, #9
    static Rand + #23, #7
    static Rand + #24, #10
    static Rand + #25, #8
    static Rand + #26, #7
    static Rand + #27, #9
    static Rand + #28, #10
    static Rand + #29, #8

jmp MostrarMenu

Msg1: string "DESEJA JOGAR NOVAMENTE? (s/n)" ; Mensagem para jogar novamente
OpSaidaFinal: var #1		; Contem a letra que foi digitada - 1 byte apenas
MsgFim: string "OBRIGADO POR JOGAR!"


MsgTitulo: string "==== BOMBERMAN ===="
MsgOpcao1: string "1 - JOGAR"
MsgOpcao2: string "2 - SAIR"
OpInicio: var #1 ; guarda a escolha do jogador

; Variaveis de posicao
posAzul: var #1         ; Contem a posicao atual do Azul - inicial = 1043
posAntAzul: var #1      ; Contem a posicao anterior do Azul

posRosa: var #1         ; Contem a posicao atual da Rosa - inicial = 156
posAntRosa: var #1      ; Contem a posicao anterior da Rosa

; Variaveis de poderes dos jogadores -- bitmask dos diversos poderes
efeitosAzul: var #1
efeitosRosa: var #1

; Variaveis de colocar bombas
usadoBombaAzul: var #1  ; Quantidade de bombas usado pelo jogador Azul; EM MUDANCA
maxBombaAzul: var #1    ; Quantidade maxima de bombas do jogador Azul

usadoBombaRosa: var #1  ; Quantidade de bombas usado pelo jogador Rosa
maxBombaRosa: var #1    ; Quantidade maxima de bombas do jogador Rosa

; Variaveis das propriedades das bombas
timeBombaAzul: var #1   ; Tempo para a bomba do jogador Azul explodir (mudar de valor com poderes)
rangeBombaAzul: var #1  ; Alcance das bombas do jogador Azul

timeBombaRosa: var #1   ; Tempo para a bomba do jogador Rosa explodir (mudar de valor com poderes)
rangeBombaRosa: var #1  ; Alcance das bombas do jogador Rosa


limBombas: var #1       ; Maximo de bombas que um jogador pode ter (= 5)
static limBombas, #5

; Array com as bombas em jogo de cada jogador
; Cada item do array eh composto da seguinte forma:
; | contador (1 byte) | posicao (1 byte) | raio de explosao (1 byte) | efeitos (1 byte)
; Cada item tem 4 bytes, entao o tamanho do array eh: 4 * maxBombas
bombasAzul: var #20
bombasRosa: var #20


teclaLidaLoop: var #1   ; Input do teclado no loop

Letra: var #1		; Contem a letra que foi digitada -- com delay


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
    
    MostrarMenu_Escolha:        ; Procedimento que espera por uma entrada valida do usuario
        call DigLetra

        ; provavel ter que fazer o numero virar char!!!
        load r1, Letra
        store OpInicio, r1

        ; Verifica opcoes
        loadn r3, #'1'
        loadn r4, #'2'

        cmp r1, r3
        jeq main

        cmp r1, r4
        jeq Sair

        jmp MostrarMenu_Escolha         ; Se for opcao invalida, nao fazer nada

;------------------------
	
;********************************************************
;                        MAIN
; Procedimento principal do jogo
;********************************************************
main:
    ; INICIALIZACAO DAS VARIAVEIS
    loadn r0, #1043
    store posAzul, r0       ; Zera Posicao do AZUL
    store posAntAzul, r0    ; Zera Posicao Anterior do AZUL

    loadn r0, #156
    store posRosa, r0      ; Zera Posicao Atual da ROSA
    store posAntRosa, r0   ; Zera Posicao Anterior da ROSA

    loadn r0, #3
    store maxBombaAzul, r0
    store maxBombaRosa, r0

    loadn r0, #0
    store usadoBombaAzul, r0
    store usadoBombaRosa, r0

    loadn r0, #500               ; Nao sei se esse valor ta legal
    store timeBombaAzul, r0
    store timeBombaRosa, r0

    loadn r0, #3
    store rangeBombaAzul, r0
    store rangeBombaRosa, r0

    call ImprimirCenario

    ; Desenha os jogadores na tela
    call AtualizaAzul_Desenha
    call AtualizaRosa_Desenha   

    loadn r0,#0                 ; Contador de frames (motivo: preciso de objetos que atualizem mais rapido que outros,
                                ; como um contador da bomba, sla)
    loadn r2,#0                 ; Variavel auxiliar para verificar se num_frames == 0 mod n (n: tamanho de frames de um ciclo)

;********************************************************
;                   LOOP PRINCIPAL
;********************************************************
    Loop:
        inchar r1
        store teclaLidaLoop, r1

        call AnimExplosao               ; chamada para cuidar das animacoes das bombas; remove as explosoes quando terminarem

        
        call AtualizaAzul               ; atualiza o jogador azul (movimento e bomba)
        call AtualizaRosa               ; atualiza o jogador rosa (movimento e bomba)

        call TickBombas                 ; logica para fazer o delay das bombas

        ; call CheckExplosao --> Verifica se algum player morre pela bomba; (verificar isso por ciclos menores)


        call Delay
        inc r0      ; frame counter
        jmp Loop

;------------------- FIM DO MAIN ------------------------


; PROCEDIMENTOS

;********************************************************
;                   ImprimeCenario
; Procedimento que imprime um novo cenario na tela e 
; salva os resultados em tela0.
; 
; 0 branco							0000 0000
; 256 marrom						0001 0000
; 512 verde							0010 0000
; 768 oliva							0011 0000
; 1024 azul marinho					0100 0000
; 1280 roxo							0101 0000
; 1536 teal							0110 0000
; 1792 prata						0111 0000
; 2048 cinza						1000 0000
; 2304 vermelho						1001 0000
; 2560 lima							1010 0000
; 2816 amarelo						1011 0000
; 3072 azul							1100 0000
; 3328 rosa							1101 0000
; 3584 aqua							1110 0000
; 3840 branco						1111 0000
; 
; carregar cenarios com as especificas cores;
;********************************************************
ImprimirCenario:
    push r1
    push r2

    call ApagaTela ; Limpa a tela antes de comecar a desenhar o cenario

	loadn r1, #tela1Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #2048  			; cor cinza!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira
    
	loadn r1, #tela2Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #3584  			; cor aqua!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira

	loadn r1, #tela3Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #2304  			; cor vermelha!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira

	loadn r1, #tela4Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #512  			; cor verde!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira

	loadn r1, #tela5Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #0      			; cor branca!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira

	loadn r1, #tela6Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #1280  			; cor roxa!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira

	loadn r1, #tela7Linha0	    ; Endereco onde comeca a primeira linha do cenario!!
	loadn r2, #2816  			; cor amarela!
	call ImprimeTela2   		; Rotina de Impresao de Cenario na Tela Inteira

    pop r2
    pop r1
    rts

;----------------------------------


;********************************************************
;                   AnimExplosao
; Procedimento que anima as explosoes no mapa.
;********************************************************
AnimExplosao:
	push r0
	push r1
    push r2
    push r3
    push r4
    push r5
    push r6
	
    loadn r0, #tela8Linha0
    loadn r1, #0                        ; Iterador do loop
    loadn r2, #1200                     ; Limite do loop
    loadn r3, #2310                     ; Ultimo frame da explosao aplicando a cor vermelha: 2304 + 6
    loadn r4, #2306                     ; Primeiro frame da explosao aplicando a cor vermelha: 2304 + 2

    AnimExplosao_Loop:
        loadi r5, r0
        cmp r5, r4
        jle AnimExplosao_Loop_Skip

        cmp r3, r5
        jeq AnimExplosao_Loop_Remove    ; Caso a animacao estiver no ultimo frame, remover a explosao
        
        inc r5
        storei r0, r5                   ; Avanca o frame de animacao
        outchar r5, r1
        jmp AnimExplosao_Loop_Skip

        AnimExplosao_Loop_Remove:
            loadn r5, #' '
            storei r0, r5               ; Remover a explosao
            outchar r5, r1

        AnimExplosao_Loop_Skip:
            inc r1
            loadn r5, #40
            loadn r6, #0
            mod r5, r1, r5

            cmp r5, r6
            jne AnimExplosao_Loop_Skip_NonZero

            inc r0

            AnimExplosao_Loop_Skip_NonZero:
                inc r0
                cmp r1, r2
                jle AnimExplosao_Loop

    pop r6
    pop r5
    pop r4
    pop r3
	pop r2
    pop r1
	pop r0
	rts	

;----------------------------------

;********************************************************
;                   AtualizaAzul
; Procedimento que cuida das interacoes do jogador
; azul, como a movimentacao e a colocacao das bombas.
;********************************************************
AtualizaAzul:
    push r0
    push r1

    call AtualizaAzul_Input         ; Trata do input do jogador -- movimentacao e colocar bombas
    
    load r0, posAntAzul
    load r1, posAzul

    cmp r0, r1
    jeq AtualizaAzul_SkipDraw       ; Se a posicao nao mudar, nao redesenhar o jogador
    
    ; Caso contrario, redesenhar o jogador
    call AtualizaAzul_Apaga
    call AtualizaAzul_Desenha

    AtualizaAzul_SkipDraw:
        pop r1
        pop r0
        rts


;********************************************************
;                   AtualizaAzul_Input
; Sub-procedimento que le e age de acordo com o input 
; do jogador
;********************************************************
AtualizaAzul_Input:
    push r0
    push r1
    push r2
    push r3

    load r0, posAzul            ; r0 = posicao atual do jogador Azul (NÃO MUDAR NO PROCEDIMENTO)
    load r1, teclaLidaLoop      ; r1 = Input do teclado no frame

    loadn r2, #'a'
    cmp r1,r2
    jeq AtualizaAzul_Input_A        ; Tecla a (mover para esquerda)

    loadn r2, #'d'
    cmp r1,r2
    jeq AtualizaAzul_Input_D        ; Tecla d (mover para direita)

    loadn r2, #'w'
    cmp r1,r2
    jeq AtualizaAzul_Input_W        ; Tecla w (mover para cima)

    loadn r2, #'s'
    cmp r1,r2
    jeq AtualizaAzul_Input_S        ; Tecla s (mover para baixo)

    loadn r2, #'f'
    cmp r1,r2
    jeq AtualizaAzul_Input_F        ; Tecla f (colocar bomba na posicao)

    AtualizaAzul_Input_Skip:
        pop r3
        pop r2
        pop r1
        pop r0

        rts


    AtualizaAzul_Input_A:
        loadn r1, #40
        loadn r2, #0

        mod r1, r0, r1                  ; Testa condicoes de Contorno 
        cmp r1, r2
        jeq AtualizaAzul_Input_Skip

        dec r0	; pos = pos -1
        jmp AtualizaAzul_Input_Colisao

    AtualizaAzul_Input_D:
        loadn r1, #40
        loadn r2, #39

        mod r1, r0, r1		; Testa condicoes de Contorno 
        cmp r1, r2
        jeq AtualizaAzul_Input_Skip

        inc r0	; pos = pos + 1
        jmp AtualizaAzul_Input_Colisao

    AtualizaAzul_Input_W:
        loadn r1, #40
        cmp r0, r1
        jle AtualizaAzul_Input_Skip     ; Verifica se Azul nao pode mover para cima (posAzul < 40 -->
                                        ; Azul esta na primeira linha)

        sub r0, r0, r1                  ; pos = pos - 40

        jmp AtualizaAzul_Input_Colisao

    AtualizaAzul_Input_S:
        loadn r1, #1159
        cmp r0, r1
        jgr AtualizaAzul_Input_Skip     ; Verifica se Azul nao pode mover para cima (posAzul < 40 -->
                                        ; Azul esta na primeira linha)

        loadn r1, #40
        add r0, r0, r1                  ; pos = pos + 40

        jmp AtualizaAzul_Input_Colisao

    AtualizaAzul_Input_F:
        load r1, usadoBombaAzul
        load r2, maxBombaAzul

        cmp r1, r2                      ; Cancela jogar bomba se todas as bombas estiverem no jogo
        jeg AtualizaAzul_Input_Skip
        
        push r1
        ; r0 = posicao; (saida) r1 = resultado
        call DetectaColisao             ; Verifica se existe um bloco colidindo na posicao do jogador Azul -- caso o jogador estiver em cima de uma bomba
        mov r2, r1                      ; r2 = resultado da colisao
        pop r1
        
        loadn r3, #0
        cmp r2, r3
        jne AtualizaAzul_Input_Skip     ; Cancela jogar bomba se tiver colisao na posicao

        ; r1 = usadoBombaAzul * 4 --> Indice para colocar os dados da bomba inserida
        ; obs. Preciso do '* 4' uma vez que cada item da lista tem 4 bytes
        loadn r2, #4
        mul r1, r1, r2                  ; r1 = usadoBombaAzul * 4

        loadn r2, #bombasAzul           ; r2 = addr(bombasAzul)
        add r2, r2, r1                  ; r2 = addr(bombasAzul[r1])

        load r1, timeBombaAzul
        storei r2, r1                   ; bombasAzul[r2 + 0] = timeBombaAzul
       
        inc r2
        storei r2, r0                   ; bombasAzul[r2 + 1] = posAzul

        inc r2
        load r1, rangeBombaAzul         ; r1 = rangeBombaAzul
        storei r2, r1                   ; bombasAzul[r2 + 2] = rangeBombaAzul

        ; inc r2
        ; colocar em r2 os efeitos especiais da bomba

        ; Colocar bomba no mapa de fato; r0 = posicao da bomba
        call ColocaBombaMapa

        load r1, usadoBombaAzul
        inc r1
        store usadoBombaAzul, r1         ; Incrementa a variavel de quantidade de bombas no mapa do jogador Azul

        jmp AtualizaAzul_Input_Skip


    AtualizaAzul_Input_Colisao:
        call DetectaColisao             ; testa se nao ha nenhuma colisao na posicao a ser usada
                                        ; Retorna resultado em r1

        loadn r2,#0
        cmp r1, r2
        jne AtualizaAzul_Input_Skip     ; Se existir colisao, nao atualizar a posicao
        
        ; Caso contrario, atualizar a posicao
        store posAzul, r0

        jmp AtualizaAzul_Input_Skip


;********************************************************
;                   AtualizaAzul_Apaga
; Sub-procedimento que apaga o player Azul na posicao
; anterior dele
; 
; Obs. Esse procedimento poderia ser generalizado para 
; ambos os jogadores, mas decidi separar por questoes
; de facilidade na leitura do codigo. 
;********************************************************
AtualizaAzul_Apaga:
	push r0
	push r1
	push r2

    load r0, posAntAzul

    push r0
    call CalculaPosTela0    ; r0 = pos + pos//40
    loadn r1, #tela0Linha0  ; r1 = addr(tela0Linha0)
    add r1, r1, r0          ; r1 = addr(tela0Linha0) + pos + pos//40
    pop r0
    
	loadi r2, r1            ; r5 = Char (Tela(posAnt))
	outchar r2, r0          ; Apaga o Obj na tela com o Char correspondente na memoria do cenario
	
	pop r2
	pop r1
	pop r0
	rts

AtualizaAzul_Desenha:
    push r0
    push r1
    push r2
    push r3

    load r0, posAzul
    load r1, posAntAzul


    loadn r2, #0            ; Caractere do jogador
    loadn r3, #3072         ; Cor azul
    add r2,r2,r3            ; Carregar cor azul no caractere
    outchar r2, r0          ; Desenhar o jogador na tela

    store posAntAzul, r0          ; atualiza posAntAzul = nova pos

    pop r3
    pop r2
    pop r1
    pop r0
    rts

;----------------------------------


;********************************************************
;                       AtualizaRosa
; Procedimento que cuida das interacoes com o jogador
; Rosa, como a movimentacao e a colocacao das bombas.
;********************************************************
AtualizaRosa:
    push r0
    push r1

    call AtualizaRosa_Input         ; Trata do input do jogador -- movimentacao e colocar bombas
    
    load r0, posAntRosa
    load r1, posRosa
    
    cmp r0,r1
    jeq AtualizaRosa_SkipDraw       ; Se a posicao nao mudar, nao redesenhar o jogador
    
    ; Caso contrario, redesenhar o jogador
    call AtualizaRosa_Apaga
    call AtualizaRosa_Desenha

    AtualizaRosa_SkipDraw:
        pop r1
        pop r0
        rts


;********************************************************
;                   AtualizaRosa_Input
; Sub-procedimento que le e age de acordo com o input 
; do jogador
;********************************************************
AtualizaRosa_Input:
    push r0
    push r1
    push r2

    load r0, posRosa            ; r0 = posicao atual do jogador Rosa (NÃO MUDAR NO PROCEDIMENTO)
    load r1, teclaLidaLoop      ; r1 = Input do teclado no frame

    loadn r2, #'j'
    cmp r1,r2
    jeq AtualizaRosa_Input_J        ; Tecla a (mover para esquerda)

    loadn r2, #'l'
    cmp r1,r2
    jeq AtualizaRosa_Input_L        ; Tecla d (mover para direita)

    loadn r2, #'i'
    cmp r1,r2
    jeq AtualizaRosa_Input_I        ; Tecla w (mover para cima)

    loadn r2, #'k'
    cmp r1,r2
    jeq AtualizaRosa_Input_K        ; Tecla s (mover para baixo)

    loadn r2, #'h'
    cmp r1,r2
    jeq AtualizaRosa_Input_H        ; Tecla f (colocar bomba na posicao)

    AtualizaRosa_Input_Skip:
        pop r2
        pop r1
        pop r0

        rts


    AtualizaRosa_Input_J:
        loadn r1, #40
        loadn r2, #0

        mod r1, r0, r1                  ; Testa condicoes de Contorno 
        cmp r1, r2
        jeq AtualizaRosa_Input_Skip

        dec r0	; pos = pos -1
        jmp AtualizaRosa_Input_Colisao

    AtualizaRosa_Input_L:
        loadn r1, #40
        loadn r2, #39

        mod r1, r0, r1		; Testa condicoes de Contorno 
        cmp r1, r2
        jeq AtualizaRosa_Input_Skip

        inc r0	; pos = pos + 1
        jmp AtualizaRosa_Input_Colisao

    AtualizaRosa_Input_I:
        loadn r1,#40
        cmp r0,r1
        jle AtualizaRosa_Input_Skip     ; Verifica se Rosa nao pode mover para cima (posRosa < 40 -->
                                        ; Rosa esta na primeira linha)

        sub r0,r0,r1                    ; pos = pos - 40

        jmp AtualizaRosa_Input_Colisao

    AtualizaRosa_Input_K:
        loadn r1,#1159
        cmp r0,r1
        jgr AtualizaRosa_Input_Skip     ; Verifica se Rosa nao pode mover para cima (posRosa < 40 -->
                                        ; Rosa esta na primeira linha)

        loadn r1,#40
        add r0,r0,r1                    ; pos = pos + 40

        jmp AtualizaRosa_Input_Colisao

    AtualizaRosa_Input_H:
        load r1, usadoBombaRosa
        load r2, maxBombaRosa

        cmp r1, r2                      ; Cancela jogar bomba se todas as bombas estiverem no jogo
        jeg AtualizaRosa_Input_Skip

        push r1
        ; r0 = posicao; (saida) r1 = resultado
        call DetectaColisao             ; Verifica se existe um bloco colidindo na posicao do jogador Azul -- caso o jogador estiver em cima de uma bomba
        mov r2, r1                      ; r2 = resultado da colisao
        pop r1
        
        loadn r3, #0
        cmp r2, r3
        jne AtualizaRosa_Input_Skip     ; Cancela jogar bomba se tiver colisao na posicao
        
        ; r1 = usadoBombaRosa * 4 --> Indice para colocar os dados da bomba inserida
        ; obs. Preciso do '* 4' uma vez que cada item da lista tem 4 bytes
        loadn r2, #4
        mul r1, r1, r2                  ; r1 = usadoBombaRosa * 2

        loadn r2, #bombasRosa           ; r2 = addr(bombasRosa)
        add r2, r2, r1                  ; r2 = addr(bombasRosa[r1])

        load r1, timeBombaRosa
        storei r2, r1                   ; bombasRosa[r2 + 0] = timeBombaRosa
       
        inc r2
        storei r2, r0                   ; bombasRosa[r2 + 1] = posRosa

        inc r2
        load r1, rangeBombaRosa         ; r1 = rangeBombaRosa
        storei r2, r1                   ; bombasRosa[r2 + 2] = rangeBombaRosa

        ; inc r2
        ; colocar em r2 os efeitos especiais da bomba


        ; Colocar bomba no mapa de fato; r0 = posicao da bomba
        call ColocaBombaMapa

        load r1, usadoBombaRosa
        inc r1
        store usadoBombaRosa, r1        ; Incrementa a variavel de quantidade de bombas no mapa do jogador Rosa

        jmp AtualizaRosa_Input_Skip


    AtualizaRosa_Input_Colisao:
        call DetectaColisao             ; testa se nao ha nenhuma colisao na posicao a ser usada
                                        ; Retorna resultado em r1

        loadn r2,#0
        cmp r1, r2
        jne AtualizaRosa_Input_Skip     ; Se existir colisao, nao atualizar a posicao

        ; Caso contrario, atualizar a posicao
        store posRosa, r0

        jmp AtualizaRosa_Input_Skip
    

;********************************************************
;                   AtualizaRosa_Apaga
; Sub-procedimento que apaga o player Rosa na posicao
; anterior dele
; 
; Obs. Esse procedimento poderia ser generalizado para 
; ambos os jogadores, mas decidi separar por questoes
; de facilidade na leitura do codigo. 
;********************************************************
AtualizaRosa_Apaga:
	push r0
	push r1
	push r2

    load r0, posAntRosa

    push r0
    call CalculaPosTela0    ; r0 = pos + pos//40
    loadn r1, #tela0Linha0  ; r1 = addr(tela0Linha0)
    add r1, r1, r0          ; r1 = addr(tela0Linha0) + pos + pos//40
    pop r0
    
	loadi r2, r1            ; r5 = Char (Tela(posAnt))
	outchar r2, r0          ; Apaga o Obj na tela com o Char correspondente na memoria do cenario
	
	pop r2
	pop r1
	pop r0
	rts

AtualizaRosa_Desenha:
    push r0
    push r1
    push r2
    push r3

    load r0, posRosa
    load r1, posAntRosa


    loadn r2, #0            ; Caractere do jogador
    loadn r3, #3328         ; Cor rosa
    add r2,r2,r3            ; Carregar cor azul no caractere
    outchar r2, r0          ; Desenhar o jogador na tela

    store posAntRosa, r0          ; atualiza posAntRosa = nova pos

    pop r3
    pop r2
    pop r1
    pop r0
    rts

;----------------------------------


;********************************************************
;                   DetectaColisao
; Procedimento que detecta se algum bloco (objeto 
; colidivel) existe na posicao guardada em r0
; 
; ARGS  : r0 = posicao para verificar a colisao
;
; SAIDA : r1 = resultado da verificacao
;           0: sem colisao
;           1: com colisao (bomba)
;           2: com colisao (luck box)
;           3: com colisao (bloco destrutivel)
;           4: com colisao (parede)
;
; 
; IDEIAS -- Guilherme
; index 1 : bomba - independente se do adversario ou nao 
; index 2 : bloco
; index 3 : luck box
; index 4 : caixa 
; 
; caixaS para efeitos -> explodir ou apenas passar por cima e ter efeito?
;********************************************************
DetectaColisao:
    push r0
    push r2
    push r3

    loadn r1, #0                    ; Inicia saida como sem colisao

    loadn r2, #127                  ; Bitmask para remover a cor do caractere do cenario

    call CalculaPosTela0            ; r0 = pos + pos//40
    loadn r3, #tela0Linha0          ; r3 = addr(tela0Linha0)
    add r0, r0, r3                  ; r0 = addr(tela0Linha0) + pos + pos//40

    loadi r3, r0                    ; r5 = Valor do cenario na posicao em r0
    and r3, r3, r2                  ; Aplica o bitmask em r5 para capturar o caractere armazenado (sem cor)
    

    loadn r2,#1
    cmp r3,r2                       
    jeq DetectaColisao_Bomba        ; Colisao com uma bomba 

    loadn r2,#'C'      
    cmp r3,r2
    jeq DetectaColisao_BlocoDest    ; colisao com o bloco 'C' (bloco destrutivel)

    loadn r2,#'U'
    cmp r3,r2
    jeq DetectaColisao_LuckBox      ; colisao com o bloco 'U' (luck box)

    loadn r2,#'L'
    cmp r3,r2
    jeq DetectaColisao_Parede       ; Colisao com bloco 'L' (parede1)

    loadn r2,#'H'
    cmp r3,r2
    jeq DetectaColisao_Parede       ; Colisao com o bloco 'H' (parede2)

    loadn r2,#'X'
    cmp r3,r2
    jeq DetectaColisao_Parede       ; Colisao com o bloco 'X' (parede3)

    loadn r2,#'P'
    cmp r3,r2
    jeq DetectaColisao_Parede       ; Colisao com o bloco 'P' (parede4)

    loadn r2,#'K'
    cmp r3,r2
    jeq DetectaColisao_Parede       ; Colisao com o bloco 'K' (parede5)

    jmp DetectaColisao_Fim

    DetectaColisao_Parede:
        loadn r1, #4
        jmp DetectaColisao_Fim

    DetectaColisao_BlocoDest:
        loadn r1, #3
        jmp DetectaColisao_Fim

    DetectaColisao_LuckBox:
        loadn r1, #2
        jmp DetectaColisao_Fim

    DetectaColisao_Bomba:
        loadn r1, #1
        jmp DetectaColisao_Fim
    
    DetectaColisao_Fim:
        pop r3
        pop r2
        pop r0

        rts

;---------------------------------- 


;********************************************************
;                   ColocaBombaMapa
; Procedimento que dada uma posicao, coloca a bomba no 
; mapa e a insere na tela0
; 
; ARGS  : r0 = posicao para colocar a bomba
;********************************************************
ColocaBombaMapa:
    push r0
    push r1
    push r2

    push r0
    call CalculaPosTela0        ; r0 = addr(tela0Linha0) + pos + pos//40
    loadn r2, #tela0Linha0
    add r2, r2, r0
    pop r0

    loadn r1, #1                ; r1 = caractere da bomba (cor branca)
    outchar r1, r0

    storei r2, r1               ; Registra a bomba em tela0

    pop r2
    pop r1
    pop r0
    rts

;----------------------------------


;********************************************************
;                       TickBombas
; Procedimento que decrementa os contadores das bombas
; 
; Descricao geral: o procedimento itera pelos arrays 
; bombasAzul e bombasRosa e decrementa o contador de cada
; bomba. Se o contador chega em 0, entao a bomba eh 
; explodida
;********************************************************
TickBombas:
    push r0
    push r1
    push r2

    loadn r1, #usadoBombaAzul   ; r1 = Limite do loop (endereco)
    loadn r2, #bombasAzul       ; r2 = addr(BombasAzul) --> endereco do comeco da lista das bombas
    call TickBombas_Generico	; Iteracao pelo bombasAzul

    loadn r1, #usadoBombaRosa   ; r1 = Limite do loop (endereco)
    loadn r2, #bombasRosa       ; r2 = addr(BombasAzul) --> endereco do comeco da lista das bombas
    call TickBombas_Generico	; Iteracao pelo bombasRosa

    pop r2
    pop r1
    pop r0
    rts

;----------------------------------


; ATENCAO: DEFINITIVAMENTE TA MEIO FEIO, SE PUDEREM
; ARRUMAR SERIA LEGAL, O EXPLODIRBOMBA TAMBEM
;********************************************************
;               TickBombas_Generico
; Sub-procedimento de loop para decrementar os contadores
; das bombas, aplicando-se para ambos os jogadores
; 
; ARGS: r1 = endereco da variavel que guarda as bombas
; usadas de um jogador (usadoBomba)
;       r2 = endereco do vetor de bombas de um jogador
;       (bombas)
; 
; obs. os enderecos de r1 e r2 devem pertencer ao mesmo
; jogador
; 
; IDEIAS - Guilherme
; se caixa: caso a bomba exploda 
;   -> e caixaS estiver numa regiao proxima e jogador NAO atingido (proximo) -> caixaS tem chance randomica (numeros, exemplo: se par entao sorteia dnv pra ver qual item) 
;       (se impar, nao faz nada)
;             faz o item aparecer no lugar onde foi explodida a caixa;
;   
;   -> (jogador atingido) 
;     -> jogador de OUTRO numero sai como vitorioso apos um delay; conta apenas o primeiro que morrer; flagzinha pra isso
;
; 
; bomba -> explosao em + -> se caixa estiver em +, explode normal
; bomba -> se caixaS -> explode normal, chance de item
; 
; bomba alteracoes: caso colocamos efeitos especiais
;********************************************************
TickBombas_Generico:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6

    loadn r0, #0                ; r0 = Iterador do loop
    loadi r6, r1                ; r6 = usadoBomba -- Limite do Loop

    TickBombas_Generico_Loop:
        cmp r0, r6
        jeg TickBombas_Generico_Fim     ; Condicao de saida -- r0 >= r1

        loadn r5, #4
        mul r4, r0, r5                  ; r4 = 4 * iterador
        add r4, r4, r2                  ; r4 = addr(bombas) + 4 * iterador  (QUERO SALVAR O ENDERECO, NAO MUDE)
        loadi r3, r4                    ; r3 = bombas[4 * iterador] -- Carrega o contador da (iterador)-ezima bomba em bombas

        dec r3 
        storei r4, r3                   ; Decrementa o contador e salva na memoria

        loadn r5, #0
        cmp r3, r5
        jne TickBombas_Generico_Skip    ; Caso o contador nao for zero, ir para a proxima bomba

        ; Caso contrario, exploda a bomba da posicao atual

        ; r0 = posicao da bomba no vetor; r1 = endereco de usadoBomba; r2 = endereco de bombas
        call ExplodirBomba

        TickBombas_Generico_Skip:
            inc r0
            jmp TickBombas_Generico_Loop 

    TickBombas_Generico_Fim:
        pop r6
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0
        rts

;----------------------------------


;********************************************************
;               ExplodirBomba
; Procedimento que explode uma bomba e arruma o vetor
; de bombas de acordo
; 
; ARGS: r0 = index da bomba no vetor
;       r1 = endereco da variavel que guarda as bombas
; usadas de um jogador (usadoBomba)
;       r2 = endereco do vetor de bombas de um jogador
;       (bombas) 
; 
; obs. os enderecos de r1 e r2 devem pertencer ao mesmo
; jogador
;********************************************************
ExplodirBomba:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    push r6

    loadn r5, #4
    mul r4, r0, r5                  ; r4 = 4 * index
    add r4, r4, r2                  ; r4 = addr(bombas) + 4 * index  (NAO MUDAR)

    ; ********** Remocao da bomba em tela0 **********

    loadn r3, #1
    add r3, r3, r4          ; r3 = addr(bombasAzul) + 4 * index + 1
    loadi r5, r3            ; r5 = bombas[2 * iterador + 1] -- Carrega a posicao da r0-ezima bomba em bombasAzul

    push r0
    mov r0, r5              ; r0 = bombaPos
    call ApagaBloco         ; Apaga a bomba na posicao r0 em tela0
    pop r0

    ; ***********************************************

    push r0
    push r1

    ; Passar em r0 a posicao para a explosao
    mov r0, r5
    ; Passar em r1 o raio de explosao
    loadn r3, #2
    add r3, r3, r4          ; r3 = addr(bombasAzul) + 4 * index + 2
    loadi r1, r3            ; r5 = bombas[2 * iterador + 2] -- Carrega o raio da r0-ezima bomba em bombasAzul
    call CriarExplosaoCruz

    pop r1
    pop r0


    loadi r6, r1
    dec r6                          ; r6 = r6 - 1 -- Diminui a quantidade de iteracoes do loop

    cmp r0, r6
    jeg ExplodirBomba_Fim           ; Se eu estiver no fim da lista, nao faco nada

    ; Caso contrario, coloco o ultimo item de bombas na posicao atual

    push r0
    push r1
    push r2

    mov r3, r2
    mov r2, r0              ; r2 = indice destino; NAO MUDAR A ORDEM
    mov r1, r6              ; r1 = indice origem (ultimo elemento da lista)
    mov r0, r3              ; r0 = endereco do vetor de bombas
    call CopiarBombaLista   ; Copia o ultimo item da lista na posicao atual

    pop r2
    pop r1
    pop r0

    ExplodirBomba_Fim:
        storei r1, r6               ; Salva a quantidade de bombas ainda em jogo na memoria

        pop r6
        pop r5
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0
        rts

;----------------------------------


;********************************************************
;                   CopiarBombaLista
; Procedimento que copia os dados de um item da lista 
; do tipo bombasXXXX (4 bytes cada item) de uma posicao 
; para a outra
; 
; ARGS  : r0 = endereco da lista
;         r1 = posicao (indice) origem
;         r2 = posicao (indice) destino
;********************************************************
CopiarBombaLista:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5

    loadn r3, #4
    mul r4, r1, r3          ; r4 = 4 * r1
    mul r5, r2, r3          ; r5 = 4 * r2
    add r4, r4, r0          ; r4 = addr(bombas) + 4 * r1 -- endereco da bomba de origem
    add r5, r5, r0          ; r5 = addr(bombas) + 4 * r2 -- endereco da bomba de destino

    loadi r3, r4            ; r3 = bombas[4 * r1] -- Carrega o primeiro byte da bomba de origem
    storei r5, r3           ; bombas[4 * r2] = r3 -- Substitui o primero byte da bomba de destino pelo 
                            ; primeiro byte da bomba de origem
    
    inc r4
    inc r5
    loadi r3, r4            ; r3 = bombas[4 * r1 + 1] -- Carrega o segundo byte da bomba de origem
    storei r5, r3           ; bombas[4 * r2 + 1] = r3 -- Substitui o segundo byte da bomba de destino pelo 
                            ; segundo byte da bomba de origem

    inc r4
    inc r5
    loadi r3, r4            ; r3 = bombas[4 * r1 + 2] -- Carrega o terceiro byte da bomba de origem
    storei r5, r3           ; bombas[4 * r2 + 2] = r3 -- Substitui o terceiro byte da bomba de destino pelo
                            ; terceiro byte da bomba de origem

    inc r4
    inc r5
    loadi r3, r4            ; r3 = bombas[4 * r1 + 3] -- Carrega o quarto byte da bomba de origem
    storei r5, r3           ; bombas[4 * r2 + 3] = r3 -- Substitui o quarto byte da bomba de destino pelo
                            ; quarto byte da bomba de origem

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

;----------------------------------


;********************************************************
;                   CriarExplosaoCruz
; Procedimento que cria uma explosao em formato de 
; cruz.
; 
; ARGS  : r0 = centro da explosao
;         r1 = raio da explosao
;********************************************************
CriarExplosaoCruz:
    push r1
    call ExplodirPos
    pop r1

    call CriarExplosaoCruz_Esq
    call CriarExplosaoCruz_Dir
    call CriarExplosaoCruz_Cima
    call CriarExplosaoCruz_Baixo

    CriarExplosaoCruz_Fim:
        rts


;********************************************************
;                   CriarExplosaoCruz_Esq
; Sub-procedimento que cria uma explosao para esquerda
; 
; ARGS  : r0 = centro da explosao
;         r1 = raio da explosao
;********************************************************
CriarExplosaoCruz_Esq:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r2, #0                            ; Iterador
    CriarExplosaoCruz_Esq_Loop:
        cmp r2, r1
        jeg CriarExplosaoCruz_Esq_Fim       ; Fim do loop
        
        loadn r3, #40
        loadn r4, #0
        mod r3, r0, r3                      ; r3 = r1 mod 40

        cmp r3, r4                          ; r3 == 0
        jeq CriarExplosaoCruz_Esq_Fim       ; Condicao de saida da tela

        dec r0                              ; r0 = r0 - 1 -- nova posicao para a explosao

        push r1
        call ExplodirPos                    ; Tenta explodir a posicao atual e manda resultado (igual a DetectaColisao) em r1
        mov r3, r1
        pop r1

        loadn r4, #0
        cmp r3, r4
        jeq CriarExplosaoCruz_Esq_Cont      ; Caso nao tiver colisao: continuar

        jmp CriarExplosaoCruz_Esq_Fim       ; Caso tiver colisao com qualquer coisa: parar

        CriarExplosaoCruz_Esq_Cont:
            inc r2
            jmp CriarExplosaoCruz_Esq_Loop

    CriarExplosaoCruz_Esq_Fim:
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0

        rts


;********************************************************
;                   CriarExplosaoCruz_Dir
; Sub-procedimento que cria uma explosao para direita
; 
; ARGS  : r0 = centro da explosao
;         r1 = raio da explosao
;********************************************************
CriarExplosaoCruz_Dir:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r2, #0                            ; Iterador
    CriarExplosaoCruz_Dir_Loop:
        cmp r2, r1
        jeg CriarExplosaoCruz_Dir_Fim       ; Fim do loop

        loadn r3, #40
        loadn r4, #39
        mod r3, r0, r3                      ; r3 = r1 mod 40

        cmp r3, r4                          ; r3 == 39
        jeq CriarExplosaoCruz_Dir_Fim       ; Condicao de saida da tela (na nova pos)

        inc r0                              ; r0 = r0 + 1 -- nova posicao para a explosao

        push r1
        call ExplodirPos                    ; Tenta explodir a posicao atual e manda resultado (igual a DetectaColisao) em r1
        mov r3, r1
        pop r1

        loadn r4, #0
        cmp r3, r4
        jeq CriarExplosaoCruz_Dir_Cont      ; Caso nao tiver colisao: continuar

        jmp CriarExplosaoCruz_Dir_Fim       ; Caso tiver colisao com qualquer coisa: parar

        CriarExplosaoCruz_Dir_Cont:
            inc r2
            jmp CriarExplosaoCruz_Dir_Loop

    CriarExplosaoCruz_Dir_Fim:
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0

        rts


;********************************************************
;                   CriarExplosaoCruz_Cima
; Sub-procedimento que cria uma explosao para cima
; 
; ARGS  : r0 = centro da explosao
;         r1 = raio da explosao
;********************************************************
CriarExplosaoCruz_Cima:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r2, #0                            ; Iterador
    CriarExplosaoCruz_Cima_Loop:
        cmp r2, r1
        jeg CriarExplosaoCruz_Cima_Fim       ; Fim do loop

        loadn r3, #40
        cmp r0, r3
        jle CriarExplosaoCruz_Cima_Fim       ; Condicao de saida da tela

        sub r0, r0, r3

        push r1
        call ExplodirPos                    ; Tenta explodir a posicao atual e manda resultado (igual a DetectaColisao) em r1
        mov r3, r1
        pop r1

        loadn r4, #0
        cmp r3, r4
        jeq CriarExplosaoCruz_Cima_Cont      ; Caso nao tiver colisao: continuar

        jmp CriarExplosaoCruz_Cima_Fim       ; Caso tiver colisao com qualquer coisa: parar

        CriarExplosaoCruz_Cima_Cont:
            inc r2
            jmp CriarExplosaoCruz_Cima_Loop

    CriarExplosaoCruz_Cima_Fim:
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0

        rts


;********************************************************
;                   CriarExplosaoCruz_Baixo
; Sub-procedimento que cria uma explosao para baixo
; 
; ARGS  : r0 = centro da explosao
;         r1 = raio da explosao
;********************************************************
CriarExplosaoCruz_Baixo:
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r2, #0                            ; Iterador
    CriarExplosaoCruz_Baixo_Loop:
        cmp r2, r1
        jeg CriarExplosaoCruz_Baixo_Fim       ; Fim do loop

        loadn r3, #1159
        cmp r0, r3
        jgr CriarExplosaoCruz_Baixo_Fim       ; Condicao de saida da tela

        loadn r3, #40
        add r0, r0, r3

        push r1
        call ExplodirPos                    ; Tenta explodir a posicao atual e manda resultado (igual a DetectaColisao) em r1
        mov r3, r1
        pop r1

        loadn r4, #0
        cmp r3, r4
        jeq CriarExplosaoCruz_Baixo_Cont      ; Caso nao tiver colisao: continuar

        jmp CriarExplosaoCruz_Baixo_Fim       ; Caso tiver colisao com qualquer coisa: parar

        CriarExplosaoCruz_Baixo_Cont:
            inc r2
            jmp CriarExplosaoCruz_Baixo_Loop

    CriarExplosaoCruz_Baixo_Fim:
        pop r4
        pop r3
        pop r2
        pop r1
        pop r0

        rts

;----------------------------------


;********************************************************
;                   ExplodirPos
; Procedimento que dada uma posicao, explode essa posicao
; e cuida dos resultados
; 
; Em especial, cada bloco vai ter uma resposta diferente
; 
; ARGS  : r0 = posicao a ser explodida
; 
; SAIDA : r1 = Mesmo que DetectaColisao na posicao
;********************************************************
ExplodirPos:
    push r0
    push r2
    push r3

    call DetectaColisao
    
    loadn r2, #0
    cmp r1, r2
    jeq ExplodirPos_Normal      ; Explosao de espaco vazio

    loadn r2, #1
    cmp r1, r2
    jeq ExplodirPos_HitBomba    ; Explosao de bomba (explodir a outra bomba)

;     loadn r2, #2
;     cmp r1, r2
;     jeq ExplodirPos_LuckBox     ; Explosao de luck box (gerar item caso der sorte)

    loadn r2, #3
    cmp r1, r2
    jeq ExplodirPos_Destruir    ; Explosao de bloco destrutível

    loadn r2, #4
    cmp r1, r2
    jeq ExplodirPos_Skip        ; Explosao de parede

    ExplodirPos_LuckBox:       ; Explosao de luck box
        push r0
        push r2
        push r3
        push r4
        push r5

        loadn r2,#Rand ; declara ponteiro para tabela rand na memoria
        load r1, IncRand ; Pega Incremento da tabela Rand
        add r2, r2, r1          ; Incrementa o rand para gerar um novo numero aleatorio
        loadi R3, R2 		; busca nr. randomico da memoria em R3
						    ; R3 = Rand(IncRand)
        inc r1				; Incremento ++
	    loadn r2, #30
	    cmp r1, r2			; Compara com o Final da Tabela e re-estarta em 0
	    jne Lucky_RecalculaPos_Skip
		loadn r1, #0		; re-estarta a Tabela Rand em 0

Lucky_RecalculaPos_Skip:
    	store IncRand, r1	; Salva incremento ++
        
        loadn r4, #3072         ; Cor azul 
        add r4, r4, r3          ; Aplica a cor em r2
        outchar r4, r0          ; Imprimir o powerup na tela

        call CalculaPosTela0
        loadn r5, #tela0Linha0   ; r5 = addr(tela0Linha0)
        add r5, r5, r0          ; r5 = addr(tela0Linha0) + posTela; posTela = pos + pos//40
        storei r5, r3           ; tela0[posTela] = char luck box -- Salvar o luck box em tela8

        pop r5
        pop r4
        pop r3
        pop r2
        pop r0
        jmp ExplodirPos_Skip     ; Pular para o fim

    ExplodirPos_Destruir:       ; Apaga o bloco do cenario
        call ApagaBloco

    ExplodirPos_Normal:         ; Explode a posicao
        loadn r2, #2            ; Caractere do primeiro frame da explosao
        loadn r3, #2304         ; Cor vermelha
        add r2, r2, r3          ; Aplica a cor em r2
        outchar r2, r0          ; Imprimir a explosao na tela

        call CalculaPosTela0
        loadn r3, #tela8Linha0  ; r3 = addr(tela8Linha0)
        add r3, r3, r0          ; r3 = addr(tela8Linha0) + posTela; posTela = pos + pos//40
        storei r3, r2           ; tela8[posTela] = char explosao -- Salvar a explosao em tela8
        jmp ExplodirPos_Skip

    ExplodirPos_HitBomba:
        call ExplodirPos_HitBomba_Azul
        call ExplodirPos_HitBomba_Rosa

    ExplodirPos_Skip:
        pop r3
        pop r2
        pop r0
        rts


;********************************************************
;           ExplodirPos_HitBomba_Azul
; Procedimento que dada uma posicao, explode essa posicao
; e cuida dos resultados
; 
; Em especial, cada bloco vai ter uma resposta diferente
; 
; ARGS  : r0 = posicao a ser explodida
;********************************************************
ExplodirPos_HitBomba_Azul:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    
    loadn r1, #bombasAzul
    inc r1                      ; r1 = addr(bombasAzul)+1 -> endereco da posicao da primeira bomba
    loadn r2, #0
    load r3, maxBombaAzul

    ExplodirPos_HitBomba_Azul_Loop:
        ; EXPLODIR A BOMBA DE FATO!!!!
        push r0
        push r1
        push r2

        loadi r4, r1                ; r4 = bombasAzul[r2].pos
        mov r5, r0                  ; r5 = posicao a ser explodida (r0)

        mov r0, r2                  ; r0 = indice da bomba
        loadn r1, #usadoBombaAzul   ; r1 = addr(usadoBombaAzul)
        loadn r2, #bombasAzul       ; r2 = addr(bombasAzul)

        cmp r4, r5
        ceq ExplodirBomba

        pop r2
        pop r1
        pop r0

        cmp r4, r5
        jeq ExplodirPos_HitBomba_Azul_Fim
        
        inc r2                      ; r2 = r2 + 1
        loadn r4, #4
        add r1, r1, r4              ; r1 = r1 + 4
        cmp r2, r3

        jle ExplodirPos_HitBomba_Azul_Loop

    ExplodirPos_HitBomba_Azul_Fim:

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

;----------------------------------


;********************************************************
;           ExplodirPos_HitBomba_Rosa
; Procedimento que dada uma posicao, explode essa posicao
; e cuida dos resultados
; 
; Em especial, cada bloco vai ter uma resposta diferente
; 
; ARGS  : r0 = posicao a ser explodida
;********************************************************
ExplodirPos_HitBomba_Rosa:
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5
    
    loadn r1, #bombasRosa
    inc r1                      ; r1 = addr(bombasRosa)+1 -> endereco da posicao da primeira bomba
    loadn r2, #0
    load r3, maxBombaRosa

    ExplodirPos_HitBomba_Rosa_Loop:
        ; EXPLODIR A BOMBA DE FATO!!!!
        push r0
        push r1
        push r2

        loadi r4, r1                ; r4 = bombasRosa[r2].pos
        mov r5, r0                  ; r5 = posicao a ser explodida (r0)

        mov r0, r2                  ; r0 = indice da bomba
        loadn r1, #usadoBombaRosa   ; r1 = addr(usadoBombaRosa)
        loadn r2, #bombasRosa       ; r2 = addr(bombasRosa)

        cmp r4, r5
        ceq ExplodirBomba

        pop r2
        pop r1
        pop r0

        cmp r4, r5
        jeq ExplodirPos_HitBomba_Rosa_Fim
        
        inc r2                      ; r2 = r2 + 1
        loadn r4, #4
        add r1, r1, r4              ; r1 = r1 + 4
        cmp r2, r3

        jle ExplodirPos_HitBomba_Rosa_Loop

    ExplodirPos_HitBomba_Rosa_Fim:

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

;********************************************************
;               CalculaPosTela0
; Procedimento que, dado uma posicao (no display) mapeia
; para a posicao correspondente na tela0
;
; ARGS  : r0 = posicao no display
;
; SAIDA : r0 = posicao em tela0
;********************************************************
CalculaPosTela0:
    push r1

    loadn r1, #40
    div r1, r0, r1              ; r1 = pos//40 (divisao inteira)
    add r0, r1, r0              ; r0 = pos + pos//40  -->  tem que somar pos//40 pois as linhas da string (tela0) possuem '\0'

    pop r1
    rts

;----------------------------------


;********************************************************
;                   ApagaBloco
; Procedimento que, dado uma posicao, apaga o bloco na 
; posicao correspondente em tela0
; 
; ARGS  : r0 = posicao a ser apagada
;********************************************************
ApagaBloco:
    push r0
    push r1
    
    loadn r1, #' '
    outchar r1, r0          ; Apaga a posicao no display
    
    call CalculaPosTela0    ; r0 = pos + pos//40
    loadn r1, #tela0Linha0  ; r1 = addr(tela0Linha0)
    add r0, r0, r1          ; r0 = addr(tela0Linha0) + pos + pos//40

    loadn r1, #' '
    storei r0, r1           ; tela0[pos + pos//40] = ' ' -- Apaga a posicao em tela0

    pop r1
    pop r0
    rts

;----------------------------------


;********************************************************
;                       SAIR
; Procedimento para sair do jogo e terminar o programa.
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
; Procedimento que apaga a tela inteira.
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
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = r0 + 40
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
;                       IMPRIME TELA4
;********************************************************	

ImprimeTela4: 	;  Rotina de Impresao das Explosoes na Tela Inteira (ImprimeTela2, porem nao escreve em tela0)
		;  r1 = endereco onde comeca a primeira linha do Cenario
		;  r2 = cor do Cenario para ser impresso

	push r0	; protege o r3 na pilha para ser usado na subrotina
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina

	loadn r0, #0  	; posicao inicial tem que ser o comeco da tela!
	loadn r3, #40  	; Incremento da posicao da tela!
	loadn r4, #41  	; incremento do ponteiro das linhas da tela
	loadn r5, #1200 ; Limite da tela!
	
   ImprimeTela4_Loop:
		call ImprimeStr4
		add r0, r0, r3  	; incrementaposicao para a segunda linha na tela -->  r0 = r0 + 40
		add r1, r1, r4  	; incrementa o ponteiro para o comeco da proxima linha na memoria (40 + 1 porcausa do /0 !!) --> r1 = r1 + 41
		cmp r0, r5			; Compara r0 com 1200
		jne ImprimeTela4_Loop	; Enquanto r0 < 1200

	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
				
;---------------------------	


;********************************************************
;                   IMPRIME STRING4
;********************************************************
	
ImprimeStr4:    ; Rotina de Impresao de Mensagens; Obs: a mensagem sera' impressa ate' encontrar "/0"
    ; r0 = Posicao da tela que o primeiro caractere da mensagem sera' impresso
    ; r1 = endereco onde comeca a mensagem
    ; r2 = cor da mensagem.

	push r0	; protege o r0 na pilha para preservar seu valor
	push r1	; protege o r1 na pilha para preservar seu valor
	push r2	; protege o r1 na pilha para preservar seu valor
	push r3	; protege o r3 na pilha para ser usado na subrotina
	push r4	; protege o r4 na pilha para ser usado na subrotina
	push r5	; protege o r5 na pilha para ser usado na subrotina
	
	
	loadn r3, #'\0'	; Criterio de parada
	loadn r5, #' '	; Espaco em Branco

    ImprimeStr4_Loop:	
		loadi r4, r1
		cmp r4, r3		; If (Char == \0)  vai Embora
		jeq ImprimeStr4_Sai
		cmp r4, r5		; If (Char == ' ')  vai Pula outchar do espaco para na apagar outros caracteres
		jeq ImprimeStr4_Skip
		add r4, r2, r4	; Soma a Cor
		outchar r4, r0	; Imprime o caractere na tela
    ImprimeStr4_Skip:
		inc r0			; Incrementa a posicao na tela
		inc r1			; Incrementa o ponteiro da String
		jmp ImprimeStr4_Loop
	
    ImprimeStr4_Sai:	
	pop r5	; Resgata os valores dos registradores utilizados na Subrotina da Pilha
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts

;---------------------------	


;********************************************************
;                   DIGITE UMA LETRA
;********************************************************

DigLetra:	; Espera que uma tecla seja digitada e salva na variavel global "Letra"
	push r0
	push r1
	loadn r1, #255	; Se nao digitar nada vem 255

   DigLetra_Loop:
		inchar r0			; Le o teclado, se nada for digitado = 255
		cmp r0, r1			; compara r0 com 255
		jeq DigLetra_Loop	; Fica lendo ate' que digite uma tecla valida

	store Letra, r0			; Salva a tecla na variavel global "Letra"

	pop r1
	pop r0
	rts


; completo -- tela0 eh o buffer do cenario, nao eh realmente usado no jogo
tela0Linha0  : string "                                        "
tela0Linha1  : string "                                        "
tela0Linha2  : string "                                        "
tela0Linha3  : string "                                        "
tela0Linha4  : string "                                        "
tela0Linha5  : string "                                        "
tela0Linha6  : string "                                        "
tela0Linha7  : string "                                        "
tela0Linha8  : string "                                        "
tela0Linha9  : string "                                        "
tela0Linha10 : string "                                        "
tela0Linha11 : string "                                        "
tela0Linha12 : string "                                        "
tela0Linha13 : string "                                        "
tela0Linha14 : string "                                        "
tela0Linha15 : string "                                        "
tela0Linha16 : string "                                        "
tela0Linha17 : string "                                        "
tela0Linha18 : string "                                        "
tela0Linha19 : string "                                        "
tela0Linha20 : string "                                        "
tela0Linha21 : string "                                        "
tela0Linha22 : string "                                        "
tela0Linha23 : string "                                        "
tela0Linha24 : string "                                        "
tela0Linha25 : string "                                        "
tela0Linha26 : string "                                        "
tela0Linha27 : string "                                        "
tela0Linha28 : string "                                        "
tela0Linha29 : string "                                        "     


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
tela4Linha3  : string "                   XXX                  "
tela4Linha4  : string "                                        "
tela4Linha5  : string "      XXXXXXXXXXXXXXXXXXXXXXXXXXXX      "
tela4Linha6  : string "                                        "
tela4Linha7  : string "      XXX   X              X   XXX      "
tela4Linha8  : string "      XXX                      XXX      "
tela4Linha9  : string "      XXX   X              X   XXX      "
tela4Linha10 : string "      XXX                      XXX      "
tela4Linha11 : string "      XXX   X              X   XXX      "
tela4Linha12 : string "      XXX                      XXX      "
tela4Linha13 : string "      XXX   X              X   XXX      "
tela4Linha14 : string "      XXX                      XXX      "
tela4Linha15 : string "      XXX   X              X   XXX      "
tela4Linha16 : string "      XXX                      XXX      "
tela4Linha17 : string "      XXX   X              X   XXX      "
tela4Linha18 : string "      XXX                      XXX      "
tela4Linha19 : string "      XXX   X              X   XXX      "
tela4Linha20 : string "      XXX                      XXX      "
tela4Linha21 : string "      XXX   X              X   XXX      "
tela4Linha22 : string "                                        "
tela4Linha23 : string "      XXXXXXXXXXXXXXXXXXXXXXXXXXXX      "
tela4Linha24 : string "      XXXXXXXXXXXXXXXXXXXXXXXXXXXX      "
tela4Linha25 : string "                                        "
tela4Linha26 : string "     X             XXX           X  X   "
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

; Tela dedicada para as explosoes no mapa -- Vermelho
tela8Linha0  : string "                                        "
tela8Linha1  : string "                                        "
tela8Linha2  : string "                                        "
tela8Linha3  : string "                                        "
tela8Linha4  : string "                                        "
tela8Linha5  : string "                                        "
tela8Linha6  : string "                                        "
tela8Linha7  : string "                                        "
tela8Linha8  : string "                                        "
tela8Linha9  : string "                                        "
tela8Linha10 : string "                                        "
tela8Linha11 : string "                                        "
tela8Linha12 : string "                                        "
tela8Linha13 : string "                                        "
tela8Linha14 : string "                                        "
tela8Linha15 : string "                                        "
tela8Linha16 : string "                                        "
tela8Linha17 : string "                                        "
tela8Linha18 : string "                                        "
tela8Linha19 : string "                                        "
tela8Linha20 : string "                                        "
tela8Linha21 : string "                                        "
tela8Linha22 : string "                                        "
tela8Linha23 : string "                                        "
tela8Linha24 : string "                                        "
tela8Linha25 : string "                                        "
tela8Linha26 : string "                                        "
tela8Linha27 : string "                                        "
tela8Linha28 : string "                                        "
tela8Linha29 : string "                                        " 


