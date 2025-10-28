const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Logger middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Backend funcionando correctamente',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'production'
    });
});

// Endpoint para recibir mensajes
app.post('/api/message', (req, res) => {
    const { message } = req.body;
    
    if (!message) {
        return res.status(400).json({
            error: 'El mensaje es requerido'
        });
    }

    console.log('Mensaje recibido:', message);

    res.json({
        success: true,
        received: message,
        response: `¡Mensaje "${message}" procesado exitosamente!`,
        timestamp: new Date().toISOString()
    });
});

// Endpoint de información
app.get('/api/info', (req, res) => {
    res.json({
        name: 'Backend API - Práctica 3.2',
        version: '1.0.0',
        description: 'API REST desplegada con Terraform, GitHub Actions y Docker',
        endpoints: [
            { path: '/api/health', method: 'GET', description: 'Health check' },
            { path: '/api/message', method: 'POST', description: 'Enviar mensaje' },
            { path: '/api/info', method: 'GET', description: 'Información de la API' }
        ]
    });
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        message: 'Bienvenido al Backend API',
        status: 'running',
        docs: '/api/info'
    });
});

// Manejador de rutas no encontradas
app.use((req, res) => {
    res.status(404).json({
        error: 'Ruta no encontrada',
        path: req.path
    });
});

// Manejador de errores
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(500).json({
        error: 'Error interno del servidor',
        message: err.message
    });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log('=================================');
    console.log(`🚀 Servidor iniciado en puerto ${PORT}`);
    console.log(`📡 Endpoints disponibles:`);
    console.log(`   GET  /api/health`);
    console.log(`   POST /api/message`);
    console.log(`   GET  /api/info`);
    console.log('=================================');
});