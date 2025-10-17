.PHONY: help init plan apply destroy validate fmt clean check-kubeconfig

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-kubeconfig: ## Verify kubectl access to the cluster
	@echo "Checking Kubernetes connectivity..."
	@kubectl cluster-info
	@kubectl get nodes

init: check-kubeconfig ## Initialize Terraform
	terraform init

validate: ## Validate Terraform configuration
	terraform validate

fmt: ## Format Terraform files
	terraform fmt -recursive

plan: validate ## Show Terraform execution plan
	terraform plan

apply: validate ## Apply Terraform configuration
	terraform apply

apply-auto: validate ## Apply without confirmation (use with caution)
	terraform apply -auto-approve

destroy: ## Destroy all Terraform-managed resources
	terraform destroy

destroy-auto: ## Destroy without confirmation (use with caution)
	terraform destroy -auto-approve

clean: ## Remove Terraform state and cache
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*

show: ## Show current Terraform state
	terraform show

output: ## Display Terraform outputs
	terraform output

logs: ## Show Jenkins logs
	kubectl logs -f deployment/jenkins -n devops-tools

get-password: ## Get Jenkins initial admin password
	@echo "Getting Jenkins initial admin password..."
	@kubectl exec -it -n devops-tools deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword

helm-status: ## Show Helm release status
	helm status jenkins -n devops-tools

helm-values: ## Show current Helm values
	helm get values jenkins -n devops-tools

helm-upgrade: ## Upgrade Jenkins Helm release
	helm upgrade jenkins jenkins/jenkins -n devops-tools -f helm-values.yaml

restart: ## Restart Jenkins deployment
	kubectl rollout restart deployment/jenkins -n devops-tools

status: ## Show Jenkins deployment status
	@echo "=== Namespace ==="
	@kubectl get namespace devops-tools
	@echo ""
	@echo "=== Deployment ==="
	@kubectl get deployment jenkins -n devops-tools
	@echo ""
	@echo "=== Pods ==="
	@kubectl get pods -n devops-tools
	@echo ""
	@echo "=== Service ==="
	@kubectl get service jenkins-service -n devops-tools
	@echo ""
	@echo "=== Ingress ==="
	@kubectl get ingress jenkins-ingress -n devops-tools
	@echo ""
	@echo "=== PV & PVC ==="
	@kubectl get pv,pvc -n devops-tools

debug: ## Show detailed debug information
	@echo "=== Pod Details ==="
	@kubectl describe pod -l app=jenkins-server -n devops-tools
	@echo ""
	@echo "=== Recent Events ==="
	@kubectl get events -n devops-tools --sort-by='.lastTimestamp' | tail -20

port-forward: ## Forward Jenkins port to localhost:8080
	@echo "Forwarding Jenkins to http://localhost:8080"
	@kubectl port-forward -n devops-tools service/jenkins-service 8080:8080
