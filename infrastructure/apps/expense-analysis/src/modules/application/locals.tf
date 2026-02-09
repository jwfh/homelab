locals {
  app_domain_name = module.configuration.configuration.app.domain_name
  app_auth_method = module.configuration.configuration.app.auth_method

  oidc_configuration = local.app_auth_method == "oidc" ? {
    client_id     = module.configuration.configuration.sso.oidc_client_id
    client_secret = module.configuration.configuration.sso.oidc_client_secret
    discovery_url = module.configuration.configuration.sso.oidc_discovery_url
    redirect_uri  = module.configuration.configuration.sso.oidc_redirect_uri
    provider_name = module.configuration.configuration.sso.oidc_provider_name
    provider_url  = module.configuration.configuration.sso.oidc_provider_url
    admin_group   = module.configuration.configuration.sso.oidc_admin_group
    groups_claim  = module.configuration.configuration.sso.oidc_groups_claim
  } : null

  db_name = module.configuration.configuration.database.name
  db_user = module.configuration.configuration.database.user
}
