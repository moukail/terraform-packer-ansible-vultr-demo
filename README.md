#### Step 1: Build RAW image with Packer
```bash
packer init .
packer build .
```

#### Step 2: Make a tunnel in Cloudflare and publish the RAW image with nginx
https://registry.terraform.io/providers/cloudflare/cloudflare/latest
```bash
cd cloudflare
terraform init -upgrade
terraform plan -out ./cloudflare_plan
terraform apply "./cloudflare_plan"

docker compose up --build -d
```

#### Step 3: Create an instance in Vultr with a snapshot
```bash
terraform init -upgrade
terraform plan -out ./terraform_plan
terraform apply "./terraform_plan"
```

#### Step 4: test connection
```bash
ssh -i ~/id_ed25519 admin@ip-address
```

#### Step 5: Delete Snapshot
```bash
terraform state rm vultr_snapshot_from_url.my_snapshot
```

#### Step 6: 
```bash
terraform destroy
```

#### Snapshots from Url can be imported using the Snapshot ID, e.g.
```bash
terraform import vultr_snapshot_from_url.my_snapshot 119d3524-96ff-4091-9df6-c3d9bcdbea93
terraform refresh && terraform state show vultr_snapshot_from_url.my_snapshot
```
