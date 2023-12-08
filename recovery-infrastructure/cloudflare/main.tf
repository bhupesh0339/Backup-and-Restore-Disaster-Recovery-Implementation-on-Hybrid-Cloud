provider "cloudflare" {
  api_token = var.cloudflare-api-token
}
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.19.0"
    }
  }
}
resource "cloudflare_record" "domain" {
  zone_id         = var.cloudflare-zone-id
  name            = var.cloudflare-domain-name
  value           = var.cloudflare-ipv4-address
  type            = "A"
  ttl             = "60"
}