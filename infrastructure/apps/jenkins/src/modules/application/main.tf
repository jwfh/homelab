resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version
  namespace  = var.namespace

  # Wait for resources to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 600

  values = [
    yamlencode({
      controller = {
        image = {
          registry   = "docker.io"
          repository = "jenkins/jenkins"
          tag        = var.jenkins_image_tag
          pullPolicy = "IfNotPresent"
        }

        replicas = 1

        # Align runtime identity with NFS ownership for controller data path access.
        runAsUser = local.controller_run_as_user
        fsGroup   = local.controller_fs_group
        containerSecurityContext = {
          runAsUser               = local.controller_run_as_user
          runAsGroup              = local.controller_run_as_group
          readOnlyRootFilesystem  = true
          allowPrivilegeEscalation = false
        }

        resources = {
          requests = {
            cpu    = local.controller_cpu_request
            memory = local.controller_memory_request
          }
          limits = {
            cpu    = local.controller_cpu_limit
            memory = local.controller_memory_limit
          }
        }

        serviceAccount = {
          create = false
          name   = var.service_account_name
        }

        javaOpts = "-Djenkins.install.runSetupWizard=false -Dhudson.model.DirectoryBrowserSupport.CSP= -Duser.home=/var/jenkins_home"

        initContainerEnv = [
          {
            name  = "HOME"
            value = "/var/jenkins_home"
          },
          {
            name  = "JAVA_OPTS"
            value = "-Duser.home=/var/jenkins_home"
          }
        ]

        containerEnv = [
          {
            name  = "HOME"
            value = "/var/jenkins_home"
          }
        ]

        installPlugins = [
          # Core plugins
          "kubernetes",
          "workflow-aggregator",
          "git",
          "configuration-as-code",
          # GitHub integration
          "github-branch-source",
          "github",
          # Pipeline and job management
          "job-dsl",
          "pipeline-stage-step",
          "pipeline-input-step",
          "pipeline-milestone-step",
          "pipeline-graph-view",
          "pipeline-stage-view",
          "pipeline-utility-steps",
          "timestamper",
          "ansicolor",
        ]

        additionalPlugins = []

        JCasC = {
          defaultConfig = false
          configScripts = {
            "system-config"     = local.jcasc_system_config
            "security-config"   = local.jcasc_security_config
            "kubernetes-cloud"  = local.jcasc_kubernetes_cloud
            "github-org-seed"   = local.jcasc_github_org_seed
          }
        }

        sidecars = {
          configAutoReload = {
            # The sidecar image does not include /var/jenkins_home and needs root to
            # create the nested mountpoint /var/jenkins_home/casc_configs at startup.
            containerSecurityContext = {
              runAsUser               = 0
              runAsGroup              = 0
              runAsNonRoot            = false
              readOnlyRootFilesystem  = false
              allowPrivilegeEscalation = false
            }
          }
        }

        ingress = {
          enabled          = true
          ingressClassName = local.ingress_class_name
          hostName         = local.domain_name
          annotations = {
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
            "traefik.ingress.kubernetes.io/router.tls"         = "true"
          }
          tls = [
            {
              secretName = "jenkins-tls"
              hosts      = [local.domain_name]
            }
          ]
        }

        healthProbes = true
        probes = {
          startupProbe = {
            httpGet = {
              path = "/login"
              port = "http"
            }
            periodSeconds   = 10
            timeoutSeconds  = 5
            failureThreshold = 12
          }
          livenessProbe = {
            httpGet = {
              path = "/login"
              port = "http"
            }
            periodSeconds   = 10
            timeoutSeconds  = 5
            failureThreshold = 5
          }
          readinessProbe = {
            httpGet = {
              path = "/login"
              port = "http"
            }
            periodSeconds   = 10
            timeoutSeconds  = 5
            failureThreshold = 3
          }
        }

        servicePort           = 8080
        targetPort            = 8080
        agentListenerPort     = 50000
        agentListenerServiceType = "ClusterIP"
      }

      persistence = {
        enabled       = true
        existingClaim = var.pvc_name
      }

      agent = {
        enabled = false
      }

      networkPolicy = {
        enabled = false
      }

      rbac = {
        create      = false
        readSecrets = true
      }

      serviceAccount = {
        create = false
        name   = var.service_account_name
      }
    })
  ]
}
