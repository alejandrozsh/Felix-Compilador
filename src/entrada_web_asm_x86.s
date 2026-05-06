; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
str_0:      db "El impuesto a pagar es:", 0
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   impuesto -> [rbp-8]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 32

    ; --- [0] * 500.0 0.16 impuesto ---
    mov     rax, 500
    mov     rcx, 0
    imul    rax, rcx
    mov     qword [rbp-8], rax

    ; --- [1] WRITE "El impuesto a pagar es:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_0]
    xor     eax, eax
    call    printf

    ; --- [2] WRITE impuesto - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-8]
    xor     eax, eax
    call    printf

    ; Epilogo
    xor     eax, eax
    leave
    ret
