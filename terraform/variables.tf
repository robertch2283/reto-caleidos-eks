variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-2"
}

variable "project" {
  description = "Prefijo de todos los recursos (debe coincidir con la política IAM: acme-tx-*)"
  type        = string
  default     = "acme-tx"
}

variable "environment" {
  description = "Entorno"
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "Rango de IPs de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Cantidad de zonas de disponibilidad"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "Para alta disponibilidad se necesitan entre 2 y 3 AZs."
  }
}

variable "single_nat_gateway" {
  description = "true = 1 NAT (más barato, sin HA). false = 1 NAT por AZ (alta disponibilidad)"
  type        = bool
  default     = false
}

variable "allowed_ingress_cidrs" {
  description = "Orígenes que pueden llegar al ALB por HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ---------------- EKS ----------------
variable "kubernetes_version" {
  description = "Versión de Kubernetes (en soporte estándar para evitar el costo de soporte extendido)"
  type        = string
  default     = "1.35"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "IPs que pueden usar kubectl contra el API del cluster"
  type        = list(string)
}

variable "node_instance_types" {
description = "Tipo de instancia de los nodos (debe ser Free Tier eligible en el plan gratuito)"
  type        = list(string)
  default     = ["c7i-flex.large"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}
