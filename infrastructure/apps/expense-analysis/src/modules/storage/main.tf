# Persistent Volume for Uploads (NFS)
resource "kubernetes_persistent_volume" "data" {
  metadata {
    name = "${var.namespace}-data-pv"
    labels = {
      app       = "expense-analysis"
      type      = "data"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.data_storage_size
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = var.nfs_data_path
      }
    }
  }
}

# Persistent Volume Claim for Uploads
resource "kubernetes_persistent_volume_claim" "data" {
  metadata {
    name      = "expense-analysis-data-pvc"
    namespace = var.namespace
    labels = {
      app  = "expense-analysis"
      type = "data"
    }
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.data_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.data.metadata[0].name
  }
}

# Persistent Volume for PostgreSQL (NFS)
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "${var.namespace}-postgres-pv"
    labels = {
      app       = "expense-analysis"
      type      = "postgres"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.postgres_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = var.nfs_postgres_path
      }
    }
  }
}

# Persistent Volume Claim for PostgreSQL
resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "expense-analysis-postgres-pvc"
    namespace = var.namespace
    labels = {
      app  = "expense-analysis"
      type = "postgres"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.postgres_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.postgres.metadata[0].name
  }
}
