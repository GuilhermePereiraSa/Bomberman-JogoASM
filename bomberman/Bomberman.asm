; Tela de Menu
; carrega tela de menu




;iniciar jogo quando apertado a tecla
; Jogo em si

INCHAR r1 ; ler tecla em R1

CMP r1, #SETARY ; compara com codigo de seta para cima
JEQ movCima ; se igual, salta para rot. de mover para cima

CMP r1, #BOMBA ; tecla de bomba
JEQ soltarBomba

JMP loopInicio ; volta para o inicio do loop



movCima:


; Fim do jogo