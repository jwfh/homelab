variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
}

variable "storage_size" {
  description = "Storage size for Jenkins home PVC"
  type        = string
  default     = "20Gi"
}
