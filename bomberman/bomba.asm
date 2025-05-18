bombaPosition : var #1

bomba : var #16
  static bomba + #0, #5 ; 
  ;10  espacos para o proximo caractere
  static bomba + #1, #5 ; 
  ;30  espacos para o proximo caractere
  static bomba + #2, #5 ; 
  ;9  espacos para o proximo caractere
  static bomba + #3, #5 ; 
  static bomba + #4, #5 ; 
  ;30  espacos para o proximo caractere
  static bomba + #5, #5 ; 
  ;5  espacos para o proximo caractere
  static bomba + #6, #5 ; 
  ;5  espacos para o proximo caractere
  static bomba + #7, #5 ; 
  static bomba + #8, #5 ; 
  ;29  espacos para o proximo caractere
  static bomba + #9, #5 ; 
  static bomba + #10, #5 ; 
  static bomba + #11, #5 ; 
  ;3  espacos para o proximo caractere
  static bomba + #12, #5 ; 
  static bomba + #13, #5 ; 
  ;35  espacos para o proximo caractere
  static bomba + #14, #5 ; 
  static bomba + #15, #5 ; 

bombaGaps : var #16
  static bombaGaps + #0, #0
  static bombaGaps + #1, #9
  static bombaGaps + #2, #29
  static bombaGaps + #3, #8
  static bombaGaps + #4, #0
  static bombaGaps + #5, #29
  static bombaGaps + #6, #4
  static bombaGaps + #7, #4
  static bombaGaps + #8, #0
  static bombaGaps + #9, #28
  static bombaGaps + #10, #0
  static bombaGaps + #11, #0
  static bombaGaps + #12, #2
  static bombaGaps + #13, #0
  static bombaGaps + #14, #34
  static bombaGaps + #15, #0

printbomba:
  push R0
  push R1
  push R2
  push R3
  push R4
  push R5
  push R6

  loadn R0, #bomba
  loadn R1, #bombaGaps
  load R2, bombaPosition
  loadn R3, #16 ;tamanho bomba
  loadn R4, #0 ;incremetador

  printbombaLoop:
    add R5,R0,R4
    loadi R5, R5

    add R6,R1,R4
    loadi R6, R6

    add R2, R2, R6

    outchar R5, R2

    inc R2
     inc R4
     cmp R3, R4
    jne printbombaLoop

  pop R6
  pop R5
  pop R4
  pop R3
  pop R2
  pop R1
  pop R0
  rts

apagarbomba:
  push R0
  push R1
  push R2
  push R3
  push R4
  push R5

  loadn R0, #3967
  loadn R1, #bombaGaps
  load R2, bombaPosition
  loadn R3, #16 ;tamanho bomba
  loadn R4, #0 ;incremetador

  apagarbombaLoop:
    add R5,R1,R4
    loadi R5, R5

    add R2,R2,R5
    outchar R0, R2

    inc R2
     inc R4
     cmp R3, R4
    jne apagarbombaLoop

  pop R5
  pop R4
  pop R3
  pop R2
  pop R1
  pop R0
  rts
