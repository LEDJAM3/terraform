FROM node:18-alpine

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install --production

# Copiar código de la aplicación
COPY . .

EXPOSE 8000

CMD ["node", "server.js"]