# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/expense-analysis/src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  environment = "prod"
  namespace             = dependency.namespace.outputs.namespace
  data_storage_size     = "32Gi"
  postgres_storage_size = "50Gi"
}
