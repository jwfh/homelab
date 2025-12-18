# Persistent Volume for Ollama Models (NFS)
resource "kubernetes_persistent_volume" "models" {
  metadata {
    name = "${var.namespace}-models-pv"
    labels = {
      app       = "ollama"
      type      = "models"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.models_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_models_path
      }
    }
  }
}

# Persistent Volume Claim for Ollama Models
resource "kubernetes_persistent_volume_claim" "models" {
  metadata {
    name      = "ollama-models-pvc"
    namespace = var.namespace
    labels = {
      app  = "ollama"
      type = "models"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.models_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.models.metadata[0].name
  }
}
