variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
  default     = "jenkins"
}

variable "jenkins_chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.8.3"
}

variable "jenkins_image_tag" {
  description = "Jenkins Docker image tag (lts, lts-jdk17, or specific version)"
  type        = string
  default     = "lts-jdk17"
}

# NFS Storage Configuration
variable "nfs_server" {
  description = "NFS server hostname or IP for Jenkins controller storage"
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
  default     = "20Gi"
}

# Ingress Configuration
variable "ingress_host" {
  description = "Hostname for Jenkins ingress"
  type        = string
  default     = "ci.jwfh.ca"
}

variable "ingress_class_name" {
  description = "Ingress class name (e.g., traefik, nginx)"
  type        = string
  default     = "traefik"
}

# Controller Resource Configuration
variable "controller_cpu_request" {
  description = "CPU request for Jenkins controller"
  type        = string
  default     = "500m"
}

variable "controller_cpu_limit" {
  description = "CPU limit for Jenkins controller"
  type        = string
  default     = "2000m"
}

variable "controller_memory_request" {
  description = "Memory request for Jenkins controller"
  type        = string
  default     = "1Gi"
}

variable "controller_memory_limit" {
  description = "Memory limit for Jenkins controller"
  type        = string
  default     = "4Gi"
}

# Agent Resource Configuration  
variable "agent_cpu_request" {
  description = "CPU request for Jenkins agents"
  type        = string
  default     = "500m"
}

variable "agent_cpu_limit" {
  description = "CPU limit for Jenkins agents"
  type        = string
  default     = "1000m"
}

variable "agent_memory_request" {
  description = "Memory request for Jenkins agents"
  type        = string
  default     = "512Mi"
}

variable "agent_memory_limit" {
  description = "Memory limit for Jenkins agents"
  type        = string
  default     = "2Gi"
}

variable "agent_max_instances" {
  description = "Maximum number of concurrent agent pods"
  type        = number
  default     = 10
}

# GitHub Organization Configuration
variable "github_organization" {
  description = "GitHub organization name to scan for repositories"
  type        = string
  default     = "jwfh"
}

variable "github_credentials_id" {
  description = "Jenkins credentials ID for GitHub authentication"
  type        = string
  default     = "github-token"
}

variable "github_repo_regex" {
  description = "Regex pattern to filter repositories in the GitHub organization"
  type        = string
  default     = ".*"
}

variable "github_branch_regex" {
  description = "Regex pattern to filter branches for building"
  type        = string
  default     = "^(main|master|develop|feature/.*)$"
}

variable "github_scan_interval" {
  description = "Organization scan interval in minutes"
  type        = number
  default     = 60
}
