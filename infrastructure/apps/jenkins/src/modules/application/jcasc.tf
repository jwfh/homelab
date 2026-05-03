locals {
  jcasc_system_config = <<-EOT
jenkins:
  systemMessage: |
    Jenkins CI/CD Server
    Configured automatically by JCasC and Terraform
  numExecutors: 0
  mode: EXCLUSIVE
  quietPeriod: 5
  scmCheckoutRetryCount: 3
  
unclassified:
  location:
    url: "https://${local.domain_name}/"
    adminAddress: "admin@${local.domain_name}"
  EOT

  # OIDC security configuration
  jcasc_security_oidc = <<-EOT
jenkins:
  securityRealm:
    oic:
      clientId: "${local.oidc_client_id}"
      clientSecret: "${local.oidc_client_secret}"
      serverConfiguration:
        wellKnown:
          wellKnownOpenIDConfigurationUrl: "${local.oidc_well_known_url}"
          scopesOverride: "${local.oidc_scopes}"
      userNameField: "${local.oidc_user_name_field}"
      fullNameFieldName: "${local.oidc_full_name_field}"
      emailFieldName: "${local.oidc_email_field}"
      groupsFieldName: "${local.oidc_groups_field}"
      disableSslVerification: ${local.oidc_disable_ssl_verification}
      logoutFromOpenidProvider: ${local.oidc_logout_from_provider}
      properties:
        - pkce
  authorizationStrategy:
    roleBased:
      roles:
        global:
          - name: "${local.oidc_admin_group}"
            description: "Jenkins Administrators"
            permissions:
              - "Overall/Administer"
            entries:
              - group: "${local.oidc_admin_group}"
          - name: "${local.oidc_user_group}"
            description: "Jenkins Users"
            permissions:
              - "Overall/Read"
              - "Job/Build"
              - "Job/Cancel"
              - "Job/Read"
              - "Job/Workspace"
              - "View/Read"
            entries:
              - group: "${local.oidc_user_group}"
  remotingSecurity:
    enabled: true
  EOT

  # Local security configuration
  jcasc_security_local = <<-EOT
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      users:
        - id: "${local.admin_username}"
          name: "${local.admin_username}"
          password: "${local.admin_password}"
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
  remotingSecurity:
    enabled: true
  EOT

  # Select the appropriate security configuration
  jcasc_security_config = local.oidc_enabled ? local.jcasc_security_oidc : local.jcasc_security_local

  jcasc_credentials_config = <<-EOT
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePassword:
              scope: GLOBAL
              id: "${local.github_credentials_id}"
              username: "${local.github_username}"
              password: "${local.github_password}"
              description: "GitHub credentials for ${local.github_organization}"
  EOT

  jcasc_kubernetes_cloud = <<-EOT
jenkins:
  clouds:
    - kubernetes:
        name: "kubernetes"
        serverUrl: "https://kubernetes.default.svc.cluster.local"
        skipTlsVerify: false
        namespace: "${var.namespace}"
        jenkinsUrl: "http://jenkins.${var.namespace}.svc.cluster.local:8080"
        jenkinsTunnel: "jenkins-agent.${var.namespace}.svc.cluster.local:50000"
        connectTimeout: 5
        readTimeout: 15
        containerCapStr: "${local.agent_max_instances}"
        maxRequestsPerHostStr: 32
        retentionTimeout: 5
        podRetention: "never"
        
        templates:
          - name: "default"
            label: "jenkins-agent linux"
            nodeUsageMode: NORMAL
            serviceAccount: "${var.service_account_name}"
            podRetention: "never"
            idleMinutes: 10
            activeDeadlineSeconds: 7200
            slaveConnectTimeout: 300
            
            containers:
              - name: "jnlp"
                image: "jenkins/inbound-agent:latest-jdk17"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                ttyEnabled: true
                resourceRequestCpu: "${local.agent_cpu_request}"
                resourceRequestMemory: "${local.agent_memory_request}"
                resourceLimitCpu: "${local.agent_cpu_limit}"
                resourceLimitMemory: "${local.agent_memory_limit}"
                envVars:
                  - envVar:
                      key: "JENKINS_URL"
                      value: "http://jenkins.${var.namespace}.svc.cluster.local:8080"
            
            volumes:
              - emptyDirVolume:
                  memory: false
                  mountPath: "/tmp"
              - emptyDirVolume:
                  memory: false
                  mountPath: "/home/jenkins/agent"
            
            yaml: |
              spec:
                securityContext:
                  runAsUser: 1000
                  runAsGroup: 1000
                  fsGroup: 1000
                tolerations:
                  - key: "node.kubernetes.io/not-ready"
                    operator: "Exists"
                    effect: "NoExecute"
                    tolerationSeconds: 300

          - name: "docker"
            label: "docker dind"
            nodeUsageMode: EXCLUSIVE
            serviceAccount: "${var.service_account_name}"
            podRetention: "never"
            idleMinutes: 5
            activeDeadlineSeconds: 3600
            slaveConnectTimeout: 300
            
            containers:
              - name: "jnlp"
                image: "jenkins/inbound-agent:latest-jdk17"
                alwaysPullImage: false
                workingDir: "/home/jenkins/agent"
                ttyEnabled: true
                resourceRequestCpu: "${local.agent_cpu_request}"
                resourceRequestMemory: "${local.agent_memory_request}"
                resourceLimitCpu: "${local.agent_cpu_limit}"
                resourceLimitMemory: "${local.agent_memory_limit}"
              
              - name: "docker"
                image: "docker:dind"
                privileged: true
                ttyEnabled: true
                resourceRequestCpu: "250m"
                resourceRequestMemory: "256Mi"
                resourceLimitCpu: "1000m"
                resourceLimitMemory: "1Gi"
            
            volumes:
              - emptyDirVolume:
                  memory: false
                  mountPath: "/tmp"
              - emptyDirVolume:
                  memory: false
                  mountPath: "/home/jenkins/agent"
              - emptyDirVolume:
                  memory: false
                  mountPath: "/var/lib/docker"
  EOT

  jcasc_github_org_seed = <<-EOT
jobs:
  - script: >
      organizationFolder('${local.github_organization}') {
        description('GitHub Organization: https://github.com/${local.github_organization}')
        displayName('GitHub - ${local.github_organization}')
        
        organizations {
          github {
            apiUri('https://api.github.com')
            repoOwner('${local.github_organization}')
            credentialsId('${local.github_credentials_id}')
            
            traits {
              gitHubBranchDiscovery {
                strategyId(1)
              }
              gitHubPullRequestDiscovery {
                strategyId(1)
              }
              gitHubForkDiscovery {
                strategyId(1)
                trust {
                  gitHubTrustPermissions()
                }
              }
              gitHubTagDiscovery()
              sourceWildcardFilter {
                includes('*')
                excludes('')
              }
            }
          }
        }
        
        configure { node ->
          def traits = node / navigators / 'org.jenkinsci.plugins.github__branch__source.GitHubSCMNavigator' / traits
          
          traits << 'jenkins.scm.impl.trait.RegexSCMSourceFilterTrait' {
            regex('${local.github_repo_regex}')
          }
          
          def triggers = node / triggers
          triggers << 'com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger' {
            spec('H/${local.github_scan_interval} * * * *')
            interval(${local.github_scan_interval} * 60 * 1000)
          }
        }
        
        projectFactories {
          workflowMultiBranchProjectFactory {
            scriptPath('Jenkinsfile')
          }
        }
        
        orphanedItemStrategy {
          discardOldItems {
            daysToKeep(30)
            numToKeep(50)
          }
        }
      }
  EOT
}
