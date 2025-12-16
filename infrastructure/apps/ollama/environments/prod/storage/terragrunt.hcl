# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/ollama/src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  environment = "prod"
  namespace   = dependency.namespace.outputs.namespace

  models_storage_size = "64Gi"
}
