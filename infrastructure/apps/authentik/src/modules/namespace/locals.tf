locals {
  kubernetes_namespace = "${var.environment}-authentik"

  app_secret_key = module.configuration.configuration.app.secret_key
}
