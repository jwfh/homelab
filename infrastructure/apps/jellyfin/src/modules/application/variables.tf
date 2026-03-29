variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "app_version" {
  description = "Jellyfin image tag"
  type        = string
  default     = "latest"
}

variable "config_pvc_name" {
  description = "Name of the Jellyfin config PVC"
  type        = string
}

variable "cache_pvc_name" {
  description = "Name of the Jellyfin cache PVC"
  type        = string
}

variable "media_pvc_names" {
  description = "Map of media PVC names keyed by media type"
  type        = map(string)
}
