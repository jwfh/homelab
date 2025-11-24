variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "postgres_storage_size" {
  description = "Storage size for PostgreSQL PV/PVC"
  type        = string
  default     = "10Gi"
}

variable "certs_storage_size" {
  description = "Storage size for certs PV/PVC"
  type        = string
  default     = "1Gi"
}


variable "media_storage_size" {
  description = "Storage size for media PV/PVC"
  type        = string
  default     = "5Gi"
}

variable "templates_storage_size" {
  description = "Storage size for templates PV/PVC"
  type        = string
  default     = "1Gi"
}
