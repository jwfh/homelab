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

# Persistent Volume for Open WebUI Data (NFS)
resource "kubernetes_persistent_volume" "openwebui" {
  metadata {
    name = "${var.namespace}-openwebui-pv"
    labels = {
      app       = "open-webui"
      type      = "data"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.openwebui_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_openwebui_path
      }
    }
  }
}

# Persistent Volume Claim for Open WebUI Data
resource "kubernetes_persistent_volume_claim" "openwebui" {
  metadata {
    name      = "openwebui-data-pvc"
    namespace = var.namespace
    labels = {
      app  = "open-webui"
      type = "data"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.openwebui_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.openwebui.metadata[0].name
  }
}
