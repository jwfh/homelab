output "service_name" {
  description = "Backend service name"
  value       = kubernetes_service.backend.metadata[0].name
}

output "deployment_name" {
  description = "Backend deployment name"
  value       = kubernetes_deployment.backend.metadata[0].name
}
