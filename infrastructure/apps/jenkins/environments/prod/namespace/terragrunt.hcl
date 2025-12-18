# Namespace and base resources
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jenkins/src/modules/namespace"
}

inputs = {
  environment = "prod"
}
