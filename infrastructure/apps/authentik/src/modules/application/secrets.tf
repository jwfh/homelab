resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "authentik-postgres-credentials"
    namespace = var.namespace
  }

  data = {
    username = local.postgresql_user
    password = local.postgresql_password
  }
}

# Generate self-signed certificate if not provided
resource "tls_private_key" "default" {
  count     = var.tls_cert == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  count           = var.tls_cert == null ? 1 : 0
  private_key_pem = tls_private_key.default[0].private_key_pem

  subject {
    common_name  = local.domain_name
    organization = "Authentik"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [local.domain_name]
}

# TLS certificate secret
resource "kubernetes_secret" "tls_cert" {
  metadata {
    name      = "authentik-tls"
    namespace = var.namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.tls_cert != null ? var.tls_cert : tls_self_signed_cert.default[0].cert_pem
    "tls.key" = var.tls_key != null ? var.tls_key : tls_private_key.default[0].private_key_pem
  }
}
