# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jenkins/src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  environment  = "prod"
  namespace    = dependency.namespace.outputs.namespace
  storage_size = "20Gi"
}
