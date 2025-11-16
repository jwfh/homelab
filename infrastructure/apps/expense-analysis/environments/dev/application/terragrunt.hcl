# Application (Backend)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "ingress" {
  config_path = "../ingress"
}

dependency "storage" {
  config_path = "../storage"
}

dependency "database" {
  config_path = "../database"
}

inputs = {
  namespace    = dependency.namespace.outputs.namespace
  app_version  = "latest"
  docker_image = "jwhouse/expense-analysis"
  replicas     = 1

  auth_method = dependency.namespace.outputs.auth_method
  oidc_configuration = dependency.namespace.outputs.oidc_configuration

  database_host = dependency.database.outputs.service_name
  database_port = dependency.database.outputs.service_port
  database_name = dependency.database.outputs.database_name
  database_user = dependency.database.outputs.database_user

  data_pvc_name = dependency.storage.outputs.data_pvc_name

  secrets_name = dependency.namespace.outputs.secrets_name

  domain_name = dependency.namespace.outputs.domain_name

  traefik = dependency.ingress.outputs.traefik
}
