# Persistent Volume for Media Files (NFS)
resource "kubernetes_persistent_volume" "media" {
  metadata {
    name = "${var.namespace}-media-pv"
    labels = {
      app       = "tandoor"
      type      = "media"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.media_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = var.nfs_media_path
      }
    }
  }
}

# Persistent Volume Claim for Media Files
resource "kubernetes_persistent_volume_claim" "media" {
  metadata {
    name      = "tandoor-media-pvc"
    namespace = var.namespace
    labels = {
      app  = "tandoor"
      type = "media"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.media_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.media.metadata[0].name
  }
}

# Persistent Volume for Static Files (NFS)
resource "kubernetes_persistent_volume" "static" {
  metadata {
    name = "${var.namespace}-static-pv"
    labels = {
      app       = "tandoor"
      type      = "static"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.static_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = var.nfs_server
        path   = var.nfs_static_path
      }
    }
  }
}

# Persistent Volume Claim for Static Files
resource "kubernetes_persistent_volume_claim" "static" {
  metadata {
    name      = "tandoor-static-pvc"
    namespace = var.namespace
    labels = {
      app  = "tandoor"
      type = "static"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.static_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.static.metadata[0].name
  }
}

# Persistent Volume for PostgreSQL (NFS)
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "${var.namespace}-postgres-pv"
    labels = {
      app       = "tandoor"
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
    name      = "tandoor-postgres-pvc"
    namespace = var.namespace
    labels = {
      app  = "tandoor"
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
