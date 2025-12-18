locals {
  kubernetes_namespace = "${var.environment}-expense-analysis"

  app_flask_secret = module.configuration.configuration.app.flask_secret
  db_password      = module.configuration.configuration.database.password
}
