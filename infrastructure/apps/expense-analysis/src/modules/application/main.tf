# Backend Deployment
resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "expense-analysis-backend"
    namespace = var.namespace
    labels = {
      app       = "expense-analysis"
      component = "backend"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app       = "expense-analysis"
        component = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app       = "expense-analysis"
          component = "backend"
        }
      }

      spec {
        # Exclude control plane nodes
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        # Prefer worker nodes
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
        }

        # Run as UID/GID 568 for NFS mount compatibility
        security_context {
          run_as_user     = 568
          run_as_group    = 568
          fs_group        = 568
          run_as_non_root = true
        }

        init_container {
          name  = "init-db"
          image = "${var.docker_image}:${var.app_version}"

          image_pull_policy = "Always"

          args = ["init-db"]

          env {
            name  = "DATABASE_HOST"
            value = var.database_host
          }

          env {
            name  = "DATABASE_PORT"
            value = tostring(var.database_port)
          }

          env {
            name  = "DATABASE_NAME"
            value = local.db_name
          }

          env {
            name  = "DATABASE_USER"
            value = local.db_user
          }

          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "database-password"
              }
            }
          }
        }

        container {
          name  = "backend"
          image = "${var.docker_image}:${var.app_version}"

          image_pull_policy = "Always"

          args = ["serve"]

          port {
            container_port = 8080
            name           = "http"
            protocol       = "TCP"
          }

          env {
            name  = "DATABASE_HOST"
            value = var.database_host
          }

          env {
            name  = "DATABASE_PORT"
            value = tostring(var.database_port)
          }

          env {
            name  = "DATABASE_NAME"
            value = local.db_name
          }

          env {
            name  = "DATABASE_USER"
            value = local.db_user
          }

          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "database-password"
              }
            }
          }

          env {
            name = "SECRET_KEY"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "flask-secret-key"
              }
            }
          }

          env {
            name  = "FRONTEND_URL"
            value = "https://${local.app_domain_name}"
          }

          env {
            name  = "AUTH_METHOD"
            value = local.app_auth_method
          }

          dynamic "env" {
            for_each = local.app_auth_method == "oidc" ? ["client_id", "client_secret", "discovery_url", "redirect_uri", "provider_name", "provider_url"] : []
            content {
              name  = "OIDC_${upper(env.value)}"
              value = sensitive(local.oidc_configuration[env.value])
            }
          }

          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          env {
            name  = "FLASK_DEBUG"
            value = "0"
          }

          env {
            name  = "STORAGE_BACKEND"
            value = "local"
          }

          env {
            name  = "LOCAL_STORAGE_PATH"
            value = "/app/data"
          }

          volume_mount {
            name       = "data"
            mount_path = "/app/data"
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "data"
          persistent_volume_claim {
            claim_name = var.data_pvc_name
          }
        }

        restart_policy = "Always"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
    }
  }
}

# Backend Service
resource "kubernetes_service" "backend" {
  metadata {
    name      = "expense-analysis-backend"
    namespace = var.namespace
    labels = {
      app       = "expense-analysis"
      component = "backend"
    }
  }

  spec {
    selector = {
      app       = "expense-analysis"
      component = "backend"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
