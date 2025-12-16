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
