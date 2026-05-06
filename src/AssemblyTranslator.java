import java.util.*;
import java.io.*;

/**
 * COMPILADOR FELIX — Traductor de Cuádruples a Ensamblador
 * Soporta ARM64 (GNU/Clang) y x86_64 (Intel/NASM)
 */
public class AssemblyTranslator {

    // ========== Instrucción parseada ==========
    static class Quad {
        String op, arg1, arg2, result;
        Quad(String op, String a1, String a2, String res) {
            this.op = op;
            this.arg1 = "-".equals(a1) ? null : a1;
            this.arg2 = "-".equals(a2) ? null : a2;
            this.result = "-".equals(res) ? null : res;
        }
    }

    // ========== PARSER DE ARCHIVO DE CUÁDRUPLES ==========
    public static List<Quad> parseFile(String filename) throws Exception {
        List<Quad> quads = new ArrayList<Quad>();
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        String line;
        boolean inData = false;
        while ((line = reader.readLine()) != null) {
            if (line.startsWith("---")) {
                if (!inData) { inData = true; continue; }
                else break;
            }
            if (!inData) continue;
            List<String> tokens = tokenize(line.trim());
            if (tokens.size() >= 5) {
                quads.add(new Quad(tokens.get(1), tokens.get(2), tokens.get(3), tokens.get(4)));
            }
        }
        reader.close();
        return quads;
    }

    static List<String> tokenize(String line) {
        List<String> tokens = new ArrayList<String>();
        int i = 0;
        while (i < line.length()) {
            while (i < line.length() && Character.isWhitespace(line.charAt(i))) i++;
            if (i >= line.length()) break;
            if (line.charAt(i) == '"') {
                int end = line.indexOf('"', i + 1);
                if (end == -1) end = line.length() - 1;
                tokens.add(line.substring(i, end + 1));
                i = end + 1;
            } else {
                int start = i;
                while (i < line.length() && !Character.isWhitespace(line.charAt(i))) i++;
                tokens.add(line.substring(start, i));
            }
        }
        return tokens;
    }

    // ========== UTILIDADES ==========
    static boolean isNumber(String s) {
        if (s == null) return false;
        return s.matches("-?\\d+(\\.\\d+)?");
    }

    static boolean isString(String s) {
        return s != null && s.startsWith("\"") && s.endsWith("\"");
    }

    static boolean isTemp(String s) {
        return s != null && (s.matches("t\\d+") || s.startsWith("t_"));
    }

    static String stripQuotes(String s) {
        if (s.startsWith("\"") && s.endsWith("\""))
            return s.substring(1, s.length() - 1);
        return s;
    }

    // Recolecta variables y temporales, asigna offsets en el stack
    static Map<String, Integer> buildStackMap(List<Quad> quads) {
        Map<String, Integer> map = new LinkedHashMap<String, Integer>();
        int offset = 8;
        for (Quad q : quads) {
            String[] ops = { q.result, q.arg1, q.arg2 };
            for (String s : ops) {
                if (s != null && !isNumber(s) && !isString(s) && !map.containsKey(s)) {
                    map.put(s, offset);
                    offset += 8;
                }
            }
        }
        return map;
    }

    // Recolecta cadenas literales únicas
    static List<String> collectStrings(List<Quad> quads) {
        List<String> strings = new ArrayList<String>();
        Set<String> seen = new LinkedHashSet<String>();
        for (Quad q : quads) {
            String[] ops = { q.arg1, q.arg2 };
            for (String s : ops) {
                if (s != null && isString(s) && !seen.contains(s)) {
                    seen.add(s);
                    strings.add(s);
                }
            }
        }
        return strings;
    }

    static int alignStack(int size) {
        return ((size + 15) / 16) * 16;
    }

    // ========== GENERADOR ARM64 (GNU/Clang) ==========
    public static String generateARM64(List<Quad> quads, String srcFile, String timestamp) {
        Map<String, Integer> stack = buildStackMap(quads);
        List<String> strings = collectStrings(quads);
        Map<String, Integer> strIdx = new LinkedHashMap<String, Integer>();
        for (int i = 0; i < strings.size(); i++) strIdx.put(strings.get(i), i);
        int frameSize = alignStack(stack.size() * 8 + 16);

        StringBuilder sb = new StringBuilder();
        // Encabezado
        sb.append("// Codigo Ensamblador ARM64\n");
        sb.append("// Sintaxis: GNU/Clang (aarch64)\n");

        // Sección de datos
        sb.append("    .section __DATA,__data\n");
        sb.append("    .align  3\n\n");
        sb.append("// --- Cadenas literales ---\n");
        for (int i = 0; i < strings.size(); i++) {
            sb.append("_str_").append(i).append(":    .asciz ").append(strings.get(i)).append("\n");
        }
        sb.append("_fmt_int:   .asciz \"%lld\\n\"\n");
        sb.append("_fmt_str:   .asciz \"%s\\n\"\n");
        sb.append("\n");

        // Mapa de variables como comentario
        sb.append("// --- Mapa de variables (stack offsets) ---\n");
        for (Map.Entry<String, Integer> e : stack.entrySet()) {
            sb.append("//   ").append(e.getKey()).append(" -> [x29, #-").append(e.getValue()).append("]\n");
        }
        sb.append("\n");

        // Sección de código
        sb.append("    .section __TEXT,__text\n");
        sb.append("    .global _main\n");
        sb.append("    .align  2\n\n");
        sb.append("_main:\n");
        sb.append("    // Prologo\n");
        sb.append("    stp     x29, x30, [sp, #-16]!\n");
        sb.append("    mov     x29, sp\n");
        sb.append("    sub     sp, sp, #").append(frameSize).append("\n\n");

        // Traducir cada cuádruple
        for (int i = 0; i < quads.size(); i++) {
            Quad q = quads.get(i);
            sb.append("    // --- [").append(i).append("] ");
            sb.append(q.op).append(" ").append(q.arg1 != null ? q.arg1 : "-");
            sb.append(" ").append(q.arg2 != null ? q.arg2 : "-");
            sb.append(" ").append(q.result != null ? q.result : "-").append(" ---\n");

            if (q.op.equals("=")) {
                emitARM64Load(sb, q.arg1, "x9", stack, strIdx);
                emitARM64Store(sb, "x9", q.result, stack);
            }
            else if (q.op.equals("+") || q.op.equals("-") || q.op.equals("*") || q.op.equals("/")) {
                emitARM64Load(sb, q.arg1, "x9", stack, strIdx);
                emitARM64Load(sb, q.arg2, "x10", stack, strIdx);
                String inst = q.op.equals("+") ? "add" : q.op.equals("-") ? "sub" : q.op.equals("*") ? "mul" : "sdiv";
                sb.append("    ").append(inst).append("     x11, x9, x10\n");
                emitARM64Store(sb, "x11", q.result, stack);
            }
            else if (q.op.equals("WRITE")) {
                if (isString(q.arg1)) {
                    int si = strIdx.get(q.arg1);
                    sb.append("    adrp    x0, _fmt_str@PAGE\n");
                    sb.append("    add     x0, x0, _fmt_str@PAGEOFF\n");
                    sb.append("    adrp    x1, _str_").append(si).append("@PAGE\n");
                    sb.append("    add     x1, x1, _str_").append(si).append("@PAGEOFF\n");
                } else {
                    sb.append("    adrp    x0, _fmt_int@PAGE\n");
                    sb.append("    add     x0, x0, _fmt_int@PAGEOFF\n");
                    emitARM64Load(sb, q.arg1, "x1", stack, strIdx);
                }
                sb.append("    bl      _printf\n");
            }
            else if (q.op.equals("READ")) {
                sb.append("    // READ: lectura de entrada (requiere scanf)\n");
                sb.append("    // [pendiente: implementacion completa]\n");
            }
            else if (q.op.equals("LABEL")) {
                sb.append(q.result).append(":\n");
            }
            else if (q.op.equals("GOTO")) {
                sb.append("    b       ").append(q.result).append("\n");
            }
            else if (q.op.equals("IFT")) {
                emitARM64Load(sb, q.arg1, "x9", stack, strIdx);
                sb.append("    cbnz    x9, ").append(q.result).append("\n");
            }
            else if (q.op.equals("<") || q.op.equals("<=") || q.op.equals(">") || q.op.equals(">=") || q.op.equals("==") || q.op.equals("!=")) {
                emitARM64Load(sb, q.arg1, "x9", stack, strIdx);
                emitARM64Load(sb, q.arg2, "x10", stack, strIdx);
                sb.append("    cmp     x9, x10\n");
                String cond = q.op.equals("<") ? "lt" : q.op.equals("<=") ? "le" : q.op.equals(">") ? "gt" : q.op.equals(">=") ? "ge" : q.op.equals("==") ? "eq" : "ne";
                sb.append("    cset    x11, ").append(cond).append("\n");
                emitARM64Store(sb, "x11", q.result, stack);
            }
            else if (q.op.equals("NEG")) {
                emitARM64Load(sb, q.arg1, "x9", stack, strIdx);
                sb.append("    neg     x11, x9\n");
                emitARM64Store(sb, "x11", q.result, stack);
            }
            else if (q.op.equals("NOT")) {
                emitARM64Load(sb, q.arg1, "x9", stack, strIdx);
                sb.append("    cmp     x9, #0\n");
                sb.append("    cset    x11, eq\n");
                emitARM64Store(sb, "x11", q.result, stack);
            }
            else if (q.op.equals("NEWMAT") || q.op.equals("MATGET")) {
                sb.append("    // ").append(q.op).append(": operacion de matrices [pendiente]\n");
            }
            else {
                sb.append("    // Instruccion no traducida: ").append(q.op).append("\n");
            }
            sb.append("\n");
        }

        // Epílogo
        sb.append("    // Epilogo\n");
        sb.append("    mov     x0, #0\n");
        sb.append("    mov     sp, x29\n");
        sb.append("    ldp     x29, x30, [sp], #16\n");
        sb.append("    ret\n");

        return sb.toString();
    }

    static void emitARM64Load(StringBuilder sb, String operand, String reg, Map<String, Integer> stack, Map<String, Integer> strIdx) {
        if (isNumber(operand)) {
            long val = Long.parseLong(operand.contains(".") ? operand.split("\\.")[0] : operand);
            sb.append("    mov     ").append(reg).append(", #").append(val).append("\n");
        } else if (stack.containsKey(operand)) {
            sb.append("    ldr     ").append(reg).append(", [x29, #-").append(stack.get(operand)).append("]\n");
        } else {
            sb.append("    // [warn] operando desconocido: ").append(operand).append("\n");
        }
    }

    static void emitARM64Store(StringBuilder sb, String reg, String dest, Map<String, Integer> stack) {
        if (dest != null && stack.containsKey(dest)) {
            sb.append("    str     ").append(reg).append(", [x29, #-").append(stack.get(dest)).append("]\n");
        }
    }

    // ========== GENERADOR x86_64 (Intel/NASM) ==========
    public static String generateX86(List<Quad> quads, String srcFile, String timestamp) {
        Map<String, Integer> stack = buildStackMap(quads);
        List<String> strings = collectStrings(quads);
        Map<String, Integer> strIdx = new LinkedHashMap<String, Integer>();
        for (int i = 0; i < strings.size(); i++) strIdx.put(strings.get(i), i);
        int frameSize = alignStack(stack.size() * 8 + 16);

        StringBuilder sb = new StringBuilder();
        sb.append("; Codigo Ensamblador x86_64\n");
        sb.append("; Sintaxis: Intel (NASM)\n");

        // Datos
        sb.append("    section .data\n\n");
        sb.append("; --- Cadenas literales ---\n");
        for (int i = 0; i < strings.size(); i++) {
            sb.append("str_").append(i).append(":      db ").append(strings.get(i)).append(", 0\n");
        }
        sb.append("fmt_int:    db \"%lld\", 10, 0\n");
        sb.append("fmt_str:    db \"%s\", 10, 0\n\n");

        // Mapa
        sb.append("; --- Mapa de variables (stack offsets) ---\n");
        for (Map.Entry<String, Integer> e : stack.entrySet()) {
            sb.append(";   ").append(e.getKey()).append(" -> [rbp-").append(e.getValue()).append("]\n");
        }
        sb.append("\n");

        // Código
        sb.append("    section .text\n");
        sb.append("    global  main\n");
        sb.append("    extern  printf\n\n");
        sb.append("main:\n");
        sb.append("    ; Prologo\n");
        sb.append("    push    rbp\n");
        sb.append("    mov     rbp, rsp\n");
        sb.append("    sub     rsp, ").append(frameSize).append("\n\n");

        for (int i = 0; i < quads.size(); i++) {
            Quad q = quads.get(i);
            sb.append("    ; --- [").append(i).append("] ");
            sb.append(q.op).append(" ").append(q.arg1 != null ? q.arg1 : "-");
            sb.append(" ").append(q.arg2 != null ? q.arg2 : "-");
            sb.append(" ").append(q.result != null ? q.result : "-").append(" ---\n");

            if (q.op.equals("=")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                emitX86Store(sb, "rax", q.result, stack);
            }
            else if (q.op.equals("+") || q.op.equals("-") || q.op.equals("*")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                emitX86Load(sb, q.arg2, "rcx", stack);
                if (q.op.equals("+")) sb.append("    add     rax, rcx\n");
                else if (q.op.equals("-")) sb.append("    sub     rax, rcx\n");
                else sb.append("    imul    rax, rcx\n");
                emitX86Store(sb, "rax", q.result, stack);
            }
            else if (q.op.equals("/")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                sb.append("    cqo\n");
                emitX86Load(sb, q.arg2, "rcx", stack);
                sb.append("    idiv    rcx\n");
                emitX86Store(sb, "rax", q.result, stack);
            }
            else if (q.op.equals("WRITE")) {
                if (isString(q.arg1)) {
                    int si = strIdx.get(q.arg1);
                    sb.append("    lea     rdi, [rel fmt_str]\n");
                    sb.append("    lea     rsi, [rel str_").append(si).append("]\n");
                } else {
                    sb.append("    lea     rdi, [rel fmt_int]\n");
                    emitX86Load(sb, q.arg1, "rsi", stack);
                }
                sb.append("    xor     eax, eax\n");
                sb.append("    call    printf\n");
            }
            else if (q.op.equals("READ")) {
                sb.append("    ; READ: lectura de entrada (requiere scanf)\n");
                sb.append("    ; [pendiente: implementacion completa]\n");
            }
            else if (q.op.equals("LABEL")) {
                sb.append(q.result).append(":\n");
            }
            else if (q.op.equals("GOTO")) {
                sb.append("    jmp     ").append(q.result).append("\n");
            }
            else if (q.op.equals("IFT")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                sb.append("    cmp     rax, 0\n");
                sb.append("    jne     ").append(q.result).append("\n");
            }
            else if (q.op.equals("<") || q.op.equals("<=") || q.op.equals(">") || q.op.equals(">=") || q.op.equals("==") || q.op.equals("!=")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                emitX86Load(sb, q.arg2, "rcx", stack);
                sb.append("    cmp     rax, rcx\n");
                String inst = q.op.equals("<") ? "setl" : q.op.equals("<=") ? "setle" : q.op.equals(">") ? "setg" : q.op.equals(">=") ? "setge" : q.op.equals("==") ? "sete" : "setne";
                sb.append("    ").append(inst).append("    al\n");
                sb.append("    movzx   rax, al\n");
                emitX86Store(sb, "rax", q.result, stack);
            }
            else if (q.op.equals("NEG")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                sb.append("    neg     rax\n");
                emitX86Store(sb, "rax", q.result, stack);
            }
            else if (q.op.equals("NOT")) {
                emitX86Load(sb, q.arg1, "rax", stack);
                sb.append("    cmp     rax, 0\n");
                sb.append("    sete    al\n");
                sb.append("    movzx   rax, al\n");
                emitX86Store(sb, "rax", q.result, stack);
            }
            else if (q.op.equals("NEWMAT") || q.op.equals("MATGET")) {
                sb.append("    ; ").append(q.op).append(": operacion de matrices [pendiente]\n");
            }
            else {
                sb.append("    ; Instruccion no traducida: ").append(q.op).append("\n");
            }
            sb.append("\n");
        }

        sb.append("    ; Epilogo\n");
        sb.append("    xor     eax, eax\n");
        sb.append("    leave\n");
        sb.append("    ret\n");

        return sb.toString();
    }

    static void emitX86Load(StringBuilder sb, String operand, String reg, Map<String, Integer> stack) {
        if (isNumber(operand)) {
            long val = Long.parseLong(operand.contains(".") ? operand.split("\\.")[0] : operand);
            sb.append("    mov     ").append(reg).append(", ").append(val).append("\n");
        } else if (stack.containsKey(operand)) {
            sb.append("    mov     ").append(reg).append(", [rbp-").append(stack.get(operand)).append("]\n");
        } else {
            sb.append("    ; [warn] operando desconocido: ").append(operand).append("\n");
        }
    }

    static void emitX86Store(StringBuilder sb, String reg, String dest, Map<String, Integer> stack) {
        if (dest != null && stack.containsKey(dest)) {
            sb.append("    mov     qword [rbp-").append(stack.get(dest)).append("], ").append(reg).append("\n");
        }
    }

    // ========== MAIN ==========
    public static void main(String[] args) {
        if (args.length < 1) {
            System.out.println("Uso: java AssemblyTranslator <archivo_cuadruples_opt.txt>");
            System.exit(1);
        }
        String inputFile = args[0];
        String baseName = inputFile;
        int dotIdx = inputFile.lastIndexOf('.');
        if (dotIdx > 0) baseName = inputFile.substring(0, dotIdx);
        baseName = baseName.replace("_cuadruples_opt", "");

        java.time.LocalDateTime now = java.time.LocalDateTime.now();
        String timestamp = now.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));

        try {
            List<Quad> quads = parseFile(inputFile);
            if (quads.isEmpty()) {
                System.out.println("WARN: No se encontraron cuadruples en " + inputFile);
                return;
            }

            // Generar ARM64
            String arm64 = generateARM64(quads, inputFile, timestamp);
            String arm64File = baseName + "_asm_arm64.s";
            PrintWriter pw1 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(arm64File), "UTF-8"));
            pw1.print(arm64);
            pw1.close();

            // Generar x86_64
            String x86 = generateX86(quads, inputFile, timestamp);
            String x86File = baseName + "_asm_x86.s";
            PrintWriter pw2 = new PrintWriter(new OutputStreamWriter(new FileOutputStream(x86File), "UTF-8"));
            pw2.print(x86);
            pw2.close();

            System.out.println("Ensamblador generado:\n- " + arm64File + "\n- " + x86File);
        } catch (Exception e) {
            System.out.println("ERROR en traduccion a ensamblador: " + e.getMessage());
            System.exit(1);
        }
    }
}
