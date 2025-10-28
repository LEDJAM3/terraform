#!/bin/bash

# Script de despliegue local para Práctica 3.2
# Uso: ./deploy.sh [init|plan|apply|destroy|deploy|status]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Verificar que terraform.tfvars existe
check_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        error "No se encontró terraform.tfvars. Créalo primero con tus credenciales."
    fi
}

# Terraform init
tf_init() {
    info "Inicializando Terraform..."
    terraform init
}

# Terraform plan
tf_plan() {
    check_tfvars
    info "Generando plan de Terraform..."
    terraform plan -out=tfplan
}

# Terraform apply
tf_apply() {
    check_tfvars
    info "Aplicando cambios de Terraform..."
    terraform apply -auto-approve tfplan || terraform apply -auto-approve
    
    info "Obteniendo IP pública..."
    INSTANCE_IP=$(terraform output -raw instance_public_ip)
    echo ""
    echo "======================================="
    echo "✅ Despliegue completado!"
    echo "📍 IP Pública: $INSTANCE_IP"
    echo "🌐 Frontend: http://$INSTANCE_IP:3000"
    echo "🌐 Backend: http://$INSTANCE_IP:8000"
    echo "======================================="
    echo ""
}

# Terraform destroy
tf_destroy() {
    check_tfvars
    warn "¿Estás seguro de destruir la infraestructura? (yes/no)"
    read -r confirmation
    if [ "$confirmation" = "yes" ]; then
        info "Destruyendo infraestructura..."
        terraform destroy -auto-approve
        info "Infraestructura destruida."
    else
        info "Operación cancelada."
    fi
}

# Desplegar aplicación en la VM
deploy_app() {
    check_tfvars
    
    info "Obteniendo IP de la instancia..."
    INSTANCE_IP=$(terraform output -raw instance_public_ip)
    
    if [ -z "$INSTANCE_IP" ]; then
        error "No se pudo obtener la IP de la instancia. ¿Está aprovisionada?"
    fi
    
    info "Desplegando aplicación en $INSTANCE_IP..."
    
    # Copiar docker-compose.yml
    scp docker-compose.yml ubuntu@$INSTANCE_IP:/home/ubuntu/
    
    # Ejecutar comandos en la VM
    ssh ubuntu@$INSTANCE_IP << 'EOF'
        echo "Actualizando imágenes Docker..."
        docker pull ledjam/backend-api:latest
        docker pull ledjam/frontend-app:latest
        
        echo "Deteniendo contenedores existentes..."
        docker compose down 2>/dev/null || true
        
        echo "Iniciando nuevos contenedores..."
        docker compose up -d
        
        echo "Esperando a que los servicios inicien..."
        sleep 10
        
        echo "Estado de los contenedores:"
        docker ps
        
        echo ""
        echo "Logs de los contenedores:"
        docker compose logs --tail=20
EOF
    
    echo ""
    echo "======================================="
    echo "✅ Aplicación desplegada!"
    echo "🌐 Frontend: http://$INSTANCE_IP:3000"
    echo "🌐 Backend: http://$INSTANCE_IP:8000"
    echo "======================================="
    echo ""
}

# Ver estado
show_status() {
    check_tfvars
    
    info "Obteniendo información de la infraestructura..."
    
    if terraform state list >/dev/null 2>&1; then
        INSTANCE_IP=$(terraform output -raw instance_public_ip 2>/dev/null || echo "N/A")
        
        echo ""
        echo "======================================="
        echo "📊 Estado de la Infraestructura"
        echo "======================================="
        echo "IP Pública: $INSTANCE_IP"
        
        if [ "$INSTANCE_IP" != "N/A" ]; then
            echo ""
            echo "🌐 URLs:"
            echo "  Frontend: http://$INSTANCE_IP:3000"
            echo "  Backend:  http://$INSTANCE_IP:8000"
            echo "  API Info: http://$INSTANCE_IP:8000/api/info"
            echo ""
            echo "🔐 SSH:"
            echo "  ssh ubuntu@$INSTANCE_IP"
            echo ""
            
            info "Probando conectividad..."
            if curl -s -o /dev/null -w "%{http_code}" "http://$INSTANCE_IP:8000/api/health" | grep -q "200"; then
                echo "✅ Backend está respondiendo"
            else
                echo "❌ Backend no responde"
            fi
            
            if curl -s -o /dev/null -w "%{http_code}" "http://$INSTANCE_IP:3000" | grep -q "200"; then
                echo "✅ Frontend está respondiendo"
            else
                echo "❌ Frontend no responde"
            fi
        fi
        
        echo "======================================="
    else
        warn "No se encontró estado de Terraform. Ejecuta 'init' primero."
    fi
}

# Menú principal
case "$1" in
    init)
        tf_init
        ;;
    plan)
        tf_plan
        ;;
    apply)
        tf_apply
        ;;
    destroy)
        tf_destroy
        ;;
    deploy)
        deploy_app
        ;;
    status)
        show_status
        ;;
    *)
        echo "Uso: $0 {init|plan|apply|destroy|deploy|status}"
        echo ""
        echo "Comandos:"
        echo "  init     - Inicializar Terraform"
        echo "  plan     - Ver plan de cambios"
        echo "  apply    - Aplicar infraestructura"
        echo "  destroy  - Destruir infraestructura"
        echo "  deploy   - Desplegar aplicación en VM"
        echo "  status   - Ver estado actual"
        exit 1
        ;;
esac