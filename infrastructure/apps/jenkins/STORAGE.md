# HostPath Storage Configuration

This Jenkins deployment uses **hostPath** volumes instead of direct NFS mounting in Kubernetes.

## Architecture

```
Jenkins Pod → hostPath PV (/mnt/default/services/jenkins on worker node) → NFS mount on worker → ritchie NFS server
```

## Prerequisites

All Kubernetes worker nodes (and control plane if it runs workloads) must have the NFS share mounted at the same path:

```bash
# On each worker node
mount | grep /mnt/default/services
# Should show: ritchie:/mnt/default/services on /mnt/default/services type nfs4
```

This is configured via your Ansible playbook for worker nodes.

## Benefits of This Approach

1. **Bypasses Kubernetes NFS mount issues** - Let the host OS handle NFS
2. **Simpler troubleshooting** - Standard Linux NFS mount
3. **Better performance** - No double-mounting overhead
4. **Consistent with host mounts** - Uses your existing Ansible infrastructure

## Important Notes

### Node Affinity (Optional)

If your NFS mount is only on specific nodes, uncomment the node affinity section in `storage.tf` to ensure Jenkins pods only run on nodes with the mount:

```hcl
node_affinity {
  required {
    node_selector_term {
      match_expressions {
        key      = "kubernetes.io/hostname"
        operator = "In"
        values   = ["worker-node-hostname"]  # Replace with actual hostname
      }
    }
  }
}
```

### Checking Node Hostnames

```bash
kubectl get nodes -o wide
```

### Storage Class

The `local-storage` storage class is created with:
- `volumeBindingMode: WaitForFirstConsumer` - PV binding waits until pod is scheduled
- `no-provisioner` - Manual PV management (our Terraform creates the PV)

## Verification

### 1. Check NFS Mount on Worker Nodes

```bash
# On each worker node
ssh user@worker-node
mount | grep /mnt/default/services
ls -la /mnt/default/services/jenkins
```

### 2. Check Kubernetes Resources

```bash
# Storage class
kubectl get storageclass local-storage

# PV should show Available or Bound
kubectl get pv jenkins-pv-volume

# PVC should show Bound
kubectl get pvc jenkins-pv-claim -n devops-tools

# Pod should be running
kubectl get pods -n devops-tools
```

### 3. Verify Jenkins Data

```bash
# From inside the pod
kubectl exec -it -n devops-tools deployment/jenkins -- ls -la /var/jenkins_home

# From the worker node hosting the pod
# Find which node the pod is on
kubectl get pod -n devops-tools -o wide

# SSH to that node
ssh user@worker-node
ls -la /mnt/default/services/jenkins
```

## Troubleshooting

### Pod Pending (No nodes available)

If you've enabled node affinity and the pod can't schedule:

```bash
kubectl describe pod -n devops-tools -l app.kubernetes.io/component=jenkins-controller
```

**Solution:** Update the node affinity in `storage.tf` with correct node hostname

### Permission Denied

```bash
# On the worker node hosting the pod
ls -la /mnt/default/services/jenkins

# Should show owner 1000:1000
# If not:
sudo chown -R 1000:1000 /mnt/default/services/jenkins
```

### Directory Not Found

```bash
# On worker node
sudo mkdir -p /mnt/default/services/jenkins
sudo chown 1000:1000 /mnt/default/services/jenkins
```

Or ensure your Ansible playbook has mounted the NFS share.

## Migration from NFS PV

If you previously had an NFS-based PV:

```bash
# Delete old resources
kubectl delete pvc jenkins-pv-claim -n devops-tools
kubectl delete pv jenkins-pv-volume

# Reapply Terraform
terraform apply
```

Data on the NFS server is preserved since the same path is used.

## Ansible Integration

Your Ansible playbook for worker nodes should include:

```yaml
- name: Ensure NFS client is installed
  apt:
    name: nfs-common
    state: present

- name: Create mount point
  file:
    path: /mnt/default/services
    state: directory
    mode: '0755'

- name: Mount NFS share
  mount:
    path: /mnt/default/services
    src: ritchie:/mnt/default/services
    fstype: nfs4
    opts: defaults
    state: mounted
```

This ensures all worker nodes have consistent NFS mounts.
