# SPDX-FileCopyrightText: 2026 Andrey Kotlyar <guitar0.app@gmail.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

.PHONY: help install lint ping setup \
        deploy-backend deploy-frontend deploy \
        rollback-backend rollback-frontend \
        monitoring backup vault-edit

SHELL := /bin/bash

INVENTORY ?= staging
VERSION   ?= latest

ANSIBLE_CONFIG := ansible/ansible.cfg
export ANSIBLE_CONFIG

ANSIBLE := ansible-playbook -i ansible/inventory/$(INVENTORY).yml

# =============================================================================

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-24s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install Ansible and galaxy requirements
	pip install ansible ansible-lint
	ansible-galaxy install -r ansible/requirements.yml

lint: ## Run ansible-lint
	ansible-lint ansible/playbooks/

ping: ## Check SSH connectivity  (make ping INVENTORY=production)
	ansible all -i ansible/inventory/$(INVENTORY).yml -m ping

# =============================================================================
# Setup
# =============================================================================

setup: ## One-time server setup  (make setup INVENTORY=production)
	$(ANSIBLE) ansible/playbooks/setup.yml

# =============================================================================
# Deploy
# =============================================================================

deploy-backend: ## Deploy backend  (make deploy-backend VERSION=1.2.3)
	$(ANSIBLE) ansible/playbooks/deploy-backend.yml -e VERSION=$(VERSION)

deploy-frontend: ## Deploy frontend  (make deploy-frontend VERSION=1.2.3)
	$(ANSIBLE) ansible/playbooks/deploy-frontend.yml -e VERSION=$(VERSION)

deploy: deploy-backend deploy-frontend ## Deploy backend + frontend

# =============================================================================
# Rollback
# =============================================================================

rollback-backend: ## Rollback backend to previous version
	$(ANSIBLE) ansible/playbooks/rollback-backend.yml

rollback-frontend: ## Rollback frontend to previous version
	$(ANSIBLE) ansible/playbooks/rollback-frontend.yml

# =============================================================================
# Operations
# =============================================================================

monitoring: ## Deploy observability stack
	$(ANSIBLE) ansible/playbooks/monitoring.yml

backup: ## Backup backend database
	$(ANSIBLE) ansible/playbooks/backup-backend.yml

vault-edit: ## Edit secrets vault  (make vault-edit INVENTORY=production)
	ansible-vault edit ansible/inventory/group_vars/$(INVENTORY)/vault.yml
