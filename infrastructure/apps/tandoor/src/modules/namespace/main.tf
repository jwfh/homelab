data "aws_ssm_parameter" "app_configuration" {
  name = "/tandoor/configuration"
}

locals {
  app_configuration = jsondecode(data.aws_ssm_parameter.app_configuration.value)

  app_domain_name = local.app_configuration.app.domain_name
  app_secret_key  = local.app_configuration.app.secret_key

  nfs_server        = local.app_configuration.nfs.server
  nfs_media_path    = local.app_configuration.nfs.media_path
  nfs_static_path   = local.app_configuration.nfs.static_path
  nfs_postgres_path = local.app_configuration.nfs.postgres_path

  db_name     = local.app_configuration.database.name
  db_user     = local.app_configuration.database.user
  db_password = local.app_configuration.database.password

  kubernetes_namespace = "${var.environment}-tandoor"
}

resource "kubernetes_namespace" "tandoor" {
  metadata {
    name = local.kubernetes_namespace
    labels = {
      name        = local.kubernetes_namespace
      environment = var.environment
      app         = "tandoor"
    }
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "tandoor-secrets"
    namespace = kubernetes_namespace.tandoor.metadata[0].name
  }

  data = {
    postgresql-password          = local.db_password
    postgresql-postgres-password = local.db_password
    secret-key                   = local.app_secret_key
  }
}
