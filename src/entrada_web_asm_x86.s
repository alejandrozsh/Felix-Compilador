; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   a -> [rbp-8]
;   b -> [rbp-16]
;   L1 -> [rbp-24]
;   t1 -> [rbp-32]
;   L3 -> [rbp-40]
;   L2 -> [rbp-48]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 64

    ; --- [0] READ - - a ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [1] READ - - b ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [2] LABEL - - L1 ---
L1:

    ; --- [3] < a b t1 ---
    mov     rax, [rbp-8]
    mov     rcx, [rbp-16]
    cmp     rax, rcx
    setl    al
    movzx   rax, al
    mov     qword [rbp-32], rax

    ; --- [4] IFT t1 - L3 ---
    mov     rax, [rbp-32]
    cmp     rax, 0
    jne     L3

    ; --- [5] GOTO - - L2 ---
    jmp     L2

    ; --- [6] LABEL - - L3 ---
L3:

    ; --- [7] + a 1 t1 ---
    mov     rax, [rbp-8]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-32], rax

    ; --- [8] WRITE t1 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-32]
    xor     eax, eax
    call    printf

    ; --- [9] WRITE a - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-8]
    xor     eax, eax
    call    printf

    ; --- [10] GOTO - - L1 ---
    jmp     L1

    ; --- [11] LABEL - - L2 ---
L2:

    ; Epilogo
    xor     eax, eax
    leave
    ret
