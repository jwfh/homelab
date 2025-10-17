resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    replicas = var.jenkins_replicas

    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = {
        "app" = "jenkins-server"
      }
    }

    template {
      metadata {
        labels = {
          "app"                          = "jenkins-server"
          "app.kubernetes.io/name"       = "jenkins"
          "app.kubernetes.io/component"  = "controller"
          "app.kubernetes.io/managed-by" = "terraform"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.jenkins.metadata[0].name

        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }

        container {
          name              = "jenkins"
          image             = var.jenkins_image
          image_pull_policy = "Always"

          resources {
            limits = {
              memory = var.resource_limits_memory
              cpu    = var.resource_limits_cpu
            }
            requests = {
              memory = var.resource_requests_memory
              cpu    = var.resource_requests_cpu
            }
          }

          port {
            name           = "httpport"
            container_port = 8080
          }

          port {
            name           = "jnlpport"
            container_port = 50000
          }

          liveness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }

          readiness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          volume_mount {
            name       = "jenkins-data"
            mount_path = "/var/jenkins_home"
          }

          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }
        }

        volume {
          name = "jenkins-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
          }
        }
      }
    }
  }
}
