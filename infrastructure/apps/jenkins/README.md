# Jenkins on Kubernetes - Terraform Configuration

This Terraform configuration deploys Jenkins on a k3s Kubernetes cluster with NFS-backed persistent storage and Traefik ingress.

## Architecture

- **Namespace**: `devops-tools` - Isolated namespace for Jenkins
- **Storage**: NFS persistent volume (`ritchie:/mnt/default/services/jenkins`)
- **RBAC**: ServiceAccount with cluster-admin permissions for Kubernetes plugin
- **Deployment**: Jenkins LTS with ephemeral agent support
- **Ingress**: Traefik-based ingress for external access via `ci.jwfh.ca`

## Prerequisites

1. **k3s Cluster**: Running k3s cluster with Traefik enabled (default)
2. **NFS Server**: NFS server `ritchie` with export at `/mnt/default/services/jenkins`
3. **kubectl**: Configured to access your k3s cluster
4. **Terraform**: Version >= 1.0

## Quick Start

### 1. Configure kubectl Access

From your k3s control plane node (10.174.12.177):

```bash
# Copy kubeconfig
scp user@10.174.12.177:/etc/rancher/k3s/k3s.yaml ~/.kube/k3s-config

# Update server address
sed -i 's/127.0.0.1/k8s.lemarchant.jacobhouse.ca/g' ~/.kube/k3s-config

# Set kubeconfig
export KUBECONFIG=~/.kube/k3s-config
```

### 2. Prepare NFS Storage

Ensure the NFS directory exists and has correct permissions:

```bash
# On the NFS server (ritchie)
sudo mkdir -p /mnt/default/services/jenkins
sudo chown -R 1000:1000 /mnt/default/services/jenkins
sudo chmod -R 755 /mnt/default/services/jenkins
```

### 3. Initialize and Apply Terraform

```bash
cd infrastructure/apps/jenkins

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Jenkins

Once deployed, access Jenkins at: **https://ci.jwfh.ca** (via HAProxy)

Get the initial admin password:

```bash
# Get the pod name
kubectl get pods -n devops-tools

# Get the password from the pod
kubectl exec -it deployment/jenkins -n devops-tools -- cat /var/jenkins_home/secrets/initialAdminPassword
```

Or from the NFS mount:

```bash
# On ritchie or any system with NFS access
cat /mnt/default/services/jenkins/secrets/initialAdminPassword
```

## Configuration Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `namespace` | `devops-tools` | Kubernetes namespace for Jenkins |
| `jenkins_image` | `jenkins/jenkins:lts` | Jenkins Docker image |
| `jenkins_replicas` | `1` | Number of Jenkins controller replicas |
| `nfs_server` | `ritchie` | NFS server hostname |
| `nfs_path` | `/mnt/default/services/jenkins` | NFS export path |
| `storage_size` | `10Gi` | Storage size for Jenkins home |
| `ingress_host` | `ci.jwfh.ca` | Hostname for Jenkins ingress |
| `resource_limits_memory` | `2Gi` | Memory limit |
| `resource_limits_cpu` | `1000m` | CPU limit |
| `resource_requests_memory` | `500Mi` | Memory request |
| `resource_requests_cpu` | `500m` | CPU request |

### Customizing Variables

Create a `terraform.tfvars` file:

```hcl
jenkins_image           = "jenkins/jenkins:lts-jdk17"
storage_size            = "20Gi"
resource_limits_memory  = "4Gi"
resource_limits_cpu     = "2000m"
```

## Post-Installation Setup

### 1. Install Recommended Plugins

During the setup wizard, install:
- **Kubernetes Plugin** - For dynamic agent provisioning
- **Git Plugin** - For Git integration
- **Pipeline Plugin** - For Jenkins Pipeline
- **Docker Plugin** - For Docker builds (if needed)

### 2. Configure Kubernetes Plugin

1. Navigate to **Manage Jenkins** > **Manage Nodes and Clouds** > **Configure Clouds**
2. Add a **Kubernetes Cloud**:
   - **Kubernetes URL**: `https://kubernetes.default`
   - **Kubernetes Namespace**: `devops-tools`
   - **Jenkins URL**: `http://jenkins-service.devops-tools.svc.cluster.local:8080`
   - **Jenkins tunnel**: `jenkins-service.devops-tools.svc.cluster.local:50000`

### 3. Configure Pod Template for Agents

Create a pod template for ephemeral Jenkins agents:

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    jenkins: agent
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent:latest
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
```

## Kubernetes Resources Created

- **Namespace**: `devops-tools`
- **PersistentVolume**: `jenkins-pv-volume` (NFS)
- **PersistentVolumeClaim**: `jenkins-pv-claim`
- **ServiceAccount**: `jenkins-admin`
- **ClusterRole**: `jenkins-admin`
- **ClusterRoleBinding**: `jenkins-admin`
- **Deployment**: `jenkins` (1 replica)
- **Service**: `jenkins-service` (ClusterIP)
- **Ingress**: `jenkins-ingress` (Traefik)

## Maintenance

### Upgrading Jenkins

Update the image version in `variables.tf` or override:

```bash
terraform apply -var="jenkins_image=jenkins/jenkins:2.426.1-lts"
```

### Backup and Restore

Jenkins data is persisted on the NFS server. To backup:

```bash
# On ritchie or system with NFS access
sudo tar -czf jenkins-backup-$(date +%Y%m%d).tar.gz -C /mnt/default/services jenkins
```

To restore:

```bash
# Stop Jenkins
kubectl scale deployment jenkins -n devops-tools --replicas=0

# Restore data
sudo tar -xzf jenkins-backup-YYYYMMDD.tar.gz -C /mnt/default/services

# Start Jenkins
kubectl scale deployment jenkins -n devops-tools --replicas=1
```

### View Logs

```bash
# Stream logs
kubectl logs -f deployment/jenkins -n devops-tools

# Get recent logs
kubectl logs --tail=100 deployment/jenkins -n devops-tools
```

### Restart Jenkins

```bash
# Rolling restart
kubectl rollout restart deployment/jenkins -n devops-tools

# Or delete the pod (will be recreated)
kubectl delete pod -l app=jenkins-server -n devops-tools
```

## Troubleshooting

### Jenkins Pod Not Starting

```bash
# Check pod status
kubectl get pods -n devops-tools

# Describe pod for events
kubectl describe pod -l app=jenkins-server -n devops-tools

# Check logs
kubectl logs -l app=jenkins-server -n devops-tools
```

### NFS Mount Issues

```bash
# Check PV and PVC status
kubectl get pv,pvc -n devops-tools

# Verify NFS connectivity from a test pod
kubectl run -it --rm nfs-test --image=busybox --restart=Never -- sh
# Inside pod: mount | grep nfs
```

### Ingress Not Working

```bash
# Check ingress status
kubectl get ingress -n devops-tools

# Check Traefik logs
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik

# Verify service endpoints
kubectl get endpoints jenkins-service -n devops-tools
```

## Security Considerations

1. **RBAC**: The Jenkins ServiceAccount has cluster-admin permissions for dynamic agent provisioning. Consider restricting this in production.
2. **TLS**: Traffic is terminated at HAProxy with a valid certificate. Internal cluster traffic uses self-signed certs.
3. **Network Policies**: Consider adding NetworkPolicies to restrict pod communication.
4. **Secrets**: Store sensitive data (credentials, tokens) using Kubernetes Secrets or external secret management.

## References

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Traefik Kubernetes Ingress](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [k3s Documentation](https://docs.k3s.io/)

## License

This configuration is part of the homelab infrastructure managed by Terraform.
