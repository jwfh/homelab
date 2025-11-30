# Jenkins on Kubernetes with Terraform
#
# This module deploys Jenkins on Kubernetes using:
# - Helm chart from https://charts.jenkins.io (official Jenkins Helm chart)
# - Jenkins Configuration as Code (JCasC) for automated configuration
# - NFS-backed persistent storage for the controller
# - Kubernetes dynamic agents with ephemeral storage
# - GitHub Organization scanning with branch/repo filtering
#
# The deployment is managed through:
# - namespace.tf: Creates the Jenkins namespace
# - storage.tf: Sets up NFS PV and PVC for controller storage
# - rbac.tf: Creates ServiceAccount and RBAC permissions
# - helm.tf: Deploys Jenkins via Helm chart with JCasC configuration
# - helm-values.yaml: Jenkins configuration including plugins and cloud settings
# - variables.tf: Configurable parameters
#
# GitHub Organization Configuration:
# - Scans the configured GitHub organization for repositories
# - Uses regex filtering for repositories (github_repo_regex variable)
# - Filters branches using the github_branch_regex variable
# - Automatically creates multibranch pipelines for repos with Jenkinsfile
#
# Kubernetes Agents:
# - Agents run in the same namespace as the controller
# - Use ephemeral storage (emptyDir volumes)
# - Templates: "default" (general purpose) and "docker" (with DinD)
#
# Prerequisites:
# - Kubernetes cluster with k3s or similar
# - NFS server accessible from the cluster
# - Traefik ingress controller (or modify ingress_class_name)
# - GitHub personal access token stored as Jenkins credential
#
# Usage:
# 1. Copy terraform.tfvars.example to terraform.tfvars
# 2. Configure the variables for your environment
# 3. Run: terraform init && terraform apply

# Provider configuration should be provided externally via providers.tf
# Example providers.tf:
#
# provider "kubernetes" {
#   config_path = "~/.kube/config"
# }
#
# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }

