; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
str_0:      db "Cantidad de alumnos:", 0
str_1:      db "Nombre del alumno:", 0
str_2:      db "Calificacion:", 0
str_3:      db "Promedio general: ", 0
str_4:      db "Mayor calificacion:", 0
str_5:      db " -> ", 0
str_6:      db "Menor calificacion:", 0
str_7:      db " APROBADO", 0
str_8:      db " REPROBADO", 0
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   nombres -> [rbp-8]
;   calificaciones -> [rbp-16]
;   suma -> [rbp-24]
;   mayor -> [rbp-32]
;   menor -> [rbp-40]
;   cantidad -> [rbp-48]
;   t2 -> [rbp-56]
;   i -> [rbp-64]
;   L1 -> [rbp-72]
;   t_for_i -> [rbp-80]
;   L2 -> [rbp-88]
;   L3 -> [rbp-96]
;   t3 -> [rbp-104]
;   t6 -> [rbp-112]
;   L4 -> [rbp-120]
;   L5 -> [rbp-128]
;   nombreMayor -> [rbp-136]
;   t9 -> [rbp-144]
;   t10 -> [rbp-152]
;   L7 -> [rbp-160]
;   L8 -> [rbp-168]
;   nombreMenor -> [rbp-176]
;   promedio -> [rbp-184]
;   t14 -> [rbp-192]
;   j -> [rbp-200]
;   L10 -> [rbp-208]
;   t_for_j -> [rbp-216]
;   L11 -> [rbp-224]
;   L12 -> [rbp-232]
;   t15 -> [rbp-240]
;   t16 -> [rbp-248]
;   L13 -> [rbp-256]
;   L14 -> [rbp-264]
;   t17 -> [rbp-272]
;   L15 -> [rbp-280]
;   t18 -> [rbp-288]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 304

    ; --- [0] NEWARR nombres 100 - ---
    ; Instruccion no traducida: NEWARR

    ; --- [1] NEWARR calificaciones 100 - ---
    ; Instruccion no traducida: NEWARR

    ; --- [2] = 0.0 - suma ---
    mov     rax, 0
    mov     qword [rbp-24], rax

    ; --- [3] NEG 1.0 - mayor ---
    mov     rax, 1
    neg     rax
    mov     qword [rbp-32], rax

    ; --- [4] = 101.0 - menor ---
    mov     rax, 101
    mov     qword [rbp-40], rax

    ; --- [5] WRITE "Cantidad de alumnos:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_0]
    xor     eax, eax
    call    printf

    ; --- [6] READ - - cantidad ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [7] - cantidad 1 t2 ---
    mov     rax, [rbp-48]
    mov     rcx, 1
    sub     rax, rcx
    mov     qword [rbp-56], rax

    ; --- [8] = 0 - i ---
    mov     rax, 0
    mov     qword [rbp-64], rax

    ; --- [9] LABEL - - L1 ---
L1:

    ; --- [10] <= i t2 t_for_i ---
    mov     rax, [rbp-64]
    mov     rcx, [rbp-56]
    cmp     rax, rcx
    setle    al
    movzx   rax, al
    mov     qword [rbp-80], rax

    ; --- [11] IFT t_for_i - L2 ---
    mov     rax, [rbp-80]
    cmp     rax, 0
    jne     L2

    ; --- [12] GOTO - - L3 ---
    jmp     L3

    ; --- [13] LABEL - - L2 ---
L2:

    ; --- [14] WRITE "Nombre del alumno:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_1]
    xor     eax, eax
    call    printf

    ; --- [15] ARRREAD i - nombres ---
    ; Instruccion no traducida: ARRREAD

    ; --- [16] WRITE "Calificacion:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_2]
    xor     eax, eax
    call    printf

    ; --- [17] ARRREAD i - calificaciones ---
    ; Instruccion no traducida: ARRREAD

    ; --- [18] ARRGET calificaciones i t3 ---
    ; Instruccion no traducida: ARRGET

    ; --- [19] + suma t3 suma ---
    mov     rax, [rbp-24]
    mov     rcx, [rbp-104]
    add     rax, rcx
    mov     qword [rbp-24], rax

    ; --- [20] > t3 mayor t6 ---
    mov     rax, [rbp-104]
    mov     rcx, [rbp-32]
    cmp     rax, rcx
    setg    al
    movzx   rax, al
    mov     qword [rbp-112], rax

    ; --- [21] IFT t6 - L4 ---
    mov     rax, [rbp-112]
    cmp     rax, 0
    jne     L4

    ; --- [22] GOTO - - L5 ---
    jmp     L5

    ; --- [23] LABEL - - L4 ---
L4:

    ; --- [24] ARRGET calificaciones i mayor ---
    ; Instruccion no traducida: ARRGET

    ; --- [25] ARRGET nombres i nombreMayor ---
    ; Instruccion no traducida: ARRGET

    ; --- [26] LABEL - - L5 ---
L5:

    ; --- [27] ARRGET calificaciones i t9 ---
    ; Instruccion no traducida: ARRGET

    ; --- [28] < t9 menor t10 ---
    mov     rax, [rbp-144]
    mov     rcx, [rbp-40]
    cmp     rax, rcx
    setl    al
    movzx   rax, al
    mov     qword [rbp-152], rax

    ; --- [29] IFT t10 - L7 ---
    mov     rax, [rbp-152]
    cmp     rax, 0
    jne     L7

    ; --- [30] GOTO - - L8 ---
    jmp     L8

    ; --- [31] LABEL - - L7 ---
L7:

    ; --- [32] ARRGET calificaciones i menor ---
    ; Instruccion no traducida: ARRGET

    ; --- [33] ARRGET nombres i nombreMenor ---
    ; Instruccion no traducida: ARRGET

    ; --- [34] LABEL - - L8 ---
L8:

    ; --- [35] + i 1 i ---
    mov     rax, [rbp-64]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-64], rax

    ; --- [36] GOTO - - L1 ---
    jmp     L1

    ; --- [37] LABEL - - L3 ---
L3:

    ; --- [38] / suma cantidad promedio ---
    mov     rax, [rbp-24]
    cqo
    mov     rcx, [rbp-48]
    idiv    rcx
    mov     qword [rbp-184], rax

    ; --- [39] WRITE "Promedio general: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_3]
    xor     eax, eax
    call    printf

    ; --- [40] WRITE promedio - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-184]
    xor     eax, eax
    call    printf

    ; --- [41] WRITE "Mayor calificacion:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_4]
    xor     eax, eax
    call    printf

    ; --- [42] WRITE nombreMayor - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-136]
    xor     eax, eax
    call    printf

    ; --- [43] WRITE " -> " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_5]
    xor     eax, eax
    call    printf

    ; --- [44] WRITE mayor - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-32]
    xor     eax, eax
    call    printf

    ; --- [45] WRITE "Menor calificacion:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_6]
    xor     eax, eax
    call    printf

    ; --- [46] WRITE nombreMenor - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-176]
    xor     eax, eax
    call    printf

    ; --- [47] WRITE " -> " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_5]
    xor     eax, eax
    call    printf

    ; --- [48] WRITE menor - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-40]
    xor     eax, eax
    call    printf

    ; --- [49] - cantidad 1 t14 ---
    mov     rax, [rbp-48]
    mov     rcx, 1
    sub     rax, rcx
    mov     qword [rbp-192], rax

    ; --- [50] = 0 - j ---
    mov     rax, 0
    mov     qword [rbp-200], rax

    ; --- [51] LABEL - - L10 ---
L10:

    ; --- [52] <= j t14 t_for_j ---
    mov     rax, [rbp-200]
    mov     rcx, [rbp-192]
    cmp     rax, rcx
    setle    al
    movzx   rax, al
    mov     qword [rbp-216], rax

    ; --- [53] IFT t_for_j - L11 ---
    mov     rax, [rbp-216]
    cmp     rax, 0
    jne     L11

    ; --- [54] GOTO - - L12 ---
    jmp     L12

    ; --- [55] LABEL - - L11 ---
L11:

    ; --- [56] ARRGET calificaciones j t15 ---
    ; Instruccion no traducida: ARRGET

    ; --- [57] >= t15 70.0 t16 ---
    mov     rax, [rbp-240]
    mov     rcx, 70
    cmp     rax, rcx
    setge    al
    movzx   rax, al
    mov     qword [rbp-248], rax

    ; --- [58] IFT t16 - L13 ---
    mov     rax, [rbp-248]
    cmp     rax, 0
    jne     L13

    ; --- [59] GOTO - - L14 ---
    jmp     L14

    ; --- [60] LABEL - - L13 ---
L13:

    ; --- [61] ARRGET nombres j t17 ---
    ; Instruccion no traducida: ARRGET

    ; --- [62] WRITE t17 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-272]
    xor     eax, eax
    call    printf

    ; --- [63] WRITE " APROBADO" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_7]
    xor     eax, eax
    call    printf

    ; --- [64] GOTO - - L15 ---
    jmp     L15

    ; --- [65] LABEL - - L14 ---
L14:

    ; --- [66] ARRGET nombres j t18 ---
    ; Instruccion no traducida: ARRGET

    ; --- [67] WRITE t18 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-288]
    xor     eax, eax
    call    printf

    ; --- [68] WRITE " REPROBADO" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_8]
    xor     eax, eax
    call    printf

    ; --- [69] LABEL - - L15 ---
L15:

    ; --- [70] + j 1 j ---
    mov     rax, [rbp-200]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-200], rax

    ; --- [71] GOTO - - L10 ---
    jmp     L10

    ; --- [72] LABEL - - L12 ---
L12:

    ; Epilogo
    xor     eax, eax
    leave
    ret
