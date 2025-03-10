provider "aws" {
  region = "eu-west-1"  # Change to your desired AWS region
}

# Define a Security Group with a unique name or check if it exists
resource "aws_security_group" "vm_sg" {
  # Dynamically generate a unique name by using a timestamp to avoid duplicates
  name        = "vm_security_group_${timestamp()}"
  description = "Allow SSH and HTTP access"

  # Allow SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress (Allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Data source to fetch an existing key pair from your AWS account
data "aws_key_pair" "existing_key" {
  key_name = "key"  # Replace with your existing key pair name
}

# EC2 Instance using the key pair and security group
resource "aws_instance" "vm" {
  ami           = "ami-03fd334507439f4d1"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.existing_key.key_name   # Reference the existing key pair

  # Associate the EC2 instance with the security group
  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  tags = {
    Name = "TerraformVM"
  }
}

# Output the public IP of the EC2 instance
output "vm_ip" {
  value = aws_instance.vm.public_ip
}

# Save the public IP to a .txt file on apply
resource "local_file" "output_ip" {
  content  = aws_instance.vm.public_ip
  filename = "${path.module}/vm_ip.txt"
}
