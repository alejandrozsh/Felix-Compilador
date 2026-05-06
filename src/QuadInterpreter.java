import java.io.*;
import java.util.*;
import java.util.regex.*;

/**
 * QuadInterpreter — Intérprete de cuádruples optimizados.
 * Lee el archivo de cuádruples generado por Felix y ejecuta el programa,
 * produciendo la salida real (WRITE → stdout).
 *
 * Uso: java QuadInterpreter entrada_web_cuadruples_opt.txt
 */
public class QuadInterpreter {

    // ============================================================
    // Estructura de un cuádruplo parseado
    // ============================================================
    static class Quad {
        int index;
        String op, arg1, arg2, result;
        Quad(int i, String op, String a1, String a2, String res) {
            this.index = i; this.op = op;
            this.arg1 = a1; this.arg2 = a2; this.result = res;
        }
    }

    // ============================================================
    // Estado del intérprete
    // ============================================================
    private List<Quad> quads = new ArrayList<Quad>();
    private Map<String, Object> memory = new LinkedHashMap<String, Object>();
    private Map<String, Integer> labelIndex = new LinkedHashMap<String, Integer>();
    private StringBuilder output = new StringBuilder();

    // ============================================================
    // Parsear el archivo de cuádruples
    // ============================================================
    public void loadFromFile(String filename) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(filename), "UTF-8"));
        String line;
        boolean inData = false;

        while ((line = br.readLine()) != null) {
            String trimmed = line.trim();

            // Detectar inicio de datos (después del header de la tabla)
            if (trimmed.startsWith("--------------------------------------------------")) {
                if (inData) break;   // Segunda línea de guiones = fin de datos
                inData = true;
                continue;
            }

            if (!inData) continue;
            if (trimmed.isEmpty()) continue;
            if (trimmed.startsWith("Total de") || trimmed.startsWith("====")) break;

            // Parsear la línea del cuádruplo
            Quad q = parseLine(trimmed);
            if (q != null) quads.add(q);
        }
        br.close();

        // Construir índice de etiquetas
        for (int i = 0; i < quads.size(); i++) {
            if (quads.get(i).op.equals("LABEL")) {
                labelIndex.put(quads.get(i).result, i);
            }
        }
    }

    // ============================================================
    // Parsear una línea individual de cuádruplo
    // ============================================================
    private Quad parseLine(String line) {
        // Formato: No.  Operador  Arg1  Arg2  Resultado
        // Necesitamos manejar strings con espacios entre comillas

        List<String> tokens = new ArrayList<String>();
        boolean inQuote = false;
        StringBuilder current = new StringBuilder();

        for (int i = 0; i < line.length(); i++) {
            char c = line.charAt(i);
            if (c == '"') {
                inQuote = !inQuote;
                current.append(c);
            } else if (c == ' ' && !inQuote) {
                if (current.length() > 0) {
                    tokens.add(current.toString());
                    current = new StringBuilder();
                }
            } else {
                current.append(c);
            }
        }
        if (current.length() > 0) tokens.add(current.toString());

        // Mínimo necesitamos: índice, operador
        if (tokens.size() < 2) return null;

        try {
            int idx = Integer.parseInt(tokens.get(0));
            String op = tokens.get(1);
            String a1 = tokens.size() > 2 ? cleanDash(tokens.get(2)) : null;
            String a2 = tokens.size() > 3 ? cleanDash(tokens.get(3)) : null;
            String res = tokens.size() > 4 ? cleanDash(tokens.get(4)) : null;
            return new Quad(idx, op, a1, a2, res);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String cleanDash(String s) {
        if (s == null) return null;
        if (s.equals("-") || s.equals("_") || s.equals("-")) return null;
        return s;
    }

    // ============================================================
    // Resolver un valor (literal, variable o temporal)
    // ============================================================
    private Object resolve(String operand) {
        if (operand == null) return null;

        // String literal
        if (operand.startsWith("\"") && operand.endsWith("\"")) {
            return operand.substring(1, operand.length() - 1);
        }

        // Boolean
        if (operand.equalsIgnoreCase("true")) return 1.0;
        if (operand.equalsIgnoreCase("false")) return 0.0;

        // Número
        try {
            return Double.parseDouble(operand);
        } catch (NumberFormatException e) {
            // Variable o temporal
        }

        // Buscar en memoria
        if (memory.containsKey(operand)) {
            return memory.get(operand);
        }

        // Variable no inicializada
        return 0.0;
    }

    private double toDouble(Object val) {
        if (val == null) return 0.0;
        if (val instanceof Double) return (Double) val;
        if (val instanceof String) {
            try { return Double.parseDouble((String) val); }
            catch (NumberFormatException e) { return 0.0; }
        }
        return 0.0;
    }

    // ============================================================
    // Ejecutar el programa
    // ============================================================
    public String execute() {
        int pc = 0; // Program Counter
        int maxSteps = 100000; // Protección contra loops infinitos
        int steps = 0;

        while (pc < quads.size() && steps < maxSteps) {
            steps++;
            Quad q = quads.get(pc);

            switch (q.op) {
                // --- Asignación ---
                case "=":
                    memory.put(q.result, resolve(q.arg1));
                    pc++;
                    break;

                // --- Aritmética ---
                case "+": {
                    Object a = resolve(q.arg1);
                    Object b = resolve(q.arg2);
                    // Concatenación si alguno es string
                    if (a instanceof String || b instanceof String) {
                        memory.put(q.result, formatValue(a) + formatValue(b));
                    } else {
                        memory.put(q.result, toDouble(a) + toDouble(b));
                    }
                    pc++;
                    break;
                }
                case "-":
                    memory.put(q.result, toDouble(resolve(q.arg1)) - toDouble(resolve(q.arg2)));
                    pc++;
                    break;
                case "*":
                    memory.put(q.result, toDouble(resolve(q.arg1)) * toDouble(resolve(q.arg2)));
                    pc++;
                    break;
                case "/": {
                    double divisor = toDouble(resolve(q.arg2));
                    if (divisor == 0) {
                        output.append("[Error: División por cero]\n");
                        memory.put(q.result, 0.0);
                    } else {
                        memory.put(q.result, toDouble(resolve(q.arg1)) / divisor);
                    }
                    pc++;
                    break;
                }
                case "%":
                    memory.put(q.result, toDouble(resolve(q.arg1)) % toDouble(resolve(q.arg2)));
                    pc++;
                    break;

                // --- Negación ---
                case "NEG":
                    memory.put(q.result, -toDouble(resolve(q.arg1)));
                    pc++;
                    break;

                // --- Comparación ---
                case "==":
                    memory.put(q.result, equals(resolve(q.arg1), resolve(q.arg2)) ? 1.0 : 0.0);
                    pc++;
                    break;
                case "!=":
                    memory.put(q.result, !equals(resolve(q.arg1), resolve(q.arg2)) ? 1.0 : 0.0);
                    pc++;
                    break;
                case "<":
                    memory.put(q.result, toDouble(resolve(q.arg1)) < toDouble(resolve(q.arg2)) ? 1.0 : 0.0);
                    pc++;
                    break;
                case ">":
                    memory.put(q.result, toDouble(resolve(q.arg1)) > toDouble(resolve(q.arg2)) ? 1.0 : 0.0);
                    pc++;
                    break;
                case "<=":
                    memory.put(q.result, toDouble(resolve(q.arg1)) <= toDouble(resolve(q.arg2)) ? 1.0 : 0.0);
                    pc++;
                    break;
                case ">=":
                    memory.put(q.result, toDouble(resolve(q.arg1)) >= toDouble(resolve(q.arg2)) ? 1.0 : 0.0);
                    pc++;
                    break;

                // --- Lógica ---
                case "AND":
                    memory.put(q.result, (toDouble(resolve(q.arg1)) != 0 && toDouble(resolve(q.arg2)) != 0) ? 1.0 : 0.0);
                    pc++;
                    break;
                case "OR":
                    memory.put(q.result, (toDouble(resolve(q.arg1)) != 0 || toDouble(resolve(q.arg2)) != 0) ? 1.0 : 0.0);
                    pc++;
                    break;
                case "NOT":
                    memory.put(q.result, (toDouble(resolve(q.arg1)) == 0) ? 1.0 : 0.0);
                    pc++;
                    break;

                // --- WRITE (salida del programa) ---
                case "WRITE": {
                    Object val = resolve(q.arg1);
                    output.append(formatValue(val)).append("\n");
                    pc++;
                    break;
                }

                // --- READ (entrada — usa valor por defecto en web) ---
                case "READ":
                    memory.put(q.result, 0.0);
                    pc++;
                    break;

                // --- Control de flujo ---
                case "LABEL":
                    pc++;
                    break;
                case "GOTO":
                    if (labelIndex.containsKey(q.result)) {
                        pc = labelIndex.get(q.result);
                    } else {
                        pc++;
                    }
                    break;
                case "IFT": {
                    double cond = toDouble(resolve(q.arg1));
                    if (cond != 0 && labelIndex.containsKey(q.result)) {
                        pc = labelIndex.get(q.result);
                    } else {
                        pc++;
                    }
                    break;
                }

                // --- Matrices ---
                case "NEWMAT":
                    // Crear una matriz en memoria (simplificada como mapa)
                    memory.put(q.result, new LinkedHashMap<String, Object>());
                    pc++;
                    break;
                case "MATSET": {
                    // MATSET nombre fila,col valor
                    Object mat = memory.get(q.result);
                    if (mat instanceof Map) {
                        ((Map<String, Object>) mat).put(q.arg1, resolve(q.arg2));
                    }
                    pc++;
                    break;
                }
                case "MATGET": {
                    // MATGET nombre fila,col temp
                    Object mat = memory.get(q.arg1);
                    if (mat instanceof Map) {
                        Object val = ((Map<String, Object>) mat).get(q.arg2);
                        memory.put(q.result, val != null ? val : 0.0);
                    } else {
                        memory.put(q.result, 0.0);
                    }
                    pc++;
                    break;
                }

                default:
                    // Operador desconocido — avanzar
                    pc++;
                    break;
            }
        }

        if (steps >= maxSteps) {
            output.append("\n[Advertencia: Límite de ejecución alcanzado (posible loop infinito)]\n");
        }

        return output.toString();
    }

    // ============================================================
    // Formateo de valores para salida
    // ============================================================
    private String formatValue(Object val) {
        if (val == null) return "null";
        if (val instanceof String) return (String) val;
        if (val instanceof Double) {
            double d = (Double) val;
            if (d == Math.floor(d) && !Double.isInfinite(d)) {
                return String.valueOf((long) d);
            }
            return String.valueOf(d);
        }
        return val.toString();
    }

    private boolean equals(Object a, Object b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        if (a instanceof Double && b instanceof Double) {
            return ((Double) a).doubleValue() == ((Double) b).doubleValue();
        }
        return a.toString().equals(b.toString());
    }

    // ============================================================
    // Main
    // ============================================================
    public static void main(String[] args) {
        if (args.length < 1) {
            System.err.println("Uso: java QuadInterpreter <archivo_cuadruples_opt.txt>");
            System.exit(1);
        }

        try {
            QuadInterpreter interp = new QuadInterpreter();
            interp.loadFromFile(args[0]);
            String result = interp.execute();
            System.out.print(result);
        } catch (Exception e) {
            System.err.println("Error en el intérprete: " + e.getMessage());
            System.exit(1);
        }
    }
}
