#GENERAL VARIABLES
variable "vpc-cidr" {
  type    = string
  default = ""
}

variable "vpc-name" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "public-subnet-1-cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public-subnet-1-name" {
  type    = string
  default = "public_1"
}

variable "public-subnet-2-cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "public-subnet-2-name" {
  type    = string
  default = "public_2"
}

variable "private-subnet-1-cidr" {
  type    = string
  default = "10.0.3.0/24"
}

variable "private-subnet-1-name" {
  type    = string
  default = "private_1"
}

variable "private-subnet-2-cidr" {
  type    = string
  default = "10.0.4.0/24"
}

variable "private-subnet-2-name" {
  type    = string
  default = "private_2"
}

variable "security_group_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

#PYTHON VARIABLES
variable "python_machine_security_group_name" {
  type    = string
  default = "python-sg"
}

variable "python_machine_ingress_port" {
  type    = number
  default = 8000
}

#WEB VARIABLES
variable "web_machine_security_group_name" {
  type    = string
  default = "web-sg"
}

#DATABASE VARIABLES
variable "db_sg_name" {
  default = ""
}

variable "db_sg_ingress_from_port" {
  default = ""
}

variable "db_sg_ingress_to_port" {
  default = ""
}


#JENKINS VARIABLES
variable "jenkins_machine_ingress_port" {
  type    = number
  default = 8080
}

variable "jenkins_server_instance_type" {
  type    = string
  default = "c7i-flex.large"
}

variable "jenkins_server_key_name" {
  type = string
}

variable "jenkins_server_tag_name" {
  type    = string
  default = "jenkins-instance"
}