output "ingress_service_name" {
  description = "Traefik ingress service name"
  value       = "traefik"
}

output "tls_secret_name" {
  description = "Name of the TLS secret"
  value       = kubernetes_secret.tls_cert.metadata[0].name
}

output "traefik" {
  value     = helm_release.traefik
  sensitive = true
}
