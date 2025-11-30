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

  # Use the values file with variable interpolation
  values = [
    templatefile("${path.module}/helm-values.yaml", {
      namespace                = var.namespace
      ingress_host             = var.ingress_host
      ingress_class_name       = var.ingress_class_name
      jenkins_image_tag        = var.jenkins_image_tag
      controller_cpu_request   = var.controller_cpu_request
      controller_cpu_limit     = var.controller_cpu_limit
      controller_memory_request = var.controller_memory_request
      controller_memory_limit  = var.controller_memory_limit
      agent_cpu_request        = var.agent_cpu_request
      agent_cpu_limit          = var.agent_cpu_limit
      agent_memory_request     = var.agent_memory_request
      agent_memory_limit       = var.agent_memory_limit
      agent_max_instances      = var.agent_max_instances
      github_organization      = var.github_organization
      github_credentials_id    = var.github_credentials_id
      github_repo_regex        = var.github_repo_regex
      github_branch_regex      = var.github_branch_regex
      github_scan_interval     = var.github_scan_interval
    })
  ]

  # Ensure namespace, RBAC, and storage are created first
  depends_on = [
    kubernetes_namespace.jenkins,
    kubernetes_service_account.jenkins,
    kubernetes_cluster_role_binding.jenkins,
    kubernetes_persistent_volume_claim.jenkins_pvc
  ]
}
