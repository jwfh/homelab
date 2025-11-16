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
  nfs_data_path         = dependency.namespace.outputs.nfs_data_path
  nfs_postgres_path     = dependency.namespace.outputs.nfs_postgres_path
  data_storage_size     = "32Gi"
  postgres_storage_size = "50Gi"
}
