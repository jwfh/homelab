# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/authentik/src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  environment = "prod"
  namespace   = dependency.namespace.outputs.namespace

  media_storage_size     = "5Gi"
  postgres_storage_size  = "10Gi"
  templates_storage_size = "1Gi"
}
