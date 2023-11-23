
output "domain_name" {
  value = cloudflare_record.domain.hostname
}