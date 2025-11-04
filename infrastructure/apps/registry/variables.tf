variable "registry_uid" {
  description = "UID for the registry process to run as"
  type        = number
  sensitive   = false
}

variable "registry_gid" {
  description = "GID for the registry process to run as"
  type        = number
  sensitive   = false
}

variable "registry_replicas" {
  description = "Number of registry replicas to deploy"
  type        = number
  default     = 1

  validation {
    condition     = var.registry_replicas >= 1
    error_message = "registry_replicas must be at least 1."
  }
}

variable "registry_image" {
  description = "Docker image for the registry"
  type        = string
  default     = "registry:latest"
}

variable "registry_storage_size" {
  description = "Size of the persistent volume for registry storage"
  type        = string
  default     = "100Gi"
}

variable "registry_memory_request" {
  description = "Memory request for the registry container"
  type        = string
  default     = "256Mi"
}

variable "registry_memory_limit" {
  description = "Memory limit for the registry container"
  type        = string
  default     = "512Mi"
}

variable "registry_cpu_request" {
  description = "CPU request for the registry container"
  type        = string
  default     = "100m"
}

variable "registry_cpu_limit" {
  description = "CPU limit for the registry container"
  type        = string
  default     = "500m"
}

variable "registry_hostname" {
  description = "Hostname for the registry ingress"
  type        = string
  default     = "registry.jwfh.ca"
}

variable "nfs_server" {
  description = "NFS server hostname"
  type        = string
  default     = "ritchie.lemarchant.jacobhouse.ca"
}

variable "nfs_path" {
  description = "NFS export path"
  type        = string
  default     = "/mnt/default/services/docker-registry/data"
}
