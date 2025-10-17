resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins-service"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/path"   = "/"
      "prometheus.io/port"   = "8080"
    }
  }

  spec {
    selector = {
      "app" = "jenkins-server"
    }

    type = "ClusterIP"

    port {
      name        = "http"
      port        = 8080
      target_port = 8080
      protocol    = "TCP"
    }

    port {
      name        = "jnlp"
      port        = 50000
      target_port = 50000
      protocol    = "TCP"
    }
  }
}
