// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   a -> [x29, #-8]
//   b -> [x29, #-16]
//   L1 -> [x29, #-24]
//   t1 -> [x29, #-32]
//   L3 -> [x29, #-40]
//   L2 -> [x29, #-48]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #64

    // --- [0] READ - - a ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [1] READ - - b ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [2] LABEL - - L1 ---
L1:

    // --- [3] < a b t1 ---
    ldr     x9, [x29, #-8]
    ldr     x10, [x29, #-16]
    cmp     x9, x10
    cset    x11, lt
    str     x11, [x29, #-32]

    // --- [4] IFT t1 - L3 ---
    ldr     x9, [x29, #-32]
    cbnz    x9, L3

    // --- [5] GOTO - - L2 ---
    b       L2

    // --- [6] LABEL - - L3 ---
L3:

    // --- [7] + a 1 t1 ---
    ldr     x9, [x29, #-8]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-32]

    // --- [8] WRITE t1 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-32]
    bl      _printf

    // --- [9] WRITE a - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-8]
    bl      _printf

    // --- [10] GOTO - - L1 ---
    b       L1

    // --- [11] LABEL - - L2 ---
L2:

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
