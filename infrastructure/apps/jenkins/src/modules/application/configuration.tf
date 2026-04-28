locals {
  local_config = try(jsondecode(file("${path.module}/../../../config.${var.environment}.json")), null)
}

module "configuration" {
  count  = local.local_config == null ? 1 : 0
  source = "../../../../../modules/configuration"

  app_name    = "jenkins"
  environment = var.environment
}
