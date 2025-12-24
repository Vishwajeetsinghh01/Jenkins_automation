# main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_server" {
  ami           = "ami-0c02fb55956c7d316" # Example Linux Image
  instance_type = "t2.micro"

  tags = {
    Name = "Splunk-Server"
  }
}

# IMPORTANT: We need these outputs for Task 1!
output "instance_public_ip" {
  value = aws_instance.my_server.public_ip
}

output "instance_id" {
  value = aws_instance.my_server.id
}