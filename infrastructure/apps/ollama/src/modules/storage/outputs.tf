output "models_pvc_name" {
  description = "Name of the Ollama models PVC"
  value       = kubernetes_persistent_volume_claim.models.metadata[0].name
}
