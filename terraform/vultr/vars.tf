variable "vultr_api_key" {
  type        = string
  description = "Vultr API key"
}
variable "ssh_key_name" {
  type = string
  description = "SSH key name"
}
variable "user_ssh_public_key" {
  type = string
  description = "SSH public key"
}
variable "my_snapshot_url" {
  type = string
  description = "Snapshot url"
}