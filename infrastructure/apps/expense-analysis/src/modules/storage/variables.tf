variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "nfs_server" {
  description = "NFS server hostname or IP"
  type        = string
}

variable "nfs_data_path" {
  description = "NFS path for app data storage"
  type        = string
}

variable "nfs_postgres_path" {
  description = "NFS path for PostgreSQL storage"
  type        = string
}

variable "data_storage_size" {
  description = "Size of data storage"
  type        = string
}

variable "postgres_storage_size" {
  description = "Size of PostgreSQL storage"
  type        = string
}
