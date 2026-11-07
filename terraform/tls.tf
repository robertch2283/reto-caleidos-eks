# ============================================================
# Certificado autofirmado para HTTPS en el ALB (laboratorio)
# En produccion: aws_acm_certificate publico con validacion DNS (Route 53)
# ============================================================

# Llave privada RSA 2048
resource "tls_private_key" "app" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Certificado autofirmado valido por 1 año
resource "tls_self_signed_cert" "app" {
  private_key_pem = tls_private_key.app.private_key_pem

  subject {
    common_name  = var.app_domain
    organization = "ACME Transacciones (demo)"
  }

  dns_names             = [var.app_domain]
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Importacion a ACM para que el ALB pueda usarlo
resource "aws_acm_certificate" "app" {
  private_key      = tls_private_key.app.private_key_pem
  certificate_body = tls_self_signed_cert.app.cert_pem

  tags = {
    Name = "${var.project}-app-selfsigned"
  }

  lifecycle {
    create_before_destroy = true
  }
}
