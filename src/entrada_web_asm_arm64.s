// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_str_0:    .asciz "El impuesto a pagar es:"
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   impuesto -> [x29, #-8]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #32

    // --- [0] * 500.0 0.16 impuesto ---
    mov     x9, #500
    mov     x10, #0
    mul     x11, x9, x10
    str     x11, [x29, #-8]

    // --- [1] WRITE "El impuesto a pagar es:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_0@PAGE
    add     x1, x1, _str_0@PAGEOFF
    bl      _printf

    // --- [2] WRITE impuesto - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-8]
    bl      _printf

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
