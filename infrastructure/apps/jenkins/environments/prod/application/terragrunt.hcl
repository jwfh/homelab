# Application (Helm release)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jenkins/src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "storage" {
  config_path = "../storage"
}

inputs = {
  environment          = "prod"
  namespace            = dependency.namespace.outputs.namespace
  service_account_name = dependency.namespace.outputs.service_account_name
  pvc_name             = dependency.storage.outputs.pvc_name
  chart_version        = "5.8.3"
  jenkins_image_tag    = "lts-jdk17"
}
