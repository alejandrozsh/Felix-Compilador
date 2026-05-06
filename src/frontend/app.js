const API_URL = '/api';

// ==========================================
// DICCIONARIO Y ESTADO GLOBAL
// ==========================================
const defaultState = {
    sourceCode: "",
    consoleOut: "Esperando ejecución...",
    jjCode: "Cargando Felix.jj desde el servidor...",
    quadsUnopt: "Ejecuta el compilador para ver el código sin optimizar.",
    quadsOpt: "Ejecuta el compilador para ver el código optimizado.",
    asmARM64: "Ejecuta el compilador para generar ensamblador ARM64.",
    asmX86: "Ejecuta el compilador para generar ensamblador x86_64.",
    currentWorkspace: "intermedio",
    arch: null
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

// ==========================================
// DETECCIÓN DE ARQUITECTURA
// ==========================================
async function detectArchitecture() {
    try {
        const res = await fetch(`${API_URL}/arch`);
        const data = await res.json();
        appState.arch = data;
        saveState();

        // Actualizar badges
        const badgeARM = document.getElementById('badge-arm64');
        const badgeX86 = document.getElementById('badge-x86');
        const tabARM = document.getElementById('tab-asm-arm64');
        const tabX86 = document.getElementById('tab-asm-x86');

        if (data.arm64Enabled) {
            badgeARM.textContent = 'Activo';
            badgeARM.className = 'arch-badge active';
            badgeX86.textContent = 'No disponible';
            badgeX86.className = 'arch-badge disabled';
            tabX86.classList.add('tab-disabled');
        } else {
            badgeX86.textContent = 'Activo';
            badgeX86.className = 'arch-badge active';
            badgeARM.textContent = 'No disponible';
            badgeARM.className = 'arch-badge disabled';
            tabARM.classList.add('tab-disabled');
        }

        // Indicador en sidebar
        const archName = document.getElementById('arch-name');
        const archDetail = document.getElementById('arch-detail');
        archName.textContent = data.detected.toUpperCase();
        archDetail.textContent = `${data.platform} — ${data.arch}`;

    } catch(e) {
        console.error('Error detectando arquitectura:', e);
        document.getElementById('arch-name').textContent = 'Sin conexión';
        document.getElementById('arch-detail').textContent = 'Verifica el servidor';
    }
}

// Cargar Felix.jj y detectar arquitectura al inicio
fetch(`${API_URL}/file/Felix.jj`)
    .then(res => res.text())
    .then(data => appState.jjCode = data)
    .catch(() => appState.jjCode = "Error al cargar Felix.jj. Verifica el servidor.");

detectArchitecture();

// ==========================================
// SYNTAX HIGHLIGHTING PARA ENSAMBLADOR
// ==========================================
function highlightASM(code, isARM) {
    const lines = code.split('\n');
    return lines.map(line => highlightASMLine(line, isARM)).join('\n');
}

function escapeHtml(str) {
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function highlightASMLine(line, isARM) {
    if (!line.trim()) return escapeHtml(line);

    // Split into: before-comment and comment
    let codePart = line;
    let commentPart = '';
    if (isARM) {
        const ci = line.indexOf('//');
        if (ci !== -1) { codePart = line.substring(0, ci); commentPart = line.substring(ci); }
    } else {
        const ci = line.indexOf(';');
        if (ci !== -1) { codePart = line.substring(0, ci); commentPart = line.substring(ci); }
    }

    // Process the code part by splitting into tokens while preserving whitespace and strings
    let result = '';
    let i = 0;
    while (i < codePart.length) {
        // Preserve leading/trailing whitespace
        if (codePart[i] === ' ' || codePart[i] === '\t') {
            result += codePart[i];
            i++;
            continue;
        }
        // String literals
        if (codePart[i] === '"') {
            let end = codePart.indexOf('"', i + 1);
            if (end === -1) end = codePart.length - 1;
            const str = codePart.substring(i, end + 1);
            result += `<span class="asm-string">${escapeHtml(str)}</span>`;
            i = end + 1;
            continue;
        }
        // Collect a token (word or punctuation group)
        let start = i;
        if (/[a-zA-Z_.]/.test(codePart[i])) {
            while (i < codePart.length && /[a-zA-Z0-9_.]/.test(codePart[i])) i++;
        } else if (/[0-9#\-]/.test(codePart[i])) {
            if (codePart[i] === '#') i++;
            if (i < codePart.length && codePart[i] === '-') i++;
            while (i < codePart.length && /[0-9.]/.test(codePart[i])) i++;
        } else {
            i++;
        }
        const token = codePart.substring(start, i);
        result += classifyToken(token, isARM);
    }

    // Add highlighted comment
    if (commentPart) {
        result += `<span class="asm-comment">${escapeHtml(commentPart)}</span>`;
    }

    return result;
}

function classifyToken(token, isARM) {
    const escaped = escapeHtml(token);
    const lower = token.toLowerCase();

    // Labels (token ending with colon)
    if (token.endsWith(':')) {
        return `<span class="asm-label">${escaped}</span>`;
    }

    // Directives (starting with dot)
    if (token.startsWith('.')) {
        return `<span class="asm-directive">${escaped}</span>`;
    }

    // x86 directives
    if (!isARM && /^(section|global|extern|db|dq|dd|dw|qword|rel)$/i.test(token)) {
        return `<span class="asm-directive">${escaped}</span>`;
    }

    // Numbers (including #immediate)
    if (/^#?-?\d+(\.\d+)?$/.test(token)) {
        return `<span class="asm-number">${escaped}</span>`;
    }

    // ARM64 instructions
    if (isARM && /^(stp|ldp|str|ldr|mov|add|sub|mul|sdiv|bl|b|ret|svc|cmp|cbnz|cbz|cset|neg|adrp|nop|and|orr|eor|lsl|lsr|mvn)$/i.test(token)) {
        return `<span class="asm-instruction">${escaped}</span>`;
    }
    // ARM64 registers
    if (isARM && /^(x\d{1,2}|w\d{1,2}|sp|lr|xzr|wzr)$/i.test(token)) {
        return `<span class="asm-register">${escaped}</span>`;
    }

    // x86 instructions
    if (!isARM && /^(mov|add|sub|imul|idiv|push|pop|call|ret|jmp|jne|je|jl|jle|jg|jge|jnz|jz|cmp|lea|xor|neg|cqo|leave|sete|setne|setl|setle|setg|setge|movzx|nop|and|or|not|shl|shr|test)$/i.test(token)) {
        return `<span class="asm-instruction">${escaped}</span>`;
    }
    // x86 registers
    if (!isARM && /^(rax|rbx|rcx|rdx|rsi|rdi|rbp|rsp|r8|r9|r10|r11|r12|r13|r14|r15|eax|ebx|ecx|edx|esi|edi|al|bl|cl|dl|ah|bh|ch|dh)$/i.test(token)) {
        return `<span class="asm-register">${escaped}</span>`;
    }

    return escaped;
}

// ==========================================
// SISTEMA DE PANELES (WORKSPACE MANAGER)
// ==========================================
const workspace = document.getElementById('workspace');

function updateActiveTab(tabId) {
    document.querySelectorAll('header button[id^="tab-"]').forEach(btn => {
        btn.classList.remove('tab-active', 'text-blue-400');
    });
    const tab = document.getElementById(`tab-${tabId}`);
    if (tab) tab.classList.add('tab-active', 'text-blue-400');
}

// Genera la columna del Editor + Terminal (Siempre van juntos)
function createEditorColumn() {
    const col = document.createElement('div');
    col.className = "editor-col flex flex-col gap-4 overflow-hidden";
    col.style.minWidth = "300px";
    col.style.flex = "1 1 0";
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
        <div class="panel h-48 rounded-lg flex flex-col" style="flex-shrink: 0;">
            <div class="header-bar px-4 py-1">Terminal / Salida</div>
            <div id="terminal" class="flex-1 p-4 overflow-y-auto text-xs whitespace-pre-wrap font-mono">${appState.consoleOut}</div>
        </div>
    `;
    
    setTimeout(updateLineNumbers, 0);
    return col;
}

// Función global para actualizar la cuenta de líneas
window.updateLineNumbers = function() {
    const textarea = document.getElementById('sourceCode');
    const lineNumbers = document.getElementById('lineNumbers');
    if (!textarea || !lineNumbers) return;
    
    const lines = textarea.value.split('\n').length;
    let numbersHtml = '';
    for (let i = 1; i <= lines; i++) {
        numbersHtml += i + '<br>';
    }
    lineNumbers.innerHTML = numbersHtml;
};

// Genera una columna genérica de solo lectura (para .jj o Cuádruples)
function createViewerColumn(title, content, isASM, isARM) {
    const col = document.createElement('div');
    col.className = "viewer-col panel rounded-lg flex flex-col overflow-hidden";
    col.style.minWidth = "250px";
    col.style.flex = "1 1 0";

    const displayContent = (isASM && content && !content.startsWith("Ejecuta"))
        ? highlightASM(content, isARM)
        : escapeHtml(content || '');

    col.innerHTML = `
        <div class="header-bar px-4 py-1 text-center relative flex justify-center items-center">
            <span>${title}</span>
            <button onclick="this.closest('.viewer-col').remove()" class="absolute right-3 text-red-400 hover:text-red-500 font-bold transition-colors text-sm" title="Cerrar panel">✖</button>
        </div>
        <div class="p-4 text-xs whitespace-pre-wrap overflow-y-auto h-full text-gray-300 ${isASM ? 'asm-viewer' : ''}">${displayContent}</div>
    `;
    return col;
}

// Crea un handle de redimensionado entre paneles
function createResizeHandle() {
    const handle = document.createElement('div');
    handle.className = 'resize-handle';
    handle.title = 'Arrastra para redimensionar';
    return handle;
}

// ==========================================
// SISTEMA DE REDIMENSIONADO DE PANELES
// ==========================================
function initResizableHandles() {
    const handles = workspace.querySelectorAll('.resize-handle');
    handles.forEach(handle => {
        handle.addEventListener('mousedown', startResize);
        handle.addEventListener('touchstart', startResizeTouch, { passive: false });
    });
}

function startResize(e) {
    e.preventDefault();
    const handle = e.target;
    const prevPanel = handle.previousElementSibling;
    const nextPanel = handle.nextElementSibling;
    if (!prevPanel || !nextPanel) return;

    const startX = e.clientX;
    const prevWidth = prevPanel.getBoundingClientRect().width;
    const nextWidth = nextPanel.getBoundingClientRect().width;

    handle.classList.add('active');
    document.body.classList.add('resizing');

    function onMove(e) {
        const delta = e.clientX - startX;
        const newPrev = Math.max(200, prevWidth + delta);
        const newNext = Math.max(200, nextWidth - delta);
        prevPanel.style.flex = 'none';
        nextPanel.style.flex = 'none';
        prevPanel.style.width = newPrev + 'px';
        nextPanel.style.width = newNext + 'px';
    }

    function onUp() {
        handle.classList.remove('active');
        document.body.classList.remove('resizing');
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
    }

    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup', onUp);
}

function startResizeTouch(e) {
    e.preventDefault();
    const handle = e.target;
    const prevPanel = handle.previousElementSibling;
    const nextPanel = handle.nextElementSibling;
    if (!prevPanel || !nextPanel) return;

    const startX = e.touches[0].clientX;
    const prevWidth = prevPanel.getBoundingClientRect().width;
    const nextWidth = nextPanel.getBoundingClientRect().width;

    handle.classList.add('active');

    function onMove(e) {
        const delta = e.touches[0].clientX - startX;
        const newPrev = Math.max(200, prevWidth + delta);
        const newNext = Math.max(200, nextWidth - delta);
        prevPanel.style.flex = 'none';
        nextPanel.style.flex = 'none';
        prevPanel.style.width = newPrev + 'px';
        nextPanel.style.width = newNext + 'px';
    }

    function onUp() {
        handle.classList.remove('active');
        document.removeEventListener('touchmove', onMove);
        document.removeEventListener('touchend', onUp);
    }

    document.addEventListener('touchmove', onMove, { passive: false });
    document.addEventListener('touchend', onUp);
}

// ==========================================
// NAVEGACIÓN Y RENDERIZADO
// ==========================================

function setWorkspace(preset) {
    workspace.innerHTML = '';

    if (preset === 'jj') {
        workspace.appendChild(createViewerColumn('Felix.jj (Código Fuente del Compilador)', appState.jjCode));
    } 
    else if (preset === 'intermedio') {
        workspace.appendChild(createEditorColumn());
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Cuádruples (Sin Optimizar)', appState.quadsUnopt));
    } 
    else if (preset === 'optimizado') {
        workspace.appendChild(createEditorColumn());
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Cuádruples (Sin Optimizar)', appState.quadsUnopt));
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Cuádruples (Optimizados)', appState.quadsOpt));
    }
    else if (preset === 'asm-arm64') {
        workspace.appendChild(createEditorColumn());
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Cuádruples (Optimizados)', appState.quadsOpt));
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Ensamblador ARM64 (GNU/Clang)', appState.asmARM64, true, true));
    }
    else if (preset === 'asm-x86') {
        workspace.appendChild(createEditorColumn());
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Cuádruples (Optimizados)', appState.quadsOpt));
        workspace.appendChild(createResizeHandle());
        workspace.appendChild(createViewerColumn('Ensamblador x86_64 (Intel/NASM)', appState.asmX86, true, false));
    }

    appState.currentWorkspace = preset;
    saveState();
    updateActiveTab(preset);
    initResizableHandles();
}

// ==========================================
// INTERACCIÓN Y COMPILACIÓN
// ==========================================

function loadExample(type) {
    if (type === 'libre') {
        document.getElementById('explicacion-dict').innerHTML = "<b>Modo Libre:</b><br>Escribe tu propio código Felix. Observa cómo el pipeline intenta aplicar todas las optimizaciones posibles a la vez.";
        appState.consoleOut = `<span class="text-blue-400">Modo Libre activado. Escribe tu código y presiona Ejecutar.</span>`;
        appState.sourceCode = "";
    } else {
        document.getElementById('explicacion-dict').innerHTML = explanations[type];
        appState.consoleOut = `<span class="text-blue-400">Ejemplo cargado. Haz clic en Ejecutar.</span>`;
        appState.lastExample = type;
        
        if(type === 'cse') appState.sourceCode = `
    WRITE "Calculando coordenadas...";
    SET x TO 10;
    SET y TO 20;
    SET z TO 5;

    WRITE "Punto A:";
    SET puntoA TO (x * y) + z;
    WRITE puntoA;

    WRITE "Punto B (con offset):";
    SET puntoB TO (x * y) + 15;
    WRITE puntoB;
    `;
        if(type === 'copy') appState.sourceCode = `
    SET tarifaBase TO 500,0;
    SET tarifaCliente TO tarifaBase;
    SET cobroFinal TO tarifaCliente;
    SET impuesto TO cobroFinal * 0.16;

    WRITE "El impuesto a pagar es:";
    WRITE impuesto;
    `;
        if(type === 'loop') appState.sourceCode = `
    SET factor TO 3;
    SET iteracion TO 0;

    WHILE (iteracion < 50) DO
    WRITE "Procesando...";
    SET constanteMagica TO (factor * 100) / 2;
    SET resultado TO iteracion + constanteMagica;
     WRITE resultado;
    
    SET iteracion TO iteracion + 1;
    ENDWHILE
    `;
    }
    
    saveState();
    setWorkspace('intermedio');
}

function uploadFile(event) {
    const file = event.target.files[0];
    if (file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            appState.sourceCode = e.target.result;
            saveState();
            
            const currentEditor = document.getElementById('sourceCode');
            if (currentEditor) {
                currentEditor.value = appState.sourceCode;
                updateLineNumbers();
            }
            
            const currentTerminal = document.getElementById('terminal');
            if (currentTerminal) {
                currentTerminal.innerHTML = `<span class="text-blue-400">Archivo '${file.name}' cargado exitosamente.</span>`;
            }
            
            event.target.value = ''; 
        };
        reader.readAsText(file);
    }
}

async function compileCode() {
    const codeArea = document.getElementById('sourceCode');
    if(codeArea) appState.sourceCode = codeArea.value;

    appState.consoleOut = '<span class="text-blue-400">Compilando, optimizando y generando ensamblador...</span>';
    setWorkspace('intermedio'); 

    try {
        const response = await fetch(`${API_URL}/compile`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: JSON.stringify({ code: appState.sourceCode })
        });
        
        if (!response.ok) {
            appState.consoleOut = `<span class="text-red-500">Error HTTP ${response.status}: ${response.statusText}</span>`;
            setWorkspace('intermedio');
            saveState();
            return;
        }

        const data = await response.json();
        
        if (data.hasErrors) {
            appState.consoleOut = `<span class="text-red-400">Error:</span>\n${data.terminalOutput}`;
            appState.quadsUnopt = "No generado debido a errores.";
            appState.quadsOpt = "No generado debido a errores.";
            appState.asmARM64 = "No generado debido a errores.";
            appState.asmX86 = "No generado debido a errores.";
        } else {
            // Construir salida de terminal con resultado del programa
            const escapeHTML = (str) => str.replace(/[&<>'"]/g, 
                tag => ({
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    "'": '&#39;',
                    '"': '&quot;'
                }[tag])
            );

            let terminalHTML = `<span class="text-green-400">✓ Compilación exitosa</span>\n`;
            
            if (data.programOutput && data.programOutput.trim()) {
                terminalHTML += `\n<span class="text-blue-400">━━━ Salida del programa ━━━</span>\n`;
                terminalHTML += `<span class="text-white">${escapeHTML(data.programOutput.trim())}</span>\n`;
                terminalHTML += `<span class="text-blue-400">━━━━━━━━━━━━━━━━━━━━━━━━━━</span>`;
            } else {
                terminalHTML += `<span class="text-gray-400">(El programa no produce salida)</span>`;
            }
            
            appState.consoleOut = terminalHTML;
            appState.quadsUnopt = data.quadsUnopt || "Archivo sin optimizar vacío o no encontrado.";
            appState.quadsOpt = data.quadsOpt || "Archivo optimizado vacío o no encontrado.";
            appState.asmARM64 = data.asmARM64 || "Ensamblador ARM64 no generado.";
            appState.asmX86 = data.asmX86 || "Ensamblador x86_64 no generado.";
        }
        
        // Cambiar a vista de ensamblador activo automáticamente
        if (!data.hasErrors && appState.arch) {
            if (appState.arch.arm64Enabled) {
                setWorkspace('asm-arm64');
            } else {
                setWorkspace('asm-x86');
            }
        } else {
            setWorkspace('optimizado');
        }

    } catch (err) {
        console.error('Error de compilación:', err);
        appState.consoleOut = `<span class="text-red-500">Error de conexión: ${err.message}</span>\n<span class="text-gray-400">Verifica que el servidor esté corriendo en ${API_URL.replace('/api','')}</span>`;
        setWorkspace('intermedio');
    }
}

// Inicializar la vista: restaurar el workspace guardado o usar el predeterminado
setWorkspace(appState.currentWorkspace || 'intermedio');