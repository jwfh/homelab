locals {
  domain_name = module.configuration.configuration.app.domain_name
  secret_key  = module.configuration.configuration.app.secret_key

  ingress_class_name = module.configuration.configuration.ingress.class_name

  email_from     = module.configuration.configuration.email.from
  email_host     = module.configuration.configuration.email.host
  email_port     = module.configuration.configuration.email.port
  email_username = module.configuration.configuration.email.username
  email_password = module.configuration.configuration.email.password
  email_security = module.configuration.configuration.email.security

  postgresql_name     = module.configuration.configuration.postgresql.name
  postgresql_user     = module.configuration.configuration.postgresql.user
  postgresql_password = module.configuration.configuration.postgresql.password
}
