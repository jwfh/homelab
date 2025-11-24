module "configuration" {
  source = "../../../../../modules/configuration"

  app_name    = "expense-analysis"
  environment = var.environment
}
