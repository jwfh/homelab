# Namespace
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/jellyfin/src/modules/namespace"
}

inputs = {
  environment = "prod"
}
