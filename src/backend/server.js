// compilador/backend/server.js
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const http = require('http');
const { exec, execSync } = require('child_process');
const path = require('path');
const os = require('os');

const app = express();

// CORS manual (el paquete cors no funciona correctamente con Express 5)
app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    if (req.method === 'OPTIONS') { res.status(200).end(); return; }
    next();
});
app.use(express.json());

// Apuntamos a tu carpeta src donde está el compilador
const COMPILER_DIR = path.join(__dirname, '..');

// Servir el frontend directamente desde el backend
const FRONTEND_DIR = path.join(__dirname, '..', 'frontend');
app.use(express.static(FRONTEND_DIR));

// ==========================================
// DETECCIÓN DE ARQUITECTURA
// ==========================================
const detectedArch = os.arch();   // 'x64', 'arm64', 'ia32', etc.
const detectedPlatform = os.platform(); // 'win32', 'darwin', 'linux'
const isARM64 = detectedArch === 'arm64';
const isX86 = detectedArch === 'x64' || detectedArch === 'ia32';

console.log(`Arquitectura detectada: ${detectedArch} (${detectedPlatform})`);

// ==========================================
// COMPILACIÓN INICIAL DE FELIX
// ==========================================
console.log("Iniciando reconstrucción del compilador Felix...");
try {
    // Compila JavaCC y luego Java cada vez que inicias el servidor
    execSync('javacc Felix.jj', { cwd: COMPILER_DIR, stdio: 'inherit' });
    execSync('javac *.java', { cwd: COMPILER_DIR, stdio: 'inherit', encoding: 'utf8' });
    console.log("Compilación exitosa. Servidor listo en el puerto 3001.");
} catch (error) {
    console.error("Error al construir el compilador. Revisa la terminal.");
}

// ==========================================
// ENDPOINT: DETECCIÓN DE ARQUITECTURA
// ==========================================
app.get('/api/arch', (req, res) => {
    res.json({
        detected: isARM64 ? 'arm64' : 'x86_64',
        platform: detectedPlatform,
        arch: detectedArch,
        arm64Enabled: isARM64,
        x86Enabled: isX86
    });
});

// ==========================================
// ENDPOINT: COMPILACIÓN COMPLETA
// ==========================================
app.post('/api/compile', (req, res) => {
    const { code } = req.body;
    
    // Archivo temporal donde Node guardará el código que envíe el usuario desde la web
    const tempFile = path.join(COMPILER_DIR, 'entrada_web.txt');
    fs.writeFileSync(tempFile, code, 'utf8');

    // Limpiar archivos anteriores para no mostrar resultados viejos
    const filesToClean = [
        'entrada_web_cuadruples_unopt.txt',
        'entrada_web_cuadruples_opt.txt',
        'entrada_web_asm_arm64.s',
        'entrada_web_asm_x86.s'
    ];
    filesToClean.forEach(f => {
        const fp = path.join(COMPILER_DIR, f);
        if (fs.existsSync(fp)) fs.unlinkSync(fp);
    });

    // Paso 1: Ejecutar el compilador Felix
    const javaOpts = '"-Dfile.encoding=UTF-8"';
    exec(`java ${javaOpts} Felix entrada_web.txt`, { cwd: COMPILER_DIR, encoding: 'utf8' }, (error, stdout, stderr) => {
        
        // Leemos los archivos generados por Felix
        let quadsUnopt = "";
        let quadsOpt = "";
        const unoptFile = path.join(COMPILER_DIR, 'entrada_web_cuadruples_unopt.txt');
        const optFile = path.join(COMPILER_DIR, 'entrada_web_cuadruples_opt.txt');
        
        if (fs.existsSync(unoptFile)) quadsUnopt = fs.readFileSync(unoptFile, 'utf8');
        if (fs.existsSync(optFile)) quadsOpt = fs.readFileSync(optFile, 'utf8');

        const hasErrors = error !== null || (stdout && stdout.includes("ERROR"));

        // Paso 2: Si no hay errores y existen cuádruples optimizados, generar ensamblador
        let asmARM64 = "";
        let asmX86 = "";
        let programOutput = "";

        if (!hasErrors && fs.existsSync(optFile)) {
            // 2a: Generar ensamblador
            try {
                execSync(`java ${javaOpts} AssemblyTranslator entrada_web_cuadruples_opt.txt`, { 
                    cwd: COMPILER_DIR, 
                    encoding: 'utf8',
                    stdio: 'pipe'
                });

                const arm64File = path.join(COMPILER_DIR, 'entrada_web_asm_arm64.s');
                const x86File = path.join(COMPILER_DIR, 'entrada_web_asm_x86.s');

                if (fs.existsSync(arm64File)) asmARM64 = fs.readFileSync(arm64File, 'utf8');
                if (fs.existsSync(x86File)) asmX86 = fs.readFileSync(x86File, 'utf8');
            } catch (asmError) {
                console.error("Error en traducción a ensamblador:", asmError.message);
            }

            // 2b: Interpretar cuádruples para obtener la salida del programa
            try {
                programOutput = execSync(`java ${javaOpts} QuadInterpreter entrada_web_cuadruples_opt.txt`, {
                    cwd: COMPILER_DIR,
                    encoding: 'utf8',
                    stdio: 'pipe'
                });
            } catch (interpError) {
                console.error("Error en intérprete:", interpError.message);
                programOutput = "[Error al interpretar el programa]";
            }
        }

        res.json({
            terminalOutput: stdout || stderr,
            hasErrors: hasErrors,
            quadsUnopt: quadsUnopt,
            quadsOpt: quadsOpt,
            asmARM64: asmARM64,
            asmX86: asmX86,
            programOutput: programOutput
        });
    });
});

// Endpoint para leer archivos fuente (como Felix.jj)
app.get('/api/file/:name', (req, res) => {
    const filePath = path.join(COMPILER_DIR, req.params.name);
    if (fs.existsSync(filePath)) {
        res.send(fs.readFileSync(filePath, 'utf8'));
    } else {
        res.status(404).send('Archivo no encontrado');
    }
});

// Usar http.createServer en lugar de app.listen para compatibilidad con Express 5
const server = http.createServer(app);
server.listen(3001, () => {
    console.log('Backend corriendo en http://localhost:3001');
});
server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
        console.error('ERROR: El puerto 3001 ya está en uso. Cierra el proceso anterior o cambia el puerto.');
    } else {
        console.error('Error del servidor:', err.message);
    }
    process.exit(1);
});