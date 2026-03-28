# Generate a secret key for Open WebUI
resource "random_password" "openwebui_secret" {
  length  = 32
  special = false
}

resource "helm_release" "ollama" {
  name       = "ollama"
  repository = "https://helm.otwld.com/"
  chart      = "ollama"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    yamlencode({
      ollama = {
        gpu = {
          enabled = false
        }
        models = {
          pull = local.models_to_pull
        }
        # Override default mount path since we're not running as root
        mountPath = "/ollama/.ollama"
      }

      # Run as UID 568 to match NFS volume permissions
      podSecurityContext = {
        runAsUser  = 568
        runAsGroup = 568
        fsGroup    = 568
      }

      securityContext = {
        runAsNonRoot             = true
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
      }

      # Set HOME so Ollama writes to the mounted volume
      extraEnv = [
        {
          name  = "HOME"
          value = "/ollama"
        }
      ]

      persistentVolume = {
        enabled       = true
        existingClaim = var.models_pvc_name
      }

      resources = {
        limits = {
          memory = var.memory_limit
        }
      }

      ingress = {
        enabled   = true
        className = local.ingress_class_name
        hosts = [
          {
            host = local.domain_name
            paths = [
              {
                path     = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
        tls = [
          {
            hosts      = [local.domain_name]
            secretName = "ollama-tls"
          }
        ]
      }

      livenessProbe = {
        enabled             = true
        initialDelaySeconds = 120
        periodSeconds       = 10
        timeoutSeconds      = 5
        failureThreshold    = 6
      }

      readinessProbe = {
        enabled             = true
        initialDelaySeconds = 60
        periodSeconds       = 5
        timeoutSeconds      = 3
        failureThreshold    = 6
      }

      serviceAccount = {
        create = true
      }
    })
  ]

  # Wait for resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 300 # 5 minutes - model pulling can take time
}

# Open WebUI - Web interface for Ollama
resource "helm_release" "open_webui" {
  name       = "open-webui"
  repository = "https://helm.openwebui.com/"
  chart      = "open-webui"
  version    = var.openwebui_chart_version
  namespace  = var.namespace

  values = [
    yamlencode({
      # Disable embedded Ollama - we use our own
      ollama = {
        enabled = false
      }

      # Point to our Ollama instance
      ollamaUrls = ["http://ollama:11434"]

      # Disable pipelines for now (can enable later if needed)
      pipelines = {
        enabled = false
      }

      # Disable OpenAI API (we're using Ollama only)
      enableOpenaiApi = false

      # Persistence for Open WebUI data
      persistence = {
        enabled       = true
        existingClaim = var.openwebui_pvc_name
        size          = "2Gi"
      }

      # Ingress configuration
      ingress = {
        enabled = true
        class   = local.ingress_class_name
        host    = local.openwebui_domain
        tls     = true
        existingSecret = "openwebui-tls"
        annotations = {
          "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
          "traefik.ingress.kubernetes.io/router.tls"         = "true"
        }
      }

      # Service account
      serviceAccount = {
        enable = true
        create = true
      }

      # Security context - run as UID 568 for NFS permissions
      podSecurityContext = {
        fsGroup = 568
      }

      containerSecurityContext = {
        runAsUser    = 568
        runAsGroup   = 568
        runAsNonRoot = true
      }

      # Environment variables
      extraEnvVars = [
        {
          name  = "WEBUI_SECRET_KEY"
          value = random_password.openwebui_secret.result
        },
        {
          name  = "DATA_DIR"
          value = "/app/backend/data"
        }
      ]

      # Resource limits
      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "1000m"
          memory = "1Gi"
        }
      }
    })
  ]

  # Wait for Ollama to be ready first
  depends_on = [helm_release.ollama]

  wait          = true
  wait_for_jobs = true
  timeout       = 300
}

# Self-signed TLS certificate for Open WebUI
resource "tls_private_key" "openwebui" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "openwebui" {
  private_key_pem = tls_private_key.openwebui.private_key_pem

  subject {
    common_name  = local.openwebui_domain
    organization = "Open WebUI"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = [local.openwebui_domain]
}

resource "kubernetes_secret" "openwebui_tls" {
  metadata {
    name      = "openwebui-tls"
    namespace = var.namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.openwebui.cert_pem
    "tls.key" = tls_private_key.openwebui.private_key_pem
  }
}
