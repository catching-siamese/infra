

resource "tls_private_key" "app_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Generate Self-Signed TLS Certificate
resource "tls_self_signed_cert" "app_cert" {
  private_key_pem = tls_private_key.app_key.private_key_pem

  subject {
    organization = var.environment
    common_name  = var.common_name
  }

  validity_period_hours = 8760 # 1 year
  early_renewal_hours = 720 # 1 month before expiry

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [
    "${var.common_name}",
    "*.${var.common_name}",
  ]
}

# 4. Save the Keypair into a Kubernetes TLS Secret
resource "kubernetes_secret_v1" "tls_secret" {
  metadata {
    name      = "tls-cert"
    namespace = var.secret_name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.app_cert.cert_pem
    "tls.key" = tls_private_key.app_key.private_key_pem
  }
}