locals {
  nfs_server        = module.configuration.configuration.nfs.server
  nfs_data_path     = module.configuration.configuration.nfs.data_path
  nfs_postgres_path = module.configuration.configuration.nfs.postgres_path
}
