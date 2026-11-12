terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Create a DNS record
resource "cloudflare_dns_record" "example_dns_record" {
  zone_id = ""
  name = "example.com"
  ttl = 3600
  type = "A"
  comment = "Domain verification record"
  content = "198.51.100.4"
  private_routing = true
  proxied = true
  settings = {
    ipv4_only = true
    ipv6_only = true
  }
  tags = ["owner:dns-team"]
}

resource "cloudflare_zone" "example_zone" {
  account = {
    id = ""
  }
  name = "example.com"
  type = "full"
}

resource "cloudflare_zone_dnssec" "example_zone_dnssec" {
  zone_id = ""
  dnssec_multi_signer = false
  dnssec_presigned = true
  dnssec_use_nsec3 = false
  status = "active"
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "example_zero_trust_tunnel_cloudflared" {
  account_id = ""
  name = "blog"
  config_src = "cloudflare"
  tunnel_secret = ""
}