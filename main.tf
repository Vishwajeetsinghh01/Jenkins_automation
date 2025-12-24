provider "aws" {
  region = "us-east-1"
}

# 1. Create a Security Group (Firewall)
resource "aws_security_group" "splunk_sg" {
  name        = "splunk_sg"
  description = "Allow SSH and Splunk traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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

resource "aws_instance" "my_server" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]
  key_name = "Vishwajeetsingh"

  # <--- NEW PART: Install Python 3.8 on boot --->
  user_data = <<-EOF
              #!/bin/bash
              amazon-linux-extras install python3.8 -y
              EOF
  
  tags = {
    Name = "Splunk-Server"
  }
}

output "instance_public_ip" {
  value = aws_instance.my_server.public_ip
}

output "instance_id" {
  value = aws_instance.my_server.id
}