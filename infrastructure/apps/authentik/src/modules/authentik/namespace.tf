resource "kubernetes_namespace" "authentik" {
  metadata {
    name = module.configuration.namespace
    labels = {
      name        = module.configuration.namespace
      environment = var.environment
      app         = "authentik"
      managed-by  = "terraform"
    }
  }
}
