; main module

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

    ; verificam daca avem intre 8 si 16 octeti
    cmp actual_len, 8
    jb  read_loop    ; < 8, se cere din nou introducerea octetilor
    cmp actual_len, 16
    ja  read_loop   

    mov ah, 4ch
    int 21h
code ends
end start