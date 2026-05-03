locals {
  config = local.local_config != null ? local.local_config : module.configuration[0].configuration

  # Domain and ingress configuration
  domain_name        = local.config.app.domain_name
  ingress_class_name = local.config.ingress.class_name

  # GitHub organization configuration
  github_organization   = local.config.github.organization
  github_credentials_id = local.config.github.credentials_id
  github_username       = local.config.github.username
  github_password       = local.config.github.password
  github_repo_regex     = local.config.github.repo_regex
  github_branch_regex   = local.config.github.branch_regex
  github_scan_interval  = local.config.github.scan_interval

  # Jenkins admin credentials
  admin_username = local.config.auth.admin_username
  admin_password = local.config.auth.admin_password

  # OIDC configuration
  oidc_enabled                = try(local.config.auth.oidc.enabled, false)
  oidc_client_id              = try(local.config.auth.oidc.client_id, "")
  oidc_client_secret          = try(local.config.auth.oidc.client_secret, "")
  oidc_well_known_url         = try(local.config.auth.oidc.well_known_url, "")
  oidc_user_name_field        = try(local.config.auth.oidc.user_name_field, "preferred_username")
  oidc_full_name_field        = try(local.config.auth.oidc.full_name_field, "name")
  oidc_email_field            = try(local.config.auth.oidc.email_field, "email")
  oidc_groups_field           = try(local.config.auth.oidc.groups_field, "groups")
  oidc_scopes                 = try(local.config.auth.oidc.scopes, "openid profile email")
  oidc_logout_from_provider   = try(local.config.auth.oidc.logout_from_provider, true)
  oidc_disable_ssl_verification = try(local.config.auth.oidc.disable_ssl_verification, false)
  oidc_pkce_enabled           = try(local.config.auth.oidc.pkce_enabled, true)
  oidc_user_group             = try(local.config.auth.oidc.user_group, "")
  oidc_admin_group            = try(local.config.auth.oidc.admin_group, "")

  # Controller resources
  controller_cpu_request    = local.config.controller.cpu_request
  controller_cpu_limit      = local.config.controller.cpu_limit
  controller_memory_request = local.config.controller.memory_request
  controller_memory_limit   = local.config.controller.memory_limit
  controller_run_as_user    = try(local.config.controller.run_as_user, 1000)
  controller_run_as_group   = try(local.config.controller.run_as_group, local.controller_run_as_user)
  controller_fs_group       = try(local.config.controller.fs_group, local.controller_run_as_group)

  # Agent resources
  agent_cpu_request    = local.config.agent.cpu_request
  agent_cpu_limit      = local.config.agent.cpu_limit
  agent_memory_request = local.config.agent.memory_request
  agent_memory_limit   = local.config.agent.memory_limit
  agent_max_instances  = local.config.agent.max_instances
}
