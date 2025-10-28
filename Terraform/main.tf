# Security List para permitir tráfico HTTP/HTTPS y puertos de aplicación
resource "oci_core_security_list" "app_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_subnet.existing_subnet.vcn_id
  display_name   = "app-security-list"

  # Reglas de entrada (Ingress)
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "Allow SSH"
    
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Allow HTTP"
    
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Allow HTTPS"
    
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Allow Frontend"
    
    tcp_options {
      min = var.frontend_port
      max = var.frontend_port
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Allow Backend"
    
    tcp_options {
      min = var.backend_port
      max = var.backend_port
    }
  }

  # Reglas de salida (Egress)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }
}

# Data source para obtener información de la subnet existente
data "oci_core_subnet" "existing_subnet" {
  subnet_id = var.subnet_id
}

# Script de inicialización para la VM
locals {
  cloud_init_script = <<-EOF
    #!/bin/bash
    set -e
    
    # Actualizar sistema
    apt-get update
    apt-get upgrade -y
    
    # Instalar dependencias
    apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      git \
      ufw
    
    # Instalar Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Configurar Docker para usuario ubuntu
    usermod -aG docker ubuntu
    systemctl enable docker
    systemctl start docker
    
    # Configurar firewall
    ufw --force enable
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow ${var.frontend_port}/tcp
    ufw allow ${var.backend_port}/tcp
    
    # Crear directorio para la aplicación
    mkdir -p /opt/app
    chown ubuntu:ubuntu /opt/app
    
    # Crear archivo de flag para indicar que la inicialización está completa
    touch /var/log/cloud-init-complete.log
    echo "Cloud init completed at $(date)" > /var/log/cloud-init-complete.log
  EOF
}

# Instancia de Compute (VM única para frontend y backend)
resource "oci_core_instance" "app_instance" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.instance_shape
  display_name        = "app-fullstack-instance"

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    display_name     = "app-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_ocid
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data          = base64encode(local.cloud_init_script)
  }

  # Configuración de recursos
  shape_config {
    memory_in_gbs = 1
    ocpus         = 1
  }

  # Preservar el boot volume al destruir la instancia
  preserve_boot_volume = false
}

# Output de la IP pública
output "instance_public_ip" {
  description = "IP pública de la instancia"
  value       = oci_core_instance.app_instance.public_ip
}

output "instance_id" {
  description = "OCID de la instancia"
  value       = oci_core_instance.app_instance.id
}

output "instance_state" {
  description = "Estado de la instancia"
  value       = oci_core_instance.app_instance.state
}

output "connection_string" {
  description = "Comando para conectar por SSH"
  value       = "ssh ubuntu@${oci_core_instance.app_instance.public_ip}"
}

output "frontend_url" {
  description = "URL del frontend"
  value       = "http://${oci_core_instance.app_instance.public_ip}:${var.frontend_port}"
}

output "backend_url" {
  description = "URL del backend"
  value       = "http://${oci_core_instance.app_instance.public_ip}:${var.backend_port}"
}