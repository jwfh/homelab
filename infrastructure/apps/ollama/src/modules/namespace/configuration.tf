module "configuration" {
  source = "../../../../../modules/configuration"

  app_name    = "ollama"
  environment = var.environment
}
