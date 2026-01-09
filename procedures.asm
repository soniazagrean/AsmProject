; procedures module

; importam variabilele din main
extrn octet_array:byte, actual_len:word, word_c:word
extrn max_bit_pos:byte, buffer:byte, msg_space:byte

; facem functiile vizibile pentru main
public parse_input, calc_word_c, sort_desc, find_max_bits

code segment
assume cs:code

; parse_input
parse_input proc
    lea si, buffer+2      ; pointer la inceputul sirului introdus
    lea di, octet_array   ; desc in memorie
    xor cx, cx            ; contor pt nr de octeti

next_octet:
    xor ax, ax            ; reset ax pt noul octet
    xor bx, bx            ; in bx construim valoarea

skip_spaces:
    mov al,[si]
    cmp al, 0dh           ; verificam daca e 'enter'
    je done_parsing
    cmp al, ' '           ; sarim peste spatii
    jne get_first_nibble
    inc si
    jmp skip_spaces

get_first_nibble:
    call hex_to_nibble    ; convertim primul caracter ascii in valoare numerica
    mov bl, al            ; salvam prima cifra
    inc si 

    mov al, [si]          ; inspectam caracterul curent pentru a decide tipul de input
    cmp al, ' '
    je store_byte         ; valoarea ramane in partea low
    cmp al, 0dh           ; verificam daca am ajuns la sfarsitul sirului
    je store_byte         ; daca da, salvam cifra curenta ca fiind ultimul octet

    shl bl, 4             ; prima cifra ramane in partea high
    call hex_to_nibble    ; convertim al doilea caracter ascii in valoare numerica
    or  bl, al            ; combinam cele doua cifre intr-un singur octet
    inc si                ; trecem la urmatorul caracter din buffer

store_byte:
    mov [di], bl          ; salvam in array octetul rezultat
    inc di                ; incrementam indexul in array
    inc cx                ; incrementam numarul de elemente citite
    cmp cx, 16            ; verificam limita maxima de 16 elemente
    je done_parsing
    jmp next_octet        ; continuam procesarea pentru restul sirului

done_parsing:
    mov actual_len, cx    ; salvam numarul total de octeti procesati
    ret
parse_input endp

hex_to_nibble proc
    cmp al, '0'           ; verificare limita inferioara cifre
    jb b_err
    cmp al, '9'           ; verificare daca este cifra 0-9
    jbe dig
    and al, 0dfh          ; transformam in litera mare daca este cazul
    sub al, 7             ; ajustare pentru literele a-f
dig: sub al, '0'          ; conversie finala din ascii in valoare
    ret
b_err: xor al, al         ; in caz de eroare returnam zero
    ret
hex_to_nibble endp

; calc_word_c
calc_word_c proc
    ; extragem primul nibble din primul octet si ultimul nibble din ultimul octet
    mov al, octet_array[0]
    shr al, 4             ; aducem partea high pe pozitia low
    mov si, actual_len
    dec si
    mov bl, octet_array[si]
    and bl, 0fh           ; izolam partea low
    xor al, bl            ; aplicam operatia xor conform cerintei
    and al, 0fh
    mov bl, al            ; rezultatul partial in bl

    xor al, al            ; reset al pentru operatia or
    lea si, octet_array
    mov cx, actual_len
or_l:
    mov dl, [si]
    shr dl, 2             ; shiftare dreapta cu 2 pozitii
    and dl, 0fh
    or al, dl
    inc si
    loop or_l
    shl al, 4             ; mutam rezultatul or pe pozitia high nibble
    or bl, al             ; combinam cu rezultatul anterior

    xor al, al 
    lea si, octet_array
    mov cx, actual_len
sum_l: add al, [si]       ; adunare repetata pentru suma modulo 256
    inc si
    loop sum_l
    
    mov ah, al            ; suma merge in partea high a word-ului
    mov al, bl            ; rezultatele merg in partea low
    mov word_c, ax        ; salvam cuvantul de control final
    ret
calc_word_c endp

; sort_desc
sort_desc proc
    mov cx, actual_len
    dec cx                ; setam numarul de pasi pentru bubble sort
    jz s_done
outer:
    push cx
    lea si, octet_array
inner:
    mov al, [si]
    cmp al, [si+1]        ; comparam elementele vecine
    jae no_swap           ; daca ordinea e corecta, nu facem nimic
    xchg al, [si+1]       ; interschimbare valori, sortare descrescatoare
    mov [si], al
no_swap: inc si
    loop inner
    pop cx
    loop outer
s_done: ret
sort_desc endp

; find_max_bits
find_max_bits proc
    xor dx, dx            ; dh va fi pozitia curenta, dl va fi numarul maxim de biti
    mov max_bit_pos, 0ffh ; valoare default daca nu a fost gasit
    mov cx, actual_len
    lea si, octet_array
f_loop:
    push cx
    mov al, [si]
    xor bl, bl            ; contor pentru bitii de 1 ai octetului curent
    mov cx, 8
b_cnt: shr al, 1          ; extragem bitul cel mai putin semnificativ in carry
    adc bl, 0             ; adunam carry la contor
    loop b_cnt
    cmp bl, 3             ; verificam conditia: mai mult de 3 biti de 1
    jbe f_next
    cmp bl, dl            ; comparam cu maximul gasit anterior
    jbe f_next
    mov dl, bl            ; actualizam maximul
    mov max_bit_pos, dh   ; retinem pozitia curenta
f_next: inc si
    inc dh                ; avansam la urmatoarea pozitie
    pop cx
    loop f_loop
    ret
find_max_bits endp

; rotation
rotation proc
    lea si, octet_array
    mov cx, actual_len
rot_l:
    push cx
    mov al, [si]
    mov bl, al
    and bl, 03h           ; determinam numarul de rotatii, ultimii 2 biti
    mov cl, bl            ; mutam in cl pentru instructiunea rol
    rol al, cl            ; rotire ciclica la stanga
    mov [si], al          ; salvam valoarea modificata inapoi in array
    inc si
    pop cx
    loop rot_l
    ret
rotation endp

code ends
end