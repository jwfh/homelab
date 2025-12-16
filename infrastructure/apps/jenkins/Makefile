# Jenkins Terraform Makefile
#
# This Makefile provides targets for managing Jenkins infrastructure
# using Terragrunt with environment-based deployments.
#
# Structure:
#   environments/
#     prod/
#       namespace/     - Kubernetes namespace and RBAC
#       storage/       - NFS PV/PVC for Jenkins controller
#       application/   - Jenkins Helm release with JCasC
#   src/
#     modules/
#       namespace/     - Namespace and RBAC resources
#       storage/       - NFS storage configuration
#       application/   - Jenkins Helm chart deployment

.PHONY: help init plan apply destroy all-plan all-apply run-all fmt validate clean status logs

# Default environment (can be overridden: make ENVIRONMENT=staging plan)
ENVIRONMENT ?= prod

# Optional: specify a single module to operate on
MODULE ?=

# Base paths
ENVIRONMENT_PATH := environments/$(ENVIRONMENT)

help:
	@echo ""
	@echo "╔═══════════════════════════════════════════════════════════════════════╗"
	@echo "║                   Jenkins Infrastructure Management                   ║"
	@echo "╠═══════════════════════════════════════════════════════════════════════╣"
	@echo "║  Modules: namespace, storage, application                             ║"
	@echo "╚═══════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "USAGE"
	@echo "━━━━━"
	@echo "  make [target] ENVIRONMENT=<env> [MODULE=<module>]"
	@echo ""
	@echo "ENVIRONMENT VALUES"
	@echo "━━━━━━━━━━━━━━━━━━"
	@echo "  prod (default)"
	@echo ""
	@echo "TARGETS"
	@echo "━━━━━━━"
	@echo "  init       Initialize Terragrunt (downloads providers, modules)"
	@echo "  plan       Show planned changes (dry-run)"
	@echo "  apply      Apply changes to infrastructure"
	@echo "  destroy    Destroy infrastructure"
	@echo "  all-plan   Plan all modules in dependency order"
	@echo "  all-apply  Apply all modules in dependency order"
	@echo "  fmt        Format Terraform code"
	@echo "  validate   Validate Terraform configuration"
	@echo "  clean      Remove Terragrunt cache directories"
	@echo "  status     Show Jenkins deployment status"
	@echo "  logs       Show Jenkins controller logs"
	@echo ""
	@echo "EXAMPLES"
	@echo "━━━━━━━━"
	@echo "  # Plan all modules in prod (default)"
	@echo "  make plan"
	@echo ""
	@echo "  # Apply all modules in prod"
	@echo "  make ENVIRONMENT=prod all-apply"
	@echo ""
	@echo "  # Update only the application module"
	@echo "  make ENVIRONMENT=prod MODULE=application apply"
	@echo ""
	@echo "  # Destroy prod environment"
	@echo "  make ENVIRONMENT=prod destroy"
	@echo ""
	@echo "MODULE DEPENDENCY GRAPH"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  namespace (Kubernetes namespace and RBAC)"
	@echo "      └── storage (NFS PV/PVC for Jenkins controller)"
	@echo "          └── application (Helm release with JCasC)"
	@echo ""

init:
	@echo "Initializing Terragrunt for $(ENVIRONMENT) environment..."
ifeq ($(MODULE),)
	cd $(ENVIRONMENT_PATH) && terragrunt run-all init
else
	cd $(ENVIRONMENT_PATH)/$(MODULE) && terragrunt init
endif

plan:
	@echo "Planning Terraform changes for $(ENVIRONMENT) environment..."
ifeq ($(MODULE),)
	cd $(ENVIRONMENT_PATH) && terragrunt run-all plan
else
	cd $(ENVIRONMENT_PATH)/$(MODULE) && terragrunt plan
endif

apply:
	@echo "Applying Terraform changes for $(ENVIRONMENT) environment..."
ifeq ($(MODULE),)
	cd $(ENVIRONMENT_PATH) && terragrunt run-all apply
else
	cd $(ENVIRONMENT_PATH)/$(MODULE) && terragrunt apply
endif

destroy:
	@echo "Destroying infrastructure for $(ENVIRONMENT) environment..."
ifeq ($(MODULE),)
	cd $(ENVIRONMENT_PATH) && terragrunt run-all destroy
else
	cd $(ENVIRONMENT_PATH)/$(MODULE) && terragrunt destroy
endif

all-plan:
	@echo "╔═══════════════════════════════════════════════════════════════════════╗"
	@echo "║  Planning all modules in dependency order for $(ENVIRONMENT) environment"
	@echo "╚═══════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Modules to plan:"
	@echo "  1. namespace   → Kubernetes namespace and RBAC for Jenkins"
	@echo "  2. storage     → NFS PV/PVC for Jenkins controller"
	@echo "  3. application → Jenkins Helm chart with JCasC"
	@echo ""
	cd $(ENVIRONMENT_PATH) && terragrunt run-all plan

all-apply:
	@echo "╔═══════════════════════════════════════════════════════════════════════╗"
	@echo "║  Applying all modules in dependency order for $(ENVIRONMENT) environment"
	@echo "╚═══════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Deployment order:"
	@echo "  1. namespace   → Kubernetes namespace and RBAC for Jenkins"
	@echo "  2. storage     → NFS PV/PVC for Jenkins controller"
	@echo "  3. application → Jenkins Helm chart with JCasC"
	@echo ""
	cd $(ENVIRONMENT_PATH) && terragrunt run-all apply --terragrunt-non-interactive

run-all: all-apply
	@echo "Note: 'run-all' is deprecated. Use 'all-apply' instead."

fmt:
	@echo "Formatting Terraform code..."
	cd src && terraform fmt -recursive

validate:
	@echo "Validating Terraform configuration for $(ENVIRONMENT) environment..."
ifeq ($(MODULE),)
	cd $(ENVIRONMENT_PATH) && terragrunt run-all validate
else
	cd $(ENVIRONMENT_PATH)/$(MODULE) && terragrunt validate
endif

clean:
	@echo "Cleaning Terragrunt cache directories..."
	find $(ENVIRONMENT_PATH) -type d -name ".terragrunt-cache" -exec rm -rf {} + 2>/dev/null || true
	@echo "Cache cleaned."

status:
	@echo "=== Namespace ==="
	@kubectl get namespace prod-jenkins
	@echo ""
	@echo "=== Pods ==="
	@kubectl get pods -n prod-jenkins
	@echo ""
	@echo "=== Services ==="
	@kubectl get services -n prod-jenkins
	@echo ""
	@echo "=== Ingress ==="
	@kubectl get ingress -n prod-jenkins
	@echo ""
	@echo "=== PV & PVC ==="
	@kubectl get pv,pvc -n prod-jenkins
	@echo ""
	@echo "=== Helm Release ==="
	@helm status jenkins -n prod-jenkins 2>/dev/null || echo "Helm release not found"

logs:
	@kubectl logs -f -l app.kubernetes.io/name=jenkins -n prod-jenkins --all-containers
