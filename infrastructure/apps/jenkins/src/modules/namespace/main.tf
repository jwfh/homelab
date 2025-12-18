resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "jenkins"
      managed-by  = "terraform"
    }
  }
}

# Service Account for Jenkins controller and agents
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

# Cluster Role with permissions needed for Jenkins and Kubernetes agents
resource "kubernetes_cluster_role" "jenkins" {
  metadata {
    name = "${local.kubernetes_namespace}-admin"

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  # Core API permissions for agent pods and secrets
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/exec", "pods/log", "pods/attach"]
    verbs      = ["get", "list", "watch", "create", "delete", "patch", "update"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }

  # Apps API for deployments
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  # Batch API for jobs
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
}

# Role for namespace-specific permissions
resource "kubernetes_role" "jenkins_namespace" {
  metadata {
    name      = "jenkins-namespace-admin"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  # Full control in the jenkins namespace for agent management
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

# Cluster Role Binding
resource "kubernetes_cluster_role_binding" "jenkins" {
  metadata {
    name = "${local.kubernetes_namespace}-admin"

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

# Role Binding for namespace-specific permissions
resource "kubernetes_role_binding" "jenkins_namespace" {
  metadata {
    name      = "jenkins-namespace-admin"
    namespace = kubernetes_namespace.jenkins.metadata[0].name

    labels = {
      "app.kubernetes.io/name"       = "jenkins"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.jenkins_namespace.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.jenkins.metadata[0].name
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }
}
