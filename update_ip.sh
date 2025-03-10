#!/bin/bash

# Run Terraform to apply the changes and get the IP output
terraform apply -auto-approve

# Capture the IP address from Terraform's output
INSTANCE_IP=$(terraform output -raw instance_ip)

# Verify if the IP was captured successfully
if [[ -z "$INSTANCE_IP" ]]; then
    echo "Failed to retrieve the instance IP. Please check Terraform configuration."
    exit 1
fi

# Update the inventory.ini file with the new IP
echo "[aws_servers]" > inventory.ini
echo "$INSTANCE_IP ansible_user=ec2-user ansible_ssh_private_key_file=my-key-pair.pem" >> inventory.ini

echo "Inventory file updated with IP: $INSTANCE_IP"
