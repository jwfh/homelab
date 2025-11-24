output "media_pvc_name" {
  description = "Name of the media PVC"
  value       = kubernetes_persistent_volume_claim.media.metadata[0].name
}

output "static_pvc_name" {
  description = "Name of the static PVC"
  value       = kubernetes_persistent_volume_claim.static.metadata[0].name
}

output "postgres_pvc_name" {
  description = "Name of the PostgreSQL PVC"
  value       = kubernetes_persistent_volume_claim.postgres.metadata[0].name
}
