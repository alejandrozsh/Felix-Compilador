// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_str_0:    .asciz "Cantidad:"
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   n -> [x29, #-8]
//   a -> [x29, #-16]
//   b -> [x29, #-24]
//   i -> [x29, #-32]
//   L1 -> [x29, #-40]
//   t1 -> [x29, #-48]
//   L3 -> [x29, #-56]
//   L2 -> [x29, #-64]
//   temp -> [x29, #-72]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #96

    // --- [0] WRITE "Cantidad:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_0@PAGE
    add     x1, x1, _str_0@PAGEOFF
    bl      _printf

    // --- [1] READ - - n ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [2] = 0 - a ---
    mov     x9, #0
    str     x9, [x29, #-16]

    // --- [3] = 1 - b ---
    mov     x9, #1
    str     x9, [x29, #-24]

    // --- [4] = 0 - i ---
    mov     x9, #0
    str     x9, [x29, #-32]

    // --- [5] LABEL - - L1 ---
L1:

    // --- [6] < i n t1 ---
    ldr     x9, [x29, #-32]
    ldr     x10, [x29, #-8]
    cmp     x9, x10
    cset    x11, lt
    str     x11, [x29, #-48]

    // --- [7] IFT t1 - L3 ---
    ldr     x9, [x29, #-48]
    cbnz    x9, L3

    // --- [8] GOTO - - L2 ---
    b       L2

    // --- [9] LABEL - - L3 ---
L3:

    // --- [10] WRITE a - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-16]
    bl      _printf

    // --- [11] + a b temp ---
    ldr     x9, [x29, #-16]
    ldr     x10, [x29, #-24]
    add     x11, x9, x10
    str     x11, [x29, #-72]

    // --- [12] = b - a ---
    ldr     x9, [x29, #-24]
    str     x9, [x29, #-16]

    // --- [13] = temp - b ---
    ldr     x9, [x29, #-72]
    str     x9, [x29, #-24]

    // --- [14] + i 1 i ---
    ldr     x9, [x29, #-32]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-32]

    // --- [15] GOTO - - L1 ---
    b       L1

    // --- [16] LABEL - - L2 ---
L2:

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
