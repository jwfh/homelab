resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.jenkins_chart_version
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  # Wait for resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  # Use the values file
  values = [
    templatefile("${path.module}/helm-values.yaml", {
      namespace         = var.namespace
      ingress_host      = var.ingress_host
      nfs_server        = var.nfs_server
      nfs_path          = var.nfs_path
      storage_size      = var.storage_size
      jenkins_image_tag = var.jenkins_image_tag
    })
  ]

  # Override specific values via set blocks for dynamic configuration
  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.jenkins.metadata[0].name
  }

  set {
    name  = "persistence.existingClaim"
    value = kubernetes_persistent_volume_claim.jenkins_pvc.metadata[0].name
  }

  set {
    name  = "controller.ingress.hostName"
    value = var.ingress_host
  }

  set {
    name  = "controller.tag"
    value = var.jenkins_image_tag
  }

  set {
    name  = "controller.resources.requests.memory"
    value = var.resource_requests_memory
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = var.resource_requests_cpu
  }

  set {
    name  = "controller.resources.limits.memory"
    value = var.resource_limits_memory
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = var.resource_limits_cpu
  }

  # Ensure namespace and RBAC are created first
  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_service_account.jenkins,
    kubernetes_cluster_role_binding.jenkins,
    kubernetes_persistent_volume_claim.jenkins_pvc
  ]
}
