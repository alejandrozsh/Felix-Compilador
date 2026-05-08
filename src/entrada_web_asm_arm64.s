// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_str_0:    .asciz "Ingrese los valores para la matriz 2x2:"
_str_1:    .asciz "m[0][0]:"
_str_2:    .asciz "m[0][1]:"
_str_3:    .asciz "m[1][0]:"
_str_4:    .asciz "m[1][1]:"
_str_5:    .asciz "La suma de todos los elementos es:"
_str_6:    .asciz "El promedio es:"
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   m -> [x29, #-8]
//   2x2 -> [x29, #-16]
//   0,0 -> [x29, #-24]
//   0,1 -> [x29, #-32]
//   1,0 -> [x29, #-40]
//   1,1 -> [x29, #-48]
//   t1 -> [x29, #-56]
//   t2 -> [x29, #-64]
//   t3 -> [x29, #-72]
//   t4 -> [x29, #-80]
//   t5 -> [x29, #-88]
//   t6 -> [x29, #-96]
//   suma -> [x29, #-104]
//   promedio -> [x29, #-112]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #128

    // --- [0] NEWMAT m 2x2 - ---
    // NEWMAT: operacion de matrices [pendiente]

    // --- [1] WRITE "Ingrese los valores para la matriz 2x2:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_0@PAGE
    add     x1, x1, _str_0@PAGEOFF
    bl      _printf

    // --- [2] WRITE "m[0][0]:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_1@PAGE
    add     x1, x1, _str_1@PAGEOFF
    bl      _printf

    // --- [3] MATREAD 0,0 - m ---
    // Instruccion no traducida: MATREAD

    // --- [4] WRITE "m[0][1]:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_2@PAGE
    add     x1, x1, _str_2@PAGEOFF
    bl      _printf

    // --- [5] MATREAD 0,1 - m ---
    // Instruccion no traducida: MATREAD

    // --- [6] WRITE "m[1][0]:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_3@PAGE
    add     x1, x1, _str_3@PAGEOFF
    bl      _printf

    // --- [7] MATREAD 1,0 - m ---
    // Instruccion no traducida: MATREAD

    // --- [8] WRITE "m[1][1]:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_4@PAGE
    add     x1, x1, _str_4@PAGEOFF
    bl      _printf

    // --- [9] MATREAD 1,1 - m ---
    // Instruccion no traducida: MATREAD

    // --- [10] MATGET m 0,0 t1 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [11] MATGET m 0,1 t2 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [12] + t1 t2 t3 ---
    ldr     x9, [x29, #-56]
    ldr     x10, [x29, #-64]
    add     x11, x9, x10
    str     x11, [x29, #-72]

    // --- [13] MATGET m 1,0 t4 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [14] + t3 t4 t5 ---
    ldr     x9, [x29, #-72]
    ldr     x10, [x29, #-80]
    add     x11, x9, x10
    str     x11, [x29, #-88]

    // --- [15] MATGET m 1,1 t6 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [16] + t5 t6 suma ---
    ldr     x9, [x29, #-88]
    ldr     x10, [x29, #-96]
    add     x11, x9, x10
    str     x11, [x29, #-104]

    // --- [17] WRITE "La suma de todos los elementos es:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_5@PAGE
    add     x1, x1, _str_5@PAGEOFF
    bl      _printf

    // --- [18] WRITE suma - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-104]
    bl      _printf

    // --- [19] / suma 4 promedio ---
    ldr     x9, [x29, #-104]
    mov     x10, #4
    sdiv     x11, x9, x10
    str     x11, [x29, #-112]

    // --- [20] WRITE "El promedio es:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_6@PAGE
    add     x1, x1, _str_6@PAGEOFF
    bl      _printf

    // --- [21] WRITE promedio - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-112]
    bl      _printf

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
