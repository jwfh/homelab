output "config_pvc_name" {
  description = "Name of the Jellyfin config PVC"
  value       = kubernetes_persistent_volume_claim.config.metadata[0].name
}

output "cache_pvc_name" {
  description = "Name of the Jellyfin cache PVC"
  value       = kubernetes_persistent_volume_claim.cache.metadata[0].name
}

output "media_pvc_names" {
  description = "Map of media PVC names keyed by media type"
  value       = { for k, v in kubernetes_persistent_volume_claim.media : k => v.metadata[0].name }
}
