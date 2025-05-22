jmp telaInicial
; ---------- TABELA DE CORES ----------
; adicione ao caracter para Selecionar a cor correspondente

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

Bombs: var #10				
	static Bombs + #0, #0
	static Bombs + #1, #0
	static Bombs + #2, #0
	static Bombs + #3, #0
	static Bombs + #4, #0	
	static Bombs + #5, #0	
	static Bombs + #6, #0	
	static Bombs + #7, #0	
	static Bombs + #8, #0	
	static Bombs + #9, #0
	static Bombs + #10, #0
	static Bombs + #11, #0

fim:
	halt
	
main:
;------------ PRINT MAPA -------------------

;-------------------------------------------

PrintPlayers:
	loadn r5, #5
	loadn r1, #42   
	loadn r2, #48
	add r5,r5,r2
	outchar r5,r1
	loadn r1, #77
	outchar r5,r1
	
	loadn r1, #161   ; Posicao inicial do player 1
	loadn r2, #1158 ; Posicao inicial do player 2
	loadn r3, #3072 ; Azul
	loadn r4, #2304 ; Vermelho
	loadn r0, #72   ; H maiusculo
	loadn r5, #5   ; Quantidade de bombas que o jogador 1 pode colocar
	loadn r6, #5   ; Quantidade de bombas que o jogador 2 pode colocar
	push r0
	add r0,r0,r3
	outchar r0, r1
	pop r0
	push r0
	add r0,r0,r4
	outchar r0, r2
	pop r0
	push r5
	push r6
	
AtualizaJogadores:
	loadn r0, #72   ; H maiusculo
	pop r6
	pop r5
	push r5
	push r6
	loadn r6, #255
	inchar r7
	cmp r7, r6
	jeq AtualizaJogadores
	jmp Comandos
	
AtualizaJogadoresBomba:
	pop r0
	pop r6
	pop r5
	push r6
	loadn r6,#Bombs
	add r6,r6,r5
	storei r6, r0
	
	loadn r0, #72   ; H maiusculo
	pop r6
	push r5
	push r6
	loadn r6, #255
	inchar r7
	cmp r7, r6
	jeq AtualizaJogadores
	
AtualizaJogadoresBomba2:
	pop r0
	pop r6
	pop r5
	push r5
	push r2
	loadn r2, #6
	loadn r5,#Bombs
	add r5,r5,r2
	pop r2
	
	add r5,r5,r6
	storei r5, r0
	
	loadn r0, #72   ; H maiusculo
	pop r5
	push r5
	push r6
	loadn r6, #255
	inchar r7
	cmp r7, r6
	jeq AtualizaJogadores
;---- TABELA ASCII ----	
; 		119 - w
; 		 97 - a
; 		115 - s
; 		100 - d
; 		 99 - c
; 		102 - f
; 		112 - p
; 		105 - i
; 		106 - j
; 		107 - k
; 		108 - l
;		 59 - ;
;		 46	- .
; 		 32 - Espaco
	
	
; r3 - Ultima direção pressionada pelo jogador 1
; r4 - Ultima direção pressionada pelo jogador 2
; r6 - 0 ou 1, subtrai pixel ou soma pixel

Comandos:

	loadn r6, #112 ; Pause
	cmp r7, r6
	jeq fim

;--- Teclas Player 1 ---
	loadn r6, #115
	cmp r7, r6
	jeq DescePlayer1
	loadn r6, #119
	cmp r7, r6
	jeq SobePlayer1
	loadn r6, #97
	cmp r7, r6
	jeq EsquerdaPlayer1
	loadn r6, #100
	cmp r7, r6
	jeq DireitaPlayer1
	loadn r6, #99
	cmp r7, r6
	jeq BombaPlayer1
	loadn r6, #102
	cmp r7, r6
	jeq ExplodeBombas1
;-----------------------

;--- Teclas Player 2 ---
	loadn r6, #105
	cmp r7, r6
	jeq SobePlayer2
	inc r6
	cmp r7, r6
	jeq EsquerdaPlayer2
	inc r6
	cmp r7, r6
	jeq DescePlayer2
	inc r6
	cmp r7, r6
	jeq DireitaPlayer2
	loadn r6, #59
	cmp r7, r6
	jeq BombaPlayer2
	loadn r6, #46
	cmp r7, r6
	jeq ExplodeBombas2
;-----------------------	
	jmp AtualizaJogadores
;--- Controles Player 1 ----
ExplodeBombas1:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	loadn r0, #0
	loadn r1, #0
	loadn r3, #6
	loadn r5, #32
LoopExplode1:
	loadn r2, #Bombs
	add r2,r2,r1
	loadi r4,r2
	outchar r5,r4
	storei r2, r0
	inc r1
	cmp r1,r3
	jne LoopExplode1
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	jmp AtualizaJogadores

BombaPlayer1:
	loadn r7, #0
	cmp r5,r7
	jeq AtualizaJogadores
	pop r6
	pop r5
	dec r5
	push r5
	push r6
; Printa quantas bombas ainda tem	
	loadn r7, #48
	add r5,r5,r7
	loadn r7, #1
	outchar r5,r7
	
	loadn r7, #119 ; w
	cmp r3,r7
	jeq BombaCimaPlayer1
	loadn r7, #97 ; a
	cmp r3,r7
	jeq BombaEsquerdaPlayer1
	loadn r7, #115 ; s 
	cmp r3,r7
	jeq BombaBaixoPlayer1
	loadn r7, #100 ; d
	cmp r3,r7
	jeq BombaDireitaPlayer1
	jmp AtualizaJogadores
	
BombaCimaPlayer1:
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	jmp ColocaBombaSub
	
BombaEsquerdaPlayer1:
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	jmp ColocaBombaSub
	
BombaDireitaPlayer1:
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1
	jmp ColocaBomba	
	
BombaBaixoPlayer1:
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1

ColocaBomba:	
	push r1
	call PushAll
	loadn r0, #64 ; Arroba
	loadn r3, #3072 ; Azul
	add r0,r0,r3
	add r1,r1,r5
	outchar r0, r1
	mov r0, r1
	pop r1
	push r0
	jmp AtualizaJogadoresBomba 
	
ColocaBombaSub:	
	push r1
	call PushAll
	loadn r0, #64 ; Arroba
	loadn r3, #3072 ; Azul
	add r0,r0,r3
	sub r1,r1,r5
	outchar r0, r1
	mov r0, r1
	pop r1
	push r0
	jmp AtualizaJogadoresBomba 


SobePlayer1:
	mov r3,r7
	push r3
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	call PushAll
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r1 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r3, #3072 ; Azul
	add r0,r0,r3
	sub r1,r1,r5
	outchar r0, r1
	pop r0
	pop r3
	jmp AtualizaJogadores
	
EsquerdaPlayer1:
	mov r3,r7
	push r3
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	call PushAll
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r1 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r3, #3072 ; Azul
	add r0,r0,r3
	sub r1,r1,r5
	outchar r0, r1
	pop r0
	pop r3
	jmp AtualizaJogadores
	
DescePlayer1:
	mov r3,r7
	push r3
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1
	call PushAll
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r1 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r3, #3072 ; Azul
	add r0,r0,r3
	add r1,r1,r5
	outchar r0, r1
	pop r0
	pop r3
	jmp AtualizaJogadores
	
DireitaPlayer1:
	mov r3,r7
	push r3
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1
	call PushAll
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r1 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r3, #3072 ; Azul
	add r0,r0,r3
	add r1,r1,r5
	outchar r0, r1
	pop r0
	pop r3
	jmp AtualizaJogadores
;-----------------------------	
	
;--- CONTROLES DO PLAYER 2 ---
ExplodeBombas2:
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	loadn r0, #0
	loadn r1, #6
	loadn r3, #12
	loadn r5, #32
LoopExplode2:
	loadn r2, #Bombs
	add r2,r2, r1
	loadi r4, r2
	outchar r5, r4
	storei r2, r0
	inc r1
	cmp r1,r3
	jne LoopExplode2
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	jmp AtualizaJogadores
	
BombaPlayer2:
	loadn r7, #0
	cmp r6,r7
	jeq AtualizaJogadores
	pop r6
	dec r6
	push r6
; Printa quantas bombas ainda tem
	loadn r7, #48
	add r6,r6,r7
	loadn r7, #37
	outchar r6,r7
	
	loadn r7, #105 ; i
	cmp r4,r7
	jeq BombaCimaPlayer2
	loadn r7, #106 ; j
	cmp r4,r7
	jeq BombaEsquerdaPlayer2
	loadn r7, #107 ; k 
	cmp r4,r7
	jeq BombaBaixoPlayer2
	loadn r7, #108 ; l
	cmp r4,r7
	jeq BombaDireitaPlayer2
	jmp AtualizaJogadores
	
BombaCimaPlayer2:
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	jmp ColocaBombaSub2
	
BombaEsquerdaPlayer2:
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	jmp ColocaBombaSub2
	
BombaDireitaPlayer2:
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1
	jmp ColocaBomba2	
	
BombaBaixoPlayer2:
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1

ColocaBomba2:	
	push r2
	call PushAll2
	loadn r0, #64 ; Arroba
	loadn r3, #2304 ; Vermelho
	add r0,r0,r3
	add r2,r2,r5
	outchar r0, r2
	mov r0, r2
	pop r2
	push r0
	jmp AtualizaJogadoresBomba2 
	
ColocaBombaSub2:	
	push r2
	call PushAll2
	loadn r0, #64 ; Arroba
	loadn r3, #2304 ; Vermelho
	add r0,r0,r3
	sub r2,r2,r5
	outchar r0, r2
	mov r0, r2
	pop r2
	push r0
	jmp AtualizaJogadoresBomba2
	
SobePlayer2:
	mov r4,r7
	push r4
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	call PushAll2
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r2 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r4, #2304 ; Vermelho
	add r0,r0,r4
	sub r2,r2,r5
	outchar r0, r2
	pop r0
	pop r4
	jmp AtualizaJogadores
	
EsquerdaPlayer2:
	mov r4,r7
	push r4
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #0
	call PushAll2
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r2 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r4, #2304 ; Vermelho
	add r0,r0,r4
	sub r2,r2,r5
	outchar r0, r2
	pop r0
	pop r4
	jmp AtualizaJogadores
	
DescePlayer2:
	mov r4,r7
	push r4
	loadn r5, #40 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1
	call PushAll2
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r2 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r4, #2304 ; Vermelho
	add r0,r0,r4
	add r2,r2,r5
	outchar r0, r2
	pop r0
	pop r4
	jmp AtualizaJogadores
	
DireitaPlayer2:
	mov r4,r7
	push r4
	loadn r5, #1 ; algarismo para a soma necessária para saber o pixel para a proxima posição
	loadn r6, #1
	call PushAll2
	push r0
	loadn r0, #32 ; Barra de espaço
	outchar r0, r2 ; "Apaga" a antiga posição do jogar, printando um espaço por cima
	pop r0
	push r0
	loadn r4, #2304 ; Vermelho
	add r0,r0,r4
	add r2,r2,r5
	outchar r0, r2
	pop r0
	pop r4
	jmp AtualizaJogadores
;-------------------------




;------------------------- Colisões ------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
;-----------------------------------------------------------------------------
PosPush:
	; r2 linha
	; r3 caracter
	; r0 
	; r6
	loadn r4, #0
	cmp r4,r6
	jeq ColisaoSubTerreno
	add r1,r1,r5  ; Colisão para Baixo e Direita, em que se deve somar da posição atual
	loadn r0,#40
	div r2,r1,r0 ; Linha
	mul r3,r2,r0 ; Caracteres
	call VerificaLinha
	loadi r5, r2 ; Passa o index da string da linha
	push r1
	inc r1

LoopColi:
	dec r1
	inc r4
	cmp r3,r1
	jne LoopColi
	dec r4
	pop r1
	add r2,r2,r4
	loadi r5,r2 ; Passa o index da string da linha
	loadn r0, #48 ; Correspondente de 0 na tabela ASCII
	cmp r0,r5
	jne Deny
	jmp ColisaoPlayers
	
ColisaoSubTerreno: ; Colisão para Cima e Esquerda, em que se deve subtrair da posição atual
	sub r1,r1,r5
	loadn r0,#40
	div r2,r1,r0 ; Linha
	mul r3,r2,r0 ; Caracteres
	call VerificaLinha
	loadi r5, r2 ; Passa o index da string da linha
	push r1
	inc r1

LoopColi2:
	dec r1
	inc r4
	cmp r3,r1
	jne LoopColi
	dec r4
	pop r1
	add r2,r2,r4
	loadi r5,r2 ; Passa o index da string da linha
	loadn r0, #48 ; Correspondente de 0 na tabela ASCII
	cmp r0,r5
	jne Deny
	
	
;////////////////////////////////////////////////Colisão entre jogadores
ColisaoPlayers:
	;----- Colisão com o outro jogador ----
	cmp r1, r7 ; posicao do outro jogador
	jeq Deny ; Movimento negado
	;--------------------------------------

;///////////////////////////////////////////////Colisão com as Bombas
	
	
	loadn r3, #0
LoopColisaoBombas:
	loadn r0, #Bombs
	loadi r4, r0
	add r0,r0,r3
	loadi r4, r0
	cmp r4,r1
	jeq Deny
	inc r3
	loadn r2, #12 ; Codição de Parada
	cmp r3,r2
	jne LoopColisaoBombas

	jmp PopAll ; Sucesso, pode andar

PushAll: ; Para o player 1
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	mov r7, r2 ; Posicao do Player 2
	jmp PosPush
	
PushAll2: ; Para o player 2
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6
	push r7
	mov r7, r1 ; Posicao do player 1
	mov r1, r2 ; Passa a posicao do Player 2 para o registrador r1
	jmp PosPush
	
Deny:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	pop r3 ; Retira o rts para "VerificaObstaculo" da pilha
	pop r3 ; Entrou antes do call
	jmp AtualizaJogadores
	

PopAll:
	pop r7
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------

VerificaLinha:
		loadn r0,#1
		cmp r0,r2
		jeq EndLinha1
		inc r0
		cmp r0,r2
		jeq EndLinha2
		inc r0
		cmp r0,r2
		jeq EndLinha3
		inc r0
		cmp r0,r2
		jeq EndLinha4
		inc r0
		cmp r0,r2
		jeq EndLinha5
		inc r0
		cmp r0,r2
		jeq EndLinha6
		inc r0
		cmp r0,r2
		jeq EndLinha7
		inc r0
		cmp r0,r2
		jeq EndLinha8
		inc r0
		cmp r0,r2
		jeq EndLinha9
		inc r0
		cmp r0,r2
		jeq EndLinha10
		inc r0
		cmp r0,r2
		jeq EndLinha11
		inc r0
		cmp r0,r2
		jeq EndLinha12
		inc r0
		cmp r0,r2
		jeq EndLinha13
		inc r0
		cmp r0,r2
		jeq EndLinha14
		inc r0
		cmp r0,r2
		jeq EndLinha15
		inc r0
		cmp r0,r2
		jeq EndLinha16
		inc r0
		cmp r0,r2
		jeq EndLinha17
		inc r0
		cmp r0,r2
		jeq EndLinha18
		inc r0
		cmp r0,r2
		jeq EndLinha19
		inc r0
		cmp r0,r2
		jeq EndLinha20
        inc r0
        cmp r0,r2
        jeq EndLinha21
        inc r0
        cmp r0,r2
        jeq EndLinha22
        inc r0
        cmp r0,r2
        jeq EndLinha23
        inc r0
        cmp r0,r2
        jeq EndLinha24
        inc r0
        cmp r0,r2
        jeq EndLinha25
        inc r0
        cmp r0,r2
        jeq EndLinha26
        inc r0
        cmp r0,r2
        jeq EndLinha27
        inc r0
        cmp r0,r2
        jeq EndLinha28
        inc r0
        cmp r0,r2
        jeq EndLinha29

;---------------------------------------------------------------------

EndLinha1:
        loadn r2, #linha2
        rts
EndLinha2:
        loadn r2, #linha3
        rts
EndLinha3:
        loadn r2, #linha4
        rts
EndLinha4:
        loadn r2, #linha5
        rts
EndLinha5:
        loadn r2, #linha6
        rts
EndLinha6:
        loadn r2, #linha7
        rts
EndLinha7:
        loadn r2, #linha8
        rts
EndLinha8:
        loadn r2, #linha9
        rts
EndLinha9:
        loadn r2, #linha10
        rts
EndLinha10:
        loadn r2, #linha11
        rts
EndLinha11:
        loadn r2, #linha12
        rts
EndLinha12:
        loadn r2, #linha13
        rts
EndLinha13:
        loadn r2, #linha14
        rts
EndLinha14:
        loadn r2, #linha15
        rts
EndLinha15:
        loadn r2, #linha16
        rts
EndLinha16:
        loadn r2, #linha17
        rts
EndLinha17:
        loadn r2, #linha18
        rts
EndLinha18:
        loadn r2, #linha19
        rts
EndLinha19:
        loadn r2, #linha20
        rts
EndLinha20:
        loadn r2, #linha21
        rts
EndLinha21:
        loadn r2, #linha22
        rts
EndLinha22:
        loadn r2, #linha23
        rts
EndLinha23:
        loadn r2, #linha24
        rts
EndLinha24:
        loadn r2, #linha25
        rts
EndLinha25:
        loadn r2, #linha26
        rts
EndLinha26:
        loadn r2, #linha27
        rts
EndLinha27:
        loadn r2, #linha28
        rts
EndLinha28:
        loadn r2, #linha29
        rts
EndLinha29:
        loadn r2, #linha30
        rts







;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------







































;---------------------- PRINTA MAPA -----------------------------
;ALGORITMO PARA DESENHAR NA TELA
;CADA POSIÇÃO DA TELA REPRESENTA UM "PIXEL" QUE PODE SER COLORIDO DE QUALQUER  COR
;DECLARAÇÃO DE VARIÁVEIS
;Cada string representa uma linha da tela e é composta de números que são associados à uma determinada cor
;É possível usar até dez cores associadas aos números [0;9]
;Para espaços em cor preta, substituir o número por um espaço
;É possível usar letras no lugar dos números para imprimílos com fundo preto
	linha1 :  string "1111111111111111111111111111111111111111"
	linha2 :  string "1000000000000000000000000000000000000001"
	linha3 :  string "1000000000000000000000000000000000000001"
	linha4 :  string "1111111111111111111111111111111111111111"
	linha5 :  string "1000000000000000000000000000000000000001"
	linha6 :  string "1002202202202202202202202202202202202201"
	linha7 :  string "1002202202202202202202202202202202202201"
	linha8 :  string "1000000000000000000000000000000000000001"
	linha9 :  string "1002202202202202202202202202202202202201"
	linha10 : string "1002202202202202202202202202202202202201"
	linha11 : string "1000000000000000000000000000000000000001"
	linha12 : string "1002202202202202202202202202202202202201"
	linha13 : string "1002202202202202202202202202202202202201"
	linha14 : string "1000000000000000000000000000000000000001"
	linha15 : string "1002202202202202202202202202202202202201"
	linha16 : string "1002202202202202202202202202202202202201"
	linha17 : string "1000000000000000000000000000000000000001"
	linha18 : string "1002202202202202202202202202202202202201"
	linha19 : string "1002202202202202202202202202202202202201"
	linha20 : string "1000000000000000000000000000000000000001"
	linha21 : string "1002202202202202202202202202202202202201"
	linha22 : string "1002202202202202202202202202202202202201"
	linha23 : string "1000000000000000000000000000000000000001"
	linha24 : string "1002202202202202202202202202202202202201"
	linha25 : string "1002202202202202202202202202202202202201"
	linha26 : string "1000000000000000000000000000000000000001"
	linha27 : string "1002202202202202202202202202202202202201"
	linha28 : string "1002202202202202202202202202202202202201"
	linha29 : string "1000000000000000000000000000000000000001"
	linha30 : string "1111111111111111111111111111111111111111"

 		;linha1 :  string "0000000000000000000000000000000000000000"		; String da linha 1 
	 	;linha2 :  string "9999999999999999999999999999999999999999"		; String da linha 2
	 	;linha3 :  string "9000000000000000000000000000000000000009"		; String da linha 3
	 	;linha4 :  string "9099999999999999999099999999999999999909"		; String da linha 4
	 	;linha5 :  string "9090000000000000000000000000000000000909"		; String da linha 5
	 	;linha6 :  string "9090999999999999999099999999999999990909"		; String da linha 6
	 	;linha7 :  string "9090900000000000000000000000000000090909"		; String da linha 7
	 	;linha8 :  string "9090900000000000000000000000000000090909"		; String da linha 8
	 	;linha9 :  string "9090909999999999999999999999999999090909"		; String da linha 9
		;linha10 : string "9090000000000000000000000000000000000909"		; String da linha 10
		;linha11 : string "9090900000000000000000000000000000090909"		; String da linha 11
		;linha12 : string "9090000000000000000000000000000000000909"		; String da linha 12
		;linha13 : string "9090000000000000000000000000000000000909"		; String da linha 13
		;linha14 : string "9090000000000000000000000000000000000909"		; String da linha 14
		;linha15 : string "9090000000000000000000000000000000000909"		; String da linha 15
		;linha16 : string "9000000000000000000000000000000000000009"		; String da linha 16
		;linha17 : string "9090000000000000000000000000000000000909"		; String da linha 17
		;linha18 : string "9090000000000000000000000000000000000909"		; String da linha 18
		;linha19 : string "9090000000000000000000000000000000000909"		; String da linha 19
		;linha20 : string "9090000000000000000000000000000000000909"		; String da linha 20
		;linha21 : string "9090900000000000000000000000000000090909"		; String da linha 21
		;linha22 : string "9090000000000000000000000000000000000909"		; String da linha 22
		;linha23 : string "9090909999999999999999999999999999090909"		; String da linha 23
		;linha24 : string "9090900000000000000000000000000000090909"		; String da linha 24
		;linha25 : string "9090900000000000000000000000000000090909"		; String da linha 25
		;linha26 : string "9090999999999999999099999999999999990909"		; String da linha 26
		;linha27 : string "9090000000000000000000000000000000000909"		; String da linha 27
		;linha28 : string "9099999999999999999099999999999999999909"		; String da linha 28
		;linha29 : string "9000000000000000000000000000000000000009"		; String da linha 29
		;linha30 : string "9999999999999999999999999999999999999999"		; String da linha 30

telaInicial:
	
	loadn r1, #0			; Começa a printar na posição 1
	
;1° LINHA
	loadn r0, #linha1		; Carrega em r0 a string que representa a linha 1
	loadn r4, #40			; Parada do print para a primeira linha
	call ImprimeLinha
	
;2° LINHA
	loadn r0, #linha2		; Impressão da primeria linha
	loadn r4, #80			; Parada do print
	call ImprimeLinha
	

;3° LINHA
	loadn r0, #linha3		; Impressão da primeria linha
	loadn r4, #120			; Parada do print
	call ImprimeLinha
	
	
;4° LINHA
	loadn r0, #linha4		; Impressão da primeria linha
	loadn r4, #160			; Parada do print
	call ImprimeLinha
	
;5° LINHA
	loadn r0, #linha5		; Impressão da primeria linha
	loadn r4, #200			; Parada do print
	call ImprimeLinha
	
;6° LINHA
	loadn r0, #linha6		; Impressão da primeria linha
	loadn r4, #240			; Parada do print
	call ImprimeLinha
	
;7° LINHA
	loadn r0, #linha7		; Impressão da primeria linha
	loadn r4, #280			; Parada do print
	call ImprimeLinha
	
;8° LINHA
	loadn r0, #linha8		; Impressão da primeria linha
	loadn r4, #320			; Parada do print
	call ImprimeLinha
	
;9° LINHA
	loadn r0, #linha9		; Impressão da primeria linha
	loadn r4, #360			; Parada do print
	call ImprimeLinha
	
;10° LINHA
	loadn r0, #linha10		; Impressão da primeria linha
	loadn r4, #400			; Parada do print
	call ImprimeLinha
	
;11° LINHA
	loadn r0, #linha11		; Impressão da primeria linha
	loadn r4, #440			; Parada do print
	call ImprimeLinha
	
;12° LINHA
	loadn r0, #linha12		; Impressão da primeria linha
	loadn r4, #480			; Parada do print
	call ImprimeLinha
	
;13° LINHA
	loadn r0, #linha13		; Impressão da primeria linha
	loadn r4, #520			; Parada do print
	call ImprimeLinha
	
;14° LINHA
	loadn r0, #linha14		; Impressão da primeria linha
	loadn r4, #560			; Parada do print
	call ImprimeLinha
	
;15° LINHA
	loadn r0, #linha15		; Impressão da primeria linha
	loadn r4, #600			; Parada do print
	call ImprimeLinha
	
;16° LINHA
	loadn r0, #linha16		; Impressão da primeria linha
	loadn r4, #640			; Parada do print
	call ImprimeLinha
	
;17° LINHA
	loadn r0, #linha17		; Impressão da primeria linha
	loadn r4, #680			; Parada do print
	call ImprimeLinha
	
;18° LINHA
	loadn r0, #linha18		; Impressão da primeria linha
	loadn r4, #720			; Parada do print
	call ImprimeLinha
	
;19° LINHA
	loadn r0, #linha19		; Impressão da primeria linha
	loadn r4, #760			; Parada do print
	call ImprimeLinha
	
;20° LINHA
	loadn r0, #linha20		; Impressão da primeria linha
	loadn r4, #800			; Parada do print
	call ImprimeLinha
	
;21° LINHA
	loadn r0, #linha21		; Impressão da primeria linha
	loadn r4, #840			; Parada do print
	call ImprimeLinha
	
;22° LINHA
	loadn r0, #linha22		; Impressão da primeria linha
	loadn r4, #880			; Parada do print
	call ImprimeLinha
	
;23° LINHA
	loadn r0, #linha23		; Impressão da primeria linha
	loadn r4, #920			; Parada do print
	call ImprimeLinha
	
;24° LINHA
	loadn r0, #linha24		; Impressão da primeria linha
	loadn r4, #960			; Parada do print
	call ImprimeLinha
	
;25° LINHA
	loadn r0, #linha25		; Impressão da primeria linha
	loadn r4, #1000			; Parada do print
	call ImprimeLinha
	
;26° LINHA
	loadn r0, #linha26		; Impressão da primeria linha
	loadn r4, #1040			; Parada do print
	call ImprimeLinha
	
;27° LINHA
	loadn r0, #linha27		; Impressão da primeria linha
	loadn r4, #1080			; Parada do print
	call ImprimeLinha
	
;28° LINHA
	loadn r0, #linha28		; Impressão da primeria linha
	loadn r4, #1120			; Parada do print
	call ImprimeLinha
	
;29° LINHA
	loadn r0, #linha29		; Impressão da primeria linha
	loadn r4, #1160			; Parada do print
	call ImprimeLinha
	
;30° LINHA
	loadn r0, #linha30		; Impressão da primeria linha
	loadn r4, #1200			; Parada do print
	call ImprimeLinha
	jmp main






	
ImprimeLinha:
	loadn r5, #125
	loadi r3, r0
	cmp r1, r4
	jeq ImprimeLinha_Sai
	
	loadn r5, #125
	loadn r2, #48
	cmp r2, r3
	jeq Imprime_Cor0
	
	loadn r5, #125
	loadn r2, #49
	cmp r2, r3
	jeq Imprime_Cor1
	
	loadn r5, #125
	loadn r2, #50
	cmp r2, r3
	jeq Imprime_Cor2
	
	loadn r5, #125
	loadn r2, #51
	cmp r2, r3
	jeq Imprime_Cor3
	
	loadn r5, #125
	loadn r2, #52
	cmp r2, r3
	jeq Imprime_Cor4
	
	loadn r5, #125
	loadn r2, #53
	cmp r2, r3
	jeq Imprime_Cor5
	
	loadn r5, #125
	loadn r2, #54
	cmp r2, r3
	jeq Imprime_Cor6
	
	loadn r5, #125
	loadn r2, #55
	cmp r2, r3
	jeq Imprime_Cor7
	
	loadn r5, #125
	loadn r2, #56
	cmp r2, r3
	jeq Imprime_Cor8
	
	loadn r5, #125
	loadn r2, #57
	cmp r2, r3
	jeq Imprime_Cor9
	
	jmp Imprime_Letra
	
Loop:
	inc r1
	inc r0
	jmp ImprimeLinha

Imprime_Cor0:
	;loadn r7, #2048
	;add r6, r5, r7
	;outchar r6, r1
	jmp Loop
	
Imprime_Cor1:
	loadn r7, #2304
	add r6, r5, r7
	outchar r6, r1
	jmp Loop
	
Imprime_Cor2:
	loadn r7, #512
	add r6, r5, r7
	outchar r6, r1
	jmp Loop

Imprime_Cor3:
	loadn r7, #1280
	add r6, r5, r7
	outchar r6, r1
	jmp Loop

Imprime_Cor4:
	loadn r7, #3584
	add r6, r5, r7
	outchar r6, r1
	jmp Loop

Imprime_Cor5:
	loadn r7, #3584
	add r6, r5, r7
	outchar r6, r1
	jmp Loop
	
Imprime_Cor6:
	loadn r7, #3584
	add r6, r5, r7
	outchar r6, r1
	jmp Loop
	
Imprime_Cor7:
	loadn r7, #3584
	add r6, r5, r7
	outchar r6, r1
	jmp Loop

Imprime_Cor8:
	loadn r7, #3584
	add r6, r5, r7
	outchar r6, r1
	jmp Loop

Imprime_Cor9:
	loadn r7, #2048
	add r6, r5, r7
	outchar r6, r1
	jmp Loop
	
Imprime_Letra:	
	loadn r7, #0
	add r6, r5, r7
	outchar r6, r1
	jmp Loop

ImprimeLinha_Sai:
	rts
;------------------------------------------------------


