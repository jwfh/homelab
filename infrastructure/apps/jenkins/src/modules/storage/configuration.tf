module "configuration" {
  source = "../../../../../modules/configuration"

  app_name    = "jenkins"
  environment = var.environment
}
