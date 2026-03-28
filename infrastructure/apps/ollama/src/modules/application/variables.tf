variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "chart_version" {
  description = "Ollama Helm chart version"
  type        = string
}

variable "openwebui_chart_version" {
  description = "Open WebUI Helm chart version"
  type        = string
}

variable "models_pvc_name" {
  description = "Name of the PVC for Ollama models storage"
  type        = string
}

variable "openwebui_pvc_name" {
  description = "Name of the PVC for Open WebUI data storage"
  type        = string
}

variable "memory_limit" {
  description = "Memory limit for the Ollama container"
  type        = string
  default     = "8Gi"
}
