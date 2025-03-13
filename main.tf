provider "aws" {
  region = "eu-west-1"
}

# Fetch existing instances to avoid duplicates
data "aws_instances" "existing_instances" {
  instance_state_names = ["running", "pending"]
  filter {
    name   = "tag:Name"
    values = ["TerraformVM"]
  }
}

# Terminate previous instances before creating a new one
resource "null_resource" "terminate_old_instance" {
  count = length(data.aws_instances.existing_instances.ids) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${join(" ", data.aws_instances.existing_instances.ids)}"
  }
}

# Define Security Group
resource "aws_security_group" "vm_sg" {
  name        = "vm_security_group_${timestamp()}"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_key_pair" "existing_key" {
  key_name = "my-key-pair"
}

# EC2 Instance
resource "aws_instance" "vm" {
  ami           = "ami-03fd334507439f4d1"
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.existing_key.key_name

  vpc_security_group_ids = [aws_security_group.vm_sg.id]

  tags = {
    Name = "TerraformVM"
  }

  depends_on = [null_resource.terminate_old_instance]  # Ensure old instances are terminated before creating a new one
}

output "vm_ip" {
  value = aws_instance.vm.public_ip
}

resource "local_file" "output_ip" {
  content  = aws_instance.vm.public_ip
  filename = "${path.module}/vm_ip.txt"
}
