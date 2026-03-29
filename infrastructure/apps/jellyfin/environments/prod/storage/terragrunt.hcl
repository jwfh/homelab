# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jellyfin/src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  environment         = "prod"
  namespace           = dependency.namespace.outputs.namespace
  config_storage_size = "100Gi"
  cache_storage_size  = "10Gi"
}
