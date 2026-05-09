; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
str_0:      db "Cantidad:", 0
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   n -> [rbp-8]
;   a -> [rbp-16]
;   b -> [rbp-24]
;   i -> [rbp-32]
;   L1 -> [rbp-40]
;   t1 -> [rbp-48]
;   L3 -> [rbp-56]
;   L2 -> [rbp-64]
;   temp -> [rbp-72]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 96

    ; --- [0] WRITE "Cantidad:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_0]
    xor     eax, eax
    call    printf

    ; --- [1] READ - - n ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [2] = 0 - a ---
    mov     rax, 0
    mov     qword [rbp-16], rax

    ; --- [3] = 1 - b ---
    mov     rax, 1
    mov     qword [rbp-24], rax

    ; --- [4] = 0 - i ---
    mov     rax, 0
    mov     qword [rbp-32], rax

    ; --- [5] LABEL - - L1 ---
L1:

    ; --- [6] < i n t1 ---
    mov     rax, [rbp-32]
    mov     rcx, [rbp-8]
    cmp     rax, rcx
    setl    al
    movzx   rax, al
    mov     qword [rbp-48], rax

    ; --- [7] IFT t1 - L3 ---
    mov     rax, [rbp-48]
    cmp     rax, 0
    jne     L3

    ; --- [8] GOTO - - L2 ---
    jmp     L2

    ; --- [9] LABEL - - L3 ---
L3:

    ; --- [10] WRITE a - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-16]
    xor     eax, eax
    call    printf

    ; --- [11] + a b temp ---
    mov     rax, [rbp-16]
    mov     rcx, [rbp-24]
    add     rax, rcx
    mov     qword [rbp-72], rax

    ; --- [12] = b - a ---
    mov     rax, [rbp-24]
    mov     qword [rbp-16], rax

    ; --- [13] = temp - b ---
    mov     rax, [rbp-72]
    mov     qword [rbp-24], rax

    ; --- [14] + i 1 i ---
    mov     rax, [rbp-32]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-32], rax

    ; --- [15] GOTO - - L1 ---
    jmp     L1

    ; --- [16] LABEL - - L2 ---
L2:

    ; Epilogo
    xor     eax, eax
    leave
    ret
