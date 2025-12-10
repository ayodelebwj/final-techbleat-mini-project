# configure terraform backend
terraform {
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
}

# Configure the AWS provider
provider "aws" {
  region = "us-east-2"
}

# Jenkins Security group to allow SSH and TCP port 8080
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "JENKINS PORT"
    from_port   = 8080
    to_port     = 8080
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

#Retrieves ubuntu ami from AWS store to provision Jenkins instance
data "aws_ssm_parameter" "ubuntu_2404_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

# Filters ubuntu ami id from ssm parameter for instance provision
data "aws_ami" "ubuntu_2404" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_2404_ami.value]
  }
}

# EC2 instance 
resource "aws_instance" "jenkins_instance" {
  ami             = data.aws_ami.ubuntu_2404.id
  instance_type   = "c7i-flex.large"
  key_name        = "ohio-kp"
  security_groups = [aws_security_group.jenkins_sg.name]
  user_data       = file("./importantbinaries.sh")

  tags = {
    Name = "jenkins-Instance"
  }
}

#outputs Jenkins public ip
output "jenkins_instance_public_ip" {
  description = "public ip for the jenkins instance"
  value       = aws_instance.jenkins_instance.public_ip
}