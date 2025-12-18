# Terragrunt Infrastructure Structure

This directory contains the Terragrunt configuration for deploying the Tandoor Recipes application to Kubernetes.

## Architecture

The infrastructure is split into 5 modules with clear dependencies:

```
namespace (base)
    ├── ingress (Traefik)
    ├── storage (PV/PVCs for media, static, postgres)
    │   └── database (PostgreSQL)
    │       └── application (Tandoor + nginx)
    └── application (also depends on ingress + storage)
```

### Module Descriptions

1. **namespace** - Creates Kubernetes namespace, secrets, and reads configuration from AWS SSM
2. **ingress** - Installs Traefik ingress controller via Helm (must run before application)
3. **storage** - Creates NFS-backed persistent volumes and claims for media, static files, and database
4. **database** - Deploys PostgreSQL StatefulSet using Bitnami image
5. **application** - Deploys the Tandoor Recipes application with nginx sidecar for static content

## Directory Structure

```
terraform/
├── environments/
│   ├── terragrunt.hcl          # Root config (backend & provider generation)
│   ├── dev/
│   │   ├── backend.hcl         # Dev AWS account & bucket config
│   │   ├── namespace/terragrunt.hcl
│   │   ├── ingress/terragrunt.hcl
│   │   ├── storage/terragrunt.hcl
│   │   ├── database/terragrunt.hcl
│   │   └── application/terragrunt.hcl
│   └── prod/
│       ├── backend.hcl         # Prod AWS account & bucket config
│       ├── namespace/terragrunt.hcl
│       ├── ingress/terragrunt.hcl
│       ├── storage/terragrunt.hcl
│       ├── database/terragrunt.hcl
│       └── application/terragrunt.hcl
└── src/
    └── modules/
        ├── namespace/
        ├── ingress/
        ├── storage/
        ├── database/
        └── application/
```

## State Files

Each module has its own S3 state file:
- `s3://{bucket}/tandoor/{env}/namespace/terraform.tfstate`
- `s3://{bucket}/tandoor/{env}/ingress/terraform.tfstate`
- `s3://{bucket}/tandoor/{env}/storage/terraform.tfstate`
- `s3://{bucket}/tandoor/{env}/database/terraform.tfstate`
- `s3://{bucket}/tandoor/{env}/application/terraform.tfstate`

## Usage

### Deploy All Modules (Recommended)

Terragrunt will automatically handle dependencies:

```bash
# Initialize all modules
make ENVIRONMENT=dev init

# Plan all modules
make ENVIRONMENT=dev plan

# Apply all modules in dependency order
make ENVIRONMENT=dev apply

# Or use run-all for non-interactive apply
make ENVIRONMENT=dev run-all
```

### Deploy Specific Module

```bash
# Deploy just the namespace
make ENVIRONMENT=dev MODULE=namespace apply

# Deploy ingress (requires namespace to exist)
make ENVIRONMENT=dev MODULE=ingress apply

# Deploy application (requires all dependencies)
make ENVIRONMENT=dev MODULE=application apply
```

### Destroy Infrastructure

```bash
# Destroy all (in reverse dependency order)
make ENVIRONMENT=dev destroy

# Destroy specific module
make ENVIRONMENT=dev MODULE=application destroy
```

## Environment Configuration

### Backend Configuration

Each environment has a `backend.hcl` file with:
- `environment` - Environment name (dev/prod)
- `aws_region` - AWS region for S3 backend
- `terraform_bucket` - S3 bucket for state files
- `profile_name` - AWS CLI profile name
- `kube_config_path` - Path to kubeconfig file

### Application Configuration

Application configuration is read from AWS SSM Parameter Store at `/tandoor/configuration` with the following JSON structure:

```json
{
  "app": {
    "domain_name": "recipes.example.com",
    "secret_key": "your-django-secret-key-here"
  },
  "nfs": {
    "server": "nfs.example.com",
    "media_path": "/mnt/storage/tandoor/media",
    "static_path": "/mnt/storage/tandoor/static",
    "postgres_path": "/mnt/storage/tandoor/postgres"
  },
  "database": {
    "name": "tandoor",
    "user": "tandoor",
    "password": "secure-database-password"
  }
}
```

## Makefile Commands

- `make init` - Initialize Terragrunt for environment
- `make plan` - Generate Terraform plan
- `make apply` - Apply Terraform changes
- `make destroy` - Destroy infrastructure
- `make run-all` - Apply all modules non-interactively
- `make fmt` - Format Terraform code
- `make validate` - Validate configuration

All commands support `ENVIRONMENT` and `MODULE` variables.

## Requirements

- OpenTofu >= 1.10.6 (or Terraform >= 1.5.0)
- Terragrunt >= 0.48.0
- AWS Provider >= 6.0.0
- Kubernetes Provider >= 2.23
- Helm Provider >= 2.11
- Kubernetes cluster with kubeconfig configured
- AWS credentials configured (via profiles)
- NFS server for persistent storage

## Tandoor-Specific Features

### Architecture

The deployment follows the [official Kubernetes installation guide](https://docs.tandoor.dev/install/kubernetes/) with these components:

1. **Init Container**: Runs as root to set permissions and execute database migrations
2. **Nginx Sidecar**: Serves static files (`/static/`) and media files (`/media/`)
3. **Gunicorn Container**: Runs the Django application as user `nobody` (UID 65534)
4. **PostgreSQL Database**: Bitnami PostgreSQL image running as non-root user
5. **Traefik Ingress**: Routes traffic with path-based routing for static/media content

### Storage Requirements

- **Media Storage**: For uploaded recipe images and files (10Gi dev, 50Gi prod)
- **Static Storage**: For Django static files (10Gi dev/prod)
- **Database Storage**: PostgreSQL data directory (20Gi dev, 50Gi prod)

All storage is backed by NFS with `ReadWriteMany` access for media/static and `ReadWriteOnce` for database.

### Environment Variables

The application container is configured with:
- `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `SECRET_KEY` - Django secret key from Kubernetes secret
- `DB_ENGINE` - Set to `django.db.backends.postgresql`
- `ALLOWED_HOSTS` - Set to `*` (restricted by ingress)
- `CSRF_TRUSTED_ORIGINS` - Set to the application domain
- `GUNICORN_MEDIA` - Set to `0` (nginx handles media)

### Security

- Application runs as non-root user (65534/nobody)
- Database runs as non-root user (1001/bitnami)
- Init container runs as root only for permission setup
- Secrets stored in Kubernetes secrets
- TLS certificates managed by Traefik
- Node affinity prevents scheduling on control plane

## Dependencies

Terragrunt automatically manages dependencies using:
- `dependency` blocks in each module's `terragrunt.hcl`
- Outputs from one module become inputs to dependent modules
- `run-all` commands respect the dependency graph

Example dependency chain:
```hcl
dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  namespace = dependency.namespace.outputs.namespace
}
```

## Troubleshooting

### Media Serving Warning

You may see a warning in the Tandoor UI about serving media files with gunicorn. This can be ignored - the nginx sidecar properly handles media and static file serving through the Traefik ingress with path-based routing.

### Permission Issues

If you encounter permission errors with media or static files, ensure:
1. The init container completed successfully
2. The NFS paths have appropriate permissions (755 recommended)
3. The UIDs (65534 for app, 1001 for database) can write to NFS shares

### Database Connection

If the application can't connect to the database:
1. Check that the database StatefulSet is running: `kubectl get sts -n <namespace>`
2. Verify the database service is accessible: `kubectl get svc postgres -n <namespace>`
3. Check database logs: `kubectl logs -n <namespace> postgres-0`
4. Ensure the database password in secrets matches SSM configuration

## Version Compatibility

This deployment has been tested with:
- Tandoor Recipes: 1.5.18
- PostgreSQL (Bitnami): 16
- Traefik: 26.0.0
- Nginx: 1.25-alpine

Update the `app_version` in `application/terragrunt.hcl` to use different Tandoor versions.
