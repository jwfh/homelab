variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "chart_version" {
  description = "Version of the Authentik Helm chart"
  type        = string
  default     = "2024.10.1"
}

variable "postgres_pvc_name" {
  description = "Name of the PostgreSQL PVC"
  type        = string
}

variable "certs_pvc_name" {
  description = "Name of the certs PVC"
  type        = string
}

variable "media_pvc_name" {
  description = "Name of the media PVC"
  type        = string
}

variable "redis_pvc_name" {
  description = "Name of the Redis PVC"
  type        = string
}

variable "templates_pvc_name" {
  description = "Name of the templates PVC"
  type        = string
}

variable "authentik_secret_key" {
  description = "Secret key for Authentik (from SSM)"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password (from SSM)"
  type        = string
  sensitive   = true
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "authentik"
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "authentik"
}

variable "bootstrap_email" {
  description = "Bootstrap admin email"
  type        = string
}

variable "bootstrap_password" {
  description = "Bootstrap admin password (from SSM)"
  type        = string
  sensitive   = true
}

variable "bootstrap_token" {
  description = "Bootstrap token (from SSM)"
  type        = string
  sensitive   = true
}

variable "error_reporting_enabled" {
  description = "Enable error reporting to Authentik"
  type        = bool
  default     = false
}

variable "ingress_enabled" {
  description = "Enable ingress for Authentik"
  type        = bool
  default     = true
}

variable "ingress_host" {
  description = "Hostname for Authentik ingress"
  type        = string
}

variable "ingress_class_name" {
  description = "Ingress class name (e.g., traefik)"
  type        = string
  default     = "traefik"
}

variable "ingress_annotations" {
  description = "Annotations for the ingress resource"
  type        = map(string)
  default     = {}
}

variable "postgres_storage_size" {
  description = "Storage size for PostgreSQL PV/PVC"
  type        = string
  default     = "10Gi"
}

variable "media_storage_size" {
  description = "Storage size for media PV/PVC"
  type        = string
  default     = "5Gi"
}

variable "redis_storage_size" {
  description = "Storage size for Redis PV/PVC"
  type        = string
  default     = "2Gi"
}

variable "templates_storage_size" {
  description = "Storage size for templates PV/PVC"
  type        = string
  default     = "1Gi"
}
