output "service_name" {
  description = "PostgreSQL service name"
  value       = kubernetes_service.postgres.metadata[0].name
}

output "service_port" {
  description = "PostgreSQL service port"
  value       = kubernetes_service.postgres.spec[0].port[0].port
}
