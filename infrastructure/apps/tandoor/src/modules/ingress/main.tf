# Traefik Ingress Controller using Helm
resource "helm_release" "traefik" {
  name       = "tandoor-traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "26.0.0"
  namespace  = var.namespace

  values = [
    yamlencode({
      deployment = {
        replicas = 1
      }

      # Use a specific IngressClass name to avoid conflicts
      ingressClass = {
        enabled        = true
        isDefaultClass = false
        name           = "traefik-${var.namespace}"
      }

      service = {
        type = "NodePort"
      }

      ports = {
        websecure = {
          port        = 443
          exposedPort = 443
          tls = {
            enabled = true
          }
        }
      }

      ingressRoute = {
        dashboard = {
          enabled = false # Disable dashboard for production
        }
      }

      logs = {
        general = {
          level = "INFO"
        }
        access = {
          enabled = true
        }
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }
    })
  ]
}

# Self-signed certificate for TLS
resource "kubernetes_secret" "tls_cert" {
  metadata {
    name      = "tandoor-tls"
    namespace = var.namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.tls_cert != "" ? var.tls_cert : tls_self_signed_cert.default[0].cert_pem
    "tls.key" = var.tls_key != "" ? var.tls_key : tls_private_key.default[0].private_key_pem
  }

  depends_on = [helm_release.traefik]
}

# Generate self-signed certificate if not provided
resource "tls_private_key" "default" {
  count     = var.tls_cert == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "default" {
  count           = var.tls_cert == "" ? 1 : 0
  private_key_pem = tls_private_key.default[0].private_key_pem

  subject {
    common_name  = "recipes.jwfh.ca"
    organization = "Tandoor Recipes"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}
