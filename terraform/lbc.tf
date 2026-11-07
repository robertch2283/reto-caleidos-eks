# ============================================================
# 1. Politica IAM oficial del controller (fijada a v3.6.2)
# ============================================================
resource "aws_iam_policy" "lbc" {
  name        = "${var.project}-aws-lbc"
  description = "Permisos del AWS Load Balancer Controller"
  policy      = file("${path.module}/policies/aws-lbc-iam-policy.json")
}

# ============================================================
# 2. Rol IAM que SOLO puede asumir EKS Pod Identity
# ============================================================
resource "aws_iam_role" "lbc" {
  name = "${var.project}-aws-lbc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

# ============================================================
# 3. Vinculo: ServiceAccount del controller <-> rol IAM
# ============================================================
resource "aws_eks_pod_identity_association" "lbc" {
  cluster_name    = module.eks.cluster_name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lbc.arn
}

# ============================================================
# 4. Instalacion del controller con Helm
# ============================================================
resource "helm_release" "lbc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.lbc_chart_version
  namespace  = "kube-system"

  set = [
    { name = "clusterName", value = module.eks.cluster_name },
    { name = "region", value = var.region },
    { name = "vpcId", value = module.vpc.vpc_id },
    { name = "serviceAccount.name", value = "aws-load-balancer-controller" },
    { name = "replicaCount", value = "2" },
  ]

  # El controller debe arrancar con las credenciales ya disponibles
    depends_on = [
    module.eks,
    aws_eks_pod_identity_association.lbc,
    aws_iam_role_policy_attachment.lbc,
  ]
}
