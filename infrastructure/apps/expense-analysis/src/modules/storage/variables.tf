variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
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
