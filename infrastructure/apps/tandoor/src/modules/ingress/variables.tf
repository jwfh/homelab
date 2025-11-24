variable "namespace" {
  description = "Kubernetes namespace to deploy into"
  type        = string
}

variable "tls_cert" {
  description = "TLS certificate (PEM format). If empty, a self-signed cert will be generated"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tls_key" {
  description = "TLS private key (PEM format). If empty, a self-signed cert will be generated"
  type        = string
  default     = ""
  sensitive   = true
}
