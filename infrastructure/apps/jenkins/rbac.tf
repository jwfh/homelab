resource "kubernetes_service_account" "jenkins" {
  metadata {
    name      = "jenkins-admin"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "jenkins-admin"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "jenkins-admin"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.jenkins.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}
