# homeserver-iac

Infrastructure as Code for Ian's homeserver — Terraform + Ansible + GitHub Actions CI/CD.  

## Stack

| Tool | Purpose |
|------|---------|
| Terraform | Provisions Docker containers + Cloudflare DNS |
| Ansible | Configures the server (packages, firewall, directories) |
| GitHub Actions | Runs both on every push to `main` |

## Pipeline flow

```
push to main
    │
    ├── terraform init → fmt → validate → plan → apply
    │       └── manages: Ollama container, Nginx proxy, Cloudflare DNS record
    │
    └── ansible playbook (after terraform succeeds)
            └── installs: Docker, UFW, fail2ban, directory structure, nginx config
```

## GitHub Secrets required

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|--------|-------|
| `SERVER_IP` | Your homeserver's IP address |
| `SERVER_USER` | SSH username (e.g. `ian`) |
| `SSH_PRIVATE_KEY` | Contents of your `~/.ssh/id_rsa` |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token with DNS edit permissions |
| `CLOUDFLARE_ZONE_ID` | Zone ID from your Cloudflare dashboard |
| `DOMAIN` | Your domain (e.g. `iantolentino.dev`) |

## Local setup (before pushing)

```bash
# 1. Generate SSH key for GitHub Actions (separate from your personal key)
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions_key

# 2. Copy public key to your homeserver
ssh-copy-id -i ~/.ssh/github_actions_key.pub ian@YOUR_SERVER_IP

# 3. Add the private key contents as the SSH_PRIVATE_KEY secret
cat ~/.ssh/github_actions_key
```

## Project structure

```
homeserver-iac/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── terraform/
│   ├── main.tf                 # Docker + Cloudflare resources
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── playbook.yml            # Entry point
│   └── roles/
│       └── homeserver/
│           ├── tasks/main.yml  # All provisioning steps
│           └── handlers/main.yml
└── README.md
```

## Running locally (optional)

```bash
# Terraform
cd terraform
terraform init
terraform plan
terraform apply

# Ansible
cd ansible
ansible-playbook -i inventory.ini playbook.yml -v
```
