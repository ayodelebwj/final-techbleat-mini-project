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

resource "aws_vpc" "techbleatvpc" {
  cidr_block = var.vpc-cidr

  enable_dns_support   = true # DNS resolution
  enable_dns_hostnames = true # DNS hostnames (REQUIRED for RDS)

  tags = {
    Name = var.vpc-name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.techbleatvpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.techbleatvpc.id
  cidr_block              = var.public-subnet-1-cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name = var.public-subnet-1-name
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.techbleatvpc.id
  cidr_block              = var.public-subnet-2-cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"

  tags = {
    Name = var.public-subnet-2-name
  }
}


resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.techbleatvpc.id
  cidr_block        = var.private-subnet-1-cidr
  availability_zone = "us-east-2a"

  tags = {
    Name = var.private-subnet-1-name
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.techbleatvpc.id
  cidr_block        = var.private-subnet-2-cidr
  availability_zone = "us-east-2b"

  tags = {
    Name = var.private-subnet-2-name
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.allocation_id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.igw]


  tags = {
    Name = "nat"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.techbleatvpc.id

  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.techbleatvpc.id

  tags = {
    Name = "private"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_rt_assoc_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_rt_assoc_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.techbleatvpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_lb_target_group" "web-app-tg" {
  name     = "web-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.techbleatvpc.id
}

resource "aws_lb_target_group_attachment" "tg-registered-targets" {
  target_group_arn = aws_lb_target_group.web-app-tg.arn
  target_id        = aws_instance.web_instance.id
  port             = 80
  depends_on       = [aws_instance.web_instance]
}

resource "aws_lb_listener" "app_listener_HTTP" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-app-tg.arn
  }
}

#resource "aws_lb_listener" "app_listener_HTTPS" {
#  load_balancer_arn = aws_lb.app_lb.arn
#  port              = 443
#  protocol          = "HTTPS"

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.web-app-tg.arn
#  }
#}

resource "aws_security_group" "web_sg" {
  name        = var.web_machine_security_group_name
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.techbleatvpc.id

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
    #security_groups = [aws_security_group.alb_sg.id]
    cidr_blocks = [var.security_group_cidr_block]

  }

  ingress {
    description = "HTTPS PORT"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
    #security_groups = [aws_security_group.alb_sg.id]
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
  description = "Allow SSH and TCP ON PORT 8000"
  vpc_id      = aws_vpc.techbleatvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  ingress {
    description     = "PYTHON PORT"
    from_port       = var.python_machine_ingress_port
    to_port         = var.python_machine_ingress_port
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.security_group_cidr_block]
  }
}

# Security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Jenkins traffic"
  vpc_id      = aws_vpc.techbleatvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.security_group_cidr_block]
  }

  ingress {
    from_port   = var.jenkins_machine_ingress_port
    to_port     = var.jenkins_machine_ingress_port
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

# Security group for RDS
resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Allow Postgres traffic"
  vpc_id      = aws_vpc.techbleatvpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.python_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.security_group_cidr_block]
  }
}

#Retrieves ubuntu ami from AWS store to provision Jenkins instance
data "aws_ssm_parameter" "ubuntu_2404_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

#Filters ubuntu AMI id from ssm parameter store for Jenkins server provisioning
data "aws_ami" "ubuntu_2404" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "image-id"
    values = [data.aws_ssm_parameter.ubuntu_2404_ami.value]
  }
}

#Create Jenkins Server
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
