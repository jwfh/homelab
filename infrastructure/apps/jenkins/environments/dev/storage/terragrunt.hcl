# Storage (PV/PVC)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jenkins/src/modules/storage"
}

dependency "namespace" {
  config_path = "../namespace"

  mock_outputs = {
    namespace = "dev-jenkins"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  environment  = "dev"
  namespace    = dependency.namespace.outputs.namespace
  storage_size = "20Gi"
}
