# configure terraform backend
terraform {
  backend "s3" {
    bucket  = "techbleatweek8"
    key     = "env/dev/terraform.tfstate"
    region  = "us-east-2"
    encrypt = true
  }
}

# Configure the AWS provider
provider "aws" {
  region = var.region
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

#ROLE FOR EC2 RESOURCE ACCESS
data "aws_iam_instance_profile" "web-server-role" {
  name = "techbleat"
}


data "aws_vpc" "techbleat-vpc" {
  filter {
    name   = "tag:Name"
    values = ["techbleatvpc"]
  }
}

#Retrieve Public Subnet
data "aws_subnet" "public-1" {
  filter {
    name   = "tag:Name"
    values = ["public_1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techbleat-vpc.id]
  }
}

#Retrieve Private Subnet
data "aws_subnet" "private-1" {
  filter {
    name   = "tag:Name"
    values = ["private_1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.techbleat-vpc.id]
  }
}

#Retrieve Web Security Group
data "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = data.aws_vpc.techbleat-vpc.id
}

#Retrieve Python Security Group
data "aws_security_group" "python_sg" {
  name   = "python-sg"
  vpc_id = data.aws_vpc.techbleat-vpc.id
}

#Retrieve DB Security Group
data "aws_security_group" "db_sg" {
  name   = "postgres-sg"
  vpc_id = data.aws_vpc.techbleat-vpc.id
}


# Create Python Server
resource "aws_instance" "python_instance" {
  ami                     = data.aws_ami.python-ami.id
  instance_type           = var.python_machine_instance_type
  key_name                = var.python_machine_key_name
  security_groups         = [data.aws_security_group.python_sg.id]
  subnet_id               = data.aws_subnet.private-1.id
  iam_instance_profile    = data.aws_iam_instance_profile.web-server-role.name


  tags = {
    Name = var.python_machine_tag_name
  }
}

# Create Web Server
resource "aws_instance" "web_instance" {
  ami                     = data.aws_ami.web-ami.id
  instance_type           = var.web_machine_instance_type
  key_name                = var.web_machine_key_name
  security_groups         = [data.aws_security_group.web_sg.id]
  iam_instance_profile    = data.aws_iam_instance_profile.web-server-role.name
  subnet_id               = data.aws_subnet.public-1.id

  tags = {
    Name = var.web_machine_tag_name
  }
}

#Create DB Subnet Group
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres-subnet-group"
  subnet_ids = [
    data.aws_subnet.private-1.id
  ]

  tags = {
    Name = "postgres-subnet-group"
  }
}

# Create DB Instance
resource "aws_db_instance" "postgres" {
  identifier     = "my-postgres-db"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class
  allocated_storage = 20

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [data.aws_security_group.db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Environment = var.db_environment
  }
}