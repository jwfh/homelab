# Ingress - uses shared cluster Traefik
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../../..//apps/expense-analysis/src/modules/ingress"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  environment = "prod"
  namespace   = dependency.namespace.outputs.namespace
}
