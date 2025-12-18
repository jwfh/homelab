output "release_name" {
  description = "Helm release name"
  value       = helm_release.ollama.name
}

output "release_namespace" {
  description = "Helm release namespace"
  value       = helm_release.ollama.namespace
}
