
resource "kubernetes_namespace" "authentik" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "authentik"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "authentik-secrets"
    namespace = kubernetes_namespace.authentik.metadata[0].name
  }

  data = {
    secret-key  = local.app_secret_key
  }
}
