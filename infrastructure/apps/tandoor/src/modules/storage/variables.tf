variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
}

variable "nfs_server" {
  description = "NFS server hostname or IP"
  type        = string
}

variable "nfs_media_path" {
  description = "NFS path for media files"
  type        = string
}

variable "nfs_static_path" {
  description = "NFS path for static files"
  type        = string
}

variable "nfs_postgres_path" {
  description = "NFS path for PostgreSQL data"
  type        = string
}

variable "media_storage_size" {
  description = "Size of media storage PVC"
  type        = string
  default     = "10Gi"
}

variable "static_storage_size" {
  description = "Size of static storage PVC"
  type        = string
  default     = "10Gi"
}

variable "postgres_storage_size" {
  description = "Size of PostgreSQL storage PVC"
  type        = string
  default     = "20Gi"
}
