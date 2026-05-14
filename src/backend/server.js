// compilador/backend/server.js
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const http = require('http');
const { exec, execSync, spawn } = require('child_process');
const path = require('path');
const os = require('os');
const { Server } = require('socket.io');

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
// ENDPOINT: COMPILACIÓN COMPLETA (sin ejecución)
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
    exec(`java ${javaOpts} Felix entrada_web.txt -noexec`, { cwd: COMPILER_DIR, encoding: 'utf8' }, (error, stdout, stderr) => {
        
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

        if (!hasErrors && fs.existsSync(optFile)) {
            // Generar ensamblador
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
        }

        // Detectar si hay cuádruples READ en el archivo optimizado
        let hasReadInstructions = false;
        if (!hasErrors && quadsOpt) {
            hasReadInstructions = quadsOpt.split('\n').some(line => {
                const parts = line.trim().split(/\s+/);
                return parts.length >= 2 && parts[1] === 'READ';
            });
        }

        res.json({
            terminalOutput: stdout || stderr,
            hasErrors: hasErrors,
            quadsUnopt: quadsUnopt,
            quadsOpt: quadsOpt,
            asmARM64: asmARM64,
            asmX86: asmX86,
            hasReadInstructions: hasReadInstructions
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

// ==========================================
// SERVIDOR HTTP + SOCKET.IO
// ==========================================
const server = http.createServer(app);
const io = new Server(server, {
    cors: { origin: '*' }
});

// ==========================================
// WEBSOCKET: EJECUCIÓN INTERACTIVA
// ==========================================
io.on('connection', (socket) => {
    let childProcess = null;

    socket.on('execute', (data) => {
        // Matar proceso anterior si existe
        if (childProcess) {
            try { childProcess.kill(); } catch(e) {}
            childProcess = null;
        }

        const optFile = path.join(COMPILER_DIR, 'entrada_web_cuadruples_opt.txt');
        
        if (!fs.existsSync(optFile)) {
            socket.emit('execution_error', { message: 'No se encontró el archivo de cuádruples optimizados.' });
            return;
        }

        // Spawn del intérprete de cuádruples como proceso hijo
        childProcess = spawn('java', ['-Dfile.encoding=UTF-8', 'QuadInterpreter', 'entrada_web_cuadruples_opt.txt'], {
            cwd: COMPILER_DIR,
            stdio: ['pipe', 'pipe', 'pipe']
        });

        // Timeout de 30 segundos para evitar procesos colgados
        const executionTimeout = setTimeout(() => {
            if (childProcess) {
                socket.emit('execution_error', { message: 'Tiempo de ejecución agotado (30s). El proceso fue terminado.' });
                try { childProcess.kill(); } catch(e) {}
                childProcess = null;
            }
        }, 30000);

        let buffer = '';

        // Procesar stdout línea por línea
        childProcess.stdout.on('data', (chunk) => {
            buffer += chunk.toString();
            const lines = buffer.split('\n');
            // Mantener la última línea incompleta en el buffer
            buffer = lines.pop() || '';

            for (const line of lines) {
                const trimmed = line.trim();
                if (!trimmed) continue;

                if (trimmed.startsWith('__READ__:')) {
                    const varName = trimmed.substring(9);
                    socket.emit('read_request', { variable: varName });
                } else if (trimmed.startsWith('__WRITE__:')) {
                    const value = trimmed.substring(10);
                    socket.emit('program_output', { value: value });
                } else if (trimmed === '__DONE__') {
                    socket.emit('execution_done');
                }
            }
        });

        // Errores del proceso
        childProcess.stderr.on('data', (chunk) => {
            const msg = chunk.toString().trim();
            if (msg) {
                socket.emit('execution_error', { message: msg });
            }
        });

        // Proceso terminó
        childProcess.on('close', (code) => {
            clearTimeout(executionTimeout);
            // Procesar lo que quede en el buffer
            if (buffer.trim()) {
                const trimmed = buffer.trim();
                if (trimmed.startsWith('__WRITE__:')) {
                    socket.emit('program_output', { value: trimmed.substring(10) });
                } else if (trimmed === '__DONE__') {
                    socket.emit('execution_done');
                }
            }
            socket.emit('execution_done');
            childProcess = null;
        });

        childProcess.on('error', (err) => {
            clearTimeout(executionTimeout);
            socket.emit('execution_error', { message: 'Error al iniciar el intérprete: ' + err.message });
            childProcess = null;
        });
    });

    // Recibir respuesta del usuario para READ
    socket.on('read_response', (data) => {
        if (childProcess && childProcess.stdin && !childProcess.stdin.destroyed) {
            childProcess.stdin.write(data.value + '\n');
        }
    });

    // Limpieza al desconectar
    socket.on('disconnect', () => {
        if (childProcess) {
            childProcess.kill();
            childProcess = null;
        }
    });
});

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