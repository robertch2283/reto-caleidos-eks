# ============================================================
# TIER PÚBLICO: Security Group del Application Load Balancer
# ============================================================
resource "aws_security_group" "alb" {
  name        = "${var.project}-alb-sg"
  description = "Tier publico - ALB recibe HTTP y HTTPS desde internet"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.project}-alb-sg"
    Tier = "public"
  }
}

# HTTPS desde los orígenes permitidos
resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  for_each = toset(var.allowed_ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS desde internet"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# HTTP solo para redirigir a HTTPS (lo configura el Ingress en la Fase 5)
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each = toset(var.allowed_ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTP solo para redirect a HTTPS"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}