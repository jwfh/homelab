# Application (Jellyfin)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jellyfin/src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

dependency "ingress" {
  config_path = "../ingress"
}

inputs = {
  environment     = "dev"
  namespace       = dependency.namespace.outputs.namespace
  app_version     = "latest"
  config_pvc_name = dependency.storage.outputs.config_pvc_name
  cache_pvc_name  = dependency.storage.outputs.cache_pvc_name
  media_pvc_names = dependency.storage.outputs.media_pvc_names
}
