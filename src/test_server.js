const { spawn } = require('child_process');

const childProcess = spawn('java', ['-Dfile.encoding=UTF-8', 'QuadInterpreter', 'calificaciones_cuadruples_opt.txt'], {
    cwd: '/Users/alejandrocm/Documents/Compilador/src',
    stdio: ['pipe', 'pipe', 'pipe']
});

childProcess.stdout.on('data', (chunk) => {
    console.log("STDOUT: " + chunk.toString());
    if (chunk.toString().includes('__READ__')) {
        childProcess.stdin.write("2\n");
    }
});

childProcess.stderr.on('data', (chunk) => {
    console.error("STDERR: " + chunk.toString());
});

childProcess.on('close', (code) => {
    console.log('Proceso cerrado con codigo ' + code);
});
