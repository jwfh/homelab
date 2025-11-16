# Ingress (Traefik) - must run before application
include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../src/modules/ingress"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  namespace = dependency.namespace.outputs.namespace
}
