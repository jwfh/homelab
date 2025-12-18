variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "models_storage_size" {
  description = "Storage size for Ollama models PV/PVC"
  type        = string
  default     = "64Gi"
}
