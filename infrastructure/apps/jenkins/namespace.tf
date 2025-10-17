resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "ci-cd"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}
