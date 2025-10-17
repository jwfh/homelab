# Jenkins on Kubernetes - Quick Deployment Guide (Helm + JCasC)

## Prerequisites Checklist

- [ ] k3s cluster running at `k8s.lemarchant.jacobhouse.ca`
- [ ] Traefik ingress controller enabled (k3s default)
- [ ] NFS server `ritchie` accessible with export `/mnt/default/services/jenkins`
- [ ] kubectl configured with access to cluster
- [ ] Terraform >= 1.0 installed

## Step-by-Step Deployment

### 1. Prepare NFS Storage

On the NFS server (ritchie):

```bash
sudo mkdir -p /mnt/default/services/jenkins
sudo chown -R 1000:1000 /mnt/default/services/jenkins
sudo chmod -R 755 /mnt/default/services/jenkins
```

### 2. Configure kubectl

Copy kubeconfig from k3s control plane:

```bash
# Copy from control plane
scp user@10.174.12.177:/etc/rancher/k3s/k3s.yaml ~/.kube/k3s-config

# Update server address
sed -i 's/127.0.0.1/k8s.lemarchant.jacobhouse.ca/g' ~/.kube/k3s-config

# Set kubeconfig
export KUBECONFIG=~/.kube/k3s-config

# Verify access
kubectl get nodes
```

### 3. Configure Providers

Create `provider.tf` from the example:

```bash
cd infrastructure/apps/jenkins
cp provider.tf.example provider.tf

# Edit provider.tf and uncomment the option you want
# For local development, use Option 1 with your kubeconfig path
```

Example `provider.tf`:

```hcl
provider "kubernetes" {
  config_path = "~/.kube/k3s-config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/k3s-config"
  }
}
```

### 4. Review Helm Values (Optional)

The Jenkins configuration is in `helm-values.yaml`. Review and customize:

- **Plugins**: Pre-installed plugins list
- **JCasC**: Jenkins Configuration as Code settings
- **Resources**: CPU and memory limits
- **Kubernetes Cloud**: Agent pod templates

### 5. Deploy Jenkins

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

### 6. Get Initial Admin Password

```bash
# Using make
make get-password

# Or using kubectl
kubectl exec -it -n devops-tools deployment/jenkins -- \
  cat /var/jenkins_home/secrets/initialAdminPassword

# Or from NFS (if you have access to ritchie)
cat /mnt/default/services/jenkins/secrets/initialAdminPassword
```

### 7. Access Jenkins

Open your browser and navigate to: **https://ci.jwfh.ca**

The traffic flow is:
```
Browser → HAProxy (ci.jwfh.ca with TLS cert) → Traefik Ingress → Jenkins Service → Jenkins Pod
```

### 8. Initial Setup

**Note**: With JCasC and `runSetupWizard=false`, the setup wizard is skipped!

1. Log in with username `admin` and the initial password
2. Jenkins is already configured via JCasC with:
   - Pre-installed plugins (Kubernetes, Git, Pipeline, etc.)
   - Kubernetes cloud for dynamic agents
   - Security settings
3. Create additional users or configure SSO if needed

### 9. Verify Kubernetes Plugin

1. Go to: **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
2. You should see a **kubernetes** cloud already configured
3. Test the connection (should show success)

### 10. Create Your First Pipeline

Create a test pipeline:

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: ubuntu:22.04
    command: ['cat']
    tty: true
'''
        }
    }
    stages {
        stage('Test') {
            steps {
                container('shell') {
                    sh 'echo "Hello from Kubernetes agent!"'
                    sh 'hostname'
                }
            }
        }
    }
}
```

## Common Commands

```bash
# View logs
make logs

# Restart Jenkins
make restart

# Check status
make status

# Debug issues
make debug

# Port forward to localhost
make port-forward

# Helm-specific commands
make helm-status    # Show Helm release status
make helm-values    # Show current Helm values

# Destroy everything
make destroy
```

## Customizing Jenkins Configuration

### Add More Plugins

Edit `helm-values.yaml`:

```yaml
controller:
  installPlugins:
    - kubernetes:4029.v5712230ccb_f8
    - workflow-aggregator:596.v8c21c963d92d
    - your-new-plugin:version
```

Then apply:

```bash
terraform apply
```

### Modify JCasC Settings

Edit `helm-values.yaml` under `controller.JCasC.configScripts`:

```yaml
controller:
  JCasC:
    configScripts:
      custom-config: |
        jenkins:
          systemMessage: "My Custom Jenkins Server"
          numExecutors: 0  # Force all builds to agents
```

Apply changes:

```bash
terraform apply
```

### Change Resource Limits

Edit `terraform.tfvars`:

```hcl
resource_limits_memory  = "4Gi"
resource_limits_cpu     = "2000m"
resource_requests_memory = "1Gi"
resource_requests_cpu    = "1000m"
```

Apply:

```bash
terraform apply
```

## Upgrading Jenkins

### Upgrade to Newer LTS Version

```bash
# Option 1: Edit variables.tf and change jenkins_image_tag
# Option 2: Override on command line
terraform apply -var="jenkins_image_tag=2.426.1-lts"
```

### Upgrade Helm Chart Version

```bash
# Option 1: Edit variables.tf and change jenkins_chart_version
# Option 2: Override on command line
terraform apply -var="jenkins_chart_version=5.1.0"
```

## Troubleshooting

### Pod not starting?
```bash
kubectl describe pod -l app.kubernetes.io/component=jenkins-controller -n devops-tools
kubectl logs -l app.kubernetes.io/component=jenkins-controller -n devops-tools
```

### Helm release failed?
```bash
make helm-status
helm list -n devops-tools
helm get manifest jenkins -n devops-tools
```

### NFS mount issues?
```bash
# Check PV/PVC status
kubectl get pv,pvc -n devops-tools

# Test NFS from a pod
kubectl run -it --rm nfs-test --image=busybox --restart=Never -- sh
```

### Can't access via ingress?
```bash
# Check ingress
kubectl get ingress -n devops-tools
kubectl describe ingress jenkins -n devops-tools

# Check Traefik
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
```

### JCasC not applying?
```bash
# View JCasC logs
kubectl logs -n devops-tools deployment/jenkins | grep -i casc

# Check current JCasC configuration
kubectl exec -it -n devops-tools deployment/jenkins -- \
  cat /var/jenkins_home/jenkins.yaml
```

## Next Steps

1. **Configure Credentials**:
   - Add GitHub/GitLab credentials
   - Configure Docker registry access
   - Set up cloud provider credentials

2. **Set Up Pipelines**:
   - Create your first CI/CD pipeline
   - Configure webhooks for automatic builds
   - Set up multi-branch pipelines

3. **Configure Monitoring**:
   - Enable Prometheus metrics (already configured)
   - Set up Grafana dashboards
   - Configure alerting

4. **Enhance Security**:
   - Configure LDAP/SSO authentication
   - Set up matrix-based authorization
   - Enable audit logging

5. **Optimize Performance**:
   - Fine-tune resource limits
   - Configure build retention policies
   - Set up build caching

## Important Files

- `helm-values.yaml` - Jenkins Helm chart configuration with JCasC
- `provider.tf` - Kubernetes and Helm provider configuration
- `variables.tf` - Terraform variables
- `terraform.tfvars` - Your custom variable values (create from .example)
- `helm.tf` - Helm release configuration
- `storage.tf` - NFS PV and PVC configuration
- `rbac.tf` - ServiceAccount and permissions

## Resources

- [Jenkins Helm Chart Documentation](https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
- [JCasC Examples](https://github.com/jenkinsci/configuration-as-code-plugin/tree/master/demos)
- [Kubernetes Plugin Documentation](https://plugins.jenkins.io/kubernetes/)
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
