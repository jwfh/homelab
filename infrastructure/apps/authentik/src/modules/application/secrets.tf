resource "kubernetes_secret" "postgres_credentials" {
  metadata {
    name      = "authentik-postgres-credentials"
    namespace = kubernetes_namespace.authentik.id
  }

  data = {
    username = local.postgresql_user
    password = local.postgresql_password
  }
}
