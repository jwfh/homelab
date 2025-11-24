terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/k3s-config"
}

provider "tls" {}

# Namespace
resource "kubernetes_namespace" "docker_registry" {
  metadata {
    name = "docker-registry"
  }
}

# Generate self-signed TLS certificate
resource "tls_private_key" "registry" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "registry" {
  private_key_pem = tls_private_key.registry.private_key_pem

  subject {
    common_name  = var.registry_hostname
    organization = "Homelab"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

# Create TLS secret for the registry
resource "kubernetes_secret" "registry_tls" {
  metadata {
    name      = "registry-tls"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.registry.cert_pem
    "tls.key" = tls_private_key.registry.private_key_pem
  }

  depends_on = [kubernetes_namespace.docker_registry]
}

# PersistentVolume
resource "kubernetes_persistent_volume" "registry_storage" {
  metadata {
    name = "registry-storage-pv"
  }

  spec {
    capacity = {
      storage = "100Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = var.nfs_path
      }
    }
  }
}

# PersistentVolumeClaim
resource "kubernetes_persistent_volume_claim" "registry_storage" {
  metadata {
    name      = "registry-storage-pvc"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"
    volume_name        = kubernetes_persistent_volume.registry_storage.metadata[0].name

    resources {
      requests = {
        storage = "100Gi"
      }
    }
  }

  depends_on = [kubernetes_persistent_volume.registry_storage]
}

# Service
resource "kubernetes_service" "registry" {
  metadata {
    name      = "registry"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
    labels = {
      app = "registry"
    }
  }

  spec {
    type = "ClusterIP"
    port {
      port        = 5000
      target_port = "5000"
      protocol    = "TCP"
      name        = "http"
    }

    selector = {
      app = "registry"
    }
  }
}

# Deployment
resource "kubernetes_deployment" "registry" {
  metadata {
    name      = "registry"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
    labels = {
      app = "registry"
    }
  }

  spec {
    replicas = var.registry_replicas

    selector {
      match_labels = {
        app = "registry"
      }
    }

    template {
      metadata {
        labels = {
          app = "registry"
        }
      }

      spec {
        security_context {
          run_as_non_root = false
          fs_group        = var.registry_gid
          run_as_user     = var.registry_uid
        }

        container {
          name  = "registry"
          image = "registry:latest"
          port {
            container_port = 5000
            name           = "http"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "storage"
            mount_path = "/var/lib/registry"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          liveness_probe {
            http_get {
              path = "/v2/"
              port = "5000"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/v2/"
              port = "5000"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }

        volume {
          name = "storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.registry_storage.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_persistent_volume_claim.registry_storage]
}

# Ingress
resource "kubernetes_ingress_v1" "registry" {
  metadata {
    name      = "registry"
    namespace = kubernetes_namespace.docker_registry.metadata[0].name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
      "traefik.ingress.kubernetes.io/router.tls"         = "true"
    }
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = var.registry_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.registry.metadata[0].name
              port {
                number = 5000
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = [var.registry_hostname]
      secret_name = kubernetes_secret.registry_tls.metadata[0].name
    }
  }

  depends_on = [kubernetes_service.registry, kubernetes_secret.registry_tls]
}
