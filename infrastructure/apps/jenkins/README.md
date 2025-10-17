# Jenkins on Kubernetes - Terraform + Helm Configuration

This Terraform configuration deploys Jenkins on a k3s Kubernetes cluster using the official Jenkins Helm chart with Jenkins Configuration as Code (JCasC).

## Why Helm + JCasC?

- **Easy Upgrades**: Update Jenkins by simply changing the Helm chart version
- **Configuration as Code**: All Jenkins configuration in version-controlled YAML
- **Battle-tested**: Use the official Jenkins Helm chart maintained by the community
- **Plugin Management**: Automatic plugin installation and updates
- **Best Practices**: Pre-configured security and performance settings

## Architecture

- **Deployment**: Jenkins Helm chart with JCasC
- **Namespace**: `devops-tools` - Isolated namespace for Jenkins
- **Storage**: NFS persistent volume (`ritchie:/mnt/default/services/jenkins`)
- **RBAC**: ServiceAccount with cluster-admin permissions for Kubernetes plugin
- **Ingress**: Traefik-based ingress for external access via `ci.jwfh.ca`
- **Agents**: Dynamic Kubernetes-based ephemeral agents

## Prerequisites

1. **k3s Cluster**: Running k3s cluster with Traefik enabled (default)
2. **NFS Server**: NFS server `ritchie` with export at `/mnt/default/services/jenkins`
3. **kubectl**: Configured to access your k3s cluster
4. **Terraform**: Version >= 1.0
5. **Helm**: Version >= 3.0 (Terraform will manage it, but good to have for debugging)

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

### 3. Configure Provider

Create `provider.tf` from the example:

```bash
cd infrastructure/apps/jenkins
cp provider.tf.example provider.tf

# Edit provider.tf and set your kubeconfig path
```

### 4. Deploy Jenkins

Using Makefile (recommended):

```bash
# Verify cluster connectivity
make check-kubeconfig

# Initialize Terraform
make init

# Review the plan
make plan

# Apply the configuration
make apply

# Check deployment status
make status
```

Or using Terraform directly:

```bash
terraform init
terraform plan
terraform apply
```

### 5. Access Jenkins

Once deployed, access Jenkins at: **https://ci.jwfh.ca** (via HAProxy)

**Note**: With JCasC, the setup wizard is skipped. You'll need to create the initial admin user via JCasC or use the generated password.

Get the initial admin password:

```bash
# Using make
make get-password

# Or using kubectl
kubectl exec -it -n devops-tools deployment/jenkins -- \
  cat /var/jenkins_home/secrets/initialAdminPassword
```

## Configuration

### Jenkins Configuration as Code (JCasC)

Jenkins is configured entirely through the `helm-values.yaml` file using JCasC. Key configurations include:

- **Pre-installed Plugins**: Kubernetes, Git, Pipeline, Blue Ocean, Docker, etc.
- **Kubernetes Cloud**: Auto-configured for dynamic agent provisioning
- **Security**: Logged-in users authorization strategy
- **Agent Templates**: Pre-configured pod templates for builds

To modify Jenkins configuration, edit `helm-values.yaml` and run:

```bash
terraform apply
```

### Adding Plugins

Edit `helm-values.yaml` under `controller.installPlugins`:

```yaml
controller:
  installPlugins:
    - kubernetes:4029.v5712230ccb_f8
    - workflow-aggregator:596.v8c21c963d92d
    - your-plugin:version
```

Find plugins at: https://plugins.jenkins.io/

### Customizing JCasC

Edit the `controller.JCasC.configScripts` section in `helm-values.yaml`:

```yaml
controller:
  JCasC:
    configScripts:
      your-config: |
        jenkins:
          systemMessage: "My Custom Message"
```

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `namespace` | `devops-tools` | Kubernetes namespace for Jenkins |
| `jenkins_chart_version` | `5.0.0` | Jenkins Helm chart version |
| `jenkins_image_tag` | `lts` | Jenkins Docker image tag |
| `jenkins_replicas` | `1` | Number of controller replicas |
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
jenkins_chart_version   = "5.1.0"
jenkins_image_tag       = "lts-jdk17"
storage_size            = "20Gi"
resource_limits_memory  = "4Gi"
```

## Kubernetes Resources Created

- **Namespace**: `devops-tools`
- **PersistentVolume**: `jenkins-pv-volume` (NFS)
- **PersistentVolumeClaim**: `jenkins-pv-claim`
- **ServiceAccount**: `jenkins-admin`
- **ClusterRole**: `jenkins-admin`
- **ClusterRoleBinding**: `jenkins-admin`
- **Helm Release**: `jenkins` (creates Deployment, Service, Ingress, etc.)

## Upgrading Jenkins

### Upgrade to Latest LTS

Update the image tag in `variables.tf` or override:

```bash
terraform apply -var="jenkins_image_tag=lts"
```

### Upgrade Helm Chart

Update the chart version:

```bash
terraform apply -var="jenkins_chart_version=5.1.0"
```

### Upgrade via Helm Directly (for testing)

```bash
make helm-upgrade
```

## Maintenance

### View Helm Release Status

```bash
make helm-status
make helm-values
```

### View Logs

```bash
make logs

# Or with kubectl
kubectl logs -f -n devops-tools deployment/jenkins
```

### Restart Jenkins

```bash
make restart

# Or with kubectl
kubectl rollout restart deployment/jenkins -n devops-tools
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

## Using Dynamic Kubernetes Agents

Jenkins is pre-configured to use Kubernetes for ephemeral build agents. In your Jenkinsfile:

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: maven
    image: maven:3.9-eclipse-temurin-17
    command: ['cat']
    tty: true
  - name: docker
    image: docker:24-dind
    securityContext:
      privileged: true
'''
        }
    }
    stages {
        stage('Build') {
            steps {
                container('maven') {
                    sh 'mvn clean package'
                }
            }
        }
    }
}
```

## Troubleshooting

### Jenkins Pod Not Starting

```bash
kubectl get pods -n devops-tools
kubectl describe pod -l app.kubernetes.io/component=jenkins-controller -n devops-tools
kubectl logs -l app.kubernetes.io/component=jenkins-controller -n devops-tools
```

### Helm Release Issues

```bash
helm list -n devops-tools
helm status jenkins -n devops-tools
helm get values jenkins -n devops-tools
```

### NFS Mount Issues

```bash
kubectl get pv,pvc -n devops-tools
kubectl describe pvc jenkins-pv-claim -n devops-tools
```

### Ingress Not Working

```bash
kubectl get ingress -n devops-tools
kubectl describe ingress jenkins -n devops-tools
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
```

### JCasC Configuration Issues

```bash
# Check JCasC logs
kubectl logs -n devops-tools deployment/jenkins | grep -i casc

# Export current configuration
kubectl exec -it -n devops-tools deployment/jenkins -- \
  cat /var/jenkins_home/jenkins.yaml
```

## Advanced Configuration

### Custom JCasC Configuration

You can extend JCasC configuration in `helm-values.yaml`:

```yaml
controller:
  JCasC:
    configScripts:
      credentials: |
        credentials:
          system:
            domainCredentials:
              - credentials:
                - usernamePassword:
                    scope: GLOBAL
                    id: "github"
                    username: "your-username"
                    password: "${GITHUB_TOKEN}"
      
      email: |
        unclassified:
          mailer:
            smtpHost: "smtp.example.com"
            smtpPort: 587
```

### Enable LDAP/Active Directory

```yaml
controller:
  JCasC:
    configScripts:
      security: |
        jenkins:
          securityRealm:
            ldap:
              configurations:
                - server: "ldap.example.com"
                  rootDN: "dc=example,dc=com"
```

## Security Considerations

1. **RBAC**: The Jenkins ServiceAccount has cluster-admin permissions. Consider restricting in production:
   ```bash
   # Edit rbac.tf to use specific permissions instead of "*"
   ```

2. **JCasC Secrets**: Use Kubernetes secrets for sensitive JCasC values:
   ```yaml
   controller:
     JCasC:
       configScripts:
         credentials: |
           credentials:
             system:
               domainCredentials:
                 - credentials:
                   - string:
                       id: "secret-key"
                       secret: "${SECRET_FROM_K8S}"
   ```

3. **Network Policies**: Add NetworkPolicies to restrict pod communication

4. **Pod Security**: Enable Pod Security Admission/Policies

## Useful Make Commands

```bash
make help              # Show all available commands
make check-kubeconfig  # Verify cluster access
make init              # Initialize Terraform
make plan              # Show execution plan
make apply             # Apply changes
make status            # Show deployment status
make logs              # Stream Jenkins logs
make get-password      # Get admin password
make restart           # Restart Jenkins
make helm-status       # Show Helm release status
make helm-values       # Show Helm values
make destroy           # Destroy everything
```

## References

- [Jenkins Helm Chart](https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Traefik Kubernetes Ingress](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [k3s Documentation](https://docs.k3s.io/)

## License

This configuration is part of the homelab infrastructure managed by Terraform.
