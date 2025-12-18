output "traefik" {
  description = "Traefik Helm release metadata"
  value = {
    name      = helm_release.traefik.name
    namespace = helm_release.traefik.namespace
    version   = helm_release.traefik.version
  }
}

output "tls_secret_name" {
  description = "Name of the TLS secret"
  value       = kubernetes_secret.tls_cert.metadata[0].name
}
