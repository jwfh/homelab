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

variable "auth_method" {
  description = "Authentication method for the application (e.g., oidc, local)"
  type        = string
  default     = "local"
}

variable "oidc_configuration" {
  description = "OIDC configuration for the application"
  type = object({
    client_id     = string
    client_secret = string
    discovery_url = string
    redirect_uri  = string
    provider_name = string
    provider_url  = string
  })
  default = null
}

variable "database_host" {
  description = "Database host"
  type        = string
}

variable "database_port" {
  description = "Database port"
  type        = number
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "database_user" {
  description = "Database user"
  type        = string
}

variable "data_pvc_name" {
  description = "Name of the data PVC"
  type        = string
}

variable "secrets_name" {
  description = "Name of the secrets resource"
  type        = string
}

variable "domain_name" {
  description = "Domain name for ingress"
  type        = string
}

variable "traefik" {
  type    = any
  default = null
}
