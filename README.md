# 🚀 Práctica 3.2 - Despliegue Fullstack con Terraform

Despliegue automatizado de una aplicación fullstack en Oracle Cloud usando Terraform, GitHub Actions y Docker.

## 📋 Descripción

Aplicación web fullstack simple desplegada automáticamente en Oracle Cloud Infrastructure (OCI) con:
- **Frontend**: HTML, CSS, JS con Nginx
- **Backend**: Node.js + Express API REST
- **Infraestructura**: Terraform
- **CI/CD**: GitHub Actions
- **Contenedores**: Docker + DockerHub

## 🏗️ Estructura del Proyecto

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline de GitHub Actions
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   ├── style.css
│   ├── script.js
│   └── nginx.conf
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── main.tf                     # Configuración principal de Terraform
├── provider.tf                 # Configuración del provider de OCI
├── variables.tf                # Variables de Terraform
├── terraform.tfvars            # Valores de las variables (NO subir a Git)
├── docker-compose.yml          # Orquestación de contenedores
└── README.md
```

## ⚙️ Requisitos Previos

1. **Cuenta de Oracle Cloud** con:
   - Tenancy OCID
   - User OCID
   - API Key (fingerprint y private key)
   - VCN y Subnet configuradas

2. **Cuenta de DockerHub**:
   - Usuario: `ledjam`
   - Token de acceso personal

3. **Repositorio de GitHub**:
   - https://github.com/LEDJAM3/terraform.git

4. **Par de claves SSH** para acceso a las instancias

## 🔐 Configuración de Secrets en GitHub

Ve a tu repositorio → Settings → Secrets and variables → Actions → New repository secret

Agrega los siguientes secrets:

### Oracle Cloud Infrastructure
- `OCI_TENANCY_OCID`: Tu tenancy OCID
- `OCI_USER_OCID`: Tu user OCID
- `OCI_FINGERPRINT`: Fingerprint de tu API key
- `OCI_PRIVATE_KEY`: Tu private key completa (incluye `-----BEGIN PRIVATE KEY-----`)
- `OCI_REGION`: Región (ej: `sa-saopaulo-1`)
- `OCI_COMPARTMENT_OCID`: Compartment OCID
- `OCI_SUBNET_ID`: Subnet OCID
- `OCI_AVAILABILITY_DOMAIN`: Availability domain (ej: `wyaX:SA-SAOPAULO-1-AD-1`)
- `OCI_UBUNTU_IMAGE_OCID`: OCID de la imagen Ubuntu 22.04

### SSH Keys
- `SSH_PUBLIC_KEY`: Tu clave SSH pública (para la instancia)
- `SSH_PRIVATE_KEY`: Tu clave SSH privada (para deployment)

### DockerHub
- `DOCKERHUB_TOKEN`: Token de acceso de DockerHub

### Email Notifications
- `EMAIL_USERNAME`: Tu email de Gmail (ej: `diegomelna14@gmail.com`)
- `EMAIL_PASSWORD`: App password de Gmail (no tu contraseña normal)

### Cómo generar App Password de Gmail:
1. Ve a tu cuenta de Google
2. Seguridad → Verificación en dos pasos (actívala si no lo está)
3. App passwords → Generar
4. Copia el password de 16 dígitos

## 🚀 Despliegue Manual (Primera vez)

### 1. Clonar el repositorio
```bash
git clone https://github.com/LEDJAM3/terraform.git
cd terraform
```

### 2. Configurar Terraform
Crea o edita `terraform.tfvars` con tus valores:
```hcl
tenancy_ocid = "ocid1.tenancy..."
user_ocid = "ocid1.user..."
fingerprint = "0c:59:..."
private_key_path = "ruta/a/tu/clave.pem"
region = "sa-saopaulo-1"
compartment_ocid = "ocid1.tenancy..."
subnet_id = "ocid1.subnet..."
availability_domain = "wyaX:SA-SAOPAULO-1-AD-1"
ubuntu_image_ocid = "ocid1.image..."
ssh_public_key = "ssh-ed25519 AAAA..."
```

### 3. Inicializar y aplicar Terraform
```bash
terraform init
terraform validate
terraform plan
terraform apply
```

### 4. Obtener la IP pública
```bash
terraform output instance_public_ip
```

### 5. Conectarse a la instancia
```bash
ssh ubuntu@[IP_PUBLICA]
```

### 6. Desplegar manualmente (opcional)
En la instancia:
```bash
# Descargar docker-compose.yml desde el repo
wget https://raw.githubusercontent.com/LEDJAM3/terraform/main/docker-compose.yml

# Iniciar contenedores
docker compose up -d

# Ver logs
docker compose logs -f
```

## 🔄 Despliegue Automático con GitHub Actions

Una vez configurados los secrets:

1. **Push a main/master**: El pipeline se ejecuta automáticamente
2. **Workflow manual**: Ve a Actions → Deploy Fullstack App → Run workflow

### Pipeline Jobs:
1. ✅ **Checkout**: Descarga el código
2. 🏗️ **Build**: Construye y sube imágenes Docker
3. 🌐 **Infrastructure**: Provisiona con Terraform
4. 🚀 **Deploy**: Despliega contenedores en la VM
5. 📧 **Notify**: Envía email con resultado

## 🌐 URLs de Acceso

Después del despliegue:
- **Frontend**: `http://[IP_PUBLICA]:3000`
- **Backend**: `http://[IP_PUBLICA]:8000`
- **API Info**: `http://[IP_PUBLICA]:8000/api/info`
- **Health Check**: `http://[IP_PUBLICA]:8000/api/health`

## 🧪 Probar la Aplicación

### Frontend
Abre en el navegador: `http://[IP_PUBLICA]:3000`

### Backend (con curl)
```bash
# Health check
curl http://[IP_PUBLICA]:8000/api/health

# Información de la API
curl http://[IP_PUBLICA]:8000/api/info

# Enviar mensaje
curl -X POST http://[IP_PUBLICA]:8000/api/message \
  -H "Content-Type: application/json" \
  -d '{"message":"Hola desde curl"}'
```

## 🐳 Comandos Docker Útiles

En la VM:
```bash
# Ver contenedores en ejecución
docker ps

# Ver logs
docker compose logs -f

# Reiniciar servicios
docker compose restart

# Detener servicios
docker compose down

# Actualizar imágenes
docker compose pull
docker compose up -d
```

## 🧹 Limpieza

Para destruir la infraestructura:
```bash
terraform destroy
```

## 📧 Notificaciones por Email

Recibirás emails en `diegomelna14@gmail.com` con:
- ✅ Despliegues exitosos con las URLs de acceso
- ❌ Despliegues fallidos con links a los logs

## 🔧 Troubleshooting

### Error de conexión SSH
```bash
# Verificar que la clave tenga los permisos correctos
chmod 600 ~/.ssh/id_rsa
```

### Contenedores no inician
```bash
# Conectarse a la VM
ssh ubuntu@[IP_PUBLICA]

# Ver logs
docker compose logs

# Verificar imágenes
docker images
```

### Firewall bloqueando puertos
```bash
# En la VM, verificar UFW
sudo ufw status

# Permitir puertos si es necesario
sudo ufw allow 3000/tcp
sudo ufw allow 8000/tcp
```

## 📝 Notas

- El `terraform.tfvars` **NO** debe subirse a Git (está en .gitignore)
- Las claves privadas **NUNCA** deben compartirse públicamente
- Usa App Passwords de Gmail, no tu contraseña normal
- La primera ejecución del pipeline puede tardar 5-10 minutos

## 👨‍💻 Autor

Diego Mena - LEDJAM
- GitHub: [@LEDJAM3](https://github.com/LEDJAM3)
- DockerHub: [ledjam](https://hub.docker.com/u/ledjam)
- Email: diegomelna14@gmail.com

## 📚 Recursos

- [Documentación de Terraform](https://www.terraform.io/docs)
- [Oracle Cloud Infrastructure](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Docker](https://docs.docker.com/)