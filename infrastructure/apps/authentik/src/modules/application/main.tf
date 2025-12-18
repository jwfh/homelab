resource "helm_release" "authentik" {
  name       = "authentik"
  repository = "https://charts.goauthentik.io"
  chart      = "authentik"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    yamlencode({
      authentik = {
        secret_key = local.secret_key
        log_level  = "info"
        error_reporting = {
          enabled = var.error_reporting_enabled
        }
        email = {
          from     = local.email_from
          host     = local.email_host
          port     = local.email_port
          username = local.email_username
          password = local.email_password
          use_tls  = local.email_security == "tls" ? true : false
          use_ssl  = local.email_security == "ssl" ? true : false
        }
        postgresql = {
          name     = local.postgresql_name
          user     = "file:///postgres-creds/username"
          password = "file:///postgres-creds/password"
        }
      }

      postgresql = {
        enabled = true
        primary = {
          persistence = {
            enabled       = true
            existingClaim = var.postgres_pvc_name
          }
          podSecurityContext = {
            enabled  = true
            fsGroup  = 1001
            runAsUser = 1001
          }
          containerSecurityContext = {
            enabled                  = true
            runAsNonRoot             = true
            allowPrivilegeEscalation = false
            capabilities = {
              drop = ["ALL"]
            }
          }
        }
        auth = {
          username = local.postgresql_user
          database = local.postgresql_name
        }
      }

      server = {
        # Pod-level security context
        securityContext = {
          runAsNonRoot = true
          runAsUser    = 568
          runAsGroup   = 568
          fsGroup      = 568
        }
        # Container-level security context
        containerSecurityContext = {
          allowPrivilegeEscalation = false
          capabilities = {
            drop = ["ALL"]
          }
          readOnlyRootFilesystem = false
        }
        volumes = [
          {
            name = "certs"
            persistentVolumeClaim = {
              claimName = var.certs_pvc_name
            }
          },
          {
            name = "media"
            persistentVolumeClaim = {
              claimName = var.media_pvc_name
            }
          },
          {
            name = "templates"
            persistentVolumeClaim = {
              claimName = var.templates_pvc_name
            }
          },
          {
            name = "postgres-creds"
            secret = {
              secretName = kubernetes_secret.postgres_credentials.id
            }
          },
        ]
        volumeMounts = [
          {
            name      = "certs"
            mountPath = "/certs"
          },
          {
            name      = "media"
            mountPath = "/media"
          },
          {
            name      = "templates"
            mountPath = "/templates"
          },
          {
            name      = "postgres-creds"
            mountPath = "/postgres-creds"
            readOnly  = true
          },
        ]
        ingress = {
          enabled          = true
          ingressClassName = local.ingress_class_name
          hosts = [local.domain_name]
          paths = ["/"]
          pathType = "Prefix"
          tls = [
            {
              hosts      = [local.domain_name]
              secretName = "authentik-tls"
            }
          ]
        }
      }

      worker = {
        # Pod-level security context
        securityContext = {
          runAsNonRoot = true
          runAsUser    = 568
          runAsGroup   = 568
          fsGroup      = 568
        }
        # Container-level security context
        containerSecurityContext = {
          allowPrivilegeEscalation = false
          capabilities = {
            drop = ["ALL"]
          }
          readOnlyRootFilesystem = false
        }
        volumes = [
          {
            name = "certs"
            persistentVolumeClaim = {
              claimName = var.certs_pvc_name
            }
          },
          {
            name = "media"
            persistentVolumeClaim = {
              claimName = var.media_pvc_name
            }
          },
          {
            name = "templates"
            persistentVolumeClaim = {
              claimName = var.templates_pvc_name
            }
          },
          {
            name = "postgres-creds"
            secret = {
              secretName = kubernetes_secret.postgres_credentials.id
            }
          },
        ]
        volumeMounts = [
          {
            name      = "certs"
            mountPath = "/certs"
          },
          {
            name      = "media"
            mountPath = "/media"
          },
          {
            name      = "templates"
            mountPath = "/templates"
          },
          {
            name      = "postgres-creds"
            mountPath = "/postgres-creds"
            readOnly  = true
          },
        ]
      }

      kubernetesIntegration = {
        enabled = true
      }

      serviceAccount = {
        create = true
      }
    })
  ]

  # Wait for resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 120
}
