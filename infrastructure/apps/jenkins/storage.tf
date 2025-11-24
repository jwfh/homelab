# Storage Class for local/hostPath volumes
resource "kubernetes_storage_class" "local_storage" {
  metadata {
    name = "local-storage"
  }

  storage_provisioner    = "kubernetes.io/no-provisioner"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
}

resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name = "jenkins-pv-volume"

    labels = {
      "type"                         = "hostpath"
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

    storage_class_name = "local-storage"

    persistent_volume_source {
      host_path {
        path = "/mnt/default/services/jenkins"
        type = "DirectoryOrCreate"
      }
    }

    # Optional: Node affinity to ensure pod runs on nodes with the NFS mount
    # Uncomment if you want to restrict to specific nodes
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "kubernetes.io/hostname"
            operator = "In"
            values   = ["k8s12-001.lemarchant.jacobhouse.ca"] # Replace with your worker node hostname
          }
        }
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

    storage_class_name = "local-storage"

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    volume_name = kubernetes_persistent_volume.jenkins_pv.metadata[0].name
  }
}
