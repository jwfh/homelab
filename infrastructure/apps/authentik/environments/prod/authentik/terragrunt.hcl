include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../src/modules/authentik"
}

inputs = {  
  chart_version = "2024.10.1"
  
  error_reporting_enabled = false
  
  # Ingress configuration
  ingress_enabled    = true
  ingress_host       = "auth.example.com"
  ingress_class_name = "traefik"
  ingress_annotations = {
    "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
  }
}
