const API_URL = 'http://localhost:3000/api';

// ==========================================
// DICCIONARIO Y ESTADO GLOBAL (Con tildes UTF-8)
// ==========================================
const defaultState = {
    sourceCode: "SET x TO 10;\nSET y TO x;\nSET z TO y + 5;\nWRITE z;",
    consoleOut: "Esperando ejecución...",
    jjCode: "Cargando Felix.jj desde el servidor...",
    quadsUnopt: "Ejecuta el compilador para ver el código sin optimizar.",
    quadsOpt: "Ejecuta el compilador para ver el código optimizado.",
    currentWorkspace: "intermedio"
};

// Restaurar estado de sessionStorage para sobrevivir recargas de Live Server
function loadState() {
    try {
        const saved = sessionStorage.getItem('felixAppState');
        if (saved) return { ...defaultState, ...JSON.parse(saved) };
    } catch(e) {}
    return { ...defaultState };
}

function saveState() {
    try {
        sessionStorage.setItem('felixAppState', JSON.stringify(appState));
    } catch(e) {}
}

const appState = loadState();

const explanations = {
    cse: "<b>Eliminación de subexpresiones:</b><br>Detecta operaciones idénticas en el mismo bloque y reutiliza el resultado temporal anterior en lugar de recalcularlo.",
    copy: "<b>Propagación de copias:</b><br>Sustituye variables que son copias directas de otras (ej. x = y) para reducir asignaciones redundantes.",
    loop: "<b>Reducción de frecuencia:</b><br>Mueve operaciones que no cambian dentro de un ciclo (invariantes) hacia afuera para no recalcularlas en cada iteración."
};

// Cargar Felix.jj al inicio
fetch(`${API_URL}/file/Felix.jj`)
    .then(res => res.text())
    .then(data => appState.jjCode = data)
    .catch(() => appState.jjCode = "Error al cargar Felix.jj. Verifica el servidor.");

// ==========================================
// SISTEMA DE PANELES (WORKSPACE MANAGER)
// ==========================================
const workspace = document.getElementById('workspace');

function updateActiveTab(tabId) {
    document.querySelectorAll('header button').forEach(btn => btn.classList.remove('tab-active', 'text-blue-400'));
    document.getElementById(`tab-${tabId}`).classList.add('tab-active', 'text-blue-400');
}

// Genera la columna del Editor + Terminal (Siempre van juntos)
// Genera la columna del Editor + Terminal (Siempre van juntos)
// Genera la columna del Editor + Terminal (Siempre van juntos)
function createEditorColumn() {
    const col = document.createElement('div');
    col.className = "editor-col flex-1 flex flex-col gap-4 min-w-[400px]";
    col.innerHTML = `
        <div class="panel rounded-lg flex-1 flex flex-col relative overflow-hidden">
            <div class="header-bar px-4 py-1 flex justify-between items-center z-10 border-b border-divider">
                <span>Modo Libre / Código Fuente</span>
                <div class="flex items-center gap-4">
                    <label class="cursor-pointer hover:text-white transition-colors">
                        Adjuntar .txt <input type="file" class="hidden" accept=".txt" onchange="uploadFile(event)">
                    </label>
                    <button onclick="this.closest('.editor-col').remove()" class="text-red-400 hover:text-red-500 font-bold px-1 transition-colors text-sm" title="Cerrar panel">✖</button>
                </div>
            </div>
            
            <div class="flex flex-1 overflow-hidden bg-[var(--bg-main)]">
                <div id="lineNumbers" class="w-10 bg-[var(--bg-panel)] text-gray-500 text-right pr-2 py-4 text-sm font-mono select-none overflow-hidden border-r border-divider leading-normal">
                    1
                </div>
                <textarea id="sourceCode" 
                    class="w-full flex-1 bg-transparent p-4 text-sm text-green-300 resize-none focus:outline-none whitespace-pre font-mono leading-normal overflow-auto" 
                    spellcheck="false" 
                    wrap="off"
                    oninput="appState.sourceCode = this.value; updateLineNumbers(); saveState();" 
                    onscroll="document.getElementById('lineNumbers').scrollTop = this.scrollTop;"
                >${appState.sourceCode}</textarea>
            </div>
        </div>
        <div class="panel h-48 rounded-lg flex flex-col">
            <div class="header-bar px-4 py-1">Terminal / Salida</div>
            <div id="terminal" class="flex-1 p-4 overflow-y-auto text-xs whitespace-pre-wrap font-mono">${appState.consoleOut}</div>
        </div>
    `;
    
    // Forzamos el cálculo de las líneas justo después de pintar el panel
    setTimeout(updateLineNumbers, 0);
    return col;
}

// Función global para actualizar la cuenta de líneas
window.updateLineNumbers = function() {
    const textarea = document.getElementById('sourceCode');
    const lineNumbers = document.getElementById('lineNumbers');
    if (!textarea || !lineNumbers) return;
    
    // Contamos las líneas separando por saltos de línea (\n)
    const lines = textarea.value.split('\n').length;
    let numbersHtml = '';
    for (let i = 1; i <= lines; i++) {
        numbersHtml += i + '<br>';
    }
    lineNumbers.innerHTML = numbersHtml;
};

// Genera una columna genérica de solo lectura (para .jj o Cuádruples)
function createViewerColumn(title, content) {
    const col = document.createElement('div');
    // Añadimos una clase 'viewer-col' para referenciarla al cerrar
    col.className = "viewer-col panel rounded-lg flex-1 flex flex-col min-w-[300px]";
    col.innerHTML = `
        <div class="header-bar px-4 py-1 text-center relative flex justify-center items-center">
            <span>${title}</span>
            <button onclick="this.closest('.viewer-col').remove()" class="absolute right-3 text-red-400 hover:text-red-500 font-bold transition-colors text-sm" title="Cerrar panel">✖</button>
        </div>
        <div class="p-4 text-xs whitespace-pre-wrap overflow-y-auto h-full text-gray-300">${content}</div>
    `;
    return col;
}

// ==========================================
// NAVEGACIÓN Y RENDERIZADO
// ==========================================

function setWorkspace(preset) {
    workspace.innerHTML = ''; // Limpiar área de trabajo

    if (preset === 'jj') {
        // Solo muestra el código de JavaCC
        workspace.appendChild(createViewerColumn('Felix.jj (Código Fuente del Compilador)', appState.jjCode));
    } 
    else if (preset === 'intermedio') {
        // Muestra Editor + Cuádruples sin optimizar
        workspace.appendChild(createEditorColumn());
        workspace.appendChild(createViewerColumn('Cuádruples (Sin Optimizar)', appState.quadsUnopt));
    } 
    else if (preset === 'optimizado') {
        // Muestra Editor + Cuádruples sin optimizar + Cuádruples Optimizados (Comparación)
        workspace.appendChild(createEditorColumn());
        workspace.appendChild(createViewerColumn('Cuádruples (Sin Optimizar)', appState.quadsUnopt));
        workspace.appendChild(createViewerColumn('Cuádruples (Optimizados)', appState.quadsOpt));
    }

    appState.currentWorkspace = preset;
    saveState();
    updateActiveTab(preset);
}

// Función para el botón "+ Agregar Panel"
function addCustomPanel() {
    // Agrega una nueva columna de cuádruples al final
    workspace.appendChild(createViewerColumn('Panel Extra', 'Puedes conectar otra salida aquí.'));
}

// ==========================================
// INTERACCIÓN Y COMPILACIÓN
// ==========================================

function loadExample(type) {
    if (type === 'libre') {
        document.getElementById('explicacion-dict').innerHTML = "<b>Modo Libre:</b><br>Escribe tu propio código Felix. Observa cómo el pipeline intenta aplicar todas las optimizaciones posibles a la vez.";
        appState.consoleOut = `<span class="text-blue-400">Modo Libre activado. Escribe tu código y presiona Ejecutar.</span>`;
        appState.sourceCode = ""; // Limpiamos el editor
    } else {
        document.getElementById('explicacion-dict').innerHTML = explanations[type];
        appState.consoleOut = `<span class="text-blue-400">Ejemplo cargado. Haz clic en Ejecutar.</span>`;
        appState.lastExample = type;
        
        if(type === 'cse') appState.sourceCode = `
    SET a TO 5;
    SET b TO 10;
    SET c TO 2;

    SET t1 TO a + b;
    SET t2 TO a + b;
    SET t3 TO a + b;

    SET x TO t1 * c;
    SET y TO t2 * c;
    SET z TO t3 * c;

    SET m TO a + b;
    SET n TO a + b;

    SET r TO m + n;

    SET p TO a * b;
    SET q TO a * b;

    SET s TO p + q;

    WRITE x;
    WRITE y;
    WRITE z;
    WRITE r;
    WRITE s;
    `;
        if(type === 'copy') appState.sourceCode = `
    SET a TO 10;
    SET b TO a;
    SET c TO b;
    SET d TO c;

    SET e TO d + 5;
    SET f TO e;

    SET g TO f + 2;
    SET h TO g;

    SET i TO h + a;
    SET j TO i;

    SET k TO j + b;
    SET l TO k;

    SET m TO l + 1;
    SET n TO m;

    SET o TO n + c;

    WRITE e;
    WRITE g;
    WRITE i;
    WRITE k;
    WRITE m;
    WRITE o;
    `;
        if(type === 'loop') appState.sourceCode = `
    SET a TO 5;
    SET b TO 10;
    SET c TO 2;
    SET i TO 0;

    WHILE (i < 10) DO
        SET t1 TO a + b;
        SET t2 TO a + b;
        SET t3 TO t1 * c;

        SET x TO t2 + t3;
        SET y TO a + b;

        SET z TO y * c;

        SET r TO a * b;

        SET s TO r + c;

        SET i TO i + 1;
    ENDWHILE

    WRITE x;
    WRITE y;
    WRITE z;
    WRITE s;
    `;
    }
    
    saveState();
    setWorkspace('intermedio'); // Forzar la vista del editor
}

function uploadFile(event) {
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            // Guardamos el código en la memoria del estado
            appState.sourceCode = e.target.result;
            saveState();
            
            // Buscamos el editor ACTIVO en la pantalla y le inyectamos el texto
            const currentEditor = document.getElementById('sourceCode');
            if (currentEditor) {
                currentEditor.value = appState.sourceCode;
                updateLineNumbers();
            }
            
            const currentTerminal = document.getElementById('terminal');
            if (currentTerminal) {
                currentTerminal.innerHTML = `<span class="text-blue-400">Archivo '${file.name}' cargado exitosamente.</span>`;
            }
            
            // Limpia el input para permitir recargar el mismo archivo si hay cambios
            event.target.value = ''; 
        };
        reader.readAsText(file);
    }
}

async function compileCode() {
    const codeArea = document.getElementById('sourceCode');
    if(codeArea) appState.sourceCode = codeArea.value;

    appState.consoleOut = '<span class="text-blue-400">Compilando y optimizando...</span>';
    setWorkspace('intermedio'); 

    try {
        const response = await fetch(`${API_URL}/compile`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ code: appState.sourceCode })
        });
        
        const data = await response.json();
        
        if (data.hasErrors) {
            appState.consoleOut = `<span class="text-red-400">Error:</span>\n${data.terminalOutput}`;
            appState.quadsUnopt = "No generado debido a errores.";
            appState.quadsOpt = "No generado debido a errores.";
        } else {
            appState.consoleOut = `<span class="text-green-400">¡Éxito!</span>\n${data.terminalOutput}`;
            
            // Aquí leemos las dos variables DISTINTAS que nos manda el nuevo server.js
            appState.quadsUnopt = data.quadsUnopt || "Archivo sin optimizar vacío o no encontrado.";
            appState.quadsOpt = data.quadsOpt || "Archivo optimizado vacío o no encontrado.";
        }
        
        // Cambiamos automáticamente a la vista de 3 columnas para ver la comparativa
        setWorkspace('optimizado'); 

    } catch (err) {
        appState.consoleOut = `<span class="text-red-500">Error de servidor.</span>`;
        setWorkspace('intermedio');
    }
}

// Inicializar la vista: restaurar el workspace guardado o usar el predeterminado
setWorkspace(appState.currentWorkspace || 'intermedio');