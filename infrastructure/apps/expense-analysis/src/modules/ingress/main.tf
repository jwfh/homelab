module "configuration" {
  source = "../../../../../modules/configuration"

  app_name    = "expense-analysis"
  environment = var.environment
}

locals {
  domain_name        = module.configuration.configuration.app.domain_name
  ingress_class_name = module.configuration.configuration.ingress.class_name
}

# Kubernetes Ingress using shared Traefik
resource "kubernetes_ingress_v1" "expense_analysis" {
  metadata {
    name      = "expense-analysis"
    namespace = var.namespace
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"         = "true"
    }
  }

  spec {
    ingress_class_name = local.ingress_class_name

    tls {
      hosts       = [local.domain_name]
      secret_name = "expense-analysis-tls"
    }

    rule {
      host = local.domain_name

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "expense-analysis-backend"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

# Self-signed certificate for TLS (HAProxy terminates TLS, but we need a cert for the ingress)
resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  subject {
    common_name  = local.domain_name
    organization = "Expense Analysis"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [local.domain_name]
}

resource "kubernetes_secret" "tls_cert" {
  metadata {
    name      = "expense-analysis-tls"
    namespace = var.namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.default.cert_pem
    "tls.key" = tls_private_key.default.private_key_pem
  }
}

