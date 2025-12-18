# Database (PostgreSQL)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/expense-analysis/src/modules/database"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

inputs = {
  environment = "prod"
  namespace     = dependency.namespace.outputs.namespace
  secrets_name  = dependency.namespace.outputs.secrets_name
  pvc_name      = dependency.storage.outputs.postgres_pvc_name
}
