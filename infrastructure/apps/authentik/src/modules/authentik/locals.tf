locals {
  domain_name = module.configuration.configuration.app.domain_name
  secret_key  = module.configuration.configuration.app.secret_key

  bootstrap_email    = module.configuration.configuration.bootstrap.email
  bootstrap_password = module.configuration.configuration.bootstrap.password
  bootstrap_token    = module.configuration.configuration.bootstrap.token

  email_from     = module.configuration.configuration.email.from
  email_host     = module.configuration.configuration.email.host
  email_port     = module.configuration.configuration.email.port
  email_username = module.configuration.configuration.email.username
  email_password = module.configuration.configuration.email.password
  email_security = module.configuration.configuration.email.security

  nfs_server         = module.configuration.configuration.nfs.server
  nfs_media_path     = module.configuration.configuration.nfs.media_path
  nfs_postgres_path  = module.configuration.configuration.nfs.postgres_path
  nfs_redis_path     = module.configuration.configuration.nfs.redis_path
  nfs_templates_path = module.configuration.configuration.nfs.templates_path

  postgresql_name     = module.configuration.configuration.postgresql.name
  postgresql_user     = module.configuration.configuration.postgresql.user
  postgresql_password = module.configuration.configuration.postgresql.password
  redis_password      = module.configuration.configuration.redis.password
}
