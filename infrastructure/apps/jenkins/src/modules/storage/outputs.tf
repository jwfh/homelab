output "pvc_name" {
  description = "The Jenkins PVC name"
  value       = kubernetes_persistent_volume_claim.jenkins.metadata[0].name
}

output "pv_name" {
  description = "The Jenkins PV name"
  value       = kubernetes_persistent_volume.jenkins.metadata[0].name
}

output "storage_class_name" {
  description = "The storage class name"
  value       = kubernetes_storage_class.nfs_jenkins.metadata[0].name
}
