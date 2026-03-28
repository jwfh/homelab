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

variable "openwebui_storage_size" {
  description = "Storage size for Open WebUI data PV/PVC"
  type        = string
  default     = "2Gi"
}
