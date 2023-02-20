org 0x7e00
jmp 0x0000:Titulo
; VARIAVEIS USADAS NO KERNEL
data:
  ;TITULO
    nomeDoGame dw '             BETRACHTUNG', 0
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
    credito2 dw 'INFRAESTRUTURA DE SOFTWARE', 0
    credito3 dw 'Discentes envolvidos: ', 0
    credito4 dw 'Emanoel Thyago Cordeiro dos Santos-', 0
    credito5 dw 'etcs', 0
    credito6 dw 'Pericles Ferreira Sardinha - ', 0
    credito7 dw 'pfs', 0
    credito8 dw 'Rafael Ramos B Cordeiro - ', 0
    credito9 dw 'rrbc', 0
    creditoR dw '            Enter para retornar ao Menu', 0

  ;EM GAME
    contador dw 1000
    jogo1 dw '                    ESPERE', 0
    jogo2 dw '                     AGORA', 0 
    jogo3 dw 'Sua pontuacao foi: ', 0
       
;FUNÇÕES USADAS 
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
  mov ah, 0      ; ALTERANDO A RESOLUÇÃO E TAMANHO DAS LETRAS
  mov al, 13h
  int 10h

  call clear
  mov bl, 4 ; ESCOLHE A COR DA LETRA A SER PRINTADA
  int 10h  ; CHAMA A INTERRUPÇÃO PARA TROCAR A COR
  
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl

  mov si, nomeDoGame
  call prints
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl

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
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  mov bl, 1
  int 10h
  mov si, jogar
  call prints
  call endl
  call endl
  call endl
  call endl
  mov si, comandos
  call prints
  call endl
  call endl
  call endl
  call endl
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

    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    mov bl, 15
    int 10h
    mov si, jogo1
    call prints

    call delay1s

    call clear
    mov ah,0xb
    mov bh, 0
    mov bl, 2 ; COR DO FUNDO DE TELA (VERDE)
    int 10h ; 

    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    call endl
    mov bl, 15
    int 10h
    mov si, jogo2
    call prints
    mov dx, contador
  esperandoClique:
    call delay100ms
    call getchar
    cmp al, 0x20
    je pontoTotal
    sub dx, 1
    jmp esperandoClique

  pontoTotal:
    call clear
    mov ah,0xb
    mov bh, 0
    mov bl, 1 ; COR DO FUNDO DE TELA (VERDE)
    int 10h ; 
    
    call endl
    call endl
    mov bl, 15 ; COR da letra
    int 10h ; 
    mov si, jogo3
    call prints
    mov si, dx
    call prints
   
    jmp done

;TELA DE COMANDOS
comando:
  call clear
  call endl
  mov bl, 15
  int 10h
  mov si, comoJogar1
  call prints
  call endl
  call endl
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
  call endl
  call endl
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
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
  call endl
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
  call endl
  call prints
  call endl
  call endl
  call endl
  call endl
  int 10h
  mov si, credito3
  mov bl, 15
  int 10h
  call prints
  call endl 
  call endl
  call endl
  call endl
  call endl
  mov si, credito4
  mov bl, 1
  call prints
  mov bl, 4
  int 10h
  mov si, credito5
  call prints
  call endl
  call endl
  mov bl, 1
  int 10h
  mov si, credito6
  call prints
  mov bl, 4
  int 10h
  mov si, credito7
  call prints
  call endl
  call endl
  call endl
  mov bl, 1
  int 10h
  mov si, credito8
  call prints
  mov bl, 4
  int 10h
  mov si, credito9
  call prints
  call endl
  call endl
  call endl
  call endl
  call endl
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

