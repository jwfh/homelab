module "configuration" {
  source = "../../../../../modules/configuration"

  app_name    = "authentik"
  environment = var.environment
}
