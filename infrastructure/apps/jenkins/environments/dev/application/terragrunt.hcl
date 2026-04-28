# Application (Helm release)
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jenkins/src/modules/application"
}

dependency "namespace" {
  config_path = "../namespace"

  mock_outputs = {
    namespace            = "dev-jenkins"
    service_account_name = "jenkins-admin"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "storage" {
  config_path = "../storage"

  mock_outputs = {
    pvc_name = "jenkins-pvc"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  environment          = "dev"
  namespace            = dependency.namespace.outputs.namespace
  service_account_name = dependency.namespace.outputs.service_account_name
  pvc_name             = dependency.storage.outputs.pvc_name
  chart_version        = "5.8.3"
  jenkins_image_tag    = "lts-jdk17"
}
