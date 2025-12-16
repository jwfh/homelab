locals {
  jcasc_system_config = <<-EOT
    jenkins:
      systemMessage: |
        Jenkins CI/CD Server
        Configured automatically by JCasC and Terraform
        GitHub Organization: https://github.com/${local.github_organization}
      numExecutors: 0
      mode: EXCLUSIVE
      quietPeriod: 5
      scmCheckoutRetryCount: 3
      
    unclassified:
      location:
        url: "https://${local.domain_name}/"
        adminAddress: "admin@${local.domain_name}"
  EOT

  jcasc_security_config = <<-EOT
    jenkins:
      securityRealm:
        local:
          allowsSignup: false
          users:
            - id: "admin"
              name: "Administrator"
              password: "$${JENKINS_ADMIN_PASSWORD:-admin}"
      authorizationStrategy:
        loggedInUsersCanDoAnything:
          allowAnonymousRead: false
      remotingSecurity:
        enabled: true
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
            
            buildStrategies {
              buildRegularBranches()
              buildChangeRequests {
                ignoreTargetOnlyChanges(true)
                ignoreUntrustedChanges(false)
              }
              buildTags {
                atLeastDays('-1')
                atMostDays('7')
              }
            }
          }
  EOT
}
