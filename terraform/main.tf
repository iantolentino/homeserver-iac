terraform {
  required_version = ">= 1.7.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  # Store state locally — swap to S3/Terraform Cloud later if needed
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "docker" {
  host = "ssh://${var.server_user}@${var.server_ip}:22"

  ssh_opts = [
    "-i", "~/.ssh/id_rsa",
    "-o", "StrictHostKeyChecking=no"
  ]
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ─── Docker network ───────────────────────────────────────────────────────────

resource "docker_network" "homeserver" {
  name = "homeserver_net"
}

# ─── Ollama (local LLM) ───────────────────────────────────────────────────────

resource "docker_image" "ollama" {
  name = "ollama/ollama:latest"
}

resource "docker_container" "ollama" {
  name  = "ollama"
  image = docker_image.ollama.image_id

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.homeserver.name
  }

  ports {
    internal = 11434
    external = 11434
  }

  volumes {
    host_path      = "/opt/homeserver/ollama"
    container_path = "/root/.ollama"
  }
}

# ─── Nginx reverse proxy ──────────────────────────────────────────────────────

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "nginx" {
  name  = "nginx_proxy"
  image = docker_image.nginx.image_id

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.homeserver.name
  }

  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path      = "/opt/homeserver/nginx/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
}

# ─── Cloudflare DNS record ────────────────────────────────────────────────────

resource "cloudflare_record" "homeserver" {
  zone_id = var.cloudflare_zone_id
  name    = "home"
  value   = var.server_ip
  type    = "A"
  ttl     = 1
  proxied = true
}
