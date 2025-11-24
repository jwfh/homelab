# PostgreSQL StatefulSet
resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
    labels = {
      app  = "tandoor"
      tier = "database"
    }
  }

  spec {
    service_name = "postgres"
    replicas     = 1

    selector {
      match_labels = {
        app = "tandoor"
      }
    }

    update_strategy {
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          app  = "tandoor"
          tier = "database"
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
          image = "bitnami/postgresql:16"

          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user = 1001
          }

          port {
            container_port = 5432
            name           = "postgresql"
            protocol       = "TCP"
          }

          env {
            name  = "BITNAMI_DEBUG"
            value = "false"
          }

          env {
            name  = "POSTGRESQL_PORT_NUMBER"
            value = "5432"
          }

          env {
            name  = "POSTGRESQL_VOLUME_DIR"
            value = "/bitnami/postgresql"
          }

          env {
            name  = "PGDATA"
            value = "/bitnami/postgresql/data"
          }

          env {
            name  = "POSTGRES_USER"
            value = var.database_user
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "postgresql-password"
              }
            }
          }

          env {
            name = "POSTGRESQL_POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "postgresql-postgres-password"
              }
            }
          }

          env {
            name  = "POSTGRES_DB"
            value = var.database_name
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/bitnami/postgresql"
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }

          liveness_probe {
            exec {
              command = ["sh", "-c", "exec pg_isready -U \"postgres\" -d \"${var.database_name}\" -h 127.0.0.1 -p 5432"]
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          readiness_probe {
            exec {
              command = ["sh", "-c", "-e", "pg_isready -U \"postgres\" -d \"${var.database_name}\" -h 127.0.0.1 -p 5432\n[ -f /opt/bitnami/postgresql/tmp/.initialized ]"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }

        # Init container to set up permissions
        dynamic "init_container" {
          for_each = [1]
          content {
            name  = "init-chmod-data"
            image = "bitnami/minideb:stretch"

            image_pull_policy = "Always"

            security_context {
              run_as_user = 0
            }

            command = ["sh", "-c"]
            args = [<<-EOF
              mkdir -p /bitnami/postgresql/data
              chmod 700 /bitnami/postgresql/data
              find /bitnami/postgresql -mindepth 0 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" | \
                xargs chown -R 1001:1001
            EOF
            ]

            resources {
              requests = {
                cpu    = "250m"
                memory = "256Mi"
              }
            }

            volume_mount {
              name       = "postgres-storage"
              mount_path = "/bitnami/postgresql"
            }
          }
        }

        security_context {
          fs_group = 1001
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
      app  = "tandoor"
      tier = "database"
    }
  }

  spec {
    selector = {
      app  = "tandoor"
      tier = "database"
    }

    port {
      name        = "postgresql"
      port        = 5432
      target_port = "postgresql"
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}
