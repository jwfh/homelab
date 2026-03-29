variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "config_storage_size" {
  description = "Size of Jellyfin config storage"
  type        = string
}

variable "cache_storage_size" {
  description = "Size of Jellyfin cache storage"
  type        = string
}
