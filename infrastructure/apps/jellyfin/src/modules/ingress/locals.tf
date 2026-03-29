locals {
  config             = local.local_config != null ? local.local_config : module.configuration[0].configuration
  domain_name        = local.config.app.domain_name
  ingress_class_name = local.config.ingress.class_name
}
