locals {
  # Domain and ingress configuration
  domain_name        = module.configuration.configuration.app.domain_name
  ingress_class_name = module.configuration.configuration.ingress.class_name

  # GitHub organization configuration
  github_organization   = module.configuration.configuration.github.organization
  github_credentials_id = module.configuration.configuration.github.credentials_id
  github_repo_regex     = module.configuration.configuration.github.repo_regex
  github_branch_regex   = module.configuration.configuration.github.branch_regex
  github_scan_interval  = module.configuration.configuration.github.scan_interval

  # Controller resources
  controller_cpu_request    = module.configuration.configuration.controller.cpu_request
  controller_cpu_limit      = module.configuration.configuration.controller.cpu_limit
  controller_memory_request = module.configuration.configuration.controller.memory_request
  controller_memory_limit   = module.configuration.configuration.controller.memory_limit

  # Agent resources
  agent_cpu_request    = module.configuration.configuration.agent.cpu_request
  agent_cpu_limit      = module.configuration.configuration.agent.cpu_limit
  agent_memory_request = module.configuration.configuration.agent.memory_request
  agent_memory_limit   = module.configuration.configuration.agent.memory_limit
  agent_max_instances  = module.configuration.configuration.agent.max_instances
}
