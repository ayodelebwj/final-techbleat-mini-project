# configure terraform backend

#======================================================================
#CONFIGURES BACKEND FOR TERRAFORM STATEFILE
#======================================================================
terraform {
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.region
}

#======================================================================
#JENKINS SG RESOURCE BLOCK TO ALLOW PORTS 22 AND 8080
#======================================================================
# Jenkins Security group resource block to allow SSH and TCP port 8080
resource "aws_security_group" "jenkins_sg" {
  name        = var.security_group_name
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = var.security_group_ingress_ssh_port
    to_port     = var.security_group_ingress_ssh_port
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  ingress {
    description = "JENKINS PORT"
    from_port   = var.security_group_ingress_jenkins_port
    to_port     = var.security_group_ingress_jenkins_port
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.security_group_cidr_block]
  }
}

#======================================================================
#RETRIEVES UBUNTU AMI FROM AWS STORE TO PROVISION JENKINS INSTANCE
#======================================================================
#Retrieves ubuntu ami from AWS store to provision Jenkins instance
data "aws_ssm_parameter" "ubuntu_2404_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

#==========================================================================
#FILTERS UBUNTU AMI ID FROM SSM PARAMETER FOR JENKINS INSTANCE PROVISIONING
#==========================================================================
data "aws_ami" "ubuntu_2404" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_2404_ami.value]
  }
}

#======================================================
#JENKINS SERVER EC2 RESOURCE BLOCK
#======================================================
resource "aws_instance" "jenkins_instance" {
  ami             = data.aws_ami.ubuntu_2404.id
  instance_type   = var.jenkins_server_instance_type
  key_name        = var.jenkins_server_key_name
  security_groups = [aws_security_group.jenkins_sg.name]
  user_data       = file("./importantbinaries.sh")

  tags = {
    Name = var.jenkins_server_tag_name
  }
}