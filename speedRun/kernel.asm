org 0x7e00
jmp 0x0000:Titulo

; VARIAVEIS USADAS NO KERNEL
data:

  ;SEED ALEATORIA
    random_seed dd 0

  ;SAVE NUMBER
    save dd 0

  ;TITULO
    nomeDoGame dw '              BETRACHTUNG', 0
    press dw      '     pressione enter para continuar!', 0

  ;MENU
    comandos dw 'C --- Para ver como jogar', 0
    creditos dw 'M --- Para ver os creditos', 0
    jogar dw 'P --- Para jogar ', 0

  ;COMO JOGAR
    comoJogar1 dw 'Este e um jogo de velocidade', 0
    comoJogar2 dw 'A tela ira passar de vermelho para verde', 0
    comoJogar3 dw 'Voce comecara com', 0
    comoJogar4 dw ' 10000', 0
    comoJogar5 dw ' pontos', 0
    comoJogar6 dw 'Quanto mais rapido voce apertar ', 0
    comoJogar7 dw 'ESPACO',0
    comoJogar8 dw 'mais pontos tera no fim.', 0

  ;CREDITOS
    credito1 dw 'Desenvolvido para a cadeira de:  ', 0
    credito2 dw '      INFRAESTRUTURA DE SOFTWARE', 0
    credito3 dw 'Discentes envolvidos: ', 0
    credito4 dw 'Emanoel Thyago Cordeiro dos Santos-', 0
    credito5 dw 'etcs', 0
    credito6 dw 'Pericles Ferreira Sardinha - ', 0
    credito7 dw 'pfs', 0
    credito8 dw 'Rafael Ramos B Corcino - ', 0
    credito9 dw 'rrbc', 0
    creditoR dw '            Enter para retornar ao Menu', 0

  ;EM GAME
    num dw 0
    contador dw 0x2710
    jogo1 dw '                    ESPERE', 0
    jogo2 dw '                     AGORA', 0 
    jogo3 dw '                         SUA PONTUACAO FOI DE: ', 0
    lento dw '                                 Voce tentou?', 0
      
;FUNÇÕES USADAS
clear_buffer:
    xor ah, ah      ; função 0Ah da interrupção 16h
    mov al, 0       ; limpa o buffer do teclado
    int 16h         ; chama a interrupção
    ret

; gera um número aleatório entre min_val e max_val
generate_random_number:
  mov eax, [random_seed]    ; carrega a seed em eax
  imul eax, 1103515247      ; multiplica a seed por uma constante grande
  add eax, 12349           ; adiciona uma constante
  mov [random_seed], eax    ; salva a nova seed
  mov ebx, 7                ; define o limite
  xor edx, edx              ; limpa edx (resto)
  div ebx                   ; divide eax por 7, o resto vai pra edx
  inc edx                   ; adiciona 1 no resto para obter o random
  mov eax, edx              ;salva o random em eax
  ret

;Dado da imagem em SI para printar
printImagem:
  xor ax, ax
  mov ds, ax
  mov cx, ax
  mov es, ax
  mov dx, ax
	mov dx, 10            ; Y
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0        ; X
	.for2:
		cmp cl, byte[bx]
		je .endfor2
		lodsb
		push dx
		push cx
		mov ah, 0ch
		add dx, 2
		add cx, 2
		int 10h
		pop cx
		pop dx
		inc cx
		jmp .for2
	.endfor2:
		inc dx
		jmp .for1
	.endfor1:
  ret


Print_Decimal:
  ; converte o valor de hexadecimal para decimal
  xor bl, bl   ;contador de digitos
  mov cx, 0x2710; cx é o divisor (inicialmente 10000)

  convert_loop:
    xor dx, dx      ; zera dx
    div cx          ; AX = AX/CX    (RESULTADO EM AX E RESTO EM DX)
    ;mov al, ah      ; caractere a ser exibido vai pra al
    add al, 30h     ; converte o valor do dígito em ASCII
    mov ah, 0x0e    ; função da interrupção de software 21h para exibir um caractere
    push bx         ; empilha o valor dos 3 registradores do 'B'
    mov bl, 15      ; cor da fonte para branco
    int 10h         ; interrupção de software para exibir o caractere
    pop bx          ; desempilha o valor dos 3 registradores do 'B'
    inc bl          ; incrementa o contador
    mov ax, dx      ; passa pra ax o valor do resto
    cmp bl, 1
    je milhar
    cmp bl, 2
    je centena
    cmp bl, 3
    je dezena
    cmp bl, 4
    je unidade
    jmp end1

    milhar:
        mov cx, 0x3e8
        jmp convert_loop

    centena:
        mov cx, 0x64
        jmp convert_loop

    dezena:
        mov cx, 0xa
        jmp convert_loop

    unidade:
        mov cx, 0x1
        jmp convert_loop

  ; finaliza o programa
  end1:
    ret
  

putchar:    ;Printa um caractere na tela, pega o valor salvo em al
  mov ah, 0x0e
  int 10h
  ret
  
getchar:    ;Pega o caractere lido no teclado e salva em al
  mov ah, 0x00
  int 16h
  ret
  
endl:       ;Pula uma linha, printando na tela o caractere que representa o (/n)
  mov al, 0x0a          ; line feed
  call putchar
  mov al, 0x0d          ; carriage return
  call putchar
  ret

delay1s:                 ; 1 SEC DELAY
  mov cx, 0fh
  mov dx, 4240h
  mov ah, 86h
  int 15h
  ret

delay100ms:              ; 0.1 SEC DELAY
  mov cx, 01h
  mov dx, 86a0h
  mov ah, 86h
  int 15h
  ret

Espacamento:
  loop_Espaco:
    call endl       ; Pula uma linha
    dec bh         ; Decrementa bh em um
    cmp bh, 0    ; Compara bh com zero
    je exit_loop    ; Se zerar vai pro final
    jmp loop_Espaco ; Caso contrário loop novamente
  exit_loop:
    ret         ; Retorna pro ponto de chamada

prints:             ; mov si, string
  .loop:
    lodsb           ; bota character apontado por si em al 
    cmp al, 0       ; 0 é o valor atribuido ao final de uma string
    je .endloop     ; Se for o final da string, acaba o loop
    call putchar    ; printa o caractere
    jmp .loop       ; volta para o inicio do loop
  .endloop:
  ret

clear:                   ; mov bl, color
  ; set the cursor to top left-most corner of screen
  mov dx, 0 
  mov bh, 0      
  mov ah, 0x2
  int 10h

  ; print 2000 blank chars to clean  
  mov cx, 2000 
  mov bh, 0
  mov al, 0x20 ; blank char
  mov ah, 0x9
  int 10h
  
  ; reset cursor to top left-most corner of screen
  mov dx, 0 
  mov bh, 0      
  mov ah, 0x2
  int 10h
  ret

esperaOenter:
  mov ah, 0   ; configura o modo de leitura de teclado sem ecoar a tecla pressionada
  int 0x16    ; le a entrada do teclado
  cmp al, 0x0D ; compara com o valor ASCII da tecla "Enter"
  jne esperaOenter ; se não for "Enter", volta a aguardar

  ; Limpa o buffer do teclado
  ret
  
print_word:
  push bx             ; salva a base na pilha
  xor cx, cx          ; zera o contador
  mov si, 10          ; carrega o divisor
  div_loop:
    xor dx, dx      ; zera o registro DX
    div si          ; divide DX:AX pelo divisor
    add dl, '0'     ; converte o resto em um caractere ASCII
    push dx         ; salva o caractere na pilha
    inc cx          ; incrementa o contador
    cmp ax, 0       ; verifica se a divisão já foi concluída
    jne div_loop    ; se não, repete o loop
  print_loop:
    pop dx          ; carrega o próximo caractere da pilha
    mov ah, 0x0e    ; função para imprimir caractere na tela
    int 0x10        ; chama a interrupção para imprimir o caractere
    loop print_loop ; repete o loop enquanto ainda houver caracteres na pilha
  pop bx              ; restaura a base da pilha
  ret


;TELA DE TITULO
Titulo:
  ;DEFININDO O MODO DE VIDEO
  mov ah, 0
  mov al, 13h
  int 10h

  call clear
  mov bl, 4 ; ESCOLHE A COR DA LETRA A SER PRINTADA
  int 10h  ; CHAMA A INTERRUPÇÃO PARA TROCAR A COR
  
  mov bh, 8 ;numero de espaços
  call Espacamento ;pulanndo 8 espaços

  mov si, nomeDoGame
  call prints
  mov bh, 7 ;numero de espaços
  call Espacamento ;pulanndo 7 espaços

  mov si, press
  call prints
  call endl
  ;mov si, blue_flag 
  ;call printImagem
  call esperaOenter
  call menu

;TELA DO MENU
menu: 
  call clear
  call endl
  call endl
  mov bl, 4
  int 10h
  mov si, nomeDoGame
  call prints
  mov bh, 7 ;numero de espaços
  call Espacamento ; pulando 7 espaços
  mov bl, 1
  int 10h
  mov si, jogar
  call prints
  mov bh, 4 ;numero de espaços
  call Espacamento ;pulando 4 espaços
  mov si, comandos
  call prints
  mov bh, 4 ;numero de espaços
  call Espacamento ;pulando 4 espaços
  mov si, creditos
  call prints
  leituraMenu:
    call getchar
    cmp al, 0x70
    je play
    cmp al, 0x63
    je comando
    cmp al, 0x6d
    je credito
    jmp leituraMenu

;TELA DO JOGO
play:
  teladeJogo:
    call clear
    mov ah, 0 
    mov al, 12h
    int 10h ;setando modo gráfico
      
    mov ah,0xb
    mov bh, 0
    mov bl, 4 ; COR DO FUNDO DE TELA (VERMELHO)
    int 10h ; 

    mov bh, 12 ;numero de espaços
    call Espacamento ;pulanndo 12 espaços
    mov bl, 15
    int 10h
    mov si, jogo1
    call prints
    
    call generate_random_number ;random em ax
    mov bl, al
  loop_delay:
    call delay1s
    dec bl
    cmp bl, 0
    jle continue
    jmp loop_delay
    
  continue: 
    call clear
    mov ah,0xb
    mov bh, 0
    mov bl, 2 ; COR DO FUNDO DE TELA (VERDE)
    int 10h ; 

    mov bh, 12 ;numero de espaços
    call Espacamento ;pulanndo 12 espaços
    mov bl, 15
    int 10h
    mov si, jogo2
    call prints

    ;DEFINE
    mov cx, 0
    mov dx, 0
    
  esperandoClique:

    in al, 0x64       ; Lê a porta do status do teclado
    test al, 0x01     ; Verifica se o bit 0 está definido (entrada disponível)
    jz sem_entrada    ; Se o bit 0 não estiver definido, saia sem ler entrada
    
    push cx 
    call getchar 	; USA: (A)
    cmp al, 0x20
    je pontoTotal

    sem_entrada:
      add dx, 1
      cmp dx, 65500
      ja umCiclo
      jmp esperandoClique	
    
    umCiclo:
      mov dx, 0
      add cx, 13
      cmp cx, 10000
      ja muitoLento
      jmp esperandoClique
  
  pontoTotal:
    call clear 		; USA: (A, B, C, D)
    mov ah, 0xb
    mov bh, 0
    mov bl, 1 		; COR DO FUNDO DE TELA (AZUL)
    int 10h ; 
    
    mov bh, 12 		; numero de espaços
    call Espacamento 	; pulando 2 espaços --  USA: (B)
    mov bl, 15 		; COR da letra
    int 10h
    mov si, jogo3
    call prints 	; USA: (A)
    
    ;CALCULANDO PONTUAÇÃO E EXIBINDO
    mov dx, 10000
    pop cx
    sub dx, cx
    mov ax, dx
    call Print_Decimal
    
    mov bh, 12 ;numero de espaços
    call Espacamento ;pulanndo 12 espaços

    mov bl, 15
    int 10h
    mov si, creditoR
    call prints


    call esperaOenter
    jmp Titulo
  
  muitoLento:
    call clear 		; USA: (A, B, C, D)
    mov ah, 0xb
    mov bh, 0
    mov bl, 6 		; COR DO FUNDO DE TELA (AZUL)
    int 10h ; 

    mov bh, 12 		; numero de espaços
    call Espacamento 	; pulando 2 espaços --  USA: (B)
    mov bl, 15 		; COR da letra
    int 10h
    mov si, lento
    call prints 	; USA: (A)

    mov bh, 12 ;numero de espaços
    call Espacamento ;pulanndo 12 espaços

    mov bl, 15
    int 10h
    mov si, creditoR
    call prints


    call esperaOenter
    jmp Titulo

;TELA DE COMANDOS
comando:
  call clear
  call endl
  mov bl, 15
  int 10h
  mov si, comoJogar1
  call prints
  mov bh, 2 ;numero de espaços
  call Espacamento ;pulanndo 2 espaços
  mov si, comoJogar2
  call prints
  call endl
  mov si, comoJogar3
  call prints
  mov bl, 4
  int 10h
  mov si, comoJogar4
  call prints
  mov bl, 15
  int 10h
  mov si, comoJogar5
  call prints
  mov bh, 2 ;numero de espaços
  call Espacamento ;pulanndo 2 espaços
  mov si, comoJogar6
  call prints 
  mov bl, 4
  int 10h
  mov si, comoJogar7
  call prints
  mov bl, 15
  int 10h
  call endl
  mov si, comoJogar8
  call prints
  mov bh, 14 ;numero de espaços
  call Espacamento ;pulanndo 14 espaços
  mov bl, 15
  int 10h
  mov si, creditoR
  call prints
  call esperaOenter
  jmp menu

;TELA DOS CREDITOS
credito:
  call clear
  call endl
  mov bl, 15
  int 10h
  mov si, credito1
  call prints
  call endl
  mov bl, 4
  int 10h
  mov si, credito2
  mov bh, 2 ;numero de espaços
  call Espacamento ;pulanndo 2 espaços
  call prints
  mov bh, 4 ;numero de espaços
  call Espacamento ;pulanndo 4 espaços
  int 10h
  mov si, credito3
  mov bl, 15
  int 10h
  call prints
  mov bh, 4 ;numero de espaços
  call Espacamento ;pulanndo 4 espaços
  mov si, credito4
  mov bl, 1
  call prints
  mov bl, 4
  int 10h
  mov si, credito5
  call prints
  mov bh, 2 ;numero de espaços
  call Espacamento ;pulanndo 2 espaços
  mov bl, 1
  int 10h
  mov si, credito6
  call prints
  mov bl, 4
  int 10h
  mov si, credito7
  call prints
  mov bh, 3 ;numero de espaços
  call Espacamento ;pulanndo 3 espaços
  mov bl, 1
  int 10h
  mov si, credito8
  call prints
  mov bl, 4
  int 10h
  mov si, credito9
  call prints
  mov bh, 5 ;numero de espaços
  call Espacamento ;pulanndo 5 espaços
  mov bl, 15
  int 10h
  mov si, creditoR
  call prints
  call esperaOenter
  jmp menu

.end:
  jmp done

done:
  jmp $
