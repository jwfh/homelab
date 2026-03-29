resource "kubernetes_namespace" "jellyfin" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "jellyfin"
      managed-by  = "terraform"
    }
  }
}
