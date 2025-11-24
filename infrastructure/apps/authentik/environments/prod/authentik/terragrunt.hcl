include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/authentik/src/modules/application"
}

inputs = {  
  environment = "prod"
  chart_version = "2024.10.1"
  
  error_reporting_enabled = false
}
