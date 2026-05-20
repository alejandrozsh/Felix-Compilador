; Codigo Ensamblador x86_64
; Sintaxis: Intel (NASM)
    section .data

; --- Cadenas literales ---
str_0:      db "===== INVENTARIO =====", 0
str_1:      db "1. Agregar producto", 0
str_2:      db "2. Mostrar productos", 0
str_3:      db "3. Buscar producto", 0
str_4:      db "4. Vender producto", 0
str_5:      db "5. Salir", 0
str_6:      db "Clave del producto:", 0
str_7:      db "Precio:", 0
str_8:      db "Stock:", 0
str_9:      db "Producto agregado", 0
str_10:      db "Inventario vacio", 0
str_11:      db "Producto ", 0
str_12:      db "Clave: ", 0
str_13:      db "Precio: ", 0
str_14:      db "Stock: ", 0
str_15:      db "Clave a buscar:", 0
str_16:      db "Producto encontrado", 0
str_17:      db "Producto no encontrado", 0
str_18:      db "Cantidad a vender:", 0
str_19:      db "Venta realizada", 0
str_20:      db "Stock restante: ", 0
str_21:      db "Stock insuficiente", 0
str_22:      db "Producto inexistente", 0
str_23:      db "Saliendo del sistema", 0
str_24:      db "Opcion invalida", 0
fmt_int:    db "%lld", 10, 0
fmt_str:    db "%s", 10, 0

; --- Mapa de variables (stack offsets) ---
;   claves -> [rbp-8]
;   precios -> [rbp-16]
;   stock -> [rbp-24]
;   cantidad -> [rbp-32]
;   opcion -> [rbp-40]
;   L1 -> [rbp-48]
;   t1 -> [rbp-56]
;   L3 -> [rbp-64]
;   L2 -> [rbp-72]
;   t_sw -> [rbp-80]
;   L5 -> [rbp-88]
;   L6 -> [rbp-96]
;   L4 -> [rbp-104]
;   L7 -> [rbp-112]
;   L8 -> [rbp-120]
;   t3 -> [rbp-128]
;   L9 -> [rbp-136]
;   L10 -> [rbp-144]
;   L11 -> [rbp-152]
;   t4 -> [rbp-160]
;   i -> [rbp-168]
;   L12 -> [rbp-176]
;   t_for_i -> [rbp-184]
;   L13 -> [rbp-192]
;   L14 -> [rbp-200]
;   t5 -> [rbp-208]
;   t6 -> [rbp-216]
;   t7 -> [rbp-224]
;   L15 -> [rbp-232]
;   L16 -> [rbp-240]
;   claveBuscar -> [rbp-248]
;   encontrado -> [rbp-256]
;   t8 -> [rbp-264]
;   L17 -> [rbp-272]
;   L18 -> [rbp-280]
;   L19 -> [rbp-288]
;   t9 -> [rbp-296]
;   t10 -> [rbp-304]
;   L20 -> [rbp-312]
;   L21 -> [rbp-320]
;   t11 -> [rbp-328]
;   t12 -> [rbp-336]
;   t13 -> [rbp-344]
;   L23 -> [rbp-352]
;   L24 -> [rbp-360]
;   L26 -> [rbp-368]
;   L27 -> [rbp-376]
;   claveVenta -> [rbp-384]
;   cantidadVenta -> [rbp-392]
;   vendido -> [rbp-400]
;   t14 -> [rbp-408]
;   L28 -> [rbp-416]
;   L29 -> [rbp-424]
;   L30 -> [rbp-432]
;   t15 -> [rbp-440]
;   t16 -> [rbp-448]
;   L31 -> [rbp-456]
;   L32 -> [rbp-464]
;   t17 -> [rbp-472]
;   t18 -> [rbp-480]
;   L34 -> [rbp-488]
;   L35 -> [rbp-496]
;   t19 -> [rbp-504]
;   t20 -> [rbp-512]
;   t21 -> [rbp-520]
;   L36 -> [rbp-528]
;   t22 -> [rbp-536]
;   L37 -> [rbp-544]
;   L38 -> [rbp-552]
;   L40 -> [rbp-560]
;   L41 -> [rbp-568]
;   L42 -> [rbp-576]

    section .text
    global  main
    extern  printf

main:
    ; Prologo
    push    rbp
    mov     rbp, rsp
    sub     rsp, 592

    ; --- [0] NEWARR claves 100 - ---
    ; Instruccion no traducida: NEWARR

    ; --- [1] NEWARR precios 100 - ---
    ; Instruccion no traducida: NEWARR

    ; --- [2] NEWARR stock 100 - ---
    ; Instruccion no traducida: NEWARR

    ; --- [3] = 0 - cantidad ---
    mov     rax, 0
    mov     qword [rbp-32], rax

    ; --- [4] = 0 - opcion ---
    mov     rax, 0
    mov     qword [rbp-40], rax

    ; --- [5] LABEL - - L1 ---
L1:

    ; --- [6] != opcion 5 t1 ---
    mov     rax, [rbp-40]
    mov     rcx, 5
    cmp     rax, rcx
    setne    al
    movzx   rax, al
    mov     qword [rbp-56], rax

    ; --- [7] IFT t1 - L3 ---
    mov     rax, [rbp-56]
    cmp     rax, 0
    jne     L3

    ; --- [8] GOTO - - L2 ---
    jmp     L2

    ; --- [9] LABEL - - L3 ---
L3:

    ; --- [10] WRITE "===== INVENTARIO =====" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_0]
    xor     eax, eax
    call    printf

    ; --- [11] WRITE "1. Agregar producto" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_1]
    xor     eax, eax
    call    printf

    ; --- [12] WRITE "2. Mostrar productos" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_2]
    xor     eax, eax
    call    printf

    ; --- [13] WRITE "3. Buscar producto" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_3]
    xor     eax, eax
    call    printf

    ; --- [14] WRITE "4. Vender producto" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_4]
    xor     eax, eax
    call    printf

    ; --- [15] WRITE "5. Salir" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_5]
    xor     eax, eax
    call    printf

    ; --- [16] READ - - opcion ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [17] == opcion 1 t_sw ---
    mov     rax, [rbp-40]
    mov     rcx, 1
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-80], rax

    ; --- [18] IFT t_sw - L5 ---
    mov     rax, [rbp-80]
    cmp     rax, 0
    jne     L5

    ; --- [19] GOTO - - L6 ---
    jmp     L6

    ; --- [20] LABEL - - L5 ---
L5:

    ; --- [21] WRITE "Clave del producto:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_6]
    xor     eax, eax
    call    printf

    ; --- [22] ARRREAD cantidad - claves ---
    ; Instruccion no traducida: ARRREAD

    ; --- [23] WRITE "Precio:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_7]
    xor     eax, eax
    call    printf

    ; --- [24] ARRREAD cantidad - precios ---
    ; Instruccion no traducida: ARRREAD

    ; --- [25] WRITE "Stock:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_8]
    xor     eax, eax
    call    printf

    ; --- [26] ARRREAD cantidad - stock ---
    ; Instruccion no traducida: ARRREAD

    ; --- [27] + cantidad 1 cantidad ---
    mov     rax, [rbp-32]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-32], rax

    ; --- [28] WRITE "Producto agregado" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_9]
    xor     eax, eax
    call    printf

    ; --- [29] GOTO - - L4 ---
    jmp     L4

    ; --- [30] LABEL - - L6 ---
L6:

    ; --- [31] == opcion 2 t_sw ---
    mov     rax, [rbp-40]
    mov     rcx, 2
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-80], rax

    ; --- [32] IFT t_sw - L7 ---
    mov     rax, [rbp-80]
    cmp     rax, 0
    jne     L7

    ; --- [33] GOTO - - L8 ---
    jmp     L8

    ; --- [34] LABEL - - L7 ---
L7:

    ; --- [35] == cantidad 0 t3 ---
    mov     rax, [rbp-32]
    mov     rcx, 0
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-128], rax

    ; --- [36] IFT t3 - L9 ---
    mov     rax, [rbp-128]
    cmp     rax, 0
    jne     L9

    ; --- [37] GOTO - - L10 ---
    jmp     L10

    ; --- [38] LABEL - - L9 ---
L9:

    ; --- [39] WRITE "Inventario vacio" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_10]
    xor     eax, eax
    call    printf

    ; --- [40] GOTO - - L11 ---
    jmp     L11

    ; --- [41] LABEL - - L10 ---
L10:

    ; --- [42] - cantidad 1 t4 ---
    mov     rax, [rbp-32]
    mov     rcx, 1
    sub     rax, rcx
    mov     qword [rbp-160], rax

    ; --- [43] = 0 - i ---
    mov     rax, 0
    mov     qword [rbp-168], rax

    ; --- [44] LABEL - - L12 ---
L12:

    ; --- [45] <= i t4 t_for_i ---
    mov     rax, [rbp-168]
    mov     rcx, [rbp-160]
    cmp     rax, rcx
    setle    al
    movzx   rax, al
    mov     qword [rbp-184], rax

    ; --- [46] IFT t_for_i - L13 ---
    mov     rax, [rbp-184]
    cmp     rax, 0
    jne     L13

    ; --- [47] GOTO - - L14 ---
    jmp     L14

    ; --- [48] LABEL - - L13 ---
L13:

    ; --- [49] WRITE "Producto " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_11]
    xor     eax, eax
    call    printf

    ; --- [50] WRITE i - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-168]
    xor     eax, eax
    call    printf

    ; --- [51] WRITE "Clave: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_12]
    xor     eax, eax
    call    printf

    ; --- [52] ARRGET claves i t5 ---
    ; Instruccion no traducida: ARRGET

    ; --- [53] WRITE t5 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-208]
    xor     eax, eax
    call    printf

    ; --- [54] WRITE "Precio: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_13]
    xor     eax, eax
    call    printf

    ; --- [55] ARRGET precios i t6 ---
    ; Instruccion no traducida: ARRGET

    ; --- [56] WRITE t6 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-216]
    xor     eax, eax
    call    printf

    ; --- [57] WRITE "Stock: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_14]
    xor     eax, eax
    call    printf

    ; --- [58] ARRGET stock i t7 ---
    ; Instruccion no traducida: ARRGET

    ; --- [59] WRITE t7 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-224]
    xor     eax, eax
    call    printf

    ; --- [60] + i 1 i ---
    mov     rax, [rbp-168]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-168], rax

    ; --- [61] GOTO - - L12 ---
    jmp     L12

    ; --- [62] LABEL - - L14 ---
L14:

    ; --- [63] LABEL - - L11 ---
L11:

    ; --- [64] GOTO - - L4 ---
    jmp     L4

    ; --- [65] LABEL - - L8 ---
L8:

    ; --- [66] == opcion 3 t_sw ---
    mov     rax, [rbp-40]
    mov     rcx, 3
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-80], rax

    ; --- [67] IFT t_sw - L15 ---
    mov     rax, [rbp-80]
    cmp     rax, 0
    jne     L15

    ; --- [68] GOTO - - L16 ---
    jmp     L16

    ; --- [69] LABEL - - L15 ---
L15:

    ; --- [70] WRITE "Clave a buscar:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_15]
    xor     eax, eax
    call    printf

    ; --- [71] READ - - claveBuscar ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [72] = 0 - encontrado ---
    mov     rax, 0
    mov     qword [rbp-256], rax

    ; --- [73] - cantidad 1 t8 ---
    mov     rax, [rbp-32]
    mov     rcx, 1
    sub     rax, rcx
    mov     qword [rbp-264], rax

    ; --- [74] = 0 - i ---
    mov     rax, 0
    mov     qword [rbp-168], rax

    ; --- [75] = 1 - encontrado ---
    mov     rax, 1
    mov     qword [rbp-256], rax

    ; --- [76] LABEL - - L17 ---
L17:

    ; --- [77] <= i t8 t_for_i ---
    mov     rax, [rbp-168]
    mov     rcx, [rbp-264]
    cmp     rax, rcx
    setle    al
    movzx   rax, al
    mov     qword [rbp-184], rax

    ; --- [78] IFT t_for_i - L18 ---
    mov     rax, [rbp-184]
    cmp     rax, 0
    jne     L18

    ; --- [79] GOTO - - L19 ---
    jmp     L19

    ; --- [80] LABEL - - L18 ---
L18:

    ; --- [81] ARRGET claves i t9 ---
    ; Instruccion no traducida: ARRGET

    ; --- [82] == t9 claveBuscar t10 ---
    mov     rax, [rbp-296]
    mov     rcx, [rbp-248]
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-304], rax

    ; --- [83] IFT t10 - L20 ---
    mov     rax, [rbp-304]
    cmp     rax, 0
    jne     L20

    ; --- [84] GOTO - - L21 ---
    jmp     L21

    ; --- [85] LABEL - - L20 ---
L20:

    ; --- [86] WRITE "Producto encontrado" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_16]
    xor     eax, eax
    call    printf

    ; --- [87] WRITE "Precio: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_13]
    xor     eax, eax
    call    printf

    ; --- [88] ARRGET precios i t11 ---
    ; Instruccion no traducida: ARRGET

    ; --- [89] WRITE t11 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-328]
    xor     eax, eax
    call    printf

    ; --- [90] WRITE "Stock: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_14]
    xor     eax, eax
    call    printf

    ; --- [91] ARRGET stock i t12 ---
    ; Instruccion no traducida: ARRGET

    ; --- [92] WRITE t12 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-336]
    xor     eax, eax
    call    printf

    ; --- [93] LABEL - - L21 ---
L21:

    ; --- [94] + i 1 i ---
    mov     rax, [rbp-168]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-168], rax

    ; --- [95] GOTO - - L17 ---
    jmp     L17

    ; --- [96] LABEL - - L19 ---
L19:

    ; --- [97] == encontrado 0 t13 ---
    mov     rax, [rbp-256]
    mov     rcx, 0
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-344], rax

    ; --- [98] IFT t13 - L23 ---
    mov     rax, [rbp-344]
    cmp     rax, 0
    jne     L23

    ; --- [99] GOTO - - L24 ---
    jmp     L24

    ; --- [100] LABEL - - L23 ---
L23:

    ; --- [101] WRITE "Producto no encontrado" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_17]
    xor     eax, eax
    call    printf

    ; --- [102] LABEL - - L24 ---
L24:

    ; --- [103] GOTO - - L4 ---
    jmp     L4

    ; --- [104] LABEL - - L16 ---
L16:

    ; --- [105] == opcion 4 t_sw ---
    mov     rax, [rbp-40]
    mov     rcx, 4
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-80], rax

    ; --- [106] IFT t_sw - L26 ---
    mov     rax, [rbp-80]
    cmp     rax, 0
    jne     L26

    ; --- [107] GOTO - - L27 ---
    jmp     L27

    ; --- [108] LABEL - - L26 ---
L26:

    ; --- [109] WRITE "Clave del producto:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_6]
    xor     eax, eax
    call    printf

    ; --- [110] READ - - claveVenta ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [111] WRITE "Cantidad a vender:" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_18]
    xor     eax, eax
    call    printf

    ; --- [112] READ - - cantidadVenta ---
    ; READ: lectura de entrada (requiere scanf)
    ; [pendiente: implementacion completa]

    ; --- [113] = 0 - vendido ---
    mov     rax, 0
    mov     qword [rbp-400], rax

    ; --- [114] - cantidad 1 t14 ---
    mov     rax, [rbp-32]
    mov     rcx, 1
    sub     rax, rcx
    mov     qword [rbp-408], rax

    ; --- [115] = 0 - i ---
    mov     rax, 0
    mov     qword [rbp-168], rax

    ; --- [116] = 1 - vendido ---
    mov     rax, 1
    mov     qword [rbp-400], rax

    ; --- [117] LABEL - - L28 ---
L28:

    ; --- [118] <= i t14 t_for_i ---
    mov     rax, [rbp-168]
    mov     rcx, [rbp-408]
    cmp     rax, rcx
    setle    al
    movzx   rax, al
    mov     qword [rbp-184], rax

    ; --- [119] IFT t_for_i - L29 ---
    mov     rax, [rbp-184]
    cmp     rax, 0
    jne     L29

    ; --- [120] GOTO - - L30 ---
    jmp     L30

    ; --- [121] LABEL - - L29 ---
L29:

    ; --- [122] ARRGET claves i t15 ---
    ; Instruccion no traducida: ARRGET

    ; --- [123] == t15 claveVenta t16 ---
    mov     rax, [rbp-440]
    mov     rcx, [rbp-384]
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-448], rax

    ; --- [124] IFT t16 - L31 ---
    mov     rax, [rbp-448]
    cmp     rax, 0
    jne     L31

    ; --- [125] GOTO - - L32 ---
    jmp     L32

    ; --- [126] LABEL - - L31 ---
L31:

    ; --- [127] ARRGET stock i t17 ---
    ; Instruccion no traducida: ARRGET

    ; --- [128] >= t17 cantidadVenta t18 ---
    mov     rax, [rbp-472]
    mov     rcx, [rbp-392]
    cmp     rax, rcx
    setge    al
    movzx   rax, al
    mov     qword [rbp-480], rax

    ; --- [129] IFT t18 - L34 ---
    mov     rax, [rbp-480]
    cmp     rax, 0
    jne     L34

    ; --- [130] GOTO - - L35 ---
    jmp     L35

    ; --- [131] LABEL - - L34 ---
L34:

    ; --- [132] ARRGET stock i t19 ---
    ; Instruccion no traducida: ARRGET

    ; --- [133] - t19 cantidadVenta t20 ---
    mov     rax, [rbp-504]
    mov     rcx, [rbp-392]
    sub     rax, rcx
    mov     qword [rbp-512], rax

    ; --- [134] ARRSET i t20 stock ---
    ; Instruccion no traducida: ARRSET

    ; --- [135] WRITE "Venta realizada" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_19]
    xor     eax, eax
    call    printf

    ; --- [136] WRITE "Stock restante: " - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_20]
    xor     eax, eax
    call    printf

    ; --- [137] ARRGET stock i t21 ---
    ; Instruccion no traducida: ARRGET

    ; --- [138] WRITE t21 - - ---
    lea     rdi, [rel fmt_int]
    mov     rsi, [rbp-520]
    xor     eax, eax
    call    printf

    ; --- [139] GOTO - - L36 ---
    jmp     L36

    ; --- [140] LABEL - - L35 ---
L35:

    ; --- [141] WRITE "Stock insuficiente" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_21]
    xor     eax, eax
    call    printf

    ; --- [142] LABEL - - L36 ---
L36:

    ; --- [143] LABEL - - L32 ---
L32:

    ; --- [144] + i 1 i ---
    mov     rax, [rbp-168]
    mov     rcx, 1
    add     rax, rcx
    mov     qword [rbp-168], rax

    ; --- [145] GOTO - - L28 ---
    jmp     L28

    ; --- [146] LABEL - - L30 ---
L30:

    ; --- [147] == vendido 0 t22 ---
    mov     rax, [rbp-400]
    mov     rcx, 0
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-536], rax

    ; --- [148] IFT t22 - L37 ---
    mov     rax, [rbp-536]
    cmp     rax, 0
    jne     L37

    ; --- [149] GOTO - - L38 ---
    jmp     L38

    ; --- [150] LABEL - - L37 ---
L37:

    ; --- [151] WRITE "Producto inexistente" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_22]
    xor     eax, eax
    call    printf

    ; --- [152] LABEL - - L38 ---
L38:

    ; --- [153] GOTO - - L4 ---
    jmp     L4

    ; --- [154] LABEL - - L27 ---
L27:

    ; --- [155] == opcion 5 t_sw ---
    mov     rax, [rbp-40]
    mov     rcx, 5
    cmp     rax, rcx
    sete    al
    movzx   rax, al
    mov     qword [rbp-80], rax

    ; --- [156] IFT t_sw - L40 ---
    mov     rax, [rbp-80]
    cmp     rax, 0
    jne     L40

    ; --- [157] GOTO - - L41 ---
    jmp     L41

    ; --- [158] LABEL - - L40 ---
L40:

    ; --- [159] WRITE "Saliendo del sistema" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_23]
    xor     eax, eax
    call    printf

    ; --- [160] GOTO - - L4 ---
    jmp     L4

    ; --- [161] LABEL - - L41 ---
L41:

    ; --- [162] LABEL - - L42 ---
L42:

    ; --- [163] WRITE "Opcion invalida" - - ---
    lea     rdi, [rel fmt_str]
    lea     rsi, [rel str_24]
    xor     eax, eax
    call    printf

    ; --- [164] LABEL - - L4 ---
L4:

    ; --- [165] GOTO - - L1 ---
    jmp     L1

    ; --- [166] LABEL - - L2 ---
L2:

    ; Epilogo
    xor     eax, eax
    leave
    ret
