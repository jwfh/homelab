resource "kubernetes_ingress_v1" "jenkins" {
  metadata {
    name      = "jenkins-ingress"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"         = "true"
    }
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.jenkins.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [var.ingress_host]
    }
  }
}
