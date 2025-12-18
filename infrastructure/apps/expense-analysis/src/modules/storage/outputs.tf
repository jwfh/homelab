output "data_pvc_name" {
  description = "Name of the data PVC"
  value       = kubernetes_persistent_volume_claim.data.metadata[0].name
}

output "postgres_pvc_name" {
  description = "Name of the PostgreSQL PVC"
  value       = kubernetes_persistent_volume_claim.postgres.metadata[0].name
}
