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

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "database_user" {
  description = "PostgreSQL database user"
  type        = string
}
