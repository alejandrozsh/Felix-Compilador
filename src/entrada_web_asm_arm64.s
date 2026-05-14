// Codigo Ensamblador ARM64
// Sintaxis: GNU/Clang (aarch64)
    .section __DATA,__data
    .align  3

// --- Cadenas literales ---
_str_0:    .asciz "Cantidad de alumnos:"
_str_1:    .asciz "Nombre del alumno:"
_str_2:    .asciz "Calificacion:"
_str_3:    .asciz "Promedio general: "
_str_4:    .asciz "Mayor calificacion:"
_str_5:    .asciz " -> "
_str_6:    .asciz "Menor calificacion:"
_str_7:    .asciz " APROBADO"
_str_8:    .asciz " REPROBADO"
_fmt_int:   .asciz "%lld\n"
_fmt_str:   .asciz "%s\n"

// --- Mapa de variables (stack offsets) ---
//   nombres -> [x29, #-8]
//   calificaciones -> [x29, #-16]
//   suma -> [x29, #-24]
//   mayor -> [x29, #-32]
//   menor -> [x29, #-40]
//   cantidad -> [x29, #-48]
//   t2 -> [x29, #-56]
//   i -> [x29, #-64]
//   L1 -> [x29, #-72]
//   t_for_i -> [x29, #-80]
//   L2 -> [x29, #-88]
//   L3 -> [x29, #-96]
//   t3 -> [x29, #-104]
//   t6 -> [x29, #-112]
//   L4 -> [x29, #-120]
//   L5 -> [x29, #-128]
//   nombreMayor -> [x29, #-136]
//   t9 -> [x29, #-144]
//   t10 -> [x29, #-152]
//   L7 -> [x29, #-160]
//   L8 -> [x29, #-168]
//   nombreMenor -> [x29, #-176]
//   promedio -> [x29, #-184]
//   t14 -> [x29, #-192]
//   j -> [x29, #-200]
//   L10 -> [x29, #-208]
//   t_for_j -> [x29, #-216]
//   L11 -> [x29, #-224]
//   L12 -> [x29, #-232]
//   t15 -> [x29, #-240]
//   t16 -> [x29, #-248]
//   L13 -> [x29, #-256]
//   L14 -> [x29, #-264]
//   t17 -> [x29, #-272]
//   L15 -> [x29, #-280]
//   t18 -> [x29, #-288]

    .section __TEXT,__text
    .global _main
    .align  2

_main:
    // Prologo
    stp     x29, x30, [sp, #-16]!
    mov     x29, sp
    sub     sp, sp, #304

    // --- [0] NEWARR nombres 100 - ---
    // Instruccion no traducida: NEWARR

    // --- [1] NEWARR calificaciones 100 - ---
    // Instruccion no traducida: NEWARR

    // --- [2] = 0.0 - suma ---
    mov     x9, #0
    str     x9, [x29, #-24]

    // --- [3] NEG 1.0 - mayor ---
    mov     x9, #1
    neg     x11, x9
    str     x11, [x29, #-32]

    // --- [4] = 101.0 - menor ---
    mov     x9, #101
    str     x9, [x29, #-40]

    // --- [5] WRITE "Cantidad de alumnos:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_0@PAGE
    add     x1, x1, _str_0@PAGEOFF
    bl      _printf

    // --- [6] READ - - cantidad ---
    // READ: lectura de entrada (requiere scanf)
    // [pendiente: implementacion completa]

    // --- [7] - cantidad 1 t2 ---
    ldr     x9, [x29, #-48]
    mov     x10, #1
    sub     x11, x9, x10
    str     x11, [x29, #-56]

    // --- [8] = 0 - i ---
    mov     x9, #0
    str     x9, [x29, #-64]

    // --- [9] LABEL - - L1 ---
L1:

    // --- [10] <= i t2 t_for_i ---
    ldr     x9, [x29, #-64]
    ldr     x10, [x29, #-56]
    cmp     x9, x10
    cset    x11, le
    str     x11, [x29, #-80]

    // --- [11] IFT t_for_i - L2 ---
    ldr     x9, [x29, #-80]
    cbnz    x9, L2

    // --- [12] GOTO - - L3 ---
    b       L3

    // --- [13] LABEL - - L2 ---
L2:

    // --- [14] WRITE "Nombre del alumno:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_1@PAGE
    add     x1, x1, _str_1@PAGEOFF
    bl      _printf

    // --- [15] ARRREAD i - nombres ---
    // Instruccion no traducida: ARRREAD

    // --- [16] WRITE "Calificacion:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_2@PAGE
    add     x1, x1, _str_2@PAGEOFF
    bl      _printf

    // --- [17] ARRREAD i - calificaciones ---
    // Instruccion no traducida: ARRREAD

    // --- [18] ARRGET calificaciones i t3 ---
    // Instruccion no traducida: ARRGET

    // --- [19] + suma t3 suma ---
    ldr     x9, [x29, #-24]
    ldr     x10, [x29, #-104]
    add     x11, x9, x10
    str     x11, [x29, #-24]

    // --- [20] > t3 mayor t6 ---
    ldr     x9, [x29, #-104]
    ldr     x10, [x29, #-32]
    cmp     x9, x10
    cset    x11, gt
    str     x11, [x29, #-112]

    // --- [21] IFT t6 - L4 ---
    ldr     x9, [x29, #-112]
    cbnz    x9, L4

    // --- [22] GOTO - - L5 ---
    b       L5

    // --- [23] LABEL - - L4 ---
L4:

    // --- [24] ARRGET calificaciones i mayor ---
    // Instruccion no traducida: ARRGET

    // --- [25] ARRGET nombres i nombreMayor ---
    // Instruccion no traducida: ARRGET

    // --- [26] LABEL - - L5 ---
L5:

    // --- [27] ARRGET calificaciones i t9 ---
    // Instruccion no traducida: ARRGET

    // --- [28] < t9 menor t10 ---
    ldr     x9, [x29, #-144]
    ldr     x10, [x29, #-40]
    cmp     x9, x10
    cset    x11, lt
    str     x11, [x29, #-152]

    // --- [29] IFT t10 - L7 ---
    ldr     x9, [x29, #-152]
    cbnz    x9, L7

    // --- [30] GOTO - - L8 ---
    b       L8

    // --- [31] LABEL - - L7 ---
L7:

    // --- [32] ARRGET calificaciones i menor ---
    // Instruccion no traducida: ARRGET

    // --- [33] ARRGET nombres i nombreMenor ---
    // Instruccion no traducida: ARRGET

    // --- [34] LABEL - - L8 ---
L8:

    // --- [35] + i 1 i ---
    ldr     x9, [x29, #-64]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-64]

    // --- [36] GOTO - - L1 ---
    b       L1

    // --- [37] LABEL - - L3 ---
L3:

    // --- [38] / suma cantidad promedio ---
    ldr     x9, [x29, #-24]
    ldr     x10, [x29, #-48]
    sdiv     x11, x9, x10
    str     x11, [x29, #-184]

    // --- [39] WRITE "Promedio general: " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_3@PAGE
    add     x1, x1, _str_3@PAGEOFF
    bl      _printf

    // --- [40] WRITE promedio - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-184]
    bl      _printf

    // --- [41] WRITE "Mayor calificacion:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_4@PAGE
    add     x1, x1, _str_4@PAGEOFF
    bl      _printf

    // --- [42] WRITE nombreMayor - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-136]
    bl      _printf

    // --- [43] WRITE " -> " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_5@PAGE
    add     x1, x1, _str_5@PAGEOFF
    bl      _printf

    // --- [44] WRITE mayor - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-32]
    bl      _printf

    // --- [45] WRITE "Menor calificacion:" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_6@PAGE
    add     x1, x1, _str_6@PAGEOFF
    bl      _printf

    // --- [46] WRITE nombreMenor - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-176]
    bl      _printf

    // --- [47] WRITE " -> " - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_5@PAGE
    add     x1, x1, _str_5@PAGEOFF
    bl      _printf

    // --- [48] WRITE menor - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-40]
    bl      _printf

    // --- [49] - cantidad 1 t14 ---
    ldr     x9, [x29, #-48]
    mov     x10, #1
    sub     x11, x9, x10
    str     x11, [x29, #-192]

    // --- [50] = 0 - j ---
    mov     x9, #0
    str     x9, [x29, #-200]

    // --- [51] LABEL - - L10 ---
L10:

    // --- [52] <= j t14 t_for_j ---
    ldr     x9, [x29, #-200]
    ldr     x10, [x29, #-192]
    cmp     x9, x10
    cset    x11, le
    str     x11, [x29, #-216]

    // --- [53] IFT t_for_j - L11 ---
    ldr     x9, [x29, #-216]
    cbnz    x9, L11

    // --- [54] GOTO - - L12 ---
    b       L12

    // --- [55] LABEL - - L11 ---
L11:

    // --- [56] ARRGET calificaciones j t15 ---
    // Instruccion no traducida: ARRGET

    // --- [57] >= t15 70.0 t16 ---
    ldr     x9, [x29, #-240]
    mov     x10, #70
    cmp     x9, x10
    cset    x11, ge
    str     x11, [x29, #-248]

    // --- [58] IFT t16 - L13 ---
    ldr     x9, [x29, #-248]
    cbnz    x9, L13

    // --- [59] GOTO - - L14 ---
    b       L14

    // --- [60] LABEL - - L13 ---
L13:

    // --- [61] ARRGET nombres j t17 ---
    // Instruccion no traducida: ARRGET

    // --- [62] WRITE t17 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-272]
    bl      _printf

    // --- [63] WRITE " APROBADO" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_7@PAGE
    add     x1, x1, _str_7@PAGEOFF
    bl      _printf

    // --- [64] GOTO - - L15 ---
    b       L15

    // --- [65] LABEL - - L14 ---
L14:

    // --- [66] ARRGET nombres j t18 ---
    // Instruccion no traducida: ARRGET

    // --- [67] WRITE t18 - - ---
    adrp    x0, _fmt_int@PAGE
    add     x0, x0, _fmt_int@PAGEOFF
    ldr     x1, [x29, #-288]
    bl      _printf

    // --- [68] WRITE " REPROBADO" - - ---
    adrp    x0, _fmt_str@PAGE
    add     x0, x0, _fmt_str@PAGEOFF
    adrp    x1, _str_8@PAGE
    add     x1, x1, _str_8@PAGEOFF
    bl      _printf

    // --- [69] LABEL - - L15 ---
L15:

    // --- [70] + j 1 j ---
    ldr     x9, [x29, #-200]
    mov     x10, #1
    add     x11, x9, x10
    str     x11, [x29, #-200]

    // --- [71] GOTO - - L10 ---
    b       L10

    // --- [72] LABEL - - L12 ---
L12:

    // Epilogo
    mov     x0, #0
    mov     sp, x29
    ldp     x29, x30, [sp], #16
    ret
