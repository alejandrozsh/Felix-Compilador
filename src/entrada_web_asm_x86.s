; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
str_0:      db "Valor 0,0", 0
str_1:      db "Valor 0,1", 0
str_2:      db "Valor 1,0", 0
str_3:      db "Valor 1,1", 0
str_4:      db "Resultado:", 0
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   mat -> [rbp-8]
;   2x2 -> [rbp-16]
;   0,0 -> [rbp-24]
;   0,1 -> [rbp-32]
;   1,0 -> [rbp-40]
;   1,1 -> [rbp-48]
;   t1 -> [rbp-56]
;   t2 -> [rbp-64]
;   suma -> [rbp-72]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 96

    ; --- [0] NEWMAT mat 2x2 - ---
    ; NEWMAT: operacion de matrices [pendiente]

    ; --- [1] WRITE "Valor 0,0" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_0]
    xor     eax, eax
    call    printf

    ; --- [2] MATREAD 0,0 - mat ---
    ; Instruccion no traducida: MATREAD

    ; --- [3] WRITE "Valor 0,1" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_1]
    xor     eax, eax
    call    printf

    ; --- [4] MATREAD 0,1 - mat ---
    ; Instruccion no traducida: MATREAD

    ; --- [5] WRITE "Valor 1,0" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_2]
    xor     eax, eax
    call    printf

    ; --- [6] MATREAD 1,0 - mat ---
    ; Instruccion no traducida: MATREAD

    ; --- [7] WRITE "Valor 1,1" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_3]
    xor     eax, eax
    call    printf

    ; --- [8] MATREAD 1,1 - mat ---
    ; Instruccion no traducida: MATREAD

    ; --- [9] MATGET mat 0,0 t1 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [10] MATGET mat 0,1 t2 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [11] + t1 t2 suma ---
    mov     rax, [rbp-56]
    mov     rcx, [rbp-64]
    add     rax, rcx
    mov     qword [rbp-72], rax

    ; --- [12] MATGET mat 1,0 t1 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [13] + suma t1 suma ---
    mov     rax, [rbp-72]
    mov     rcx, [rbp-56]
    add     rax, rcx
    mov     qword [rbp-72], rax

    ; --- [14] MATGET mat 1,1 t1 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [15] + suma t1 suma ---
    mov     rax, [rbp-72]
    mov     rcx, [rbp-56]
    add     rax, rcx
    mov     qword [rbp-72], rax

    ; --- [16] WRITE "Resultado:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_4]
    xor     eax, eax
    call    printf

    ; --- [17] WRITE suma - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-72]
    xor     eax, eax
    call    printf

    ; Epilogo
    xor     eax, eax
    leave
    ret
