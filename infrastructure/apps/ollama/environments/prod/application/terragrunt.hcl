include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/ollama/src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

inputs = {
  environment   = "prod"
  namespace     = dependency.namespace.outputs.namespace
  chart_version = "1.10.0"

  models_pvc_name = dependency.storage.outputs.models_pvc_name
  memory_limit    = "8Gi"
}
