# Namespace and base resources
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/authentik/src/modules/namespace"
}

inputs = {
  environment = "prod"
}
