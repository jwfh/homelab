output "release_name" {
  description = "Name of the Helm release"
  value       = helm_release.authentik.name
}

output "release_status" {
  description = "Status of the Helm release"
  value       = helm_release.authentik.status
}

output "release_version" {
  description = "Version of the Helm release"
  value       = helm_release.authentik.version
}
