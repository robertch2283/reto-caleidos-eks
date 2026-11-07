output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "nat_public_ips" {
  description = "IPs públicas de salida (útil para whitelisting en terceros)"
  value       = module.vpc.nat_public_ips
}

output "alb_security_group_id" {
  description = "Se usará en el manifiesto Ingress (Fase 5)" ##eliminar FASE5
  value       = aws_security_group.alb.id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "configure_kubectl" {
  description = "Comando para conectar kubectl al cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "acm_certificate_arn" {
  description = "Se usara en el Ingress (Fase 5)"
  value       = aws_acm_certificate.app.arn
}

output "lbc_role_arn" {
  value = aws_iam_role.lbc.arn
}