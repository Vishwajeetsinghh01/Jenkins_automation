provider "aws" {
  region = "us-east-1"
}

# 1. Create a Security Group (Firewall)
resource "aws_security_group" "splunk_sg" {
  name        = "splunk_sg"
  description = "Allow SSH and Splunk traffic"

  # Allow SSH (Port 22) so Jenkins can connect
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Splunk Web (Port 8000) so you can access it later
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outgoing traffic (required for downloading updates)
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
  
  # 2. Attach the Security Group we created above
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]

  # 3. Attach YOUR specific Key Pair
  # (AWS usually names the key without the .pem extension)
  key_name = "Vishwajeetsingh" 
  
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