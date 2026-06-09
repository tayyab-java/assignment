# DevOps Engineering Technical Exercise — Makefile
# Top-level entry points. The candidate fills in the Terraform / ArgoCD / Helm pieces;
# the harness (`make verify`) is shipped as-is.

.PHONY: setup plan apply verify destroy clean help

# Path to the candidate's primary env. Override if your layout differs.
ENV_DIR ?= terraform/envs/local

help:
	@echo "Available targets:"
	@echo "  make setup     - check required tools are installed (does not install)"
	@echo "  make plan      - terraform plan in $(ENV_DIR)"
	@echo "  make apply     - terraform apply in $(ENV_DIR) (full bring-up)"
	@echo "  make verify    - run the full 16-check verification harness"
	@echo "  make destroy   - terraform destroy in $(ENV_DIR)"
	@echo "  make clean     - destroy + remove temp files"

setup:
	@for dir in terraform/envs/local terraform/envs/local-stage; do \
		if [ -f "$$dir/backend.hcl.example" ] && [ ! -f "$$dir/backend.hcl" ]; then \
			cp "$$dir/backend.hcl.example" "$$dir/backend.hcl"; \
		fi; \
		if [ -f "$$dir/terraform.tfvars.example" ] && [ ! -f "$$dir/terraform.tfvars" ]; then \
			cp "$$dir/terraform.tfvars.example" "$$dir/terraform.tfvars"; \
		fi; \
	done
	@bash verify/preflight.sh

plan:
	@cd $(ENV_DIR) && terraform init -backend-config=backend.hcl && terraform plan -out=tfplan

apply:
	@cd $(ENV_DIR) && terraform init -backend-config=backend.hcl && terraform apply -auto-approve -parallelism=3

verify:
	@bash verify/verify.sh

destroy:
	@cd $(ENV_DIR) && terraform destroy -auto-approve

clean: destroy
	@find . -name 'tfplan' -delete 2>/dev/null || true
	@find . -name '.terraform' -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name '.terraform.lock.hcl' -delete 2>/dev/null || true
	@rm -f *.kubeconfig 2>/dev/null || true
