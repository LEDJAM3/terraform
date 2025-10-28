// Configuración del backend
const BACKEND_URL = window.location.hostname === 'localhost' 
    ? 'http://localhost:8000' 
    : `http://${window.location.hostname}:8000`;

// Función para mostrar resultados
function showResult(elementId, message, isSuccess) {
    const resultDiv = document.getElementById(elementId);
    resultDiv.textContent = message;
    resultDiv.className = `result show ${isSuccess ? 'success' : 'error'}`;
}

// Probar conexión con el backend
document.getElementById('testBtn').addEventListener('click', async () => {
    const btn = document.getElementById('testBtn');
    btn.disabled = true;
    btn.textContent = 'Conectando...';

    try {
        const response = await fetch(`${BACKEND_URL}/api/health`);
        const data = await response.json();
        
        showResult('result', 
            `✅ Conexión exitosa!\n` +
            `Estado: ${data.status}\n` +
            `Mensaje: ${data.message}\n` +
            `Timestamp: ${new Date(data.timestamp).toLocaleString()}`,
            true
        );
    } catch (error) {
        showResult('result', 
            `❌ Error al conectar con el backend:\n${error.message}`,
            false
        );
    } finally {
        btn.disabled = false;
        btn.textContent = 'Probar Conexión';
    }
});

// Enviar mensaje al backend
document.getElementById('sendBtn').addEventListener('click', async () => {
    const messageInput = document.getElementById('messageInput');
    const message = messageInput.value.trim();
    
    if (!message) {
        showResult('messageResult', '⚠️ Por favor escribe un mensaje', false);
        return;
    }

    const btn = document.getElementById('sendBtn');
    btn.disabled = true;
    btn.textContent = 'Enviando...';

    try {
        const response = await fetch(`${BACKEND_URL}/api/message`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message })
        });
        
        const data = await response.json();
        
        showResult('messageResult', 
            `✅ Mensaje recibido!\n` +
            `Tu mensaje: "${data.received}"\n` +
            `Respuesta del servidor: "${data.response}"`,
            true
        );
        
        messageInput.value = '';
    } catch (error) {
        showResult('messageResult', 
            `❌ Error al enviar mensaje:\n${error.message}`,
            false
        );
    } finally {
        btn.disabled = false;
        btn.textContent = 'Enviar';
    }
});

// Permitir enviar con Enter
document.getElementById('messageInput').addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        document.getElementById('sendBtn').click();
    }
});

// Log de inicio
console.log('🚀 Frontend cargado correctamente');
console.log('📡 Backend URL:', BACKEND_URL);