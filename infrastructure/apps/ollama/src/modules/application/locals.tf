locals {
  domain_name        = module.configuration.configuration.app.domain_name
  openwebui_domain   = module.configuration.configuration.app.openwebui_domain
  ingress_class_name = module.configuration.configuration.ingress.class_name
  models_to_pull     = module.configuration.configuration.app.models
}
