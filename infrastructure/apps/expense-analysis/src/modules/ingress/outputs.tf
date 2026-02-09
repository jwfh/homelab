output "ingress_name" {
  description = "Ingress resource name"
  value       = kubernetes_ingress_v1.expense_analysis.metadata[0].name
}

output "tls_secret_name" {
  description = "Name of the TLS secret"
  value       = kubernetes_secret.tls_cert.metadata[0].name
}

output "domain_name" {
  description = "Domain name for the application"
  value       = nonsensitive(local.domain_name)
}
