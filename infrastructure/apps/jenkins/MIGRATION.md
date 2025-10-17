# Migration to Helm + JCasC

This document explains the conversion from pure Terraform to Helm-based deployment.

## What Changed?

### Files Removed
- `deployment.tf` - Replaced by Helm chart
- `service.tf` - Replaced by Helm chart
- `ingress.tf` - Replaced by Helm chart

### Files Added
- `helm.tf` - Helm release configuration
- `helm-values.yaml` - Jenkins configuration via Helm values and JCasC

### Files Modified
- `versions.tf` - Added Helm provider
- `variables.tf` - Updated for Helm chart variables
- `provider.tf.example` - Added Helm provider configuration
- `outputs.tf` - Updated to show Helm release info
- `Makefile` - Added Helm-specific commands
- `README.md` - Updated with Helm/JCasC instructions
- `QUICKSTART.md` - Updated deployment guide

### Files Unchanged
- `namespace.tf` - Still creates namespace
- `storage.tf` - Still creates NFS PV/PVC
- `rbac.tf` - Still creates ServiceAccount and permissions

## Key Differences

### Before (Pure Terraform)
```hcl
# Manual Kubernetes resources
resource "kubernetes_deployment" "jenkins" {
  # ... 100+ lines of configuration
}

resource "kubernetes_service" "jenkins" {
  # ... manual service config
}

resource "kubernetes_ingress_v1" "jenkins" {
  # ... manual ingress config
}
```

### After (Helm + Terraform)
```hcl
# Single Helm release
resource "helm_release" "jenkins" {
  chart   = "jenkins"
  values  = [templatefile("helm-values.yaml", {...})]
}
```

## Benefits of Helm Approach

### 1. Configuration as Code (JCasC)
- All Jenkins settings in YAML
- Plugins auto-installed
- No manual setup wizard
- Version-controlled configuration

### 2. Easy Upgrades
```bash
# Before: Manual resource updates
terraform apply -var="jenkins_image=jenkins/jenkins:2.426.1-lts"

# After: Just bump chart version
terraform apply -var="jenkins_chart_version=5.1.0"
```

### 3. Plugin Management
```yaml
# helm-values.yaml
controller:
  installPlugins:
    - kubernetes:4029.v5712230ccb_f8
    - git:5.2.1
    - pipeline:latest
```

### 4. Pre-configured Best Practices
- Security settings
- Resource limits
- Health checks
- Monitoring endpoints

## How to Use

### Initial Deployment
```bash
cd infrastructure/apps/jenkins
cp provider.tf.example provider.tf
# Edit provider.tf with your kubeconfig

make init
make plan
make apply
```

### Modify Jenkins Configuration
Edit `helm-values.yaml` and apply:
```bash
terraform apply
```

### Upgrade Jenkins
```bash
# Upgrade to newer LTS
terraform apply -var="jenkins_image_tag=lts"

# Upgrade Helm chart
terraform apply -var="jenkins_chart_version=5.1.0"
```

### Add Plugins
Edit `helm-values.yaml`:
```yaml
controller:
  installPlugins:
    - your-plugin:version
```
Then: `terraform apply`

## JCasC Configuration Examples

### Add System Message
```yaml
controller:
  JCasC:
    configScripts:
      welcome: |
        jenkins:
          systemMessage: "Welcome to CI/CD!"
```

### Configure Email
```yaml
controller:
  JCasC:
    configScripts:
      email: |
        unclassified:
          mailer:
            smtpHost: "smtp.example.com"
            smtpPort: 587
```

### Add Credentials
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
                    id: "github"
                    username: "user"
                    password: "${GITHUB_TOKEN}"
```

## Migration Checklist

If you had a previous pure Terraform deployment:

- [ ] Backup current Jenkins data (NFS export)
- [ ] Note current plugins and configuration
- [ ] Destroy old deployment: `terraform destroy`
- [ ] Update Terraform files (already done)
- [ ] Configure `provider.tf`
- [ ] Review `helm-values.yaml`
- [ ] Deploy new Helm-based setup: `terraform apply`
- [ ] Verify Jenkins is running
- [ ] Restore data if needed
- [ ] Configure additional plugins/settings via JCasC

## Troubleshooting

### Terraform State Issues
If you had an existing deployment:
```bash
# Remove old resources from state
terraform state rm kubernetes_deployment.jenkins
terraform state rm kubernetes_service.jenkins
terraform state rm kubernetes_ingress_v1.jenkins

# Import Helm release if it exists
terraform import helm_release.jenkins devops-tools/jenkins
```

### Helm Release Conflicts
```bash
# List Helm releases
helm list -A

# Delete conflicting release
helm delete jenkins -n devops-tools

# Re-run Terraform
terraform apply
```

## Resources

- [Jenkins Helm Chart](https://github.com/jenkinsci/helm-charts/tree/main/charts/jenkins)
- [JCasC Documentation](https://www.jenkins.io/projects/jcasc/)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
