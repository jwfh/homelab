variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
}

variable "docker_image" {
  description = "Docker image for Tandoor application"
  type        = string
  default     = "vabene1111/recipes"
}

variable "app_version" {
  description = "Version tag for the Tandoor application"
  type        = string
  default     = "latest"
}

variable "replicas" {
  description = "Number of replicas for the deployment"
  type        = number
  default     = 1
}

variable "database_host" {
  description = "PostgreSQL database host"
  type        = string
}

variable "database_port" {
  description = "PostgreSQL database port"
  type        = number
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "database_user" {
  description = "PostgreSQL database user"
  type        = string
}

variable "secrets_name" {
  description = "Name of the Kubernetes secret containing application secrets"
  type        = string
}

variable "media_pvc_name" {
  description = "Name of the PVC for media files"
  type        = string
}

variable "static_pvc_name" {
  description = "Name of the PVC for static files"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "traefik" {
  description = "Traefik Helm release metadata"
  type = object({
    name      = string
    namespace = string
    version   = string
  })
}
