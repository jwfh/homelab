output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.jellyfin.metadata[0].name
}
