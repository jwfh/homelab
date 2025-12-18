output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.authentik.metadata[0].name
}

output "secrets_name" {
  description = "Name of the secrets resource"
  value       = kubernetes_secret.app_secrets.metadata[0].name
}
