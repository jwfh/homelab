# PostgreSQL StatefulSet
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
    labels = {
      app       = "postgres"
      component = "database"
    }
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app       = "postgres"
        component = "database"
      }
    }

    template {
      metadata {
        labels = {
          app       = "postgres"
          component = "database"
        }
      }

      spec {
        # Exclude control plane nodes - tolerate the control-plane taint
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

        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          security_context {
            run_as_non_root = true
            run_as_user     = 70
            run_as_group    = 70
          }

          port {
            container_port = 5432
            name           = "postgres"
          }

          env {
            name  = "POSTGRES_DB"
            value = local.db_name
          }

          env {
            name  = "POSTGRES_USER"
            value = local.db_user
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "database-password"
              }
            }
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
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
            exec {
              command = ["pg_isready", "-U", local.db_user, "-d", local.db_name]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", local.db_user, "-d", local.db_name]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        volume {
          name = "postgres-storage"
          persistent_volume_claim {
            claim_name = var.pvc_name
          }
        }
      }
    }
  }
}

# PostgreSQL Service
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
    labels = {
      app       = "postgres"
      component = "database"
    }
  }

  spec {
    selector = {
      app       = "postgres"
      component = "database"
    }

    port {
      name        = "postgres"
      port        = 5432
      target_port = 5432
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
