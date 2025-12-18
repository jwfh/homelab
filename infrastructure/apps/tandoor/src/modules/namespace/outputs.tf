output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.tandoor.metadata[0].name
}

output "secrets_name" {
  description = "Name of the secrets resource"
  value       = kubernetes_secret.app_secrets.metadata[0].name
}

output "domain_name" {
  description = "Application domain name"
  value       = nonsensitive(local.app_domain_name)
}

output "nfs_server" {
  description = "NFS server hostname"
  value       = nonsensitive(local.nfs_server)
}

output "nfs_media_path" {
  description = "NFS path for media files"
  value       = nonsensitive(local.nfs_media_path)
}

output "nfs_static_path" {
  description = "NFS path for static files"
  value       = nonsensitive(local.nfs_static_path)
}

output "nfs_postgres_path" {
  description = "NFS path for postgres data"
  value       = nonsensitive(local.nfs_postgres_path)
}

output "db_name" {
  description = "Database name"
  value       = nonsensitive(local.db_name)
}

output "db_user" {
  description = "Database user"
  value       = nonsensitive(local.db_user)
}
