module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  # Privadas /20: 10.0.0.0/20, 10.0.16.0/20
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]

  # Públicas /24: 10.0.48.0/24, 10.0.49.0/24
  public_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + 48)]

  # Salida a internet desde las privadas
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Etiquetas que usará el AWS Load Balancer Controller (Fase 4)
  # para saber dónde crear los balanceadores
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}