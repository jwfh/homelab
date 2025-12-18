# Ollama Kubernetes Deployment

This directory contains Terraform/Terragrunt infrastructure-as-code for deploying [Ollama](https://ollama.ai/) to a Kubernetes cluster using the official Helm chart.

## Overview

Ollama is deployed with the following components:

- **Namespace**: Dedicated Kubernetes namespace (`prod-ollama`)
- **Storage**: NFS-backed persistent volume for models (64Gi)
- **Ollama**: Deployed via Helm chart with:
  - CPU-only mode (no GPU)
  - Traefik ingress with TLS
  - Persistent storage for downloaded models
  - Configuration from AWS SSM Parameter Store

## Architecture

```
prod-ollama namespace
├── Ollama Server (Deployment)
│   └── Models PVC → NFS PV (64Gi)
└── Ingress (Traefik)
    └── TLS Certificate
```

## Prerequisites

1. **Kubernetes Cluster**: K3s cluster with Traefik ingress controller
2. **NFS Server**: NFS storage with the following directory:
   - `/mnt/pool0/kubernetes/ollama/models`
3. **AWS SSM Parameter**: `/apps/prod/ollama/configuration` with the following structure:
   ```json
   {
     "app": {
       "domain_name": "ollama.jwfh.ca",
       "models": ["llama3.2:3b"]
     },
     "ingress": {
       "class_name": "traefik"
     },
     "nfs": {
       "server": "10.x.x.x",
       "models_path": "/mnt/pool0/kubernetes/ollama/models"
     }
   }
   ```
4. **Tools**:
   - Terragrunt >= 0.48.0
   - Terraform/OpenTofu >= 1.10.6
   - kubectl with kubeconfig at `~/.kube/k3s-config`
   - AWS CLI with profile `prod-apps-terraform-deployer`

## Module Structure

```
infrastructure/apps/ollama/
├── environments/
│   └── prod/
│       ├── backend.hcl         # AWS backend configuration
│       ├── namespace/          # Kubernetes namespace
│       ├── storage/            # NFS PV/PVC
│       └── application/        # Helm release
├── src/
│   └── modules/
│       ├── namespace/          # Namespace module
│       ├── storage/            # Storage module
│       └── application/        # Ollama Helm module
├── Makefile                    # Deployment automation
└── README.md
```

## Deployment

### Quick Start (Recommended)

```bash
# Deploy everything in dependency order
make ENVIRONMENT=prod all-apply
```

### Step-by-Step Deployment

```bash
# 1. Initialize all modules
make ENVIRONMENT=prod init

# 2. Review planned changes
make ENVIRONMENT=prod all-plan

# 3. Apply changes (with prompts)
make ENVIRONMENT=prod apply
```

### Individual Module Deployment

```bash
# Deploy specific modules
make ENVIRONMENT=prod MODULE=namespace apply
make ENVIRONMENT=prod MODULE=storage apply
make ENVIRONMENT=prod MODULE=application apply
```

## Configuration

### SSM Parameter Structure

The configuration is stored in AWS SSM Parameter Store at `/apps/prod/ollama/configuration`:

```json
{
  "app": {
    "domain_name": "ollama.jwfh.ca",
    "models": ["llama3.2:3b"]
  },
  "ingress": {
    "class_name": "traefik"
  },
  "nfs": {
    "server": "10.x.x.x",
    "models_path": "/mnt/pool0/kubernetes/ollama/models"
  }
}
```

### Models

Models are pulled automatically at container startup. You can configure which models to pull in the SSM parameter. Some CPU-friendly options:

- `llama3.2:1b` - Smallest, fastest
- `llama3.2:3b` - Good balance of speed and capability
- `qwen2.5:3b` - Alternative small model
- `qwen2.5:7b` - Larger, more capable

## Interacting with Ollama

Once deployed, you can interact with Ollama via:

### REST API

```bash
# Generate a response
curl https://ollama.jwfh.ca/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Hello, how are you?"
}'

# Chat completion
curl https://ollama.jwfh.ca/api/chat -d '{
  "model": "llama3.2:3b",
  "messages": [{"role": "user", "content": "Hello!"}]
}'

# List models
curl https://ollama.jwfh.ca/api/tags
```

### Python Client

```python
from ollama import Client

client = Client(host='https://ollama.jwfh.ca')
response = client.chat(model='llama3.2:3b', messages=[
    {'role': 'user', 'content': 'Hello!'}
])
print(response['message']['content'])
```

### JavaScript Client

```javascript
import { Ollama } from 'ollama';

const ollama = new Ollama({ host: 'https://ollama.jwfh.ca' });
const response = await ollama.chat({
  model: 'llama3.2:3b',
  messages: [{ role: 'user', content: 'Hello!' }]
});
console.log(response.message.content);
```

## Cleanup

```bash
# Destroy all resources
make ENVIRONMENT=prod destroy

# Clean Terragrunt cache
make clean
```

## Troubleshooting

### Pod Not Starting

Check pod events:
```bash
kubectl -n prod-ollama describe pod -l app.kubernetes.io/name=ollama
```

### Model Download Issues

Check logs:
```bash
kubectl -n prod-ollama logs -l app.kubernetes.io/name=ollama -f
```

### NFS Mount Issues

Verify NFS server is accessible:
```bash
showmount -e <nfs-server-ip>
```
