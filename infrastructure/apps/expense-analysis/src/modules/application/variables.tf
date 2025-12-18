variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "app_version" {
  description = "Application version tag"
  type        = string
}

variable "docker_image" {
  description = "Docker image repository"
  type        = string
}

variable "replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}

variable "database_host" {
  description = "Database host"
  type        = string
}

variable "database_port" {
  description = "Database port"
  type        = number
}

variable "data_pvc_name" {
  description = "Name of the data PVC"
  type        = string
}

variable "secrets_name" {
  description = "Name of the secrets resource"
  type        = string
}

variable "traefik" {
  type    = any
  default = null
}
