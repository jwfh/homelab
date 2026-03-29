# Persistent Volume for Jellyfin config (NFS)
resource "kubernetes_persistent_volume" "config" {
  metadata {
    name = "${var.namespace}-config-pv"
    labels = {
      app       = "jellyfin"
      type      = "config"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.config_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_config_path
      }
    }
  }
}

# Persistent Volume Claim for Jellyfin config
resource "kubernetes_persistent_volume_claim" "config" {
  metadata {
    name      = "jellyfin-config-pvc"
    namespace = var.namespace
    labels = {
      app  = "jellyfin"
      type = "config"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.config_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.config.metadata[0].name
  }
}

# Persistent Volume for Jellyfin cache (NFS)
resource "kubernetes_persistent_volume" "cache" {
  metadata {
    name = "${var.namespace}-cache-pv"
    labels = {
      app       = "jellyfin"
      type      = "cache"
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = var.cache_storage_size
    }

    access_modes = ["ReadWriteOnce"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = local.nfs_server
        path   = local.nfs_cache_path
      }
    }
  }
}

# Persistent Volume Claim for Jellyfin cache
resource "kubernetes_persistent_volume_claim" "cache" {
  metadata {
    name      = "jellyfin-cache-pvc"
    namespace = var.namespace
    labels = {
      app  = "jellyfin"
      type = "cache"
    }
  }

  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.cache_storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.cache.metadata[0].name
  }
}

# Persistent Volumes for media directories (NFS, dynamic)
resource "kubernetes_persistent_volume" "media" {
  for_each = local.media_mounts

  metadata {
    name = "${var.namespace}-media-${each.key}-pv"
    labels = {
      app       = "jellyfin"
      type      = "media"
      media     = each.key
      namespace = var.namespace
    }
  }

  spec {
    capacity = {
      storage = each.value.size
    }

    access_modes = ["ReadOnlyMany"]

    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "nfs"

    persistent_volume_source {
      nfs {
        server = each.value.server
        path   = each.value.path
      }
    }
  }
}

# Persistent Volume Claims for media directories (dynamic)
resource "kubernetes_persistent_volume_claim" "media" {
  for_each = local.media_mounts

  metadata {
    name      = "jellyfin-media-${each.key}-pvc"
    namespace = var.namespace
    labels = {
      app   = "jellyfin"
      type  = "media"
      media = each.key
    }
  }

  spec {
    access_modes       = ["ReadOnlyMany"]
    storage_class_name = "nfs"

    resources {
      requests = {
        storage = each.value.size
      }
    }

    volume_name = kubernetes_persistent_volume.media[each.key].metadata[0].name
  }
}
