#!/bin/bash
set -x

terraform init

terraform apply -lock=false -auto-approve
if [ $? = 1 ]; then  
  terraform destroy -lock=false -auto-approve
  exit 1
fi

# verificar dependencias (terraform, aws cli, jq)
# opções (deploy, update, delete)