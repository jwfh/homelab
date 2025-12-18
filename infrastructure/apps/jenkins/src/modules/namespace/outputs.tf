output "namespace" {
  description = "The Kubernetes namespace for Jenkins"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "service_account_name" {
  description = "The Jenkins service account name"
  value       = kubernetes_service_account.jenkins.metadata[0].name
}
