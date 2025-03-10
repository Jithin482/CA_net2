
#!/bin/bash

# Get the public IP of the EC2 instance from Terraform output
INSTANCE_IP=$(terraform output -raw vm_ip)

# Check if the IP is available
if [ -z "$INSTANCE_IP" ]; then
  echo "Error: EC2 instance IP is not available."
  exit 1
fi

# Save the IP to a text file for use by other jobs
echo "$INSTANCE_IP" > instance_ip.txt
echo "EC2 Instance IP: $INSTANCE_IP"

# Export the IP for use in subsequent steps
export INSTANCE_IP
