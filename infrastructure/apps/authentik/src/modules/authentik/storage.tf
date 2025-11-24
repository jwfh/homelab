# Persistent Volume for PostgreSQL (NFS)
resource "kubernetes_persistent_volume" "postgres" {
  metadata {
    name = "${kubernetes_namespace.authentik.id}-postgres-pv"
    labels = {
      app       = "authentik"
      type      = "postgres"
      namespace = kubernetes_namespace.authentik.id
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
    namespace = kubernetes_namespace.authentik.id
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

# Persistent Volume for Media (NFS)
resource "kubernetes_persistent_volume" "media" {
  metadata {
    name = "${kubernetes_namespace.authentik.id}-media-pv"
    labels = {
      app       = "authentik"
      type      = "media"
      namespace = kubernetes_namespace.authentik.id
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
    namespace = kubernetes_namespace.authentik.id
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

# Persistent Volume for Redis (NFS)
resource "kubernetes_persistent_volume" "redis" {
  metadata {
    name = "${kubernetes_namespace.authentik.id}-redis-pv"
    labels = {
      app       = "authentik"
      type      = "redis"
      namespace = kubernetes_namespace.authentik.id
    }
  }

  spec {
    capacity = {
      storage = var.redis_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_redis_path
      }
    }
  }
}

# Persistent Volume Claim for Redis
resource "kubernetes_persistent_volume_claim" "redis" {
  metadata {
    name      = "authentik-redis-pvc"
    namespace = kubernetes_namespace.authentik.id
    labels = {
      app  = "authentik"
      type = "redis"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.redis_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.redis.metadata[0].name
  }
}

# Persistent Volume for Templates (NFS)
resource "kubernetes_persistent_volume" "templates" {
  metadata {
    name = "${kubernetes_namespace.authentik.id}-templates-pv"
    labels = {
      app       = "authentik"
      type      = "templates"
      namespace = kubernetes_namespace.authentik.id
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
    namespace = kubernetes_namespace.authentik.id
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
