locals {
  config          = local.local_config != null ? local.local_config : module.configuration[0].configuration
  nfs_server      = local.config.nfs.server
  nfs_config_path = local.config.nfs.config_path
  nfs_cache_path  = local.config.nfs.cache_path
  media_mounts    = local.config.media_mounts
}
