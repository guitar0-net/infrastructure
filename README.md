<!--
SPDX-FileCopyrightText: 2026 Andrey Kotlyar <guitar0.app@gmail.com>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Guitar0 infrastructure

[![License](https://img.shields.io/badge/license-AGPL--3.0--or--later-green.svg)](./LICENSES/AGPL-3.0-or-later.txt)
[![REUSE status](https://api.reuse.software/badge/github.com/guitar0-net/infrastructure)](https://api.reuse.software/info/github.com/guitar0-net/infrastructure)

Ansible playbooks for deploying the [Guitar0](https://guitar0.net) platform: backend (Django), frontend (Next.js), and observability stack (Prometheus · Grafana · Loki).

## Prerequisites

- Ansible 2.17+
- `ansible-vault` password for secrets

```bash
pip install ansible
ansible-galaxy install -r ansible/requirements.yml
```

## Structure

```
ansible/
  inventory/
    staging.yml          # staging hosts
    production.yml       # production hosts
    group_vars/
      all.yml            # shared variables
      staging/           # staging overrides + vault
      production/        # production overrides + vault
  playbooks/
    setup.yml            # one-time server setup
    deploy-backend.yml
    deploy-frontend.yml
    monitoring.yml
    rollback-backend.yml
    rollback-frontend.yml
    backup-backend.yml
  roles/
    common/              # packages, Docker, nginx, firewall, certbot
    backend/
    frontend/
    monitoring/
observability/           # Prometheus rules, Grafana dashboards
```

## Usage

```bash
make setup                                    # one-time server setup (staging)
make deploy VERSION=1.2.3                     # deploy backend + frontend
make deploy-backend VERSION=1.2.3             # backend only
make rollback-backend                         # rollback to previous version
make backup                                   # backup database

make setup INVENTORY=production               # target production
make vault-edit INVENTORY=production          # edit production secrets
```

Run `make help` to list all commands.

## License

[GNU Affero General Public License v3.0 or later](./LICENSES/AGPL-3.0-or-later.txt).
All source files carry SPDX headers and are [REUSE compliant](https://reuse.software).
