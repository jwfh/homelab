resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name = "jenkins-pv-volume"

    labels = {
      "type"                         = "nfs"
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "storage"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    capacity = {
      storage = var.storage_size
    }

    access_modes = ["ReadWriteMany"]

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

resource "kubernetes_persistent_volume_claim" "jenkins_pvc" {
  metadata {
    name      = "jenkins-pv-claim"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "storage"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    access_modes = ["ReadWriteMany"]

    storage_class_name = "nfs"

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.jenkins_pv.metadata[0].name
  }
}
