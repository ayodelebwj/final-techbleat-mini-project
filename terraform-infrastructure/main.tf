# configure terraform backend
terraform {
  backend "s3" {
    bucket = "techbleatweek8"
    key = "env/dev/terraform.tfstate"
    region = "us-east-2"
    encrypt = true
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.region
}

# Java Security group  
resource "aws_security_group" "java_sg" {
  name        = var.java_machine_security_group_name
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  ingress {
    description = "JAVA PORT"
    from_port   = var.java_machine_ingress_port
    to_port     = var.java_machine_ingress_port
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

# Python Security Group
resource "aws_security_group" "python_sg" {
  name        = var.python_machine_security_group_name
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  ingress {
    description = "PYTHON PORT"
    from_port   = var.python_machine_ingress_port
    to_port     = var.python_machine_ingress_port
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

resource "aws_security_group" "web_sg" {
  name        = var.web_machine_security_group_name
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  ingress {
    description = "HTTP PORT"
    from_port   = 80
    to_port     = 80
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

# Retrieve JAVA AMI FROM CUSTOM AMI 
data "aws_ami" "java-ami" {

  filter {
    name   = "name"
    values = ["java-ami"]  
  }
}

# Retrieve PYTHON AMI FROM CUSTOM AMI
data "aws_ami" "python-ami" {

  filter {
    name   = "name"
    values = ["python-ami"]  
  }
}

# Retrieve WEB AMI FROM CREATED AMIS
data "aws_ami" "web-ami" {

  filter {
    name   = "name"
    values = ["web-ami"]  
  }
}

# CREATE Java instance
resource "aws_instance" "java_instance" {
  ami             = data.aws_ami.java-ami.id
  instance_type   = var.java_machine_instance_type             
  key_name        = var.java_machine_key_name             
  security_groups = [aws_security_group.java_sg.name]

  tags = {
    Name = var.java_machine_key_name
  }
}

# CREATE Python instance
resource "aws_instance" "python_instance" {
  ami             = data.aws_ami.python-ami.id
  instance_type   = var.python_machine_instance_type           
  key_name        = var.python_machine_key_name           
  security_groups = [aws_security_group.python_sg.name]

  tags = {
    Name = var.python_machine_tag_name
  }
}

#ACCESS A ROLE FOR WEBSERVER TO ACCESS EC2 RESOURCE
data "aws_iam_instance_profile" "web-server-role" {
  name = "techbleat"
}

# CREATE Web instance
resource "aws_instance" "web_instance" {
  ami             = data.aws_ami.web-ami.id
  instance_type   = var.web_machine_instance_type             
  key_name        = var.web_machine_key_name             
  security_groups = [aws_security_group.web_sg.name]
  iam_instance_profile = data.aws_iam_instance_profile.web-server-role.name

  tags = {
    Name = var.web_machine_tag_name
  }
}