terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.33.2"
    }
  }
}

provider "vultr" {
  api_key     = var.vultr_api_key
  rate_limit  = 100
  retry_limit = 3
}

backend "s3" {}

resource "vultr_snapshot_from_url" "my_snapshot" {
  url      = var.my_snapshot_url
  use_uefi = false

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      VULTR_API_KEY = var.vultr_api_key
      SNAPSHOT_ID   = self.id
    }
    command = <<-EOT
      echo "Waiting for snapshot $SNAPSHOT_ID to complete..."
      while true; do
        STATUS=$(curl -s -H "Authorization: Bearer $VULTR_API_KEY" \
          "https://api.vultr.com/v2/snapshots/$SNAPSHOT_ID" | jq -r '.snapshot.status // "deleted"')
        echo "Snapshot status: $STATUS"
        if [ "$STATUS" = "complete" ]; then
          break
        elif [ "$STATUS" = "deleted" ] || [ "$STATUS" = "null" ]; then
          echo "Error: Snapshot failed to import and was removed by Vultr."
          exit 1
        fi
        sleep 15
      done
    EOT
  }
}

resource "vultr_ssh_key" "user_ssh_public_key" {
  name    = var.ssh_key_name
  ssh_key = var.user_ssh_public_key
}

resource "vultr_instance" "web" {
  plan   = "vc2-1c-1gb"
  region = "ams"
  #os_id = 159
  #iso_id  = vultr_iso_private.my_iso.id
  snapshot_id = vultr_snapshot_from_url.my_snapshot.id
  label       = "my-instance-label"
  tags        = ["my-instance-tag"]
  hostname    = "my-instance-hostname"
  backups     = "disabled"
  user_scheme = "limited"
  ssh_key_ids = [
    vultr_ssh_key.user_ssh_public_key.id
  ]
  activation_email = false
}

output "public_ip" {
  value = vultr_instance.web.main_ip
}