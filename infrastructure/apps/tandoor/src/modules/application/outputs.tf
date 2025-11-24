output "service_name" {
  description = "Tandoor service name"
  value       = kubernetes_service.tandoor.metadata[0].name
}

output "service_port" {
  description = "Tandoor service port"
  value       = kubernetes_service.tandoor.spec[0].port[0].port
}

output "deployment_name" {
  description = "Tandoor deployment name"
  value       = kubernetes_deployment.tandoor.metadata[0].name
}

output "ingress_route_name" {
  description = "Tandoor IngressRoute name"
  value       = kubernetes_manifest.ingress_route.manifest.metadata.name
}
