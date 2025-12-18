resource "kubernetes_namespace" "ollama" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "ollama"
      managed-by  = "terraform"
    }
  }
}
