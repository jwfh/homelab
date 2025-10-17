# This file serves as the entry point for the Jenkins Terraform module
# It orchestrates the deployment of Jenkins on Kubernetes with:
# - Namespace creation
# - NFS-backed persistent storage
# - RBAC configuration
# - Jenkins controller deployment
# - Service and Ingress for external access

# Provider configuration is expected to be configured externally
# Example:
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
