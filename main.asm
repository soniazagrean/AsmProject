; main module

; declaram functiile care se afla in celalalt modul
extrn parse_input:proc, calc_word_c:proc, sort_desc:proc
extrn find_max_bits:proc, rotation:proc

; declaram variabilele ca fiind publice pentru a fi vazute in celalalt modul
public msg_space, octet_array, actual_len, word_c, max_bit_pos, buffer

data segment
    msg_input db 13,10,'introduceti octetii in format hex (8-16 valori): $'
    msg_wordc db 13,10,'cuvantul c calculat: $'
    msg_sorted db 13,10,'sirul sortat (descrescator): $'
    msg_maxbit db 13,10,'pozitia octetului cu cele mai multe setari de 1 (>3): $'
    msg_rot db 13,10,'sirul dupa rotiri (hex si binar): $'
    msg_space db '  $'
    
    octet_array db 16 dup(0)
    actual_len dw 0
    word_c dw 0
    max_bit_pos db 0ffh

    buffer db 50, 0, 50 dup(0)
data ends

_stack segment
    db 256 dup(?)
_stack ends

code segment
assume cs:code, ds:data, ss:_stack

start:
    mov ax, data
    mov ds, ax

read_loop:
    mov ah, 09h
    lea dx, msg_input
    int 21h

    mov ah, 0ah
    lea dx, buffer
    int 21h     

    call parse_input ; convertim textul hex in valori numerice in octet_array

    ; verificam daca avem intre 8 si 16 octeti
    cmp actual_len, 8
    jb read_loop    ; < 8, se cere din nou introducerea octetilor
    cmp actual_len, 16
    ja read_loop   ; > 16, se cere din nou intoducerea octetilor

    call calc_word_c
    call sort_desc
    call find_max_bits

    ; afisare cuvant c
    mov ah, 09h
    lea dx, msg_wordc
    int 21h
    ; functie pt afisare word_c

    ; afisare sortat
    mov ah, 09h
    lea dx, msg_sorted
    int 21h
    ; functie pt afisarea sirului sortat

    ; afisare max bit
    mov ah, 09h
    lea dx, msg_maxbit
    int 21h
    mov al, max_bit_pos
    cmp al, 0ffh
    je no_max   ; daca nu s-a gasit niciun octet nr de biti de 1 > 3
    add al, '0' ; convertim in ascii
    mov dl, al
    mov ah, 02h
    int 21h
    jmp do_rot
no_max:
    mov dl, '-' ; afisam daca nu exista rezultat
    mov ah, 02h
    int 21h

do_rot:
    call rotation
    mov ah, 09h
    lea dx, msg_rot
    int 21h
    ; functie pt afisarea sirului rotit

    mov ah, 4ch
    int 21h
code ends
end start