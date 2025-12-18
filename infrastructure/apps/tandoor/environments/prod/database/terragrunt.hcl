# Database (PostgreSQL)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../src/modules/database"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

inputs = {
  namespace     = dependency.namespace.outputs.namespace
  secrets_name  = dependency.namespace.outputs.secrets_name
  database_name = dependency.namespace.outputs.db_name
  database_user = dependency.namespace.outputs.db_user
  pvc_name      = dependency.storage.outputs.postgres_pvc_name
}
