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

        javaOpts = "-Djenkins.install.runSetupWizard=false -Dhudson.model.DirectoryBrowserSupport.CSP="

        installPlugins = [
          # Core plugins
          "kubernetes:4353.v14a_924f218ec",
          "workflow-aggregator:600.vb_57cdd26fdd7",
          "git:5.7.0",
          "configuration-as-code:1903.v4759a_648de91",
          "credentials-binding:681.vf91669a_32e45",
          # GitHub integration
          "github-branch-source:1797.v86fdb_4d57d43",
          "github:1.40.0",
          # Pipeline and job management
          "job-dsl:1.89",
          "pipeline-stage-view:2.34",
          "pipeline-utility-steps:2.18.0",
          # Additional useful plugins
          "docker-workflow:580.vc0c340686b_54",
          "timestamper:1.27",
          "ws-cleanup:0.46",
          "ansicolor:1.0.6",
          "matrix-auth:3.2.2",
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
