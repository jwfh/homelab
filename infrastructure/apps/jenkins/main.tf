# This file serves as the entry point for the Jenkins Terraform module
# It orchestrates the deployment of Jenkins on Kubernetes using:
# - Helm chart from https://charts.jenkins.io (official Jenkins Helm chart)
# - Jenkins Configuration as Code (JCasC) for automated configuration
# - NFS-backed persistent storage
# - RBAC configuration
# - Traefik ingress for external access

# The deployment is managed through:
# - namespace.tf: Creates the devops-tools namespace
# - storage.tf: Sets up NFS PV and PVC
# - rbac.tf: Creates ServiceAccount and RBAC permissions
# - helm.tf: Deploys Jenkins via Helm chart with JCasC configuration
# - helm-values.yaml: Jenkins configuration including plugins and cloud settings

# Provider configuration is expected to be configured externally
# Example:
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }
