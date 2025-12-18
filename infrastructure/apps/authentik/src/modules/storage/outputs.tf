output "media_pvc_name" {
  description = "Name of the media PVC"
  value       = kubernetes_persistent_volume_claim.media.metadata[0].name
}

output "certs_pvc_name" {
  description = "Name of the certs PVC"
  value       = kubernetes_persistent_volume_claim.certs.metadata[0].name
}

output "postgres_pvc_name" {
  description = "Name of the PostgreSQL PVC"
  value       = kubernetes_persistent_volume_claim.postgres.metadata[0].name
}

output "templates_pvc_name" {
  description = "Name of the templates PVC"
  value       = kubernetes_persistent_volume_claim.templates.metadata[0].name
}