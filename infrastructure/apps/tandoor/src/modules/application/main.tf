# ConfigMap for nginx configuration
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "tandoor-nginx-config"
    namespace = var.namespace
    labels = {
      app = "tandoor"
    }
  }

  data = {
    "nginx-config" = <<-EOF
      events {
        worker_connections 1024;
      }
      http {
        include mime.types;
        server {
          listen 80;
          server_name _;

          client_max_body_size 16M;

          # serve static files
          location /static/ {
            alias /static/;
          }
          # serve media files
          location /media/ {
            alias /media/;
          }
        }
      }
    EOF
  }
}

# Service Account for Tandoor
resource "kubernetes_service_account" "tandoor" {
  metadata {
    name      = "tandoor"
    namespace = var.namespace
  }
}

# Tandoor Deployment
resource "kubernetes_deployment" "tandoor" {
  metadata {
    name      = "tandoor"
    namespace = var.namespace
    labels = {
      app         = "tandoor"
      component   = "application"
      environment = "production"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app         = "tandoor"
        component   = "application"
        environment = "production"
      }
    }

    template {
      metadata {
        labels = {
          app         = "tandoor"
          component   = "application"
          tier        = "frontend"
          environment = "production"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.tandoor.metadata[0].name

        # Exclude control plane nodes
        toleration {
          key      = "node-role.kubernetes.io/control-plane"
          operator = "Exists"
          effect   = "NoSchedule"
        }

        # Prefer worker nodes
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "node-role.kubernetes.io/control-plane"
                  operator = "DoesNotExist"
                }
              }
            }
          }
        }

        # Init container to set permissions and run migrations
        init_container {
          name  = "init-chmod-data"
          image = "${var.docker_image}:${var.app_version}"

          image_pull_policy = "Always"

          security_context {
            run_as_user = 0 # Run as root for permission setup
          }

          command = ["/bin/sh", "-c"]
          args = [<<-EOF
            set -e
            source venv/bin/activate
            echo "Updating database"
            python manage.py migrate
            python manage.py collectstatic_js_reverse
            python manage.py collectstatic --noinput
            echo "Setting media file attributes"
            chown -R 65534:65534 /opt/recipes/mediafiles
            find /opt/recipes/mediafiles -type d | xargs -r chmod 755
            find /opt/recipes/mediafiles -type f | xargs -r chmod 644
            echo "Done"
          EOF
          ]

          env {
            name = "SECRET_KEY"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "secret-key"
              }
            }
          }

          env {
            name  = "DB_ENGINE"
            value = "django.db.backends.postgresql"
          }

          env {
            name  = "POSTGRES_HOST"
            value = var.database_host
          }

          env {
            name  = "POSTGRES_PORT"
            value = tostring(var.database_port)
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_DB"
            value = var.database_name
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "postgresql-postgres-password"
              }
            }
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "64Mi"
            }
          }

          volume_mount {
            name       = "media"
            mount_path = "/opt/recipes/mediafiles"
            sub_path   = "files"
          }

          volume_mount {
            name       = "static"
            mount_path = "/opt/recipes/staticfiles"
            sub_path   = "files"
          }
        }

        # Nginx container for static content
        container {
          name  = "nginx"
          image = "nginx:latest"

          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }

          port {
            container_port = 8080
            name           = "gunicorn"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "media"
            mount_path = "/media"
            sub_path   = "files"
          }

          volume_mount {
            name       = "static"
            mount_path = "/static"
            sub_path   = "files"
          }

          volume_mount {
            name       = "nginx-config"
            mount_path = "/etc/nginx/nginx.conf"
            sub_path   = "nginx-config"
            read_only  = true
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "64Mi"
            }
          }
        }

        # Tandoor application container (gunicorn)
        container {
          name  = "tandoor"
          image = "${var.docker_image}:${var.app_version}"

          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user = 65534 # nobody user
          }

          command = [
            "/opt/recipes/venv/bin/gunicorn",
            "-b",
            ":8080",
            "--access-logfile",
            "-",
            "--error-logfile",
            "-",
            "--log-level",
            "INFO",
            "recipes.wsgi"
          ]

          port {
            container_port = 8080
            name           = "gunicorn"
            protocol       = "TCP"
          }

          env {
            name  = "DEBUG"
            value = "0"
          }

          env {
            name  = "ALLOWED_HOSTS"
            value = "*"
          }

          env {
            name = "SECRET_KEY"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "secret-key"
              }
            }
          }

          env {
            name  = "GUNICORN_MEDIA"
            value = "0"
          }

          env {
            name  = "DB_ENGINE"
            value = "django.db.backends.postgresql"
          }

          env {
            name  = "POSTGRES_HOST"
            value = var.database_host
          }

          env {
            name  = "POSTGRES_PORT"
            value = tostring(var.database_port)
          }

          env {
            name  = "POSTGRES_USER"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_DB"
            value = var.database_name
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.secrets_name
                key  = "postgresql-postgres-password"
              }
            }
          }

          volume_mount {
            name       = "media"
            mount_path = "/opt/recipes/mediafiles"
            sub_path   = "files"
          }

          volume_mount {
            name       = "static"
            mount_path = "/opt/recipes/staticfiles"
            sub_path   = "files"
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "64Mi"
            }
          }

          liveness_probe {
            http_get {
              path   = "/"
              port   = 8080
              scheme = "HTTP"
            }
            period_seconds    = 30
            failure_threshold = 3
          }

          readiness_probe {
            http_get {
              path   = "/"
              port   = 8080
              scheme = "HTTP"
            }
            period_seconds = 30
          }
        }

        volume {
          name = "nginx-config"
          config_map {
            name = kubernetes_config_map.nginx_config.metadata[0].name
          }
        }

        volume {
          name = "media"
          persistent_volume_claim {
            claim_name = var.media_pvc_name
          }
        }

        volume {
          name = "static"
          persistent_volume_claim {
            claim_name = var.static_pvc_name
          }
        }

        restart_policy = "Always"
      }
    }

    strategy {
      type = "Recreate"
    }
  }
}

# Tandoor Service
resource "kubernetes_service" "tandoor" {
  metadata {
    name      = "tandoor"
    namespace = var.namespace
    labels = {
      app  = "tandoor"
      tier = "frontend"
    }
  }

  spec {
    selector = {
      app         = "tandoor"
      component   = "application"
      environment = "production"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "http"
      protocol    = "TCP"
    }

    port {
      name        = "gunicorn"
      port        = 8080
      target_port = "gunicorn"
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}

# Ingress Route for Traefik with path-based routing
resource "kubernetes_manifest" "ingress_route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "tandoor"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        # Main application route (gunicorn on port 8080)
        {
          match = "Host(`${var.domain_name}`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.tandoor.metadata[0].name
              port = 8080
            }
          ]
        },
        # Media files route (nginx on port 80)
        {
          match = "Host(`${var.domain_name}`) && PathPrefix(`/media`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.tandoor.metadata[0].name
              port = 80
            }
          ]
        },
        # Static files route (nginx on port 80)
        {
          match = "Host(`${var.domain_name}`) && PathPrefix(`/static`)"
          kind  = "Rule"
          services = [
            {
              name = kubernetes_service.tandoor.metadata[0].name
              port = 80
            }
          ]
        }
      ]
      tls = {
        secretName = "tandoor-tls"
      }
    }
  }

  depends_on = [
    var.traefik
  ]
}
