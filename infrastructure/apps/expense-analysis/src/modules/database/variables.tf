variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "secrets_name" {
  description = "Name of the Kubernetes secret containing database credentials"
  type        = string
}

variable "pvc_name" {
  description = "Name of the PVC for PostgreSQL data"
  type        = string
}
