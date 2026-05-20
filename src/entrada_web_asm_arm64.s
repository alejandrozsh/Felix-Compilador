// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_str_0:    .asciz "===== INVENTARIO ====="
_str_1:    .asciz "1. Agregar producto"
_str_2:    .asciz "2. Mostrar productos"
_str_3:    .asciz "3. Buscar producto"
_str_4:    .asciz "4. Vender producto"
_str_5:    .asciz "5. Salir"
_str_6:    .asciz "Clave del producto:"
_str_7:    .asciz "Precio:"
_str_8:    .asciz "Stock:"
_str_9:    .asciz "Producto agregado"
_str_10:    .asciz "Inventario vacio"
_str_11:    .asciz "Producto "
_str_12:    .asciz "Clave: "
_str_13:    .asciz "Precio: "
_str_14:    .asciz "Stock: "
_str_15:    .asciz "Clave a buscar:"
_str_16:    .asciz "Producto encontrado"
_str_17:    .asciz "Producto no encontrado"
_str_18:    .asciz "Cantidad a vender:"
_str_19:    .asciz "Venta realizada"
_str_20:    .asciz "Stock restante: "
_str_21:    .asciz "Stock insuficiente"
_str_22:    .asciz "Producto inexistente"
_str_23:    .asciz "Saliendo del sistema"
_str_24:    .asciz "Opcion invalida"
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   claves -> [x29, #-8]
//   precios -> [x29, #-16]
//   stock -> [x29, #-24]
//   cantidad -> [x29, #-32]
//   opcion -> [x29, #-40]
//   L1 -> [x29, #-48]
//   t1 -> [x29, #-56]
//   L3 -> [x29, #-64]
//   L2 -> [x29, #-72]
//   t_sw -> [x29, #-80]
//   L5 -> [x29, #-88]
//   L6 -> [x29, #-96]
//   L4 -> [x29, #-104]
//   L7 -> [x29, #-112]
//   L8 -> [x29, #-120]
//   t3 -> [x29, #-128]
//   L9 -> [x29, #-136]
//   L10 -> [x29, #-144]
//   L11 -> [x29, #-152]
//   t4 -> [x29, #-160]
//   i -> [x29, #-168]
//   L12 -> [x29, #-176]
//   t_for_i -> [x29, #-184]
//   L13 -> [x29, #-192]
//   L14 -> [x29, #-200]
//   t5 -> [x29, #-208]
//   t6 -> [x29, #-216]
//   t7 -> [x29, #-224]
//   L15 -> [x29, #-232]
//   L16 -> [x29, #-240]
//   claveBuscar -> [x29, #-248]
//   encontrado -> [x29, #-256]
//   t8 -> [x29, #-264]
//   L17 -> [x29, #-272]
//   L18 -> [x29, #-280]
//   L19 -> [x29, #-288]
//   t9 -> [x29, #-296]
//   t10 -> [x29, #-304]
//   L20 -> [x29, #-312]
//   L21 -> [x29, #-320]
//   t11 -> [x29, #-328]
//   t12 -> [x29, #-336]
//   t13 -> [x29, #-344]
//   L23 -> [x29, #-352]
//   L24 -> [x29, #-360]
//   L26 -> [x29, #-368]
//   L27 -> [x29, #-376]
//   claveVenta -> [x29, #-384]
//   cantidadVenta -> [x29, #-392]
//   vendido -> [x29, #-400]
//   t14 -> [x29, #-408]
//   L28 -> [x29, #-416]
//   L29 -> [x29, #-424]
//   L30 -> [x29, #-432]
//   t15 -> [x29, #-440]
//   t16 -> [x29, #-448]
//   L31 -> [x29, #-456]
//   L32 -> [x29, #-464]
//   t17 -> [x29, #-472]
//   t18 -> [x29, #-480]
//   L34 -> [x29, #-488]
//   L35 -> [x29, #-496]
//   t19 -> [x29, #-504]
//   t20 -> [x29, #-512]
//   t21 -> [x29, #-520]
//   L36 -> [x29, #-528]
//   t22 -> [x29, #-536]
//   L37 -> [x29, #-544]
//   L38 -> [x29, #-552]
//   L40 -> [x29, #-560]
//   L41 -> [x29, #-568]
//   L42 -> [x29, #-576]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #592

    // --- [0] NEWARR claves 100 - ---
    // Instruccion no traducida: NEWARR

    // --- [1] NEWARR precios 100 - ---
    // Instruccion no traducida: NEWARR

    // --- [2] NEWARR stock 100 - ---
    // Instruccion no traducida: NEWARR

    // --- [3] = 0 - cantidad ---
    mov     x9, #0
    str     x9, [x29, #-32]

    // --- [4] = 0 - opcion ---
    mov     x9, #0
    str     x9, [x29, #-40]

    // --- [5] LABEL - - L1 ---
L1:

    // --- [6] != opcion 5 t1 ---
    ldr     x9, [x29, #-40]
    mov     x10, #5
    cmp     x9, x10
    cset    x11, ne
    str     x11, [x29, #-56]

    // --- [7] IFT t1 - L3 ---
    ldr     x9, [x29, #-56]
    cbnz    x9, L3

    // --- [8] GOTO - - L2 ---
    b       L2

    // --- [9] LABEL - - L3 ---
L3:

    // --- [10] WRITE "===== INVENTARIO =====" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_0@PAGE
    add     x1, x1, _str_0@PAGEOFF
    bl      _printf

    // --- [11] WRITE "1. Agregar producto" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_1@PAGE
    add     x1, x1, _str_1@PAGEOFF
    bl      _printf

    // --- [12] WRITE "2. Mostrar productos" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_2@PAGE
    add     x1, x1, _str_2@PAGEOFF
    bl      _printf

    // --- [13] WRITE "3. Buscar producto" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_3@PAGE
    add     x1, x1, _str_3@PAGEOFF
    bl      _printf

    // --- [14] WRITE "4. Vender producto" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_4@PAGE
    add     x1, x1, _str_4@PAGEOFF
    bl      _printf

    // --- [15] WRITE "5. Salir" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_5@PAGE
    add     x1, x1, _str_5@PAGEOFF
    bl      _printf

    // --- [16] READ - - opcion ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [17] == opcion 1 t_sw ---
    ldr     x9, [x29, #-40]
    mov     x10, #1
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-80]

    // --- [18] IFT t_sw - L5 ---
    ldr     x9, [x29, #-80]
    cbnz    x9, L5

    // --- [19] GOTO - - L6 ---
    b       L6

    // --- [20] LABEL - - L5 ---
L5:

    // --- [21] WRITE "Clave del producto:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_6@PAGE
    add     x1, x1, _str_6@PAGEOFF
    bl      _printf

    // --- [22] ARRREAD cantidad - claves ---
    // Instruccion no traducida: ARRREAD

    // --- [23] WRITE "Precio:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_7@PAGE
    add     x1, x1, _str_7@PAGEOFF
    bl      _printf

    // --- [24] ARRREAD cantidad - precios ---
    // Instruccion no traducida: ARRREAD

    // --- [25] WRITE "Stock:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_8@PAGE
    add     x1, x1, _str_8@PAGEOFF
    bl      _printf

    // --- [26] ARRREAD cantidad - stock ---
    // Instruccion no traducida: ARRREAD

    // --- [27] + cantidad 1 cantidad ---
    ldr     x9, [x29, #-32]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-32]

    // --- [28] WRITE "Producto agregado" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_9@PAGE
    add     x1, x1, _str_9@PAGEOFF
    bl      _printf

    // --- [29] GOTO - - L4 ---
    b       L4

    // --- [30] LABEL - - L6 ---
L6:

    // --- [31] == opcion 2 t_sw ---
    ldr     x9, [x29, #-40]
    mov     x10, #2
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-80]

    // --- [32] IFT t_sw - L7 ---
    ldr     x9, [x29, #-80]
    cbnz    x9, L7

    // --- [33] GOTO - - L8 ---
    b       L8

    // --- [34] LABEL - - L7 ---
L7:

    // --- [35] == cantidad 0 t3 ---
    ldr     x9, [x29, #-32]
    mov     x10, #0
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-128]

    // --- [36] IFT t3 - L9 ---
    ldr     x9, [x29, #-128]
    cbnz    x9, L9

    // --- [37] GOTO - - L10 ---
    b       L10

    // --- [38] LABEL - - L9 ---
L9:

    // --- [39] WRITE "Inventario vacio" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_10@PAGE
    add     x1, x1, _str_10@PAGEOFF
    bl      _printf

    // --- [40] GOTO - - L11 ---
    b       L11

    // --- [41] LABEL - - L10 ---
L10:

    // --- [42] - cantidad 1 t4 ---
    ldr     x9, [x29, #-32]
    mov     x10, #1
    sub     x11, x9, x10
    str     x11, [x29, #-160]

    // --- [43] = 0 - i ---
    mov     x9, #0
    str     x9, [x29, #-168]

    // --- [44] LABEL - - L12 ---
L12:

    // --- [45] <= i t4 t_for_i ---
    ldr     x9, [x29, #-168]
    ldr     x10, [x29, #-160]
    cmp     x9, x10
    cset    x11, le
    str     x11, [x29, #-184]

    // --- [46] IFT t_for_i - L13 ---
    ldr     x9, [x29, #-184]
    cbnz    x9, L13

    // --- [47] GOTO - - L14 ---
    b       L14

    // --- [48] LABEL - - L13 ---
L13:

    // --- [49] WRITE "Producto " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_11@PAGE
    add     x1, x1, _str_11@PAGEOFF
    bl      _printf

    // --- [50] WRITE i - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-168]
    bl      _printf

    // --- [51] WRITE "Clave: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_12@PAGE
    add     x1, x1, _str_12@PAGEOFF
    bl      _printf

    // --- [52] ARRGET claves i t5 ---
    // Instruccion no traducida: ARRGET

    // --- [53] WRITE t5 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-208]
    bl      _printf

    // --- [54] WRITE "Precio: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_13@PAGE
    add     x1, x1, _str_13@PAGEOFF
    bl      _printf

    // --- [55] ARRGET precios i t6 ---
    // Instruccion no traducida: ARRGET

    // --- [56] WRITE t6 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-216]
    bl      _printf

    // --- [57] WRITE "Stock: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_14@PAGE
    add     x1, x1, _str_14@PAGEOFF
    bl      _printf

    // --- [58] ARRGET stock i t7 ---
    // Instruccion no traducida: ARRGET

    // --- [59] WRITE t7 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-224]
    bl      _printf

    // --- [60] + i 1 i ---
    ldr     x9, [x29, #-168]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-168]

    // --- [61] GOTO - - L12 ---
    b       L12

    // --- [62] LABEL - - L14 ---
L14:

    // --- [63] LABEL - - L11 ---
L11:

    // --- [64] GOTO - - L4 ---
    b       L4

    // --- [65] LABEL - - L8 ---
L8:

    // --- [66] == opcion 3 t_sw ---
    ldr     x9, [x29, #-40]
    mov     x10, #3
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-80]

    // --- [67] IFT t_sw - L15 ---
    ldr     x9, [x29, #-80]
    cbnz    x9, L15

    // --- [68] GOTO - - L16 ---
    b       L16

    // --- [69] LABEL - - L15 ---
L15:

    // --- [70] WRITE "Clave a buscar:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_15@PAGE
    add     x1, x1, _str_15@PAGEOFF
    bl      _printf

    // --- [71] READ - - claveBuscar ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [72] = 0 - encontrado ---
    mov     x9, #0
    str     x9, [x29, #-256]

    // --- [73] - cantidad 1 t8 ---
    ldr     x9, [x29, #-32]
    mov     x10, #1
    sub     x11, x9, x10
    str     x11, [x29, #-264]

    // --- [74] = 0 - i ---
    mov     x9, #0
    str     x9, [x29, #-168]

    // --- [75] = 1 - encontrado ---
    mov     x9, #1
    str     x9, [x29, #-256]

    // --- [76] LABEL - - L17 ---
L17:

    // --- [77] <= i t8 t_for_i ---
    ldr     x9, [x29, #-168]
    ldr     x10, [x29, #-264]
    cmp     x9, x10
    cset    x11, le
    str     x11, [x29, #-184]

    // --- [78] IFT t_for_i - L18 ---
    ldr     x9, [x29, #-184]
    cbnz    x9, L18

    // --- [79] GOTO - - L19 ---
    b       L19

    // --- [80] LABEL - - L18 ---
L18:

    // --- [81] ARRGET claves i t9 ---
    // Instruccion no traducida: ARRGET

    // --- [82] == t9 claveBuscar t10 ---
    ldr     x9, [x29, #-296]
    ldr     x10, [x29, #-248]
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-304]

    // --- [83] IFT t10 - L20 ---
    ldr     x9, [x29, #-304]
    cbnz    x9, L20

    // --- [84] GOTO - - L21 ---
    b       L21

    // --- [85] LABEL - - L20 ---
L20:

    // --- [86] WRITE "Producto encontrado" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_16@PAGE
    add     x1, x1, _str_16@PAGEOFF
    bl      _printf

    // --- [87] WRITE "Precio: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_13@PAGE
    add     x1, x1, _str_13@PAGEOFF
    bl      _printf

    // --- [88] ARRGET precios i t11 ---
    // Instruccion no traducida: ARRGET

    // --- [89] WRITE t11 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-328]
    bl      _printf

    // --- [90] WRITE "Stock: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_14@PAGE
    add     x1, x1, _str_14@PAGEOFF
    bl      _printf

    // --- [91] ARRGET stock i t12 ---
    // Instruccion no traducida: ARRGET

    // --- [92] WRITE t12 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-336]
    bl      _printf

    // --- [93] LABEL - - L21 ---
L21:

    // --- [94] + i 1 i ---
    ldr     x9, [x29, #-168]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-168]

    // --- [95] GOTO - - L17 ---
    b       L17

    // --- [96] LABEL - - L19 ---
L19:

    // --- [97] == encontrado 0 t13 ---
    ldr     x9, [x29, #-256]
    mov     x10, #0
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-344]

    // --- [98] IFT t13 - L23 ---
    ldr     x9, [x29, #-344]
    cbnz    x9, L23

    // --- [99] GOTO - - L24 ---
    b       L24

    // --- [100] LABEL - - L23 ---
L23:

    // --- [101] WRITE "Producto no encontrado" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_17@PAGE
    add     x1, x1, _str_17@PAGEOFF
    bl      _printf

    // --- [102] LABEL - - L24 ---
L24:

    // --- [103] GOTO - - L4 ---
    b       L4

    // --- [104] LABEL - - L16 ---
L16:

    // --- [105] == opcion 4 t_sw ---
    ldr     x9, [x29, #-40]
    mov     x10, #4
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-80]

    // --- [106] IFT t_sw - L26 ---
    ldr     x9, [x29, #-80]
    cbnz    x9, L26

    // --- [107] GOTO - - L27 ---
    b       L27

    // --- [108] LABEL - - L26 ---
L26:

    // --- [109] WRITE "Clave del producto:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_6@PAGE
    add     x1, x1, _str_6@PAGEOFF
    bl      _printf

    // --- [110] READ - - claveVenta ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [111] WRITE "Cantidad a vender:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_18@PAGE
    add     x1, x1, _str_18@PAGEOFF
    bl      _printf

    // --- [112] READ - - cantidadVenta ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [113] = 0 - vendido ---
    mov     x9, #0
    str     x9, [x29, #-400]

    // --- [114] - cantidad 1 t14 ---
    ldr     x9, [x29, #-32]
    mov     x10, #1
    sub     x11, x9, x10
    str     x11, [x29, #-408]

    // --- [115] = 0 - i ---
    mov     x9, #0
    str     x9, [x29, #-168]

    // --- [116] = 1 - vendido ---
    mov     x9, #1
    str     x9, [x29, #-400]

    // --- [117] LABEL - - L28 ---
L28:

    // --- [118] <= i t14 t_for_i ---
    ldr     x9, [x29, #-168]
    ldr     x10, [x29, #-408]
    cmp     x9, x10
    cset    x11, le
    str     x11, [x29, #-184]

    // --- [119] IFT t_for_i - L29 ---
    ldr     x9, [x29, #-184]
    cbnz    x9, L29

    // --- [120] GOTO - - L30 ---
    b       L30

    // --- [121] LABEL - - L29 ---
L29:

    // --- [122] ARRGET claves i t15 ---
    // Instruccion no traducida: ARRGET

    // --- [123] == t15 claveVenta t16 ---
    ldr     x9, [x29, #-440]
    ldr     x10, [x29, #-384]
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-448]

    // --- [124] IFT t16 - L31 ---
    ldr     x9, [x29, #-448]
    cbnz    x9, L31

    // --- [125] GOTO - - L32 ---
    b       L32

    // --- [126] LABEL - - L31 ---
L31:

    // --- [127] ARRGET stock i t17 ---
    // Instruccion no traducida: ARRGET

    // --- [128] >= t17 cantidadVenta t18 ---
    ldr     x9, [x29, #-472]
    ldr     x10, [x29, #-392]
    cmp     x9, x10
    cset    x11, ge
    str     x11, [x29, #-480]

    // --- [129] IFT t18 - L34 ---
    ldr     x9, [x29, #-480]
    cbnz    x9, L34

    // --- [130] GOTO - - L35 ---
    b       L35

    // --- [131] LABEL - - L34 ---
L34:

    // --- [132] ARRGET stock i t19 ---
    // Instruccion no traducida: ARRGET

    // --- [133] - t19 cantidadVenta t20 ---
    ldr     x9, [x29, #-504]
    ldr     x10, [x29, #-392]
    sub     x11, x9, x10
    str     x11, [x29, #-512]

    // --- [134] ARRSET i t20 stock ---
    // Instruccion no traducida: ARRSET

    // --- [135] WRITE "Venta realizada" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_19@PAGE
    add     x1, x1, _str_19@PAGEOFF
    bl      _printf

    // --- [136] WRITE "Stock restante: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_20@PAGE
    add     x1, x1, _str_20@PAGEOFF
    bl      _printf

    // --- [137] ARRGET stock i t21 ---
    // Instruccion no traducida: ARRGET

    // --- [138] WRITE t21 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-520]
    bl      _printf

    // --- [139] GOTO - - L36 ---
    b       L36

    // --- [140] LABEL - - L35 ---
L35:

    // --- [141] WRITE "Stock insuficiente" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_21@PAGE
    add     x1, x1, _str_21@PAGEOFF
    bl      _printf

    // --- [142] LABEL - - L36 ---
L36:

    // --- [143] LABEL - - L32 ---
L32:

    // --- [144] + i 1 i ---
    ldr     x9, [x29, #-168]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-168]

    // --- [145] GOTO - - L28 ---
    b       L28

    // --- [146] LABEL - - L30 ---
L30:

    // --- [147] == vendido 0 t22 ---
    ldr     x9, [x29, #-400]
    mov     x10, #0
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-536]

    // --- [148] IFT t22 - L37 ---
    ldr     x9, [x29, #-536]
    cbnz    x9, L37

    // --- [149] GOTO - - L38 ---
    b       L38

    // --- [150] LABEL - - L37 ---
L37:

    // --- [151] WRITE "Producto inexistente" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_22@PAGE
    add     x1, x1, _str_22@PAGEOFF
    bl      _printf

    // --- [152] LABEL - - L38 ---
L38:

    // --- [153] GOTO - - L4 ---
    b       L4

    // --- [154] LABEL - - L27 ---
L27:

    // --- [155] == opcion 5 t_sw ---
    ldr     x9, [x29, #-40]
    mov     x10, #5
    cmp     x9, x10
    cset    x11, eq
    str     x11, [x29, #-80]

    // --- [156] IFT t_sw - L40 ---
    ldr     x9, [x29, #-80]
    cbnz    x9, L40

    // --- [157] GOTO - - L41 ---
    b       L41

    // --- [158] LABEL - - L40 ---
L40:

    // --- [159] WRITE "Saliendo del sistema" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_23@PAGE
    add     x1, x1, _str_23@PAGEOFF
    bl      _printf

    // --- [160] GOTO - - L4 ---
    b       L4

    // --- [161] LABEL - - L41 ---
L41:

    // --- [162] LABEL - - L42 ---
L42:

    // --- [163] WRITE "Opcion invalida" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_24@PAGE
    add     x1, x1, _str_24@PAGEOFF
    bl      _printf

    // --- [164] LABEL - - L4 ---
L4:

    // --- [165] GOTO - - L1 ---
    b       L1

    // --- [166] LABEL - - L2 ---
L2:

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
