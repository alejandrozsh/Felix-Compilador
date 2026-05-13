// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_str_0:    .asciz "Valor 0,0"
_str_1:    .asciz "Valor 0,1"
_str_2:    .asciz "Valor 1,0"
_str_3:    .asciz "Valor 1,1"
_str_4:    .asciz "Resultado:"
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   mat -> [x29, #-8]
//   2x2 -> [x29, #-16]
//   0,0 -> [x29, #-24]
//   0,1 -> [x29, #-32]
//   1,0 -> [x29, #-40]
//   1,1 -> [x29, #-48]
//   t1 -> [x29, #-56]
//   t2 -> [x29, #-64]
//   suma -> [x29, #-72]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #96

    // --- [0] NEWMAT mat 2x2 - ---
    // NEWMAT: operacion de matrices [pendiente]

    // --- [1] WRITE "Valor 0,0" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_0@PAGE
    add     x1, x1, _str_0@PAGEOFF
    bl      _printf

    // --- [2] MATREAD 0,0 - mat ---
    // Instruccion no traducida: MATREAD

    // --- [3] WRITE "Valor 0,1" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_1@PAGE
    add     x1, x1, _str_1@PAGEOFF
    bl      _printf

    // --- [4] MATREAD 0,1 - mat ---
    // Instruccion no traducida: MATREAD

    // --- [5] WRITE "Valor 1,0" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_2@PAGE
    add     x1, x1, _str_2@PAGEOFF
    bl      _printf

    // --- [6] MATREAD 1,0 - mat ---
    // Instruccion no traducida: MATREAD

    // --- [7] WRITE "Valor 1,1" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_3@PAGE
    add     x1, x1, _str_3@PAGEOFF
    bl      _printf

    // --- [8] MATREAD 1,1 - mat ---
    // Instruccion no traducida: MATREAD

    // --- [9] MATGET mat 0,0 t1 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [10] MATGET mat 0,1 t2 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [11] + t1 t2 suma ---
    ldr     x9, [x29, #-56]
    ldr     x10, [x29, #-64]
    add     x11, x9, x10
    str     x11, [x29, #-72]

    // --- [12] MATGET mat 1,0 t1 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [13] + suma t1 suma ---
    ldr     x9, [x29, #-72]
    ldr     x10, [x29, #-56]
    add     x11, x9, x10
    str     x11, [x29, #-72]

    // --- [14] MATGET mat 1,1 t1 ---
    // MATGET: operacion de matrices [pendiente]

    // --- [15] + suma t1 suma ---
    ldr     x9, [x29, #-72]
    ldr     x10, [x29, #-56]
    add     x11, x9, x10
    str     x11, [x29, #-72]

    // --- [16] WRITE "Resultado:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_4@PAGE
    add     x1, x1, _str_4@PAGEOFF
    bl      _printf

    // --- [17] WRITE suma - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-72]
    bl      _printf

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
