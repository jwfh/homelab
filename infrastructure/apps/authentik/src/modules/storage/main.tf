# Persistent Volume for PostgreSQL (NFS)
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "${var.namespace}-postgres-pv"
    labels = {
      app       = "authentik"
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
        server = local.nfs_server
        path   = local.nfs_postgres_path
      }
    }
  }
}

# Persistent Volume Claim for PostgreSQL
resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "authentik-postgres-pvc"
    namespace = var.namespace
    labels = {
      app  = "authentik"
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

# Persistent Volume for Certs (NFS)
resource "kubernetes_persistent_volume" "certs" {
  metadata {
    name = "${var.namespace}-certs-pv"
    labels = {
      app       = "authentik"
      type      = "certs"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.certs_storage_size
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_certs_path
      }
    }
  }
}

# Persistent Volume Claim for Certs
resource "kubernetes_persistent_volume_claim" "certs" {
  metadata {
    name      = "authentik-certs-pvc"
    namespace = var.namespace
    labels = {
      app  = "authentik"
      type = "certs"
    }
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.certs_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.certs.metadata[0].name
  }
}

# Persistent Volume for Media (NFS)
resource "kubernetes_persistent_volume" "media" {
  metadata {
    name = "${var.namespace}-media-pv"
    labels = {
      app       = "authentik"
      type      = "media"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.media_storage_size
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_media_path
      }
    }
  }
}

# Persistent Volume Claim for Media
resource "kubernetes_persistent_volume_claim" "media" {
  metadata {
    name      = "authentik-media-pvc"
    namespace = var.namespace
    labels = {
      app  = "authentik"
      type = "media"
    }
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.media_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.media.metadata[0].name
  }
}

# Persistent Volume for Templates (NFS)
resource "kubernetes_persistent_volume" "templates" {
  metadata {
    name = "${var.namespace}-templates-pv"
    labels = {
      app       = "authentik"
      type      = "templates"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.templates_storage_size
    }

    access_modes = ["ReadWriteMany"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_templates_path
      }
    }
  }
}

# Persistent Volume Claim for Templates
resource "kubernetes_persistent_volume_claim" "templates" {
  metadata {
    name      = "authentik-templates-pvc"
    namespace = var.namespace
    labels = {
      app  = "authentik"
      type = "templates"
    }
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.templates_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.templates.metadata[0].name
  }
}
