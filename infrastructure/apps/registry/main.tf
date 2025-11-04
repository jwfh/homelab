terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/k3s-config"
}

# Namespace
resource "kubernetes_namespace" "docker_registry" {
  metadata {
    name = "docker-registry"
  }
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
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "nfs"

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
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "nfs"
    volume_name = kubernetes_persistent_volume.registry_storage.metadata[0].name

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
  }

  depends_on = [kubernetes_service.registry]
}
