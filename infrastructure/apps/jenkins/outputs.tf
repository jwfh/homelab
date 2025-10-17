output "namespace" {
  description = "Jenkins namespace"
  value       = kubernetes_namespace.jenkins.metadata[0].name
}

output "helm_release_name" {
  description = "Jenkins Helm release name"
  value       = helm_release.jenkins.name
}

output "helm_release_version" {
  description = "Jenkins Helm chart version"
  value       = helm_release.jenkins.version
}

output "helm_release_status" {
  description = "Jenkins Helm release status"
  value       = helm_release.jenkins.status
}

output "ingress_host" {
  description = "Jenkins ingress hostname"
  value       = var.ingress_host
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "https://${var.ingress_host}"
}
