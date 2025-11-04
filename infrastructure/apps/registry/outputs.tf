output "namespace_name" {
  description = "Name of the created namespace"
  value       = kubernetes_namespace.docker_registry.metadata[0].name
}

output "deployment_name" {
  description = "Name of the registry deployment"
  value       = kubernetes_deployment.registry.metadata[0].name
}

output "service_name" {
  description = "Name of the registry service"
  value       = kubernetes_service.registry.metadata[0].name
}

output "service_cluster_ip" {
  description = "Cluster IP of the registry service"
  value       = kubernetes_service.registry.spec[0].cluster_ip
}

output "service_port" {
  description = "Port of the registry service"
  value       = kubernetes_service.registry.spec[0].port[0].port
}

output "ingress_name" {
  description = "Name of the registry ingress"
  value       = kubernetes_ingress_v1.registry.metadata[0].name
}

output "registry_hostname" {
  description = "Hostname to access the registry"
  value       = "https://${var.registry_hostname}"
}

output "internal_registry_url" {
  description = "Internal URL to access the registry from within the cluster"
  value       = "http://${kubernetes_service.registry.metadata[0].name}.${kubernetes_namespace.docker_registry.metadata[0].name}.svc.cluster.local:${kubernetes_service.registry.spec[0].port[0].port}"
}

output "nfs_storage_info" {
  description = "Information about NFS storage configuration"
  value = {
    server = var.nfs_server
    path   = var.nfs_path
    pv_name = kubernetes_persistent_volume.registry_storage.metadata[0].name
    pvc_name = kubernetes_persistent_volume_claim.registry_storage.metadata[0].name
  }
}

output "registry_configuration" {
  description = "Registry deployment configuration"
  value = {
    replicas       = var.registry_replicas
    image          = var.registry_image
    uid            = var.registry_uid
    gid            = var.registry_gid
    storage_size   = var.registry_storage_size
    memory_request = var.registry_memory_request
    memory_limit   = var.registry_memory_limit
    cpu_request    = var.registry_cpu_request
    cpu_limit      = var.registry_cpu_limit
  }
}
