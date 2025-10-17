# Jenkins on Kubernetes - Quick Deployment Guide

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

### 3. Configure Provider

Create `provider.tf` from the example:

```bash
cd infrastructure/apps/jenkins
cp provider.tf.example provider.tf

# Edit provider.tf and uncomment the option you want to use
# For local development, use Option 1 with your kubeconfig path
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

### 5. Get Initial Admin Password

```bash
# Using make
make get-password

# Or using kubectl
kubectl exec -it deployment/jenkins -n devops-tools -- \
  cat /var/jenkins_home/secrets/initialAdminPassword

# Or from NFS (if you have access to ritchie)
cat /mnt/default/services/jenkins/secrets/initialAdminPassword
```

### 6. Access Jenkins

Open your browser and navigate to: **https://ci.jwfh.ca**

The traffic flow is:
```
Browser → HAProxy (ci.jwfh.ca with TLS cert) → Traefik Ingress → Jenkins Service → Jenkins Pod
```

### 7. Initial Setup

1. Enter the initial admin password
2. Install suggested plugins (or select custom)
3. Create your first admin user
4. Configure Jenkins URL: `https://ci.jwfh.ca`

### 8. Configure Kubernetes Plugin

For dynamic Jenkins agents:

1. Go to: **Manage Jenkins** → **Manage Nodes and Clouds** → **Configure Clouds**
2. Click **Add a new cloud** → **Kubernetes**
3. Configure:
   - **Name**: `kubernetes`
   - **Kubernetes URL**: `https://kubernetes.default`
   - **Kubernetes Namespace**: `devops-tools`
   - **Credentials**: Add → Kubernetes Service Account
   - **Jenkins URL**: `http://jenkins-service.devops-tools.svc.cluster.local:8080`
   - **Jenkins tunnel**: `jenkins-service.devops-tools.svc.cluster.local:50000`

4. Test the connection
5. Add a Pod Template for agents (optional, or configure in Jenkinsfile)

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

# Destroy everything
make destroy
```

## Troubleshooting

### Pod not starting?
```bash
kubectl describe pod -l app=jenkins-server -n devops-tools
kubectl logs -l app=jenkins-server -n devops-tools
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

# Check Traefik
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik
```

## Next Steps

1. **Configure Jenkins**:
   - Set up your first pipeline
   - Configure credentials
   - Install additional plugins

2. **Secure Jenkins**:
   - Enable CSRF protection
   - Configure authorization strategy
   - Set up audit logs

3. **Set up Backups**:
   - Schedule regular NFS backups
   - Consider using Jenkins Configuration as Code (JCasC)

4. **Configure Agents**:
   - Create pod templates for different build environments
   - Configure resource limits for agent pods

## Resources

- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Jenkins Configuration as Code](https://www.jenkins.io/projects/jcasc/)
