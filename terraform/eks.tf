module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project}-eks"
  kubernetes_version = var.kubernetes_version

  # --- Acceso al API de Kubernetes: público pero solo desde tu IP ---
  endpoint_public_access       = true
  endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  # El usuario que ejecuta Terraform queda como administrador del cluster
  enable_cluster_creator_admin_permissions = true

  # Usamos EKS Pod Identity en lugar de IRSA/OIDC
  enable_irsa = false

  # --- Red: el plano de datos va SOLO en subnets privadas ---
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # --- Add-ons administrados por EKS ---
  addons = {
    vpc-cni = {
      before_compute = true # debe existir ANTES que los nodos
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy     = {}
    coredns        = {}
    metrics-server = {} # requisito del HPA
  }

  # --- Plano de datos: Managed Node Group ---
  eks_managed_node_groups = {
    app = {
      name           = "${var.project}-app"
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND" # Spot está bloqueado en el plan gratuito

      min_size     = var.node_min_size
      desired_size = var.node_desired_size
      max_size     = var.node_max_size

      # Prefijo acme-tx: lo exige nuestra política IAM
      iam_role_name = "${var.project}-node"

      labels = {
        tier = "app"
      }
    }
  }
}