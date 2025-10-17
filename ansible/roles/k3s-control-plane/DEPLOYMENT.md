# Kubernetes Control Plane Deployment Guide

## Quick Start

### 1. Configure Host Variables

Create a host variables file for your control plane node:

```bash
cd ansible/inventory/host_variables
cp k8s12-001.example.yml 10.174.12.176.yml
```

Edit `10.174.12.176.yml` and configure:
- Set or generate `k3s_token` (store in Ansible Vault for production)
- Add TLS SANs for your domain/IPs
- Configure networking options
- Enable/disable components as needed

### 2. Secure the Token (Production)

For production, store the k3s token in Ansible Vault:

```bash
# Create a vault file
ansible-vault create inventory/vault.yml

# Add this content:
vault_k3s_token: "your-secure-token-here"

# In your host variables, reference it:
k3s_token: "{{ vault_k3s_token }}"
```

### 3. Deploy the Control Plane

```bash
cd ansible
ansible-playbook -i inventory/hosts.yml kubernetes-control-plane.yml
```

With vault:
```bash
ansible-playbook -i inventory/hosts.yml kubernetes-control-plane.yml --ask-vault-pass
```

### 4. Verify Installation

SSH to the control plane node:

```bash
# Check k3s service
sudo systemctl status k3s

# Check cluster status
sudo kubectl get nodes
sudo kubectl get pods -A

# Get the node token for joining workers
sudo cat /var/lib/rancher/k3s/server/node-token
```

## Architecture

```
┌─────────────────────────────────────┐
│   k8s12-001 (10.174.12.176)        │
│   ┌─────────────────────────────┐  │
│   │   k3s Control Plane         │  │
│   │   - API Server              │  │
│   │   - Controller Manager      │  │
│   │   - Scheduler               │  │
│   │   - Embedded etcd           │  │
│   └─────────────────────────────┘  │
└─────────────────────────────────────┘
           │
           │ Join via node-token
           ▼
┌─────────────────────────────────────┐
│   k8s12-002 (10.174.12.177)        │
│   ┌─────────────────────────────┐  │
│   │   k3s Worker Node           │  │
│   │   - kubelet                 │  │
│   │   - kube-proxy              │  │
│   │   - Container runtime       │  │
│   └─────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Accessing the Cluster

### From the Control Plane Node

As root:
```bash
kubectl get nodes
```

As regular user:
```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
export KUBECONFIG=~/.kube/config
kubectl get nodes
```

### From Your Workstation

```bash
# Copy kubeconfig from control plane
scp user@10.174.12.176:/etc/rancher/k3s/k3s.yaml ~/.kube/k3s-config

# Edit the file and change server IP from 127.0.0.1 to 10.174.12.176
sed -i 's/127.0.0.1/10.174.12.176/g' ~/.kube/k3s-config

# Use the config
export KUBECONFIG=~/.kube/k3s-config
kubectl get nodes
```

## High Availability Setup

For multiple control plane nodes:

1. **Deploy First Control Plane:**
   ```bash
   ansible-playbook -i inventory/hosts.yml kubernetes-control-plane.yml --limit k8s12-001
   ```

2. **Configure Additional Control Planes:**
   
   In host variables for additional control plane nodes (e.g., `10.174.12.178.yml`):
   ```yaml
   k3s_embedded_etcd: true
   k3s_server_url: "https://10.174.12.176:6443"
   k3s_token: "{{ vault_k3s_token }}"  # Same token as first node
   ```

3. **Deploy Additional Control Planes:**
   ```bash
   ansible-playbook -i inventory/hosts.yml kubernetes-control-plane.yml --limit k8s12-003
   ```

## Common Tasks

### Install Additional Components

After deployment, you can install additional components:

```bash
# Install cert-manager for automatic TLS certificates
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.yaml

# Install MetalLB (if servicelb disabled)
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.11/config/manifests/metallb-native.yaml
```

### Upgrade k3s

Update the version in host variables:
```yaml
k3s_version: v1.29.0+k3s1
```

Re-run the playbook:
```bash
ansible-playbook -i inventory/hosts.yml kubernetes-control-plane.yml
```

### Backup etcd

```bash
# Manual backup
sudo k3s etcd-snapshot save --name manual-backup

# Backups are stored in /var/lib/rancher/k3s/server/db/snapshots/
```

## Troubleshooting

### Check Service Status
```bash
sudo systemctl status k3s
sudo journalctl -u k3s -f
```

### Check Node Status
```bash
kubectl get nodes -o wide
kubectl describe node k8s12-001
```

### Check Pod Status
```bash
kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### Network Issues
```bash
# Check flannel
kubectl get pods -n kube-system | grep flannel

# Check iptables rules
sudo iptables -L -n -v

# Check IP forwarding
sysctl net.ipv4.ip_forward
sysctl net.ipv6.conf.all.forwarding
```

### Reset k3s (Nuclear Option)
```bash
# This will delete everything!
sudo /usr/local/bin/k3s-uninstall.sh

# Then re-run the playbook
```

## Security Best Practices

1. **Use Ansible Vault** for sensitive data
2. **Enable Network Policies** for pod isolation
3. **Regular Updates** - keep k3s updated
4. **RBAC** - use proper role-based access control
5. **TLS** - ensure all communications are encrypted
6. **Audit Logging** - enable Kubernetes audit logs
7. **Pod Security** - use Pod Security Admission or Policies

## References

- [k3s Documentation](https://docs.k3s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Ansible Documentation](https://docs.ansible.com/)
