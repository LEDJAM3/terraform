variable "tenancy_ocid" {
  description = "OCID del tenancy de Oracle Cloud"
  type        = string
}

variable "user_ocid" {
  description = "OCID del usuario"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la API key"
  type        = string
}

variable "private_key_path" {
  description = "Ruta a la clave privada"
  type        = string
}

variable "region" {
  description = "Región de Oracle Cloud"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_ocid" {
  description = "OCID del compartment"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subnet existente"
  type        = string
}

variable "availability_domain" {
  description = "Availability domain"
  type        = string
}

variable "ubuntu_image_ocid" {
  description = "OCID de la imagen Ubuntu 22.04"
  type        = string
}

variable "ssh_public_key" {
  description = "Clave SSH pública para acceso a las instancias"
  type        = string
}

variable "instance_shape" {
  description = "Shape de la instancia"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "frontend_port" {
  description = "Puerto del frontend"
  type        = number
  default     = 3000
}

variable "backend_port" {
  description = "Puerto del backend"
  type        = number
  default     = 8000
}

variable "notification_email" {
  description = "Email para notificaciones"
  type        = string
  default     = ""
}