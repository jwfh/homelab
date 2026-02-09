# Application (Backend)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/expense-analysis/src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

dependency "database" {
  config_path = "../database"
}

dependency "ingress" {
  config_path = "../ingress"
}

inputs = {
  environment  = "dev" 
  namespace    = dependency.namespace.outputs.namespace
  app_version  = "latest"
  docker_image = "jwhouse/expense-analysis"
  replicas     = 1

  database_host = dependency.database.outputs.service_name
  database_port = dependency.database.outputs.service_port
  data_pvc_name = dependency.storage.outputs.data_pvc_name
  secrets_name = dependency.namespace.outputs.secrets_name
}
