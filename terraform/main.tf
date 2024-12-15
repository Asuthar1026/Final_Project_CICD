# Specify the AWS Provider
provider "aws" {
  region = "us-east-1" # Replace with your preferred region
}

# Key Pair (for SSH access)
resource "aws_key_pair" "my_key" {
  key_name   = "ec2-key"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public SSH key
}

# Security Group
resource "aws_security_group" "node_sg" {
  name        = "node-sg"
  description = "Allow SSH and Node.js traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (use restricted IPs in production)
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow Node.js traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "node_app" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (change based on region)
  instance_type = "t2.micro"              # Free-tier eligible
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [
    aws_security_group.node_sg.name
  ]

  # User Data Script (Startup Script to Configure EC2)
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
              sudo yum install -y nodejs git
              git clone https://github.com/YourGitHubUsername/simple-node-api.git
              cd simple-node-api
              npm install
              nohup node index.js > output.log 2>&1 &
              EOF

  tags = {
    Name = "NodeApp"
  }
}

# Output EC2 Public IP
output "ec2_public_ip" {
  value = aws_instance.node_app.public_ip
}
