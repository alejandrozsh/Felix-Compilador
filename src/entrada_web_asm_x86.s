; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
str_0:      db "Ingrese los valores para la matriz 2x2:", 0
str_1:      db "m[0][0]:", 0
str_2:      db "m[0][1]:", 0
str_3:      db "m[1][0]:", 0
str_4:      db "m[1][1]:", 0
str_5:      db "La suma de todos los elementos es:", 0
str_6:      db "El promedio es:", 0
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   m -> [rbp-8]
;   2x2 -> [rbp-16]
;   0,0 -> [rbp-24]
;   0,1 -> [rbp-32]
;   1,0 -> [rbp-40]
;   1,1 -> [rbp-48]
;   t1 -> [rbp-56]
;   t2 -> [rbp-64]
;   t3 -> [rbp-72]
;   t4 -> [rbp-80]
;   t5 -> [rbp-88]
;   t6 -> [rbp-96]
;   suma -> [rbp-104]
;   promedio -> [rbp-112]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 128

    ; --- [0] NEWMAT m 2x2 - ---
    ; NEWMAT: operacion de matrices [pendiente]

    ; --- [1] WRITE "Ingrese los valores para la matriz 2x2:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_0]
    xor     eax, eax
    call    printf

    ; --- [2] WRITE "m[0][0]:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_1]
    xor     eax, eax
    call    printf

    ; --- [3] MATREAD 0,0 - m ---
    ; Instruccion no traducida: MATREAD

    ; --- [4] WRITE "m[0][1]:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_2]
    xor     eax, eax
    call    printf

    ; --- [5] MATREAD 0,1 - m ---
    ; Instruccion no traducida: MATREAD

    ; --- [6] WRITE "m[1][0]:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_3]
    xor     eax, eax
    call    printf

    ; --- [7] MATREAD 1,0 - m ---
    ; Instruccion no traducida: MATREAD

    ; --- [8] WRITE "m[1][1]:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_4]
    xor     eax, eax
    call    printf

    ; --- [9] MATREAD 1,1 - m ---
    ; Instruccion no traducida: MATREAD

    ; --- [10] MATGET m 0,0 t1 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [11] MATGET m 0,1 t2 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [12] + t1 t2 t3 ---
    mov     rax, [rbp-56]
    mov     rcx, [rbp-64]
    add     rax, rcx
    mov     qword [rbp-72], rax

    ; --- [13] MATGET m 1,0 t4 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [14] + t3 t4 t5 ---
    mov     rax, [rbp-72]
    mov     rcx, [rbp-80]
    add     rax, rcx
    mov     qword [rbp-88], rax

    ; --- [15] MATGET m 1,1 t6 ---
    ; MATGET: operacion de matrices [pendiente]

    ; --- [16] + t5 t6 suma ---
    mov     rax, [rbp-88]
    mov     rcx, [rbp-96]
    add     rax, rcx
    mov     qword [rbp-104], rax

    ; --- [17] WRITE "La suma de todos los elementos es:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_5]
    xor     eax, eax
    call    printf

    ; --- [18] WRITE suma - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-104]
    xor     eax, eax
    call    printf

    ; --- [19] / suma 4 promedio ---
    mov     rax, [rbp-104]
    cqo
    mov     rcx, 4
    idiv    rcx
    mov     qword [rbp-112], rax

    ; --- [20] WRITE "El promedio es:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_6]
    xor     eax, eax
    call    printf

    ; --- [21] WRITE promedio - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-112]
    xor     eax, eax
    call    printf

    ; Epilogo
    xor     eax, eax
    leave
    ret
