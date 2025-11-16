output "service_name" {
  description = "PostgreSQL service name"
  value       = kubernetes_service.postgres.metadata[0].name
}

output "service_port" {
  description = "PostgreSQL service port"
  value       = kubernetes_service.postgres.spec[0].port[0].port
}

output "database_name" {
  description = "PostgreSQL database name"
  value       = var.database_name
}

output "database_user" {
  description = "PostgreSQL database user"
  value       = var.database_user
}
