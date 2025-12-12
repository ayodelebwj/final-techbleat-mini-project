#!/bin/bash
#========================================
#THIS COMMANDS CREATES THE JENKINS SERVER
#========================================
terraform init
terraform fmt
terraform validate
terraform plan -var-file="values.tfvars"
terraform apply -var-file="values.tfvars" --auto-approve