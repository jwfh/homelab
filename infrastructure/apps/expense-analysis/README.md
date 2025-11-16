# Terragrunt Infrastructure Structure

This directory contains the Terragrunt configuration for deploying the expense-analysis application to Kubernetes.

## Architecture

The infrastructure is split into 5 modules with clear dependencies:

```
namespace (base)
    ├── ingress (Traefik)
    ├── storage (PV/PVCs)
    │   └── database (PostgreSQL)
    │       └── application (Backend)
    └── application (also depends on ingress + storage)
```

### Module Descriptions

1. **namespace** - Creates Kubernetes namespace, secrets, and reads configuration from AWS SSM
2. **ingress** - Installs Traefik ingress controller via Helm (must run before application)
3. **storage** - Creates NFS-backed persistent volumes and claims
4. **database** - Deploys PostgreSQL StatefulSet
5. **application** - Deploys the expense-analysis backend application

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
- `s3://{bucket}/expense-analysis/{env}/namespace/terraform.tfstate`
- `s3://{bucket}/expense-analysis/{env}/ingress/terraform.tfstate`
- `s3://{bucket}/expense-analysis/{env}/storage/terraform.tfstate`
- `s3://{bucket}/expense-analysis/{env}/database/terraform.tfstate`
- `s3://{bucket}/expense-analysis/{env}/application/terraform.tfstate`

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

Each environment has a `backend.hcl` file with:
- `environment` - Environment name (dev/prod)
- `aws_region` - AWS region for S3 backend
- `terraform_bucket` - S3 bucket for state files
- `profile_name` - AWS CLI profile name

Application configuration is read from AWS SSM Parameter Store:
- `/expense-analysis/configuration` - JSON with app, database, and NFS settings

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

- OpenTofu >= 1.10.6
- Terragrunt >= 0.48.0
- AWS Provider >= 6.0.0
- Kubernetes cluster with kubeconfig configured
- AWS credentials configured (via profiles)

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
