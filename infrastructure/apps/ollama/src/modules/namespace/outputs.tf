output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.ollama.metadata[0].name
}
