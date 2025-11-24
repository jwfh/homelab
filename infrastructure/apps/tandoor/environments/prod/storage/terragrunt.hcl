# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  namespace             = dependency.namespace.outputs.namespace
  nfs_server            = dependency.namespace.outputs.nfs_server
  nfs_media_path        = dependency.namespace.outputs.nfs_media_path
  nfs_static_path       = dependency.namespace.outputs.nfs_static_path
  nfs_postgres_path     = dependency.namespace.outputs.nfs_postgres_path
  media_storage_size    = "50Gi"
  static_storage_size   = "10Gi"
  postgres_storage_size = "50Gi"
}
