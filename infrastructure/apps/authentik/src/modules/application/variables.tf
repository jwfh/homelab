variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "chart_version" {
  description = "Version of the Authentik Helm chart"
  type        = string
}

variable "error_reporting_enabled" {
  description = "Enable error reporting to Authentik"
  type        = bool
  default     = false
}

variable "postgres_pvc_name" {
  description = "Name of the existing PVC for PostgreSQL data"
  type        = string
}

variable "certs_pvc_name" {
  description = "Name of the existing PVC for certs data"
  type        = string
}

variable "media_pvc_name" {
  description = "Name of the existing PVC for media data"
  type        = string
}

variable "templates_pvc_name" {
  description = "Name of the existing PVC for templates data"
  type        = string
}

variable "tls_cert" {
  description = "TLS certificate (PEM format). If empty, a self-signed cert will be generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "tls_key" {
  description = "TLS private key (PEM format). If empty, a self-signed cert will be generated."
  type        = string
  default     = null
  sensitive   = true
}