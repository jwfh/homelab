# Docker Registry Kubernetes Deployment

This directory contains Terraform code for deploying a Docker Registry using NFS storage to a k3s cluster.

## Files

- `main.tf` - Main Terraform configuration with all Kubernetes resources
- `variables.tf` - Input variables for the deployment
- `outputs.tf` - Output values after deployment
- `terraform.tfvars.example` - Example terraform variables file
- `README.md` - This file

## Prerequisites

- Terraform >= 1.0
- Kubernetes provider configured (kubeconfig at `~/.kube/config`)
- k3s cluster with Traefik ingress controller (already available)
- NFS export accessible at `ritchie.lemarchant.jacobhouse.ca:/mnt/default/services/registry/data`
- TLS certificate for `registry.jwfh.ca` configured in Traefik

## Deployment

### Step 1: Ensure proper permissions on NFS server

On the ritchie NFS server, ensure the directory exists and has proper permissions:

```bash
sudo mkdir -p /mnt/default/services/registry/data
sudo chown <UID>:<GID> /mnt/default/services/registry/data
sudo chmod 755 /mnt/default/services/registry/data
```

Where `<UID>` and `<GID>` are the values you'll use in your Terraform configuration.

### Step 2: Configure Terraform variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set the required variables:

```hcl
registry_uid = 1000
registry_gid = 1000
```

### Step 3: Deploy with Terraform

Initialize Terraform:

```bash
terraform init
```

Review the deployment plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

## Verification

After applying the Terraform configuration, check the deployment status:

```bash
# Check pod status
kubectl get pods -n docker-registry

# Check PVC binding
kubectl get pvc -n docker-registry

# Check PV binding
kubectl get pv

# Check service
kubectl get svc -n docker-registry

# Check ingress
kubectl get ingress -n docker-registry

# View logs
kubectl logs -n docker-registry -l app=registry -f

# Get deployment info
terraform output
```

## Accessing the Registry

### From within the cluster:

```bash
http://registry.docker-registry.svc.cluster.local:5000
```

### From outside the cluster:

```bash
https://registry.jwfh.ca
```

### Using Docker CLI:

```bash
docker login registry.jwfh.ca
docker tag myimage:latest registry.jwfh.ca/myimage:latest
docker push registry.jwfh.ca/myimage:latest
```

## Scaling

To change the number of replicas, update the `registry_replicas` variable in `terraform.tfvars`:

```hcl
registry_replicas = 3
```

Then apply the changes:

```bash
terraform apply
```

Note: The current setup uses `ReadWriteOnce` access mode, which limits the number of replicas to 1. To scale beyond 1 replica, you would need:
1. Change the NFS PVC to use `ReadWriteMany` access mode
2. Ensure your NFS server supports `ReadWriteMany`
3. Update the PV and PVC access modes in `main.tf`

## Destroying the Deployment

To remove all resources created by Terraform:

```bash
terraform destroy
```

This will:
- Delete the registry deployment
- Delete the service and ingress
- Delete the PersistentVolumeClaim
- Delete the namespace
- **Keep** the PersistentVolume (due to `Retain` reclaim policy) and NFS data

To completely clean up including the PV:

```bash
kubectl delete pv registry-storage-pv
```

## Storage

- Storage location: NFS share on ritchie at `/mnt/default/services/registry/data`
- Storage allocation: 100Gi (can be adjusted in `pv.yml` and `pvc.yml`)
- Registry data persists even if the pod is deleted

## Security

The deployment includes:
- Non-root container security context (runs as specified UID/GID)
- Resource limits (512Mi memory, 500m CPU)
- Liveness and readiness probes
- TLS encryption via Traefik ingress

## Troubleshooting

### PVC stuck in Pending state

Check if the PV is properly bound:
```bash
kubectl get pv
```

Ensure NFS server is reachable and the export exists.

### Pod fails to start with permission errors

Ensure the UID/GID specified match the NFS directory ownership:
```bash
# On ritchie NFS server
ls -ld /mnt/default/services/registry/data
```

### TLS certificate issues

Verify Traefik certificate configuration:
```bash
kubectl get certificate -A
kubectl describe certificate registry-tls -n docker-registry
```
