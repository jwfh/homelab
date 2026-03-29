output "service_name" {
  description = "Jellyfin service name"
  value       = kubernetes_service.jellyfin.metadata[0].name
}

output "deployment_name" {
  description = "Jellyfin deployment name"
  value       = kubernetes_deployment.jellyfin.metadata[0].name
}
