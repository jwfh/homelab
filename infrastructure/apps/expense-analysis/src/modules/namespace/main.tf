data "aws_ssm_parameter" "app_configuration" {
  name = "/expense-analysis/configuration"
}

locals {
  app_configuration = jsondecode(data.aws_ssm_parameter.app_configuration.value)

  app_domain_name  = local.app_configuration.app.domain_name
  app_auth_method  = local.app_configuration.app.auth_method
  app_flask_secret = local.app_configuration.app.flask_secret

  nfs_server        = local.app_configuration.nfs.server
  nfs_data_path     = local.app_configuration.nfs.data_path
  nfs_postgres_path = local.app_configuration.nfs.postgres_path

  db_name     = local.app_configuration.database.name
  db_user     = local.app_configuration.database.user
  db_password = local.app_configuration.database.password

  oidc_configuration = local.app_auth_method == "oidc" ? {
    client_id     = local.app_configuration.sso.oidc_client_id
    client_secret = local.app_configuration.sso.oidc_client_secret
    discovery_url = local.app_configuration.sso.oidc_discovery_url
    redirect_uri  = local.app_configuration.sso.oidc_redirect_uri
    provider_name = local.app_configuration.sso.oidc_provider_name
    provider_url  = local.app_configuration.sso.oidc_provider_url
  } : null

  kubernetes_namespace = "${var.environment}-expense-analysis"
}

resource "kubernetes_namespace" "expense_analysis" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "expense-analysis"
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
