.PHONY: init plan apply destroy fmt validate help run-all all-plan all-apply clean

ENVIRONMENT ?= prod
ENVIRONMENT_PATH = environments/$(ENVIRONMENT)
MODULE ?= 

help:
	@echo "╔═══════════════════════════════════════════════════════════════════════╗"
	@echo "║            Terragrunt Multi-Module Infrastructure                     ║"
	@echo "║                  Tandoor Recipes Deployment                           ║"
	@echo "╚═══════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "DEPLOYMENT WORKFLOWS"
	@echo "━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "Full Stack Deployment (Recommended):"
	@echo "  make ENVIRONMENT=dev all-plan"
	@echo "    → Reviews planned changes for all modules in dependency order"
	@echo ""
	@echo "  make ENVIRONMENT=dev all-apply"
	@echo "    → Deploys all modules in dependency order non-interactively"
	@echo "    → Order: namespace → ingress/storage → database → application"
	@echo ""
	@echo "Interactive Deployment (Review Changes):"
	@echo "  make ENVIRONMENT=dev init     # Initialize all modules"
	@echo "  make ENVIRONMENT=dev plan     # Review changes across all modules"
	@echo "  make ENVIRONMENT=dev apply    # Apply with prompts for each module"
	@echo ""
	@echo "Individual Module Deployment:"
	@echo "  make ENVIRONMENT=dev MODULE=namespace apply"
	@echo "  make ENVIRONMENT=dev MODULE=ingress apply"
	@echo "  make ENVIRONMENT=dev MODULE=storage apply"
	@echo "  make ENVIRONMENT=dev MODULE=database apply"
	@echo "  make ENVIRONMENT=dev MODULE=application apply"
	@echo "    → Deploys specific module only (dependencies must exist)"
	@echo ""
	@echo "AVAILABLE COMMANDS"
	@echo "━━━━━━━━━━━━━━━━━━"
	@echo "  init       Initialize Terragrunt/Terraform"
	@echo "  plan       Generate and display execution plan"
	@echo "  apply      Apply infrastructure changes"
	@echo "  destroy    Destroy infrastructure (reverse dependency order)"
	@echo "  all-plan   Plan all modules in dependency order"
	@echo "  all-apply  Apply all modules in dependency order (non-interactive)"
	@echo "  run-all    Alias for all-apply (deprecated, use all-apply)"
	@echo "  fmt        Format all Terraform code"
	@echo "  validate   Validate Terraform configuration"
	@echo "  clean      Remove Terragrunt cache directories"
	@echo ""
	@echo "VARIABLES"
	@echo "━━━━━━━━━"
	@echo "  ENVIRONMENT  Target environment (default: prod)"
	@echo "               Options: dev, prod"
	@echo "  MODULE       Target specific module (default: all modules)"
	@echo "               Options: namespace, ingress, storage, database, application"
	@echo ""
	@echo "EXAMPLES"
	@echo "━━━━━━━━"
	@echo "  # Plan all dev modules"
	@echo "  make ENVIRONMENT=dev all-plan"
	@echo ""
	@echo "  # Deploy entire dev stack (non-interactive)"
	@echo "  make ENVIRONMENT=dev all-apply"
	@echo ""
	@echo "  # Update only the application module in prod"
	@echo "  make ENVIRONMENT=prod MODULE=application apply"
	@echo ""
	@echo "  # Plan changes for all prod modules"
	@echo "  make ENVIRONMENT=prod plan"
	@echo ""
	@echo "  # Destroy dev environment"
	@echo "  make ENVIRONMENT=dev destroy"
	@echo ""
	@echo "MODULE DEPENDENCY GRAPH"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  namespace (base: namespace, secrets, config)"
	@echo "      ├── ingress (Traefik via Helm)"
	@echo "      ├── storage (NFS PV/PVCs for media, static, postgres)"
	@echo "      │   └── database (PostgreSQL StatefulSet)"
	@echo "      │       └── application (Tandoor + nginx sidecar)"
	@echo "      └── application (also depends on ingress)"
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
	@echo "  1. namespace  → Kubernetes namespace, secrets, SSM config"
	@echo "  2. ingress    → Traefik ingress controller + CRDs"
	@echo "  3. storage    → NFS PVs/PVCs (media, static, postgres)"
	@echo "  4. database   → PostgreSQL StatefulSet (Bitnami)"
	@echo "  5. application→ Tandoor deployment with nginx sidecar"
	@echo ""
	cd $(ENVIRONMENT_PATH) && terragrunt run-all plan

all-apply:
	@echo "╔═══════════════════════════════════════════════════════════════════════╗"
	@echo "║  Applying all modules in dependency order for $(ENVIRONMENT) environment"
	@echo "╚═══════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Deployment order:"
	@echo "  1. namespace  → Kubernetes namespace, secrets, SSM config"
	@echo "  2. ingress    → Traefik ingress controller + CRDs"
	@echo "  3. storage    → NFS PVs/PVCs (media, static, postgres)"
	@echo "  4. database   → PostgreSQL StatefulSet (Bitnami)"
	@echo "  5. application→ Tandoor deployment with nginx sidecar"
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
