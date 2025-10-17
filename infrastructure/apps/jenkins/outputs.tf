output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "service_name" {
  description = "Jenkins service name"
  value       = kubernetes_service.jenkins.metadata[0].name
}

output "ingress_host" {
  description = "Jenkins ingress hostname"
  value       = var.ingress_host
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "https://${var.ingress_host}"
}
