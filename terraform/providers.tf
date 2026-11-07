provider "aws" {
  region = var.region

  # Estas etiquetas se aplican automáticamente a TODOS los recursos
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Consulta a AWS las AZs disponibles en la región (no las escribimos a mano)
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  # Toma las primeras N zonas, ej: ["us-east-2a", "us-east-2b"]
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}