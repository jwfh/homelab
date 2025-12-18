
resource "kubernetes_namespace" "expense_analysis" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "expense-analysis"
      managed-by  = "terraform"
    }
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "expense-analysis-secrets"
    namespace = kubernetes_namespace.expense_analysis.metadata[0].name
  }

  data = {
    database-password = local.db_password
    flask-secret-key  = local.app_flask_secret
  }
}
