output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.expense_analysis.metadata[0].name
}

output "secrets_name" {
  description = "Name of the secrets resource"
  value       = kubernetes_secret.app_secrets.metadata[0].name
}

# output "domain_name" {
#   description = "Application domain name"
#   value       = nonsensitive(local.app_domain_name)
# }

# output "auth_method" {
#   description = "Application authentication method"
#   value       = nonsensitive(local.app_auth_method)
# }

# output "oidc_configuration" {
#   description = "OIDC configuration for the application"
#   value       = local.oidc_configuration
#   sensitive   = true
# }

# output "nfs_server" {
#   description = "NFS server hostname"
#   value       = nonsensitive(local.nfs_server)
# }

# output "nfs_data_path" {
#   description = "NFS path for app data"
#   value       = nonsensitive(local.nfs_data_path)
# }

# output "nfs_postgres_path" {
#   description = "NFS path for postgres data"
#   value       = nonsensitive(local.nfs_postgres_path)
# }

# output "db_name" {
#   description = "Database name"
#   value       = nonsensitive(local.db_name)
# }

# output "db_user" {
#   description = "Database user"
#   value       = nonsensitive(local.db_user)
# }
