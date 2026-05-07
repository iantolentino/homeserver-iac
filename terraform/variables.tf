variable "server_ip" {
  description = "IP address of your homeserver"
  type        = string
}

variable "server_user" {
  description = "SSH user on homeserver"
  type        = string
  default     = "ian"
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token (from GitHub secret)"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for your domain"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Your domain name"
  type        = string
}
