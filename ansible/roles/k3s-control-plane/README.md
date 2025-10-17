# k3s-control-plane

Ansible role for deploying a k3s Kubernetes control plane node on Debian systems.

## Description

This role installs and configures k3s as a Kubernetes control plane node. It handles the complete setup including:
- System prerequisites and kernel parameters
- k3s installation and configuration
- Embedded etcd setup for HA (optional)
- Kubeconfig management
- Optional kubectl and helm installation
- NFS mounts for persistent storage (optional)

## Requirements

- Debian-based system
- Root or sudo access
- Python 3.x
- Ansible 2.10+

## Role Variables

### Required Variables

None - all variables have sensible defaults.

### Important Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_version` | `stable` | k3s version to install (stable, latest, or specific version) |
| `k3s_channel` | `stable` | k3s installation channel |
| `k3s_token` | auto-generated | Token for joining nodes (should be set in vault) |
| `k3s_embedded_etcd` | `true` | Enable embedded etcd for HA |
| `k3s_cluster_cidr` | `10.42.0.0/16` | Pod network CIDR |
| `k3s_service_cidr` | `10.43.0.0/16` | Service network CIDR |
| `k3s_flannel_backend` | `vxlan` | Flannel backend (vxlan, host-gw, wireguard-native, ipsec) |

### Optional Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `k3s_tls_san` | `[]` | Additional TLS SANs for API server certificate |
| `k3s_disable_components` | `[]` | Components to disable (traefik, servicelb, etc.) |
| `k3s_node_labels` | `[]` | Node labels to apply |
| `k3s_node_taints` | `[]` | Node taints to apply |
| `k3s_server_args` | `[]` | Additional arguments for k3s server |
| `k3s_install_kubectl` | `true` | Install kubectl symlink |
| `k3s_install_helm` | `false` | Install helm package manager |
| `k3s_nfs_mounts` | `[]` | NFS mounts for persistent storage |

See `defaults/main.yml` for the complete list of variables.

## Dependencies

- `base` role (automatically included via meta/main.yml)

## Example Playbook

```yaml
---
- name: Kubernetes Control Plane
  hosts: kubernetes_control_plane
  become: true
  vars_files:
    - "inventory/host_variables/{{ ansible_host }}.yml"
  roles:
    - base
    - k3s-control-plane
```

## Example Host Variables

Create a file in `inventory/host_variables/` for your control plane node:

```yaml
---
# inventory/host_variables/10.174.12.176.yml

# k3s configuration
k3s_version: v1.28.3+k3s1
k3s_token: "{{ vault_k3s_token }}"  # Store in vault

# Additional TLS SANs
k3s_tls_san:
  - "k8s.example.com"
  - "10.174.12.176"
  - "k8s12-001.local"

# Disable default components
k3s_disable_components:
  - traefik
  - servicelb

# Enable wireguard for encrypted pod networking
k3s_flannel_backend: wireguard-native

# Install tools
k3s_install_kubectl: true
k3s_install_helm: true

# NFS storage for persistent volumes
k3s_nfs_mounts:
  - server: 10.174.12.127
    remote_path: /mnt/storage/k8s
    local_path: /mnt/k8s-storage
    options: rw,sync
```

## Usage

### Deploy Control Plane

```bash
ansible-playbook -i inventory/hosts.yml kubernetes-control-plane.yml
```

### Access the Cluster

After deployment, you can access the cluster from the control plane node:

```bash
# As root
kubectl get nodes

# For non-root users, copy the kubeconfig
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
export KUBECONFIG=~/.kube/config
```

### Join Worker Nodes

The node token is stored in `/var/lib/rancher/k3s/server/node-token` and displayed during playbook execution. Use this token to join worker nodes.

## High Availability

For HA setup with multiple control plane nodes:

1. Set `k3s_embedded_etcd: true` (default)
2. Deploy the first control plane node
3. On subsequent nodes, set `k3s_server_url` to point to the first node
4. Use the same `k3s_token` for all nodes

## Security Considerations

- Store `k3s_token` in Ansible Vault
- Restrict `k3s_write_kubeconfig_mode` appropriately
- Use TLS SANs for all API server endpoints
- Consider network policies for pod isolation
- Regular updates via `k3s_version` or `k3s_channel`

## Troubleshooting

### Check k3s status
```bash
sudo systemctl status k3s
```

### View k3s logs
```bash
sudo journalctl -u k3s -f
```

### Verify cluster is ready
```bash
sudo k3s kubectl get nodes
sudo k3s kubectl get pods -A
```

## Author

Created following established patterns in the homelab repository.
