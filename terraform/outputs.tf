output "ollama_container_id" {
  description = "Ollama Docker container ID"
  value       = docker_container.ollama.id
}

output "nginx_container_id" {
  description = "Nginx proxy container ID"
  value       = docker_container.nginx.id
}

output "cloudflare_dns_record" {
  description = "Cloudflare DNS record hostname"
  value       = cloudflare_record.homeserver.hostname
}
