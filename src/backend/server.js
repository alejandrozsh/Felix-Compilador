// compilador/backend/server.js
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const { exec, execSync } = require('child_process');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

// Apuntamos a tu carpeta src donde está el compilador
const COMPILER_DIR = path.join(__dirname, '..');

console.log("Iniciando reconstrucción del compilador Felix...");
try {
    // Compila JavaCC y luego Java cada vez que inicias el servidor
    execSync('javacc Felix.jj', { cwd: COMPILER_DIR, stdio: 'inherit' });
    execSync('javac *.java', { cwd: COMPILER_DIR, stdio: 'inherit' });
    console.log("Compilación exitosa. Servidor listo en el puerto 3000.");
} catch (error) {
    console.error("Error al construir el compilador. Revisa la terminal.");
}

app.post('/api/compile', (req, res) => {
    const { code } = req.body;
    
    // Archivo temporal donde Node guardará el código que envíe el usuario desde la web
    const tempFile = path.join(COMPILER_DIR, 'entrada_web.txt');
    fs.writeFileSync(tempFile, code);

    // Limpiar archivos de cuádruples anteriores para no mostrar resultados viejos
    const unoptFilePre = path.join(COMPILER_DIR, 'entrada_web_cuadruples_unopt.txt');
    const optFilePre = path.join(COMPILER_DIR, 'entrada_web_cuadruples_opt.txt');
    if (fs.existsSync(unoptFilePre)) fs.unlinkSync(unoptFilePre);
    if (fs.existsSync(optFilePre)) fs.unlinkSync(optFilePre);

    // Ejecutamos tu compilador compilado
    exec('java Felix entrada_web.txt', { cwd: COMPILER_DIR }, (error, stdout, stderr) => {
        
        // Leemos los dos archivos generados por Felix
        let quadsUnopt = "";
        let quadsOpt = "";
        const unoptFile = path.join(COMPILER_DIR, 'entrada_web_cuadruples_unopt.txt');
        const optFile = path.join(COMPILER_DIR, 'entrada_web_cuadruples_opt.txt');
        
        if (fs.existsSync(unoptFile)) quadsUnopt = fs.readFileSync(unoptFile, 'utf8');
        if (fs.existsSync(optFile)) quadsOpt = fs.readFileSync(optFile, 'utf8');

        res.json({
            terminalOutput: stdout || stderr,
            hasErrors: error !== null || stdout.includes("ERROR"),
            quadsUnopt: quadsUnopt,
            quadsOpt: quadsOpt
        });
    });
});

// Nuevo endpoint para leer archivos fuente (como Felix.jj)
app.get('/api/file/:name', (req, res) => {
    const filePath = path.join(COMPILER_DIR, req.params.name);
    if (fs.existsSync(filePath)) {
        res.send(fs.readFileSync(filePath, 'utf8'));
    } else {
        res.status(404).send('Archivo no encontrado');
    }
});

app.listen(3000, () => console.log('Backend corriendo en http://localhost:3000'));