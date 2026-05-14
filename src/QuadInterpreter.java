import java.util.*;
import java.io.*;

public class QuadInterpreter {
    private List<Quad> quads = new ArrayList<>();
    private Map<String, Object> memory = new LinkedHashMap<>();
    private Map<String, Integer> labelIndex = new LinkedHashMap<>();
    private Map<String, double[][]> matrices = new HashMap<>();
    private Map<String, double[]> arrays = new HashMap<>();
    private Scanner scanner = new Scanner(System.in);
    private boolean hasError = false;

    private static class Quad {
        String op, arg1, arg2, result;
        Quad(String op, String arg1, String arg2, String result) {
            this.op = op; this.arg1 = arg1; this.arg2 = arg2; this.result = result;
        }
    }

    public void loadFromFile(String fileName) throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(fileName), "UTF-8"));
        String line;
        int index = 0;
        boolean reading = false;
        while ((line = br.readLine()) != null) {
            if (line.contains("Codigo optimizado") || line.contains("Codigo sin optimizar")) {
                reading = true;
                continue;
            }
            if (reading && line.startsWith("-")) {
                if (quads.size() > 0) break; // Termina la lectura de instrucciones
                continue;
            }
            if (reading && line.matches("^\\d+\\s+.*")) {
                java.util.List<String> partsList = new java.util.ArrayList<>();
                java.util.regex.Matcher m = java.util.regex.Pattern.compile("([^\"]\\S*|\".*?\")\\s*").matcher(line.trim());
                while (m.find()) {
                    if (!m.group(1).isEmpty()) partsList.add(m.group(1));
                }
                String[] parts = partsList.toArray(new String[0]);
                String op = parts.length > 1 ? parts[1] : "";
                String arg1 = parts.length > 2 && !parts[2].equals("-") ? parts[2] : null;
                String arg2 = parts.length > 3 && !parts[3].equals("-") ? parts[3] : null;
                String res = parts.length > 4 && !parts[4].equals("-") ? parts[4] : null;
                quads.add(new Quad(op, arg1, arg2, res));
                if (op.equals("LABEL") && res != null) {
                    labelIndex.put(res, index);
                }
                index++;
            }
        }
        br.close();
    }

    private Object resolveVal(String s) {
        if (s == null) return 0;
        if (s.startsWith("\"") && s.endsWith("\"")) return s;
        if (s.equalsIgnoreCase("true") || s.equals("TRUE")) return "TRUE";
        if (s.equalsIgnoreCase("false") || s.equals("FALSE")) return "FALSE";
        if (memory.containsKey(s)) return memory.get(s);
        try { 
            if (s.contains(".")) return Double.parseDouble(s); 
            else return Integer.parseInt(s);
        } catch (NumberFormatException e) { return s; }
    }

    private void checkTypeMatch(Object a, Object b) throws Exception {
        // Se permite la coacción implícita entre REAL e INTEGER para facilitar operaciones matemáticas
    }

    private double toNum(Object val) throws Exception {
        if (val instanceof Number) return ((Number) val).doubleValue();
        if (val instanceof String) {
            String s = (String) val;
            if (s.startsWith("\"")) throw new Exception("No se puede realizar operacion matematica con un string: " + s);
            if (s.equals("TRUE") || s.equals("FALSE")) throw new Exception("No se puede realizar operacion matematica con un booleano: " + s);
            try { return Double.parseDouble(s); } catch (NumberFormatException e) {
                throw new Exception("Valor no numerico en operacion matematica: " + s);
            }
        }
        throw new Exception("Tipo desconocido en operacion matematica");
    }

    private boolean eqVals(Object a, Object b) {
        if (a instanceof Number && b instanceof Number) return ((Number) a).doubleValue() == ((Number) b).doubleValue();
        return String.valueOf(a).equals(String.valueOf(b));
    }

    private String fmtVal(Object val) {
        if (val instanceof Integer) return String.valueOf(val);
        if (val instanceof Double) {
            double d = (Double) val;
            if (d == Math.floor(d) && !Double.isInfinite(d)) return String.valueOf((long) d);
            return String.valueOf(d);
        }
        if (val instanceof String) {
            String s = (String) val;
            if (s.startsWith("\"") && s.endsWith("\"")) return s.substring(1, s.length() - 1);
            return s;
        }
        return String.valueOf(val);
    }

    public void execute() {
        int pc = 0;
        while (pc < quads.size() && !hasError) {
            Quad q = quads.get(pc);
            String op = q.op;
            try {
                if (op.equals("=")) {
                    memory.put(q.result, resolveVal(q.arg1));
                    pc++;
                } else if (op.equals("+") || op.equals("-") || op.equals("*") || op.equals("/") || op.equals("%")) {
                    Object objA = resolveVal(q.arg1);
                    Object objB = resolveVal(q.arg2);
                    checkTypeMatch(objA, objB);
                    
                    if (objA instanceof Integer && objB instanceof Integer) {
                        int a = (Integer) objA; int b = (Integer) objB;
                        int r = 0;
                        if (op.equals("+")) r = a + b;
                        else if (op.equals("-")) r = a - b;
                        else if (op.equals("*")) r = a * b;
                        else if (op.equals("/")) {
                            if (b == 0) throw new Exception("División por cero entera");
                            r = a / b;
                        } else if (op.equals("%")) r = a % b;
                        memory.put(q.result, r);
                    } else {
                        double a = toNum(objA); double b = toNum(objB);
                        double r = 0;
                        if (op.equals("+")) r = a + b;
                        else if (op.equals("-")) r = a - b;
                        else if (op.equals("*")) r = a * b;
                        else if (op.equals("/")) {
                            if (b == 0) throw new Exception("División por cero");
                            r = a / b;
                        } else if (op.equals("%")) r = a % b;
                        memory.put(q.result, r);
                    }
                    pc++;
                } else if (op.equals("NEG")) {
                    Object objA = resolveVal(q.arg1);
                    if (objA instanceof Integer) memory.put(q.result, -((Integer) objA));
                    else memory.put(q.result, -toNum(objA));
                    pc++;
                } else if (op.equals("==")) {
                    memory.put(q.result, eqVals(resolveVal(q.arg1), resolveVal(q.arg2)) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equals("!=")) {
                    memory.put(q.result, !eqVals(resolveVal(q.arg1), resolveVal(q.arg2)) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equals("<")) {
                    memory.put(q.result, toNum(resolveVal(q.arg1)) < toNum(resolveVal(q.arg2)) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equals(">")) {
                    memory.put(q.result, toNum(resolveVal(q.arg1)) > toNum(resolveVal(q.arg2)) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equals("<=")) {
                    memory.put(q.result, toNum(resolveVal(q.arg1)) <= toNum(resolveVal(q.arg2)) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equals(">=")) {
                    memory.put(q.result, toNum(resolveVal(q.arg1)) >= toNum(resolveVal(q.arg2)) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equalsIgnoreCase("AND")) {
                    memory.put(q.result, (toNum(resolveVal(q.arg1)) != 0 && toNum(resolveVal(q.arg2)) != 0) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equalsIgnoreCase("OR")) {
                    memory.put(q.result, (toNum(resolveVal(q.arg1)) != 0 || toNum(resolveVal(q.arg2)) != 0) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equalsIgnoreCase("NOT")) {
                    memory.put(q.result, (toNum(resolveVal(q.arg1)) == 0) ? "TRUE" : "FALSE"); pc++;
                } else if (op.equals("WRITE")) {
                    System.out.println("__WRITE__:" + fmtVal(resolveVal(q.arg1)));
                    System.out.flush();
                    pc++;
                } else if (op.equals("READ")) {
                    System.out.println("__READ__:" + q.result);
                    System.out.flush();
                    if (scanner.hasNextLine()) {
                        String input = scanner.nextLine().trim();
                        try {
                            if (input.contains(".")) memory.put(q.result, Double.parseDouble(input));
                            else memory.put(q.result, Integer.parseInt(input));
                        } catch (NumberFormatException nfe) {
                            if (input.equalsIgnoreCase("true") || input.equalsIgnoreCase("false")) {
                                memory.put(q.result, input.toUpperCase());
                            } else {
                                memory.put(q.result, "\"" + input + "\"");
                            }
                        }
                    } else {
                        hasError = true;
                    }
                    pc++;
                } else if (op.equals("LABEL")) {
                    pc++;
                } else if (op.equals("GOTO")) {
                    if (labelIndex.containsKey(q.result)) pc = labelIndex.get(q.result);
                    else { System.out.println("__WRITE__:[Error de ejecución: Etiqueta no encontrada: " + q.result + "]"); hasError = true; }
                } else if (op.equals("IFT")) {
                    Object condObj = resolveVal(q.arg1);
                    boolean isTrue = false;
                    if (condObj instanceof String && condObj.equals("TRUE")) isTrue = true;
                    else if (condObj instanceof Number && ((Number)condObj).doubleValue() != 0) isTrue = true;
                    
                    if (isTrue) {
                        if (labelIndex.containsKey(q.result)) pc = labelIndex.get(q.result);
                        else { System.out.println("__WRITE__:[Error: Etiqueta no encontrada: " + q.result + "]"); hasError = true; }
                    } else { pc++; }
                } else if (op.equals("NEWMAT")) {
                    String[] dims = q.arg2.split("x");
                    int d1 = Integer.parseInt(dims[0]); int d2 = Integer.parseInt(dims[1]);
                    matrices.put(q.arg1, new double[d1][d2]);
                    pc++;
                } else if (op.equals("MATSET")) {
                    String[] idx = q.arg1.split(",");
                    int r = (int) toNum(resolveVal(idx[0].trim()));
                    int c = (int) toNum(resolveVal(idx[1].trim()));
                    double val = toNum(resolveVal(q.arg2));
                    if (matrices.containsKey(q.result)) matrices.get(q.result)[r][c] = val;
                    pc++;
                } else if (op.equals("MATGET")) {
                    String[] idx = q.arg2.split(",");
                    int r = (int) toNum(resolveVal(idx[0].trim()));
                    int c = (int) toNum(resolveVal(idx[1].trim()));
                    if (matrices.containsKey(q.arg1)) {
                        double v = matrices.get(q.arg1)[r][c];
                        if (v == Math.floor(v)) memory.put(q.result, (int)v);
                        else memory.put(q.result, v);
                    }
                    else memory.put(q.result, 0.0);
                    pc++;
                } else if (op.equals("MATREAD")) {
                    String[] idx = q.arg1.split(",");
                    int r = (int) toNum(resolveVal(idx[0].trim()));
                    int c = (int) toNum(resolveVal(idx[1].trim()));
                    System.out.println("__READ__:" + q.result + "[" + r + "][" + c + "]");
                    System.out.flush();
                    if (scanner.hasNextLine()) {
                        String input = scanner.nextLine().trim();
                        try {
                            if (input.contains(".")) matrices.get(q.result)[r][c] = Double.parseDouble(input);
                            else matrices.get(q.result)[r][c] = Integer.parseInt(input);
                        } catch (NumberFormatException nfe) {
                            System.out.println("__WRITE__:[Error: Se esperaba un valor numérico para la matriz]");
                            hasError = true;
                        }
                    } else {
                        hasError = true;
                    }
                    pc++;
                } else if (op.equals("NEWARR")) {
                    int size = Integer.parseInt(q.arg2);
                    arrays.put(q.arg1, new double[size]);
                    pc++;
                } else if (op.equals("ARRSET")) {
                    int idx = (int) toNum(resolveVal(q.arg1));
                    double val = toNum(resolveVal(q.arg2));
                    if (arrays.containsKey(q.result)) arrays.get(q.result)[idx] = val;
                    pc++;
                } else if (op.equals("ARRGET")) {
                    int idx = (int) toNum(resolveVal(q.arg2));
                    if (arrays.containsKey(q.arg1)) {
                        double v = arrays.get(q.arg1)[idx];
                        if (v == Math.floor(v)) memory.put(q.result, (int)v);
                        else memory.put(q.result, v);
                    }
                    else memory.put(q.result, 0.0);
                    pc++;
                } else if (op.equals("ARRREAD")) {
                    int idx = (int) toNum(resolveVal(q.arg1));
                    System.out.println("__READ__:" + q.result + "[" + idx + "]");
                    System.out.flush();
                    if (scanner.hasNextLine()) {
                        String input = scanner.nextLine().trim();
                        try {
                            if (input.contains(".")) arrays.get(q.result)[idx] = Double.parseDouble(input);
                            else arrays.get(q.result)[idx] = Integer.parseInt(input);
                        } catch (NumberFormatException nfe) {
                            System.out.println("__WRITE__:[Error: Se esperaba un valor numérico para el arreglo]");
                            hasError = true;
                        }
                    } else {
                        hasError = true;
                    }
                    pc++;
                } else {
                    pc++;
                }
            } catch (Exception ex) {
                System.out.println("__WRITE__:[Error de ejecución en instrucción " + pc + ": " + ex.getMessage() + "]");
                System.out.flush();
                hasError = true;
            }
        }
        System.out.println("__DONE__");
        System.out.flush();
    }

    public static void main(String[] args) {
        if (args.length == 0) return;
        QuadInterpreter interpreter = new QuadInterpreter();
        try {
            interpreter.loadFromFile(args[0]);
            interpreter.execute();
        } catch (Exception e) {
            System.out.println("__WRITE__:[Error fatal: " + e.getMessage() + "]");
            System.out.println("__DONE__");
        }
    }
}
