# Jellyfin Deployment
resource "kubernetes_deployment" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = var.namespace
    labels = {
      app = "jellyfin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jellyfin"
      }
    }

    template {
      metadata {
        labels = {
          app = "jellyfin"
        }
      }

      spec {
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

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

        security_context {
          run_as_user     = 868
          run_as_group    = 868
          fs_group        = 868
          run_as_non_root = true
        }

        container {
          name  = "jellyfin"
          image = "jellyfin/jellyfin:${var.app_version}"

          port {
            container_port = 8096
            name           = "http"
            protocol       = "TCP"
          }

          env {
            name  = "JELLYFIN_CACHE_DIR"
            value = "/cache"
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "cache"
            mount_path = "/cache"
          }

          dynamic "volume_mount" {
            for_each = var.media_pvc_names
            content {
              name       = "media-${volume_mount.key}"
              mount_path = "/media/${volume_mount.key}"
              read_only  = true
            }
          }

          resources {
            requests = {
              cpu    = "4000m"
              memory = "2Gi"
            }
            limits = {
              cpu    = "24000m"
              memory = "16Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8096
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 8096
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "config"
          persistent_volume_claim {
            claim_name = var.config_pvc_name
          }
        }

        volume {
          name = "cache"
          persistent_volume_claim {
            claim_name = var.cache_pvc_name
          }
        }

        dynamic "volume" {
          for_each = var.media_pvc_names
          content {
            name = "media-${volume.key}"
            persistent_volume_claim {
              claim_name = volume.value
            }
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

# Jellyfin Service
resource "kubernetes_service" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = var.namespace
    labels = {
      app = "jellyfin"
    }
  }

  spec {
    selector = {
      app = "jellyfin"
    }

    port {
      name        = "http"
      port        = 8096
      target_port = 8096
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
