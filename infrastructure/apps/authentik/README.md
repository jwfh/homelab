# Authentik Kubernetes Deployment

This directory contains Terraform/Terragrunt infrastructure-as-code for deploying [Authentik](https://goauthentik.io/) to a Kubernetes cluster using the official Helm chart.

## Overview

Authentik is deployed with the following components:

- **Namespace**: Dedicated Kubernetes namespace (`authentik`)
- **Storage**: NFS-backed persistent volumes for:
  - PostgreSQL database (10Gi)
  - Redis cache (2Gi)
  - Media files (5Gi)
- **Authentik**: Deployed via Helm chart with:
  - Kubernetes Integration enabled for outpost management
  - PostgreSQL and Redis with persistent storage
  - Traefik ingress with TLS
  - Bootstrap configuration from AWS SSM Parameter Store

## Architecture

```
authentik namespace
├── PostgreSQL (StatefulSet)
│   └── PVC → NFS PV (10Gi)
├── Redis (StatefulSet)
│   └── PVC → NFS PV (2Gi)
├── Authentik Server (Deployment)
│   └── Media PVC → NFS PV (5Gi)
├── Authentik Worker (Deployment)
│   └── Media PVC → NFS PV (5Gi)
└── Ingress (Traefik)
    └── TLS Certificate (cert-manager)
```

## Prerequisites

1. **Kubernetes Cluster**: K3s cluster with Traefik ingress controller
2. **NFS Server**: NFS storage with the following directories:
   - `/mnt/pool0/kubernetes/authentik/postgres`
   - `/mnt/pool0/kubernetes/authentik/redis`
   - `/mnt/pool0/kubernetes/authentik/media`
3. **AWS SSM Parameter**: `/authentik/configuration` with the following structure:
   ```json
   {
     "secret_key": "<random-secret-key>",
     "db_password": "<postgres-password>",
     "bootstrap_email": "admin@example.com",
     "bootstrap_password": "<admin-password>",
     "bootstrap_token": "<api-token>"
   }
   ```
4. **Tools**:
   - Terragrunt >= 0.48.0
   - Terraform/OpenTofu >= 1.10.6
   - kubectl with kubeconfig at `~/.kube/k3s-config`
   - AWS CLI with profile `prod-authentik-terraform-deployer`

## Module Structure

```
infrastructure/apps/authentik/
├── environments/
│   ├── terragrunt.hcl          # Root configuration
│   └── prod/
│       ├── backend.hcl         # AWS backend configuration
│       ├── namespace/          # Kubernetes namespace
│       ├── storage/            # NFS PVs/PVCs
│       └── authentik/          # Helm release
├── src/
│   └── modules/
│       ├── namespace/          # Namespace module
│       ├── storage/            # Storage module
│       └── authentik/          # Authentik Helm module
├── Makefile                    # Deployment automation
└── README.md
```

## Deployment

### Full Deployment

Deploy all modules in dependency order:

```bash
# Review changes
make ENVIRONMENT=prod all-plan

# Deploy (non-interactive)
make ENVIRONMENT=prod all-apply
```

### Module-by-Module Deployment

```bash
# 1. Create namespace
make ENVIRONMENT=prod MODULE=namespace apply

# 2. Create storage
make ENVIRONMENT=prod MODULE=storage apply

# 3. Deploy Authentik
make ENVIRONMENT=prod MODULE=authentik apply
```

### Individual Module Updates

```bash
# Update only Authentik (e.g., chart version upgrade)
make ENVIRONMENT=prod MODULE=authentik plan
make ENVIRONMENT=prod MODULE=authentik apply
```

## Configuration

### Helm Chart Version

The Authentik Helm chart version is specified in `environments/prod/authentik/terragrunt.hcl`:

```hcl
chart_version = "2024.10.1"
```

### Ingress

Update the ingress host in `environments/prod/authentik/terragrunt.hcl`:

```hcl
ingress_host = "auth.example.com"
ingress_annotations = {
  "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
}
```

### Storage Sizes

Modify storage sizes in `environments/prod/storage/terragrunt.hcl`:

```hcl
postgres_storage_size = "10Gi"
media_storage_size    = "5Gi"
redis_storage_size    = "2Gi"
```

## Kubernetes Integration (Outposts)

Authentik is deployed with `kubernetesIntegration.enabled = true`, which allows it to automatically manage outposts in the same Kubernetes cluster. This creates:

- ServiceAccount with cluster-level RBAC permissions
- Secret containing the outpost token (`authentik-outpost-token`)
- Automatic deployment/update of outposts when configured in Authentik UI

For more information, see: https://docs.goauthentik.io/add-secure-apps/outposts/integrations/kubernetes/

## SSM Parameter Setup

Create the SSM parameter before deployment:

```bash
aws ssm put-parameter \
  --name "/authentik/configuration" \
  --type "SecureString" \
  --value '{
    "secret_key": "'"$(openssl rand -base64 32)"'",
    "db_password": "'"$(openssl rand -base64 16)"'",
    "bootstrap_email": "admin@example.com",
    "bootstrap_password": "'"$(openssl rand -base64 16)"'",
    "bootstrap_token": "'"$(openssl rand -base64 32)"'"
  }' \
  --profile prod-authentik-terraform-deployer \
  --region ca-central-1
```

## Accessing Authentik

After deployment, access Authentik at the configured ingress host:

1. Navigate to `https://auth.example.com`
2. Login with the bootstrap email and password from SSM
3. Complete initial setup in the admin interface

## Updating Authentik

To upgrade the Helm chart version:

1. Update `chart_version` in `environments/prod/authentik/terragrunt.hcl`
2. Plan and apply:
   ```bash
   make ENVIRONMENT=prod MODULE=authentik plan
   make ENVIRONMENT=prod MODULE=authentik apply
   ```

## Destroying Infrastructure

**WARNING**: This will delete all Authentik data!

```bash
# Destroy all modules
make ENVIRONMENT=prod destroy

# Destroy specific module
make ENVIRONMENT=prod MODULE=authentik destroy
```

## Troubleshooting

### View Helm Release

```bash
helm list -n authentik
helm get values authentik -n authentik
```

### Check Pod Status

```bash
kubectl get pods -n authentik
kubectl logs -n authentik -l app.kubernetes.io/name=authentik
```

### Check PVC Binding

```bash
kubectl get pv,pvc -n authentik
```

### Verify Kubernetes Integration

```bash
kubectl get serviceaccount -n authentik
kubectl get secret authentik-outpost-token -n authentik
```

## References

- [Authentik Documentation](https://docs.goauthentik.io/)
- [Authentik Helm Chart](https://artifacthub.io/packages/helm/goauthentik/authentik)
- [Kubernetes Outpost Integration](https://docs.goauthentik.io/add-secure-apps/outposts/integrations/kubernetes/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
