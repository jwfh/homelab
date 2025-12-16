variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Jenkins"
  type        = string
}

variable "service_account_name" {
  description = "The Jenkins service account name"
  type        = string
}

variable "pvc_name" {
  description = "The Jenkins PVC name for controller storage"
  type        = string
}

variable "chart_version" {
  description = "Jenkins Helm chart version"
  type        = string
  default     = "5.8.3"
}

variable "jenkins_image_tag" {
  description = "Jenkins Docker image tag"
  type        = string
  default     = "lts-jdk17"
}
