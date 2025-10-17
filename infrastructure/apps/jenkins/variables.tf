variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "devops-tools"
}

variable "jenkins_image" {
  description = "Jenkins Docker image"
  type        = string
  default     = "jenkins/jenkins:lts"
}

variable "jenkins_replicas" {
  description = "Number of Jenkins controller replicas"
  type        = number
  default     = 1
}

variable "nfs_server" {
  description = "NFS server hostname or IP"
  type        = string
  default     = "ritchie"
}

variable "nfs_path" {
  description = "NFS export path for Jenkins home"
  type        = string
  default     = "/mnt/default/services/jenkins"
}

variable "storage_size" {
  description = "Storage size for Jenkins home PVC"
  type        = string
  default     = "10Gi"
}

variable "ingress_host" {
  description = "Hostname for Jenkins ingress"
  type        = string
  default     = "ci.jwfh.ca"
}

variable "resource_limits_memory" {
  description = "Memory limit for Jenkins controller"
  type        = string
  default     = "2Gi"
}

variable "resource_limits_cpu" {
  description = "CPU limit for Jenkins controller"
  type        = string
  default     = "1000m"
}

variable "resource_requests_memory" {
  description = "Memory request for Jenkins controller"
  type        = string
  default     = "500Mi"
}

variable "resource_requests_cpu" {
  description = "CPU request for Jenkins controller"
  type        = string
  default     = "500m"
}
