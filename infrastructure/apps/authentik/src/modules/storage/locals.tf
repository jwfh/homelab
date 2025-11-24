locals {
  nfs_server         = module.configuration.configuration.nfs.server
  nfs_certs_path     = module.configuration.configuration.nfs.certs_path
  nfs_media_path     = module.configuration.configuration.nfs.media_path
  nfs_postgres_path  = module.configuration.configuration.nfs.postgres_path
  nfs_templates_path = module.configuration.configuration.nfs.templates_path
}
