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

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "https://${local.domain_name}"
}

output "github_organization" {
  description = "GitHub organization being scanned"
  value       = local.github_organization
}

output "github_organization_url" {
  description = "GitHub organization URL"
  value       = "https://github.com/${local.github_organization}"
}
