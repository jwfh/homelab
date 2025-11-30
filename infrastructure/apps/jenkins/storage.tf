# NFS-backed storage for Jenkins controller
# Agents use ephemeral storage configured in the kubernetes cloud

resource "kubernetes_storage_class" "nfs_jenkins" {
  metadata {
    name = "nfs-jenkins"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "Immediate"

  # NFS doesn't support volume expansion natively
  allow_volume_expansion = false
}

resource "kubernetes_persistent_volume" "jenkins_nfs_pv" {
  metadata {
    name = "jenkins-nfs-pv"

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

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = kubernetes_storage_class.nfs_jenkins.metadata[0].name

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
    name      = "jenkins-pvc"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "storage"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = kubernetes_storage_class.nfs_jenkins.metadata[0].name

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.jenkins_nfs_pv.metadata[0].name
  }
}
