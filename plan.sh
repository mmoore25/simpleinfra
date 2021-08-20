echo terraform plan -var-file="$1.tfvars" -out infra.$1.tfplan
terraform plan -var-file="$1.tfvars" -out infra.$1.tfplan