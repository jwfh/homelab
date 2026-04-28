locals {
  config           = local.local_config != null ? local.local_config : module.configuration[0].configuration
  nfs_server       = local.config.nfs.server
  nfs_jenkins_path = local.config.nfs.jenkins_path
}
