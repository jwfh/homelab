include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/authentik/src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

inputs = {  
  environment = "prod"
  namespace   = dependency.namespace.outputs.namespace
  chart_version = "2025.10.2"
  
  error_reporting_enabled = false

  postgres_pvc_name = dependency.storage.outputs.postgres_pvc_name
  certs_pvc_name = dependency.storage.outputs.certs_pvc_name
  media_pvc_name = dependency.storage.outputs.media_pvc_name
  templates_pvc_name = dependency.storage.outputs.templates_pvc_name
}
