# Kubernetes and Helm Provider Configuration
# 
# This provider configuration connects Terraform to your k3s cluster.
# You have several options for authentication:

# Option 1: Use kubeconfig file (recommended for local development)
provider "kubernetes" {
  config_path = "~/.kube/k3s-config"
  # Or use the default kubeconfig
  # config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/k3s-config"
    # Or use the default kubeconfig
    # config_path = "~/.kube/config"
  }
}

# Option 2: Use kubeconfig context
# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "k3s-homelab"
# }
#
# provider "helm" {
#   kubernetes {
#     config_path    = "~/.kube/config"
#     config_context = "k3s-homelab"
#   }
# }

# Option 3: Direct cluster connection (for CI/CD)
# provider "kubernetes" {
#   host                   = "https://k8s.lemarchant.jacobhouse.ca:6443"
#   cluster_ca_certificate = base64decode(var.cluster_ca_cert)
#   token                  = var.k8s_token
# }
#
# provider "helm" {
#   kubernetes {
#     host                   = "https://k8s.lemarchant.jacobhouse.ca:6443"
#     cluster_ca_certificate = base64decode(var.cluster_ca_cert)
#     token                  = var.k8s_token
#   }
# }

# Option 4: Use environment variables
# Set these environment variables before running terraform:
# export KUBE_CONFIG_PATH=~/.kube/k3s-config
# Then use:
# provider "kubernetes" {}
# provider "helm" {
#   kubernetes {}
# }
